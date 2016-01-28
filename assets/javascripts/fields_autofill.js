$(document).ready(function(){
/*
	$('.autofilled_field').live('focus', function(){
		$(this).blur();
	});
*/
	
	$(document).on('change', '.launcher', function(){
		autofill_field();
	});

});

function autofill_field(){
	params = {};

	$('.launcher').each(function(index,value){
		//params += $(this).attr('data-attr_name')+"="+$(this).val()+"&";
		params[$(this).attr('data-attr_name')] = $(this).val();
	});
	//params = encodeURI(params.substring(0, params.length-1));
	
	if ($('.autofilled_field').hasClass('select_input')){
		default_options=new Array();
		$('.autofilled_field option').each(function(){
			option = new Array();
			option.push(this.innerHTML);
			option.push(this.value);
			default_options.push(option);
		});
		params['options'] = JSON.stringify(default_options);
	}
	$.ajax({
		url: url,
		data: params,
		success: function(data){
			if ($('.autofilled_field').is('input')){
				$('.autofilled_field').val(data);
			} else {
				$('.autofilled_field').html(data);
			}
		}
	});
}