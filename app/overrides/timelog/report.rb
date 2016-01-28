Deface::Override.new :virtual_path  => 'timelog/report',
                     :name          => 'replace_order_criteria',
                     :original		=> 'd68ac29698812daf466fc159e07782248d16b478',                 
                     :replace => "erb[loud]:contains(\"select_tag('criteria[]'\")",
                     :text => "<%= select_tag('criteria[]', options_for_select([[]] + (@report.available_criteria.keys.sort_by{|e| ignore_accents(l_or_humanize(@report.available_criteria[e][:label]))} - @report.criteria).collect{|k| [l_or_humanize(@report.available_criteria[k][:label]), k]}),
                                                          :onchange => 'this.form.submit();',
                                                          :style => 'width: 200px',
                                                          :id => nil,
                                                          :disabled => (@report.criteria.length >= 3), :id => 'criterias') %>"
