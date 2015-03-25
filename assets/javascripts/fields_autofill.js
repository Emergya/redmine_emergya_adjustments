// Rutas a las acciones de "issues_controller" para los procesamientos de autocompletado
var url = {
	'risk': "/get_exposition_level",
	'bill_cost': "/get_bill_amount",
	'currency_exchange': "/get_currency_exchange",
	'currency_exchange_bpo': "/get_currency_exchange_bpo",
	'bpo_total_cost': "/get_bpo_total"
};

$(document).ready(function(){
/*
	$('.autofilled_field').live('focus', function(){
		$(this).blur();
	});
*/
	

	$('.launcher').live('change', function(){
		autofill_field($(this).attr('data-launcher_type').split(" "));
	});

});


function autofill_field(tipos){
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
	//console.log(tipos);
	send_query(tipos);	
	//$.each(tipos.split(" "), function(i,tipo){
	//});
}

function send_query(tipos){
	tipo = tipos.shift();
	$.ajax({
		url: url[tipo],
		data: params,
		success: function(data){
			if (data != "default"){
				if ($('.autofilled_field[data-autofilled_type="'+tipo+'"]').is('input')){
					$('.autofilled_field[data-autofilled_type="'+tipo+'"]').val(data);
				} else {
					$('.autofilled_field[data-autofilled_type="'+tipo+'"]').html(data);
				}
			}

			if (tipos.length > 0){
				autofill_field(tipos);
			}		
		}
	});
}

/*
function append_attr(attr, value){
	old_values = $(this).attr(attr);
	$(this).attr(attr, value + old_values)
}
*/