Deface::Override.new :virtual_path  => 'projects/_form',
                     :name          => 'disable_project_setting_form',
                     :original		=> '',
                     :insert_before => "erb[loud]:contains(\"error_messages_for\")",
                     :text		=> "
                     	<% if @project.avoid_setting_projects? and !User.current.allowed_to?(:allow_project_settings, @project) %>
                     	<script>
		                    $(document).ready(function(){ 
		                    	$('input, textarea, select', 'div.box.tabular').attr('disabled',true); 
	                    	});
						</script>
						<% end %>"