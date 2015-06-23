class AddDocIdToDocument < ActiveRecord::Migration
  def change
    add_column :documents, :doc_id, :string
    change_column :documents, :xml, :longtext
    change_column :revisions, :xml, :longtext
    change_column :temp_documents, :xml, :longtext
  end
end
