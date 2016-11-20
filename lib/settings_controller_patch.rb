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
