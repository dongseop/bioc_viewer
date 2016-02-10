require 'nokogiri'
# require 'libxml'
class Document < ActiveRecord::Base
  belongs_to :user
  belongs_to :project, counter_cache: true
  has_many :ppis, dependent: :destroy
  has_many :atypes, dependent: :destroy
  paginates_per 20
  TYPE2COLOR = {
    "gene" => "yellow",
    "organism" => "orange",
    "experimentalmethod" => "red",
    "geneticinteractiontype" => "green",
    "gievidence" => "green",
    "gimention" => "green",
    "ppievidence" => "blue",
    "ppimention" => "blue"
  }
  before_save :overwrite_xml

  validate :validate_xml

  def unique_id
    self.doc_id || "D#{self.id}"
  end

  def annotation_types
    types = []
    self.bioc_doc.passages.each do |p|
      p.annotations.each do |a|
        types << a.infons['type'] if !a.infons.nil? && !a.infons['type'].nil?
      end
      p.sentences.each do |s|
        s.annotations.each do |a|
          types << a.infons['type'] if !a.infons.nil? && !a.infons['type'].nil?
        end
      end
    end

    return types.uniq.sort
  end

  def adjust_atypes 
    typemap = {}
    self.atypes.each do |t|
      typemap[t.name] = t
    end
    self.annotation_types.each do |t|
      atype = typemap[t.downcase] 
      if atype.nil?
        self.atypes.create({
          name: t.downcase, document_id: self.id, 
          project_id: self.project_id, cls: Atype.recommend(t.downcase)
        })
      elsif !Atype::CLASSES.include?(atype.cls)
        atype.cls = Atype.recommend(atype.name)
        atype.save
      end
    end
  end

  def atype(name)
    if @atype_map.nil?
      @atype_map = {}
      self.atypes.each do |t|
        @atype_map[t.name] = t
      end
    end
    @atype_map[name]
  end

  def self.create_from_file(file)
    doc = Document.new
    doc.filename = file.original_filename
    if file.respond_to?(:read)
      doc.xml = file.read
    elsif file.respond_to?(:path)
      doc.xml = File.read(file.path)
    else
      logger.error "Bad file: #{file.class.name}: #{file.inspect}"
    end
    begin
      doc.validate_xml
    rescue Exception => e
      logger.error e.inspect
      return nil
    end
    unless doc.bioc.nil?
      doc.source = doc.bioc.source
      doc.d_date = doc.bioc.date
      doc.key = doc.bioc.key
      doc.doc_id = doc.bioc.documents[0].id
    end
    return doc
  end

  def self.create_by_merge(org_doc, xml)
    doc = Document.new
    doc.filename = org_doc.filename 
    doc.xml = org_doc.xml
    doc.source = org_doc.source
    doc.d_date = org_doc.d_date
    doc.key = org_doc.key
    doc.doc_id = org_doc.doc_id
    doc.project_id = org_doc.project_id
    doc.user_id = org_doc.user_id

    # logger.debug(doc.xml)
    # logger.debug("=================")
    # logger.debug(xml)
    dest = SimpleBioC.from_xml_string(doc.xml)
    src = SimpleBioC.from_xml_string(xml)
    SimpleBioC.merge(dest, src)
    doc.xml = SimpleBioC::to_xml(dest)
    return doc
  end

  def merge_with(doc) 
    dest = self.bioc
    src = doc.bioc
    BiocMerger.merge(dest, src)
    self.xml = SimpleBioC::to_xml(dest)
  end
   
  # def self.merge_documents(project, user, files, errors)
  #   doc = Document.new
  #   names = []
  #   dest = nil
  #   files.each_with_index do |file, idx|
  #     if file.respond_to?(:read)
  #       xml = file.read
  #     elsif file.respond_to?(:path)
  #       xml = File.read(file.path)
  #     else
  #       logger.error "Bad file: #{file.class.name}: #{file.inspect}"
  #     end
  #     dtd = LibXML::XML::Dtd.new(File.read(Rails.root.join('public', 'bioc.dtd')))
  #     libxml = LibXML::XML::Document.string(xml)
  #     begin
  #       unless libxml.validate(dtd)
  #         errors << "Failed to validate #{file.original_filename} against BioC DTD"
  #         return nil
  #       end
  #     rescue Exception => e
  #       logger.error("Failed to validate #{file.original_filename} against BioC DTD")
  #       errors << "Failed to validate #{file.original_filename} against BioC DTD"
  #       return nil
  #     end

  #     names << file.original_filename
  #     logger.debug("#{idx} : #{file.original_filename}")
  #     if idx == 0
  #       dest = SimpleBioC.from_xml_string(xml)
  #       # logger.debug(dest.documents.size)
  #       doc.source = dest.source
  #       doc.d_date = dest.date
  #       doc.key = dest.key
  #       doc.doc_id = dest.documents[0].id
  #       doc.project_id = project.id
  #       doc.user_id = user.id
  #     else
  #       src = SimpleBioC.from_xml_string(xml)
  #       logger.debug(dest.documents.size)
  #       logger.debug(src.documents.size)
  #       SimpleBioC.merge(dest, src)
  #     end
  #   end
  #   doc.filename = names.join('+')
  #   if doc.filename.size > 100
  #     doc.filename = doc.filename[0..99] + '...'
  #   end
  #   doc.xml = SimpleBioC::to_xml(dest)
  #   return doc
  # end

  def get_psize(p)
    self.get_ptext(p).size
  end

  def get_ptext(p)
    if p.text.blank?
      p.sentences.map{|s| s.text}.join(" ")
    else
      p.text
    end
  end

  def outline
    root = {children: []}
    last_in_levels = [root]
    last_item = nil
    self.bioc_doc.passages.each_with_index do |p, index|
      next if p.infons["type"].nil?

      result = p.infons["type"].match(/title_(\d+)/)
      if result.present?
        level = result[1].strip.to_i
        item_text = "title"
      elsif %w(front abstract title).include?(p.infons["type"])
        level = 1
        item_text = p.infons["type"]
      else
        if !last_item.nil?
          last_item[:cls] = last_item[:cls] | get_class_from_passage(p)
          next
        end
      end

      desc = self.get_ptext(p)[0..30] 
      item = {id: index, text: item_text, description: desc, children: [], level: level, cls: []}
      
      last_item = item
      last_item[:cls] = last_item[:cls] | get_class_from_passage(p)
      last_in_levels[level] = item
      plevel = level - 1
      while (plevel > 0 && last_in_levels[plevel].nil?) do
        plevel = plevel - 1
      end
      p = last_in_levels[plevel]
      p[:children] << item
    end

    root[:children]
  end

  def article_id_pmc
    if @article_id_pmc.nil?
      @article_id_pmc = self.find_value_for_infonkey("article-id_pmc") 
    end
    return @article_id_pmc
  end

  def article_id_pmid
    if @article_id_pmid.nil?
      @article_id_pmid = self.find_value_for_infonkey("article-id_pmid") 
    end
    return @article_id_pmid
  end

  def find_value_for_infonkey(key)
    return self.bioc_doc.infons[key] unless self.bioc_doc.infons[key].nil?
    self.bioc_doc.passages.each do |p|
      return p.infons[key] unless p.infons[key].nil?
    end
    
  end

  def get_class_from_passage(p)
    cls = []
    p.annotations.each do |a|
      cls = cls | [get_class_from_annotation(a)]
    end
    # logger.debug("P SENTENCE #{p.sentences.size}")
    p.sentences.each do |s|
      # logger.debug("S ANNNOTATION #{s.annotations.size}")
      s.annotations.each do |a|
        cls = cls | [get_class_from_annotation(a)]
        # logger.debug("Annotation Type #{cls.inspect}")
      end
    end
    # logger.debug("Annotation Type #{cls.inspect}")

    return cls.uniq
  end

  def get_class_from_annotation(a)
    type = a.infons['type']
    cls_name = case type.downcase
    when 'gene'
      "G"
    when 'organism'
      "O"
    when 'ppimention','ppievidence'
      "EP"
    when 'geneticinteractiontype', 'gievidence', 'gimention'
      "EG"
    when 'experimentalmethod'
      "EM"
    when 'none'
      ""
    else
      "E"
    end unless type.nil?

    return cls_name
  end

  def bioc
    if @bioc.nil?
      @bioc = SimpleBioC.from_xml_string(self.xml)
    end
    @bioc
  end

  def validate_xml
    # dtd = LibXML::XML::Dtd.new(File.read(Rails.root.join('public', 'bioc.dtd')))
    # xml = LibXML::XML::Document.string(self.xml)
    # unless xml.validate(dtd)
    #   errors.add(:xml, "invalide BioC document")
    # end
  end

  def overwrite_xml
    self.bioc.source = self.source
    self.bioc.date = self.d_date
    self.bioc.key = self.key
    self.bioc.documents[0].id = self.doc_id
    self.xml = SimpleBioC::to_xml(self.bioc)
  end

  def bioc_doc
    self.bioc.documents[0]
  end

  def verify
    result = []
    id_map = {}

    doc = self.bioc_doc
    doc.passages.each do |p|
      p.sentences.each do |s|
        check_duplicated_id(s.annotations, result, 'annotation', id_map)
        check_duplicated_id(s.relations, result, 'annotation', id_map)
      end
      check_duplicated_id(p.annotations, result, 'annotation', id_map)
      check_duplicated_id(p.relations, result, 'annotation', id_map)
    end
    doc.passages.each do |p|
      p.sentences.each do |s|
        check_annotation_location(s, result)
        check_relation_ref(s, result, id_map)
      end
      check_annotation_location(p, result)
      check_relation_ref(p, result, id_map)
    end

    result
  end

  def check_duplicated_id(coll, result, type, id_map)
    coll.each do |n|
      if id_map[n.id].nil?
        id_map[n.id] = 1
      else
        result << "#{n.id}: this #{type} ID is duplicated"
      end
    end
  end

  def check_annotation_location(obj, result)
    misaligned = adjust_annotation_offsets(obj, true)
    misaligned.each do |item|
      result << "The annotation #{item[0]} is misaligned [#{item[1]}:#{item[2]}] (auto-fixed to [#{item[3]}:#{item[2]}])"
    end
    obj.annotations.each do |a|
      a.locations.each do |l|
        start_pos = l.offset.to_i - obj.offset
        end_pos = start_pos + l.length.to_i
        text = obj.text[start_pos...end_pos]
        if text != a.text
          result <<  "The annotation #{a.id} is misaligned [#{l.offset}:#{l.length}] (the text in annotation '<b>#{a.text}</b>' is different from the one at the location '<b>#{text}</b>')"
        end
      end
    end
  end

  def check_relation_ref(obj, result, id_map) 
    obj.relations.each do |r|
      r.nodes.each do |n|
        if id_map[n.refid].nil?
          result << "The relation #{r.id} refers non-existing nodes (refid: #{n.refid})"
        end
      end
    end
  end

  def adjust_offset(needFix)
    doc = self.bioc_doc
    doc.passages.each do |p|
      adjust_annotation_offsets(p, needFix)
      p.sentences.each do |s|
        adjust_annotation_offsets(s, needFix)
      end
    end
  end

  def adjust_annotation_offsets(obj, needFix)
    # Rails.logger.debug("HERE in ADJUST ANNOTATION #{obj.nil?} #{obj.annotations.nil?}, #{needFix}")
    return if obj.nil? || obj.annotations.nil?
    ret = []
    obj.annotations.each do |a|
      # Rails.logger.debug("CHECK #{a.id} #{a.text} #{a.locations.size}")
      positions = find_all_locations(obj, a.text)
      next if a.locations.nil?
      a.locations.each do |l|
        # Rails.logger.debug("   CHECK #{l.offset}")
        next if l.nil? || l == false
        # l.original_offset = l.offset.to_i if l.original_offset.nil?
        candidate = choose_offset_candidate(l.offset, positions)
        # Rails.logger.debug("#{candidate}? == #{l.offset}")
        if candidate.to_i != l.offset.to_i
          val = a.infons["error:misaligned:#{a.id}"] || ""
          arr = val.split(",")
          arr << "#{l.offset}->#{candidate}"
          a.infons["error:misaligned:#{a.id}"] = arr.join(",")
          ret << [a.id, l.offset, l.length, candidate]
          if needFix
            l.offset = candidate
          end
        end
      end
    end
    return ret
  end

  def find_all_locations(obj, text)
    positions = []
    return positions if obj.nil? || obj.text.nil?
    pos = obj.text.index(text)
    until pos.nil? 
      positions << (pos + obj.offset)
      pos = obj.text.index(text, pos + 1)
    end
    return positions
  end

  def choose_offset_candidate(offset, positions)
    return offset if positions.nil?
    min_diff = 99999
    offset = offset.to_i
    ret = offset
    positions.each do |p|
      diff = (offset - p).abs
      if diff < min_diff
        ret = p 
        min_diff = diff
      end
    end
    return ret
  end
end
