#require 'dispatcher'
if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    if Setting.plugin_redmine_emergya_adjustments['plugin_currency_manager']
      require_dependency 'currency_range'
      CurrencyRange.send(:include, CurrencyRangePatch)
    end
  end
else
  Dispatcher.to_prepare do
    if Setting.plugin_redmine_emergya_adjustments['plugin_currency_manager']
      require_dependency 'currency_range'
      CurrencyRange.send(:include, CurrencyRangePatch)
    end
  end
end


module CurrencyRangePatch

  def self.included(base) # :nodoc:
    #unloadable
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
      after_save :update_issues_callback
    end

  end

  module ClassMethods
    def update_issues(currency_type)
      get_issues_to_update(currency_type).each do |issue|
        issue.save
      end
    end

    def get_issues_to_update(currency_type)
      currency_custom_field = Setting.plugin_redmine_emergya_adjustments['currency_custom_field']

      Issue.find(:all, :include => :custom_values, :conditions => ["custom_values.custom_field_id = ? AND custom_values.value = ?", currency_custom_field, currency_type])
    end
  end


  module InstanceMethods
    # Para no tener que reiniciar el servidor cada vez que se modifica algo
    #unloadable
    def update_issues_callback
      CurrencyRange.update_issues(self.currency)
    end
  end

end
