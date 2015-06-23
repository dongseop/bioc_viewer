class AddMissingColumnsToDocument < ActiveRecord::Migration
  def change
    add_column :documents, :source, :string
    add_column :documents, :d_date, :string
    add_column :documents, :key, :string
    add_column :projects, :documents_count, :integer, default: 0
  end
end
