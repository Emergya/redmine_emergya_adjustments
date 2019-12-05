module Emergya_adjustments
  class Hooks < Redmine::Hook::ViewListener
     def controller_issues_edit_before_save(context={ })
      if (context[:issue].status.is_closed)
      	context[:issue].done_ratio = 100
      end 
    end
    render_on :view_issues_form_details_bottom,
              :partial => 'issues/tracking_custom_fields'
    render_on :view_issues_show_details_bottom,
              :partial => 'hooks/emergya/view_issues_show_details_bottom'
  end
end

