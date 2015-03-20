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
      after_save -> {update_currency_exchange 'bill'}, :if => Proc.new { |issue| 
        issue.tracker_id == Setting.plugin_redmine_emergya_adjustments['bill_tracker'].to_i}
      after_save -> {update_currency_exchange 'provider'}, :if => Proc.new { |issue| 
        issue.tracker_id == Setting.plugin_redmine_emergya_adjustments['provider_tracker'].to_i}
      #after_save -> {update_currency_exchange 'bpo'}, :if => Proc.new { |issue| 
      #  issue.tracker_id == Setting.plugin_redmine_emergya_adjustments['bpo_tracker'].to_i}
      after_save :update_currency_exchange_bpo, :if => Proc.new { |issue| 
        issue.tracker_id == Setting.plugin_redmine_emergya_adjustments['bpo_tracker'].to_i}
      after_save :update_cobro, :if => Proc.new { |issue| 
        issue.tracker_id == Setting.plugin_redmine_emergya_adjustments['bill_tracker'].to_i}
      after_save :update_bpo_total, :if => Proc.new { |issue| 
        issue.tracker_id == Setting.plugin_redmine_emergya_adjustments['bpo_tracker'].to_i}
      
    end

  end


  module InstanceMethods
    # Para no tener que reiniciar el servidor cada vez que se modifica algo
    #unloadable
    def update_cobro
      facturacion = CustomValue.find_by_customized_id_and_custom_field_id(self.id,
        Setting.plugin_redmine_emergya_adjustments['bill_invoice_custom_field'])

      iva = CustomValue.find_by_customized_id_and_custom_field_id(self.id,
            Setting.plugin_redmine_emergya_adjustments['bill_iva_custom_field'])

      cobro = CustomValue.find_by_customized_id_and_custom_field_id(self.id,
          Setting.plugin_redmine_emergya_adjustments['bill_amount_custom_field'])

      if facturacion.present? and iva.present? and iva.value != 'Manual' and cobro.present?
        cobro.update_attribute('value', AutofillOps.bill_total(facturacion.value, iva.value))
      end
    end

    def update_bpo_total
      coste_anual = CustomValue.find_by_customized_id_and_custom_field_id(self.id,
        Setting.plugin_redmine_emergya_adjustments['bpo_annual_cost_custom_field'])

      coste_total = CustomValue.find_by_customized_id_and_custom_field_id(self.id,
            Setting.plugin_redmine_emergya_adjustments['bpo_total_cost_custom_field'])

      if coste_anual.present? and coste_total.present? and self.start_date.present? and self.due_date.present?
        coste_total.update_attribute('value', AutofillOps.bpo_total(coste_anual.value, self.start_date, self.due_date))
      end
    end

    def update_currency_exchange(type)
      if Setting.plugin_redmine_emergya_adjustments['plugin_currency_manager']
        moneda = CustomValue.find_by_customized_id_and_custom_field_id(self.id,
          Setting.plugin_redmine_emergya_adjustments['currency_custom_field'])

        original = CustomValue.find_by_customized_id_and_custom_field_id(self.id, 
          Setting.plugin_redmine_emergya_adjustments['currency_'+type+'_custom_field_orig'])

        euros = CustomValue.find_by_customized_id_and_custom_field_id(self.id, 
          Setting.plugin_redmine_emergya_adjustments['currency_'+type+'_custom_field_conv'])

        fin = CustomValue.find_by_customized_id_and_custom_field_id(self.id, 
          Setting.plugin_redmine_emergya_adjustments['currency_'+type+'_custom_field_date'])

        if moneda.present? and original.present? and fin.present? and euros.present?
          total = AutofillOps.currency_exchange(moneda.value, original.value, fin.value)
          
          #if total != 'default'
            euros.update_attribute('value', total)
          #end
        end
      end
    end
=begin
    def update_currency_exchange_bill
      if Setting.plugin_redmine_emergya_adjustments['plugin_currency_manager']
        moneda = CustomValue.find_by_customized_id_and_custom_field_id(self.id,
          Setting.plugin_redmine_emergya_adjustments['currency_custom_field'])

        original = CustomValue.find_by_customized_id_and_custom_field_id(self.id, 
          Setting.plugin_redmine_emergya_adjustments['currency_bill_custom_field_orig'])

        euros = CustomValue.find_by_customized_id_and_custom_field_id(self.id, 
          Setting.plugin_redmine_emergya_adjustments['currency_bill_custom_field_conv'])

        fin = CustomValue.find_by_customized_id_and_custom_field_id(self.id, 
          Setting.plugin_redmine_emergya_adjustments['currency_bill_custom_field_date'])

        if moneda.present? and original.present? and fin.present? and euros.present?
          euros.update_attribute('value', AutofillOps.currency_exchange(moneda.value, original.value, fin.value))
        end
      end
    end

    def update_currency_exchange_provider
      if Setting.plugin_redmine_emergya_adjustments['plugin_currency_manager']
        moneda = CustomValue.find_by_customized_id_and_custom_field_id(self.id,
          Setting.plugin_redmine_emergya_adjustments['currency_custom_field'])

        original = CustomValue.find_by_customized_id_and_custom_field_id(self.id, 
          Setting.plugin_redmine_emergya_adjustments['currency_provider_custom_field_orig'])

        euros = CustomValue.find_by_customized_id_and_custom_field_id(self.id, 
          Setting.plugin_redmine_emergya_adjustments['currency_provider_custom_field_conv'])

        fin = CustomValue.find_by_customized_id_and_custom_field_id(self.id, 
          Setting.plugin_redmine_emergya_adjustments['currency_provider_custom_field_date'])

        if moneda.present? and original.present? and fin.present? and euros.present?
          euros.update_attribute('value', AutofillOps.currency_exchange(moneda.value, original.value, fin.value))
        end
      end
    end
=end
    def update_currency_exchange_bpo
      if Setting.plugin_redmine_emergya_adjustments['plugin_currency_manager']
        moneda = CustomValue.find_by_customized_id_and_custom_field_id(self.id,
          Setting.plugin_redmine_emergya_adjustments['currency_custom_field'])

        original = CustomValue.find_by_customized_id_and_custom_field_id(self.id, 
          Setting.plugin_redmine_emergya_adjustments['currency_bpo_custom_field_orig'])

        euros = CustomValue.find_by_customized_id_and_custom_field_id(self.id, 
          Setting.plugin_redmine_emergya_adjustments['currency_bpo_custom_field_conv'])


        if moneda.present? and original.present? and self.start_date.present? and self.due_date.present? and euros.present?
          total = AutofillOps.currency_exchange_bpo(moneda.value, original.value, self.start_date, self.due_date)
          
          #if total != 'default'
            euros.update_attribute('value', total)
          #end
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
