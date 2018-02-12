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
    base.send(:include, InstanceMethods)

    base.class_eval do
        
      validate  :validate_required_dates
      after_save :update_cobro, :if => Proc.new { |issue| 
        issue.tracker_id == Setting.plugin_redmine_emergya_adjustments['bill_tracker'].to_i}
      after_save :update_bpo_total, :if => Proc.new { |issue| 
        issue.tracker_id == Setting.plugin_redmine_emergya_adjustments['bpo_tracker'].to_i}

      alias_method_chain :available_custom_fields, :generic_tracker
    end

  end


  module InstanceMethods
    def update_cobro
      # Tenemos que llamar al método update_amount del plugin redmine_ie antes de ejecutar este. 
      # No importa que update_amount se vuelva a ejecutar tras la ejecución de este método
      # El problema es que ambos callback deben ser de tipo after_save para detectar la modificación de sus campos personalizados, pero update_amount debe ejecutarse antes que update_cobro
      self.update_amount
      ########

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

      facturacion_ml = CustomValue.find_by_customized_id_and_custom_field_id(self.id,
        Setting.plugin_redmine_emergya_adjustments['bill_ml_invoice_custom_field'])

      if facturacion_ml.present?
        iva = CustomValue.find_by_customized_id_and_custom_field_id(self.id,
            Setting.plugin_redmine_emergya_adjustments['bill_iva_custom_field'])

        if iva.present? and iva.value != 'Manual'
          cobro_ml = CustomValue.find_by_customized_id_and_custom_field_id(self.id,
            Setting.plugin_redmine_emergya_adjustments['bill_ml_amount_custom_field'])
          
          if cobro_ml.present?
            cobro_ml.update_attribute('value', facturacion_ml.value.to_f * (1.0 + (iva.value.to_f/100.0)))
          end
        end
      end
    end

    def update_bpo_total
      coste_anual = CustomValue.find_by_customized_id_and_custom_field_id(self.id,
        Setting.plugin_redmine_emergya_adjustments['bpo_annual_cost_custom_field'])

      if coste_anual.present?
        coste_total = CustomValue.find_or_create_by(customized_id: self.id, customized_type: 'Issue', custom_field_id: Setting.plugin_redmine_emergya_adjustments['bpo_total_cost_custom_field'])
        anual = coste_anual.value.to_f
        dias = (self.due_date.to_date - self.start_date.to_date).to_i + 1
        
        coste_total.update_attribute('value', (anual*dias)/365)
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

    def available_custom_fields_with_generic_tracker
      if Setting.plugin_redmine_emergya_adjustments['generic_tracker'].present? and self.tracker_id.to_s == Setting.plugin_redmine_emergya_adjustments['generic_tracker']
        self.custom_values.map(&:custom_field)
      else
        available_custom_fields_without_generic_tracker
      end
    end
  end

end
