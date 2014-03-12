#require 'dispatcher'
if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    require_dependency 'issue'
    Issue.send(:include, IssuesDatesRequiredPatch)
  end
else
  Dispatcher.to_prepare do
    require_dependency 'issue'
    Issue.send(:include, IssuesDatesRequiredPatch)
  end
end


module IssuesDatesRequiredPatch

  def self.included(base) # :nodoc:
    #unloadable

    base.send(:include, InstanceMethods)

    base.class_eval do
      validate  :validate_required_dates
    end

  end


  module InstanceMethods
    # Para no tener que reiniciar el servidor cada vez que se modifica algo
    #unloadable

    def validate_required_dates
      trackers = Setting.plugin_redmine_emergya_adjustments['trackers']
      if (trackers!=nil && (trackers.collect{|tracker| tracker.to_i}.include? tracker_id))
         if start_date.nil?
            errors.add(:start_date, I18n.t(:"activerecord.errors.models.issue.attributes.start_date.localized_error"))
          end
        if due_date.nil? && status.is_closed
          errors.add(:due_date, I18n.t(:"activerecord.errors.models.issue.attributes.due_date.localized_error"))
        end
      end
    end
  end

end
