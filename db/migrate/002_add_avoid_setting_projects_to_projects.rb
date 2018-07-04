class AddAvoidSettingProjectsToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :avoid_setting_projects, :boolean, :default => false
  end

  def self.down
    remove_column :projects, :avoid_setting_projects
  end
end
