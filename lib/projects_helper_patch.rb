require_dependency 'projects_helper'

# Patches Redmine's ApplicationController dinamically. Redefines methods wich
# send error responses to clients
module ProjectsHelperPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :project_settings_tabs, :time_entries
    end
  end

  module ClassMethods
  end 

  module InstanceMethods
    def project_settings_tabs_with_time_entries
      tabs = project_settings_tabs_without_time_entries
      tabs << {:name => 'time_entries', :action => :only_admin, :partial => 'projects/settings/time_entries', :label => :label_time_entry_plural}

      tabs.select {|tab| User.current.allowed_to?(tab[:action], @project)}
    end
  end
end


ActionDispatch::Callbacks.to_prepare do
  ProjectsHelper.send(:include, ProjectsHelperPatch)
end