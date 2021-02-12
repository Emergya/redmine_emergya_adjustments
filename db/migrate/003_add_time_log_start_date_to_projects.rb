class AddTimeLogStartDateToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :time_log_start_date, :date, :default => false
  end

  def self.down
    remove_column :projects, :time_log_start_date
  end
end
