class Document < ActiveRecord::Base
  belongs_to :user
  belongs_to :project, counter_cache: true

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
