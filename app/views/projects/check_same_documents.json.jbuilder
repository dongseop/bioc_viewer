json.array!(@rows) do |row|
  json.extract! row, :source, :doc_id, :key, :d_date, :cnt
  json.documents @project.get_documents(row.source, row.doc_id, row.key, row.d_date)
end
