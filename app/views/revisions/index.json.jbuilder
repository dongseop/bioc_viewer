json.array!(@revisions) do |revision|
  json.extract! revision, :id, :document_id, :user_id, :comment, :xml, :version
  json.url revision_url(revision, format: :json)
end
