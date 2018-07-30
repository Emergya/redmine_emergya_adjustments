Deface::Override.new(
  :virtual_path => "issues/new",
  :name => "build_new_issue_from_params",
  :replace => "erb[loud]:contains('link_copy')",
  :text => "<%= check_box_tag 'link_copy', '1', false %>",
  :original => "<%= check_box_tag 'link_copy', '1', @link_copy %>",
  :disabled => false)