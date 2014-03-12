require_dependency 'queries_helper'
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

# Patches Redmine's ApplicationController dinamically. Redefines methods wich
# send error responses to clients
module QueriesHelperPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
      #unloadable  # Send unloadable so it will be reloaded in development
    end
  end

  module ClassMethods
  end 

  module InstanceMethods
    def ignore_accents(str)
      str.capitalize.gsub('Á','A').gsub('É','E').gsub('Í','I').gsub('Ó','O').gsub('Ú','U')
    end

    def nil_to_empty(element)
      if element == nil
        return ""
      else
        return element
      end
    end
  end
end


if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    QueriesHelper.send(:include, QueriesHelperPatch)
  end
else
  Dispatcher.to_prepare do
    QueriesHelper.send(:include, QueriesHelperPatch)
  end
end