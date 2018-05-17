
ActionDispatch::Callbacks.to_prepare do
  require_dependency 'time_entry'
  TimeEntry.send(:include, TimeEntryPatch)
end

module TimeEntryPatch

  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      before_save :avoid_time_entries
    end

  end


  module InstanceMethods
    def avoid_time_entries
      errors.add :base,  l(:"emergya.error_disabled_project_time_entries")

      self.project.avoid_time_entries.blank?
    end
  end

end
