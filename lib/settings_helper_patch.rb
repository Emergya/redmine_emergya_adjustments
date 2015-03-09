require_dependency 'settings_helper'
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

# Patches Redmine's ApplicationController dinamically. Redefines methods wich
# send error responses to clients
module SettingsHelperPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable  # Send unloadable so it will be reloaded in development
    end
  end

  module ClassMethods
  end 

  module InstanceMethods
    def settings_observe_field(launcher, target)
      javascript_tag "$('#settings_#{launcher}').change(function(){
        $('#settings_#{target}').load('/settings/show_tracker_custom_fields', {tracker: $('#settings_#{launcher}').val()});
      });"
    end
  end
end


if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    SettingsHelper.send(:include, SettingsHelperPatch)
  end
else
  Dispatcher.to_prepare do
    SettingsHelper.send(:include, SettingsHelperPatch)
  end
end