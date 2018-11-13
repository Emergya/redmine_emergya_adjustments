require_dependency 'issues_helper'

# Patches Redmine's ApplicationController dinamically.
module IssuesHelperPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :render_descendants_tree, :partial_amounts
    end
  end

  module ClassMethods
  end 

  module InstanceMethods
    def render_descendants_tree_with_partial_amounts(issue)
      if issue.is_prepaid_bundle?
        s = '<form><table class="list issues">'
        issue_list(issue.descendants.visible.preload(:status, :priority, :tracker).sort_by(&:lft)) do |child, level|
          css = "issue issue-#{child.id} hascontextmenu"
          css << " idnt idnt-#{level}" if level > 0
          s << content_tag('tr',
                 content_tag('td', check_box_tag("ids[]", child.id, false, :id => nil), :class => 'checkbox') +
                 content_tag('td', link_to_issue(child, :project => (issue.project_id != child.project_id)), :class => 'subject', :style => 'width: 50%') +
                 content_tag('td', h(child.status)) +
                 content_tag('td', link_to_user(child.assigned_to)) +
                 content_tag('td', progress_bar(child.done_ratio)) +
                 content_tag('td', child.custom_values.find_by_custom_field_id(Setting.plugin_redmine_emergya_adjustments['bill_invoice_custom_field']).value.to_f.round(2).to_s + '€'),
                 :class => css)
        end
        s << '</table></form>'
        s.html_safe
      else
        render_descendants_tree_without_partial_amounts(issue)
      end
    end
  end
end


ActionDispatch::Callbacks.to_prepare do
  IssuesHelper.send(:include, IssuesHelperPatch)
end