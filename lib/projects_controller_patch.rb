require_dependency 'projects_controller'

module ProjectsControllerPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
    end
  end

  module InstanceMethods
    def setting_time_entries
      @project.avoid_time_entries = params[:avoid_time_entries]

      if @project.save
        flash[:notice] = l(:notice_successful_update)
      else

      end

      redirect_to settings_project_path(@project, :tab => 'time_entries')
    end
  end

  module ClassMethods
  end
end

ActionDispatch::Callbacks.to_prepare do
  ProjectsController.send(:include, ProjectsControllerPatch)
end
