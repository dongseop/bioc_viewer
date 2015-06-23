class CreateTempDocuments < ActiveRecord::Migration
  def change
    create_table :temp_documents do |t|
      t.references :user, index: true
      t.references :document, index: true
      t.text :xml, null: false

      t.timestamps null: false
    end
    add_foreign_key :temp_documents, :users
    add_foreign_key :temp_documents, :documents

  end
end
