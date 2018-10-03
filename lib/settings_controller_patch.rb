require 'dispatcher' unless Rails::VERSION::MAJOR >= 3
require_dependency 'settings_controller'


module SettingsControllerPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      
    end
  end

  module InstanceMethods
    # Wraps the association to get the Deliverable subject.  Needed for the 
    # Query and filtering
    def show_tracker_custom_fields
      if params[:tracker].present?
        @options = Tracker.find(params[:tracker]).custom_fields
      else
        @options = []
      end

      render :layout => false
    end

    def show_multiple_trackers_custom_fields
      if params[:trackers].present?
        @options = IssueCustomField.joins(:trackers).where('custom_fields_trackers.tracker_id' => params[:trackers], 'custom_fields.field_format' => 'list').distinct
      else
        @options = []
      end

      render :layout => false
    end

    def show_income_expense_types
      if params[:prepaid_bundle_custom_fields].present?
        @options = CustomField.where(id: params[:prepaid_bundle_custom_fields]).map(&:possible_values).flatten.uniq
      else
        @options = []
      end

      render :layout => false
    end

  end
  module ClassMethods
  end
end

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    SettingsController.send(:include, SettingsControllerPatch)
  end
else
  Dispatcher.to_prepare do
    SettingsController.send(:include, SettingsControllerPatch)
  end
end
