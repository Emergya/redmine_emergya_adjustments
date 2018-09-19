
ActionDispatch::Callbacks.to_prepare do
  require_dependency 'time_entry'
  TimeEntry.send(:include, TimeEntryPatch)
end

module TimeEntryPatch

  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      before_save :avoid_time_entries
      alias_method_chain :validate_time_entry, :extended_restrictions
    end

  end


  module InstanceMethods
    def avoid_time_entries
      errors.add :base,  l(:"emergya.error_disabled_project_time_entries")

      self.project.avoid_time_entries.blank?
    end

    def validate_time_entry_with_extended_restrictions
      validate_time_entry_without_extended_restrictions
      errors.add :base, l(:"emergya.error_issue_is_closed") if issue.status.is_closed
      errors.add :spent_on, :greater_than_start_date if issue.start_date > spent_on
    end    
  end

end
