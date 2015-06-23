class CreateRevisions < ActiveRecord::Migration
  def change
    create_table :revisions do |t|
      t.references :document, index: true
      t.references :user, index: true
      t.string :comment, limit: 1000
      t.text :xml, null: false
      t.integer :version, null: false

      t.timestamps null: false
    end
    add_foreign_key :revisions, :documents
    add_foreign_key :revisions, :users
  end
end
