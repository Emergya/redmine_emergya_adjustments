require_dependency 'projects_controller'

module ProjectsControllerPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      alias_method_chain :update, :avoid_change_settings
    end
  end

  module InstanceMethods
    def setting_time_entries
      @project.avoid_time_entries = params[:avoid_time_entries]
      @project.time_log_start_date = params[:time_log_start_date]

      if @project.save
        flash[:notice] = l(:notice_successful_update)
      else

      end

      redirect_to settings_project_path(@project, :tab => 'time_entries')
    end

    def setting_projects
      @project.avoid_setting_projects = params[:avoid_setting_projects]

      if @project.save
        flash[:notice] = l(:notice_successful_update)
      else

      end

      redirect_to settings_project_path(@project, :tab => 'projects')
    end

    def update_with_avoid_change_settings
      params[:project] = params[:project].select{|p| ['tracker_ids','issue_custom_field_ids'].include?(p)} if @project.avoid_setting_projects? and params[:project] and !User.current.allowed_to?(:allow_project_settings, @project)
      
      update_without_avoid_change_settings
    end
  end

  module ClassMethods
  end
end

ActionDispatch::Callbacks.to_prepare do
  ProjectsController.send(:include, ProjectsControllerPatch)
end
