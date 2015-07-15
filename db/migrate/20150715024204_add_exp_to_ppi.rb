class AddExpToPpi < ActiveRecord::Migration
  def change
    add_column :ppis, :exp, :string
  end
end
