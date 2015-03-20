require 'dispatcher' unless Rails::VERSION::MAJOR >= 3
require_dependency 'issues_controller'


module IssuesControllerPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable  # Send unloadable so it will be reloaded in development
      skip_before_filter :authorize, :only => [:get_exposition_level, :get_bill_amount, :get_bpo_total, :get_currency_exchange, :get_currency_exchange_bpo]
    end
  end

  module InstanceMethods
    # Wraps the association to get the Deliverable subject.  Needed for the 
    # Query and filtering
    def get_exposition_level
      impacto = params[:impacto]
      probabilidad = params[:probabilidad]

      @opciones = ActiveSupport::JSON.decode(params[:options].gsub('\"', '"'))
      @exposicion = ExpositionLevel.getExpositionLevelValue(impacto,probabilidad)
      
      render :layout => false, :inline => "<%= options_for_select(@opciones, @exposicion) %>"
    end

    def get_bill_amount
      facturado = params[:facturado]
      iva = params[:iva]

      if facturado.present? and iva.present? and iva != 'Manual'
        #@cobrado = facturado.to_f * (1.0+(iva.to_f/100.0))
        @cobrado = AutofillOps.bill_total(facturado, iva)
        render :text => @cobrado
      else 
        render :text => 0.0 #:nothing => true
      end
    end

    def get_bpo_total
      anual = params[:anual]
      inicio = params[:inicio]
      fin = params[:fin]

      if anual.present? and inicio.present? and fin.present?
        total = AutofillOps.bpo_total(anual, inicio, fin)
        render :text => total
      else
        render :text => 0.0 #:nothing => true
      end
    end

    def get_currency_exchange
      moneda = params[:moneda]
      original = params[:original]
      fin = params[:fin]

      if moneda.present? and original.present? and Setting.plugin_redmine_emergya_adjustments['plugin_currency_manager'].present?
        begin
          euros = AutofillOps.currency_exchange(moneda, original, fin)
      
          render :text => euros
        rescue
          render :status => 400
        end
      else
        render :text => 0.0
      end
    end


    def get_currency_exchange_bpo
      moneda = params[:moneda]
      original = params[:original]
      inicio = params[:inicio]
      fin = params[:fin]

      if moneda.present? and original.present? and Setting.plugin_redmine_emergya_adjustments['plugin_currency_manager'].present?
        begin
          euros = AutofillOps.currency_exchange_bpo(moneda, original, inicio, fin)
=begin          
          total_days = (fin.to_date - inicio.to_date).to_i + 1
          if moneda == 'EUR'
            euros = original.to_f
          elsif inicio.present? and fin.present?
            euros = CurrencyRange.find(:all, :conditions => ["start_date <= ? AND due_date >= ?",fin.to_date, inicio.to_date]).inject(0.0){|sum, range|
              days = ([range[:due_date].to_date, fin.to_date].min - [range[:start_date].to_date, inicio.to_date].max).to_i + 1 
              total_days -= days
              sum += (days * range[:value].to_f * original.to_f) / 365.0
            }

            euros += (total_days * CurrencyRange.get_current(moneda).to_f * original.to_f) / 365.0
          else
            euros = (total_days * CurrencyRange.get_current(moneda).to_f * original.to_f) / 365.0
          end
=end
          render :text => euros
        rescue
          render :status => 400
        end
      else
        render :text => 0.0
      end
    end

  end
  module ClassMethods
  end
end

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    IssuesController.send(:include, IssuesControllerPatch)
  end
else
  Dispatcher.to_prepare do
    IssuesController.send(:include, IssuesControllerPatch)
  end
end
