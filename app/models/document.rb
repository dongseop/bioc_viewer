class Document < ActiveRecord::Base
  belongs_to :user
  belongs_to :project, counter_cache: true
  has_many :ppis, dependent: :destroy
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
  
  def unique_id
    self.doc_id || "D#{self.id}"
  end

  def self.create_from_file(file)
    doc = Document.new
  
    if file.respond_to?(:read)
      doc.xml = file.read
    elsif file.respond_to?(:path)
      doc.xml = File.read(file.path)
    else
      logger.error "Bad file: #{file.class.name}: #{file.inspect}"
    end

    unless doc.bioc.nil?
      doc.source = doc.bioc.source
      doc.d_date = doc.bioc.date
      doc.key = doc.bioc.key
      doc.doc_id = doc.bioc.documents[0].id
    end
    return doc
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

      desc = if p.text.nil? then "" else p.text[0..30] end
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

  def get_class_from_passage(p)
    cls = []
    p.annotations.each do |a|
      cls = cls | [get_class_from_annotation(a)]
    end
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

  def bioc_doc
    self.bioc.documents[0]
  end
end
