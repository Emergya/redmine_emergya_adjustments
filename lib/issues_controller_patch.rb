require 'dispatcher' unless Rails::VERSION::MAJOR >= 3
require_dependency 'issues_controller'


module IssuesControllerPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable  # Send unloadable so it will be reloaded in development
      skip_before_filter :authorize, :only => [:get_exposition_level, :get_bill_amount]
    end
  end

  module InstanceMethods
    # Wraps the association to get the Deliverable subject.  Needed for the 
    # Query and filtering
    def get_exposition_level
      impacto = params[:attr1]
      probabilidad = params[:attr2]
      @opciones = ActiveSupport::JSON.decode(params[:options].gsub('\"', '"'))
      @exposicion = ExpositionLevel.getExpositionLevelValue(impacto,probabilidad)
      
      render :layout => false, :inline => "<%= options_for_select(@opciones, @exposicion) %>"
    end

    def get_bill_amount
      facturado = params[:attr1].to_f
      iva = params[:attr2].to_f

      if facturado.present? && iva.present?
        @cobrado = facturado * (1.0+(iva/100.0))
        render :text => @cobrado
      else 
        render :nothing => true
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
