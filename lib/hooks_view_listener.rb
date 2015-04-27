class HooksViewListener < Redmine::Hook::ViewListener
  render_on :view_issues_form_details_top, :partial => "issues/issues_tracker_behavior"
end
