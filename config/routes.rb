RedmineApp::Application.routes.draw do
#Rails::application::routes.draw do |map|
  match 'get_exposition_level' => 'issues#get_exposition_level'
  match 'get_bill_amount' => 'issues#get_bill_amount'
end
