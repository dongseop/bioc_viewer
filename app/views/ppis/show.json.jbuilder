json.extract! @ppi, :id, :document_id, :exp, :gene1, :gene2, :name1, :name2, :created_at, :updated_at
json.itype @ppi.itype.upcase
