RedmineApp::Application.routes.draw do
#Rails::application::routes.draw do |map|
  match 'get_exposition_level' => 'issues#get_exposition_level', via: [:get]
  match 'get_bill_amount' => 'issues#get_bill_amount', via: [:get]
  match 'get_bpo_total' => 'issues#get_bpo_total', via: [:get]
  match 'settings/show_tracker_custom_fields' => 'settings#show_tracker_custom_fields', via: [:get, :post]
end
