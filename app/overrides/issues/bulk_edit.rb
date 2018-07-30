Deface::Override.new(
  :virtual_path => "issues/bulk_edit",
  :name => "bulk_update",
  :replace => "erb[loud]:contains(\"check_box_tag 'link_copy'\")",
  :text => "<%= check_box_tag 'link_copy', '1', false %>",
  :original => "<%= check_box_tag 'link_copy', '1', params[:link_copy] != 0 %>",
  :disabled => false)