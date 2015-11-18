class AddFilenameToDocument < ActiveRecord::Migration
  def change
    add_column :documents, :filename, :string
  end
end
