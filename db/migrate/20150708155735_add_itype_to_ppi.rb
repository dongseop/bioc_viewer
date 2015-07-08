class AddItypeToPpi < ActiveRecord::Migration
  def change
    add_column :ppis, :itype, :string, default: "ppi"
    add_column :ppis, :name1, :string
    add_column :ppis, :name2, :string
  end
end
