require 'dispatcher' unless Rails::VERSION::MAJOR >= 3
require_dependency 'issues_controller'


module IssuesControllerPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable  # Send unloadable so it will be reloaded in development
      skip_before_filter :authorize, :only => [:get_exposition_level, :get_bill_amount, :get_bpo_total]
    end
  end

  module InstanceMethods
    # Wraps the association to get the Deliverable subject.  Needed for the 
    # Query and filtering
    def get_exposition_level
      impacto = params[:impacto]
      probabilidad = params[:probabilidad]

      @opciones = ActiveSupport::JSON.decode(params[:options].gsub('\"', '"').gsub('&nbsp;', ''))
      @exposicion = ExpositionLevel.getExpositionLevelValue(impacto,probabilidad)

      render :layout => false, :inline => "<%= options_for_select(@opciones, @exposicion) %>"
    end

    def get_bill_amount
      facturado = params[:facturado]
      iva = params[:iva]

      if facturado.present? and iva.present? and iva != 'Manual'
        @cobrado = facturado.to_f * (1.0+(iva.to_f/100.0))
        render :text => @cobrado
      else 
        render :text => '0' #:nothing => true
      end
    end

    def get_bpo_total
      anual = params[:anual]
      inicio = params[:inicio]
      fin = params[:fin]

      if anual.present? and inicio.present? and fin.present?
        dias = (fin.to_date - inicio.to_date).to_i + 1
        total = (anual.to_f * dias)/365
        render :text => total
      else
        render :text => '0' #:nothing => true
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
