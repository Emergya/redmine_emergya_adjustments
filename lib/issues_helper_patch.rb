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
    # Devuelve el id del campo del formulario asociado al campo establecido para la id del settings
    def get_setting_custom_field_id(id)
      if Setting.plugin_redmine_emergya_adjustments[id].present?
        '#issue_custom_field_values_'+Setting.plugin_redmine_emergya_adjustments[id]
      else
        nil
      end
    end

    # Establecerá al campo del formulario con id = ID, como iniciador del autorellenado de los tipos indicados en TYPE (separados por espacio), pasandose como parametro con nombre = NAME
    def set_launcher(name, id, type)
      if id.first != '#'
        id = get_setting_custom_field_id(id)
      end

      if id.present?
        javascript_tag "$('#{id}').addClass('launcher').attr('data-attr_name','#{name}').attr('data-launcher_type','#{type}');"
      end
    end

    # Establecerá al campo del formulario con id = ID, como campo para autorellenar por el evento TYPE. Se le pueden pasar como opciones:
    # :disabled => true : para mostrar el campo inicialmente como deshabilitado
    # :class => '[clases]': para añadirle clases al campo
    def set_autofilled(id, type, options = {})
      if id.first != '#'
        id = get_setting_custom_field_id(id)
      end

      if id.present?
        script = "$('#{id}').addClass('autofilled_field').attr('data-autofilled_type','#{type}')"

        script += ".prop('disabled',#{options[:disabled]})" if options[:disabled].present?
        script += ".addClass('#{options[:class]}')" if options[:class].present?

        javascript_tag script+";"
      end
    end

    # El campo del formulario con id = ID_TOGGLE se mostrará habilitado/deshabilitado (según mode sea 'enable' o 'disable') cuando el campo del formulario con id = ID_OBSERVE tome el valor VALUE
    def set_toggling(mode, id_toggle, id_observe, value)
      if ['enable','disable'].include?(mode)
        id_toggle = get_setting_custom_field_id(id_toggle) if id_toggle.first != '#'
        id_observe = get_setting_custom_field_id(id_observe) if id_observe.first != '#'
        
        if id_toggle.present? and id_observe.present?
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