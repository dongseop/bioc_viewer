json.array!(@ppis) do |ppi|
  json.extract! ppi, :id, :document_id, :gene1, :gene2
  json.url ppi_url(ppi, format: :json)
end
