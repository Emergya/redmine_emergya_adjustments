Deface::Override.new :virtual_path  => 'my/account',
                     :name          => 'hide_mail_notification',
                     :original		=> '60cf925c7954fa66689daf3430e9c2a6da5da0bf',                 
                     :surround 		=> "fieldset.box:not(.tabular)",
                     :text 			=> "<% if User.current.admin? or User.current.superuser? %><%= render_original %><% end %>"
