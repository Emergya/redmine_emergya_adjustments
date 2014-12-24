#require 'dispatcher'
if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    require_dependency 'custom_value'
    Issue.send(:include, IssuePatch)
  end
else
  Dispatcher.to_prepare do
    require_dependency 'custom_value'
    Issue.send(:include, IssuePatch)
  end
end


module IssuePatch

  def self.included(base) # :nodoc:
    #unloadable
    base.send(:include, InstanceMethods)

    base.class_eval do
      validate  :validate_required_dates
      after_save :update_cobro, :if => Proc.new { |issue| 
        issue.tracker_id == Setting.plugin_redmine_emergya_adjustments['bill_tracker'].to_i}
    end

  end


  module InstanceMethods
    # Para no tener que reiniciar el servidor cada vez que se modifica algo
    #unloadable

    def update_cobro
      #Rails::logger.info "VA A ACTUALIZAR EL VALOR DE COBRO"
      facturacion = CustomValue.find_by_customized_id_and_custom_field_id(self.id,
        Setting.plugin_redmine_emergya_adjustments['bill_invoice_custom_field'])

      if facturacion.present?
        iva = CustomValue.find_by_customized_id_and_custom_field_id(self.id,
            Setting.plugin_redmine_emergya_adjustments['bill_iva_custom_field'])

        if iva.present? and iva.value != 'Manual'
          cobro = CustomValue.find_by_customized_id_and_custom_field_id(self.id,
            Setting.plugin_redmine_emergya_adjustments['bill_amount_custom_field'])
          
          cobro.update_attribute('value', facturacion.value.to_f * (1.0 + (iva.value.to_f/100.0)))
        end
      end
    end

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
