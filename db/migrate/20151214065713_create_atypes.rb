class CreateAtypes < ActiveRecord::Migration
  def change
    create_table :atypes do |t|
      t.string :name
      t.string :cls
      t.string :desc
      t.references :project, index: true
      t.references :document, index: true
      t.timestamps null: false
    end
    add_foreign_key :atypes, :projects
    add_foreign_key :atypes, :documents
  end
end
