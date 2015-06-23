class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :title, null: false
      t.references :user, index: true
      t.text :description

      t.timestamps null: false
    end
    add_foreign_key :projects, :users
  end
end
