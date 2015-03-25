require 'issue_patch'
require 'issues_controller_patch'
require 'queries_helper_patch'
require 'issues_helper_patch'
require 'settings_helper_patch'
require 'hooks'
require 'currency_range_patch'

Rails.configuration.to_prepare do
  TimelogController.send(:helper, :queries)
  IssuesController.send(:helper, :issues)
  SettingsController.send(:helper, :settings)
end

Redmine::Plugin.register :redmine_emergya_adjustments do
  name 'Emergya Adjustments Plugin'
  author 'ogonzalez, jresinas'
  description 'Different Redmine features to improve the fit with Emergya workflows'
  version '0.0.2'
  author_url 'http://www.emergya.es'

  settings :default => { :trackers => []}, :partial => 'settings/settings'
end