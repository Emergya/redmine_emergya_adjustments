require_dependency 'issues_helper'
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

# Patches Redmine's ApplicationController dinamically. Redefines methods wich
# send error responses to clients
module IssuesHelperPatch
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
    def get_setting_custom_field_id(id)
      '#issue_custom_field_values_'+Setting.plugin_redmine_emergya_adjustments[id]
    end

    def set_launcher(name, id, type)
      if id.first != '#'
        id = get_setting_custom_field_id(id)
      end

      javascript_tag "$('#{id}').addClass('launcher').attr('data-attr_name','#{name}').attr('data-launcher_type','#{type}');"
    end

    def set_autofilled(id, type, options = {})
      if id.first != '#'
        id = get_setting_custom_field_id(id)
      end

      script = "$('#{id}').addClass('autofilled_field').attr('data-autofilled_type','#{type}')"

      script += ".prop('disabled',#{options[:disabled]})" if options[:disabled].present?
      script += ".addClass('#{options[:class]}')" if options[:class].present?

      javascript_tag script+";"
    end

    def set_toggling(mode, id_toggle, id_observe, value)
      if ['enable','disable'].include?(mode)
        id_toggle = get_setting_custom_field_id(id_toggle) if id_toggle.first != '#'
        id_observe = get_setting_custom_field_id(id_observe) if id_observe.first != '#'
        
        script = "if ($('#{id_observe}').val() == '#{value}'){
          $('#{id_toggle}').prop('disabled', #{mode != 'enable'});
        } else {
          $('#{id_toggle}').prop('disabled', #{mode == 'enable'});
        }

        $('#{id_observe}').live('change', function(){
          if (this.value == '#{value}'){
            $('#{id_toggle}').prop('disabled', #{mode != 'enable'});
          } else {
            $('#{id_toggle}').prop('disabled', #{mode == 'enable'});
          }
        });"

        javascript_tag script
      end
    end
  end
end


if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    IssuesHelper.send(:include, IssuesHelperPatch)
  end
else
  Dispatcher.to_prepare do
    IssuesHelper.send(:include, IssuesHelperPatch)
  end
end