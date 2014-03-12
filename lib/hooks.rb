module Emergya_adjustments
  class Hooks < Redmine::Hook::ViewListener
     def controller_issues_edit_before_save(context={ })
      if (context[:issue].status.is_closed)
      	context[:issue].done_ratio = 100
      end 
    end
  end
end

