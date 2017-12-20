$(document).ready(function(){
	$(document).on('change', '.launcher', function(){
		autofill_field($(this).data('attr_slave'));
	});

});

function autofill_field(args){
	args = args.split(',');

	for(index in args){
		slave = args[index];
		params = {};

		$('.launcher').each(function(index,value){
			slaves = $(this).data('attr_slave').split(',');
			if (slaves.includes(slave)){
				params[$(this).data('attr_name')] = $(this).val();
			}
		});

		if ($('.autofilled_field[data-attr_name="'+slave+'"]').hasClass('select_input')){
			default_options=new Array();
			$('.autofilled_field[data-attr_name="'+slave+'"] option').each(function(){
				option = new Array();
				option.push(this.innerHTML);
				option.push(this.value);
				default_options.push(option);
			});
			params['options'] = JSON.stringify(default_options);
		}


		set_value(slave);
	}
}

function set_value(slave){
	$.ajax({
		url: url,
		data: params,
		success: function(data){
			if ($('.autofilled_field[data-attr_name="'+slave+'"]').is('input')){
				$('.autofilled_field[data-attr_name="'+slave+'"]').val(data);
			} else {
				$('.autofilled_field[data-attr_name="'+slave+'"]').html(data);
			}
			$('.autofilled_field[data-attr_name="'+slave+'"]').trigger('change');
		}
	});
}