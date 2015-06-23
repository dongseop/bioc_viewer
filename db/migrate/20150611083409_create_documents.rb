class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.text :xml, null: false
      t.integer :version, null: false, default: 0
      t.references :user, index: true
      t.references :project, index: true

      t.timestamps null: false
    end
    add_foreign_key :documents, :users
    add_foreign_key :documents, :projects
  end
end
