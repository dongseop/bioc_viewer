json.array!(@temp_documents) do |temp_document|
  json.extract! temp_document, :id, :user, :document, :xml
  json.url temp_document_url(temp_document, format: :json)
end
