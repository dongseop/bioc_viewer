json.array!(@atypes) do |atype|
  json.extract! atype, :id, :name, :cls, :desc, :document_id, :project_id
  json.url atype_url(atype, format: :json)
end
