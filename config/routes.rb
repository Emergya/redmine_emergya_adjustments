RedmineApp::Application.routes.draw do
#Rails::application::routes.draw do |map|
  match 'get_exposition_level' => 'issues#get_exposition_level'
  match 'get_bill_amount' => 'issues#get_bill_amount'
  match 'get_bpo_total' => 'issues#get_bpo_total'
  match 'get_currency_exchange' => 'issues#get_currency_exchange'
  match 'get_currency_exchange_bpo' => 'issues#get_currency_exchange_bpo'
  match '/settings/show_tracker_custom_fields' => 'settings#show_tracker_custom_fields'
end
