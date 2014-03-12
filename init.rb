# Run initializers
# Needs to be atop requires because some of them need to be run after initialization
#Dir["#{File.dirname(__FILE__)}/config/initializers/**/*.rb"].sort.each do |initializer|
#  require initializer
#end

# Get messages from locales
#Dir[File.join("#{File.dirname(__FILE__)}/config/locales/*.yml")].each do |locale|
#  I18n.load_path.unshift(locale)
#end

#require 'redmine'
require 'issues_dates_required_patch'
require 'issues_controller_patch'
require 'queries_helper_patch'
require 'hooks'


Rails.configuration.to_prepare do
  TimelogController.send(:helper, :queries)
#  IssuesController.send(:helper, :queries)
end

Redmine::Plugin.register :redmine_emergya_adjustments do
  name 'Emergya Adjustments Plugin'
  author 'ogonzalez, jresinas'
  description 'Different Redmine features to improve the fit with Emergya workflows'
  version '0.0.2'
  author_url 'http://www.emergya.es'

  settings :default => { :trackers => []}, :partial => 'settings/settings'
end