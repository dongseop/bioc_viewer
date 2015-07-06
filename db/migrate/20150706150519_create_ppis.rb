class CreatePpis < ActiveRecord::Migration
  def change
    create_table :ppis do |t|
      t.references :document, index: true
      t.string :gene1
      t.string :gene2

      t.timestamps null: false
    end
    add_foreign_key :ppis, :documents
    add_column :documents, :ppis_count, :integer, default: 0
  end
end
