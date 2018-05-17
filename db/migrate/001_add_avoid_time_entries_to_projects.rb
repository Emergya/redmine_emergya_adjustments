class AddAvoidTimeEntriesToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :avoid_time_entries, :boolean, :default => false
  end

  def self.down
    remove_column :projects, :avoid_time_entries
  end
end
