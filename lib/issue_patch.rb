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
        
      validate  :validate_required_dates, :validate_prepaid_bundle_issue
      after_create :update_prepaid_bundle, :if => Proc.new { |issue|
        Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_trackers'].include?(issue.tracker_id.to_s)}
      before_update :update_prepaid_bundle, :if => Proc.new { |issue|
        Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_trackers'].include?(issue.tracker_id.to_s)}
      before_destroy :restore_prepaid_bundle, :prepend => true, :if => Proc.new { |issue|
        Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_trackers'].include?(issue.tracker_id.to_s)}
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

    def validate_prepaid_bundle_issue
      if Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_trackers'].present? and Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_custom_fields'].present? and Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_income_expense_types'].present?
        invoice_type = self.editable_custom_field_values.detect{|cfv| Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_custom_fields'].include?(cfv.custom_field_id.to_s)} if Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_trackers'].include?(self.tracker_id.to_s)
        currency = self.editable_custom_field_values.detect{|cfv| IE::Integration.currency_field_id == cfv.custom_field_id.to_s}
        is_bundle = invoice_type.present? and Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_income_expense_types'].include? invoice_type.value
        if self.root.present? and self.root_id != self.id and Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_trackers'].include?(self.root.tracker_id.to_s)
          invoice_type_root = self.root.editable_custom_field_values.detect{|cfv| Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_custom_fields'].include?(cfv.custom_field_id.to_s)}
          currency_root = self.root.custom_values.find_by_custom_field_id(IE::Integration.currency_field_id)
          if Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_income_expense_types'].include? invoice_type_root.value
            errors.add(:base, l(:"emergya.error_currency_does_not_match")) unless currency.value == currency_root.value
            errors.add(:tracker, l(:"emergya.error_issue_type_does_not_match")) unless self.root.tracker_id == self.tracker_id
            errors.add(:base, l(:"emergya.error_prepaid_bundle_child_issue")) if is_bundle and invoice_type_root.value == invoice_type.value
          end
        end
      end
    end

    def update_prepaid_bundle
      if Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_trackers'].present? and Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_custom_fields'].present? and Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_income_expense_types'].present?
        if self.root.present? and self.root_id != self.id
          invoice_type_root = self.root.editable_custom_field_values.detect{|cfv| Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_custom_fields'].include?(cfv.custom_field_id.to_s)}
          if Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_income_expense_types'].include? invoice_type_root.value
            issue_currency = self.editable_custom_field_values.detect{|cfv| IE::Integration.currency_field_id == cfv.custom_field_id.to_s}
            if issue_currency.value == self.root.custom_values.find_by_custom_field_id(IE::Integration.currency_field_id).value
              facturacion_ml = self.editable_custom_field_values.detect{|cfv| cfv.custom_field_id.to_s == Setting.plugin_redmine_emergya_adjustments['bill_ml_invoice_custom_field']}
              facturacion_root_ml = CustomValue.find_by_customized_id_and_custom_field_id(self.root.id, Setting.plugin_redmine_emergya_adjustments['bill_ml_invoice_custom_field'])
              previous_facturacion_ml = facturacion_ml.value_was.present? ? facturacion_ml.value_was.to_f : 0.0
              facturacion_root_ml.update_attribute('value', facturacion_root_ml.value.to_f - facturacion_ml.value.to_f + previous_facturacion_ml) if facturacion_ml.present? and facturacion_root_ml.present?
            end
          end
        end
      end
    end

    def restore_prepaid_bundle
      if Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_trackers'].present? and Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_custom_fields'].present? and Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_income_expense_types'].present?
        if self.root.present? and self.root_id != self.id
          invoice_type_root = self.root.editable_custom_field_values.detect{|cfv| Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_custom_fields'].include?(cfv.custom_field_id.to_s)}
          if Setting.plugin_redmine_emergya_adjustments['prepaid_bundle_income_expense_types'].include? invoice_type_root.value
            if self.custom_values.find_by_custom_field_id(IE::Integration.currency_field_id).value == self.root.custom_values.find_by_custom_field_id(IE::Integration.currency_field_id).value
              facturacion_ml = CustomValue.find_by_customized_id_and_custom_field_id(self.id, Setting.plugin_redmine_emergya_adjustments['bill_ml_invoice_custom_field'])
              facturacion_root_ml = CustomValue.find_by_customized_id_and_custom_field_id(self.root.id, Setting.plugin_redmine_emergya_adjustments['bill_ml_invoice_custom_field'])
              facturacion_root_ml.update_attribute('value', facturacion_root_ml.value.to_f + facturacion_ml.value.to_f) if facturacion_ml.present? and facturacion_root_ml.present?
            end
          end
        end
      end
    end
  end

end
