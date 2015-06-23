json.array!(@documents) do |document|
  json.extract! document, :id, :xml, :version, :user_id, :project
  json.url document_url(document, format: :json)
end
