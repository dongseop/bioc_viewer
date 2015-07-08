json.array!(@ppis) do |ppi|
  json.extract! ppi, :id, :document_id, :itype, :gene1, :name1, :gene2, :name2
  json.url ppi_url(ppi, format: :json)
end
