class AddModeToProject < ActiveRecord::Migration
  def change
    add_column :projects, :mode, :string, :default => 'Normal'
    execute("UPDATE projects SET mode = 'BioGrid'")
  end
end
