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




function check_dates_listener(){
	$('#content').prepend('<div class="flash warning jquery_flash" id="jquery_flash_warning">La fecha de cobro es menor que la de facturación, ¿está usted seguro?.</div>');
    $('#content #jquery_flash_warning').hide();

    fecha_factura.live('change', function(){
        check_dates(fecha_factura, fecha_cobro);
    });

    fecha_cobro.live('change', function(){
        check_dates(fecha_factura, fecha_cobro);
    });

/*    
    console.log(fecha_factura.closest("form"));
	fecha_factura.closest("form").submit(function(event){
		event.preventDefault();
		check_dates(fecha_factura, fecha_cobro);
	});
*/
}

function check_dates(bill, pay){
	if (bill.val() != "" && pay.val() != "" && bill.val() > pay.val()){
	  $('#jquery_flash_warning').show();
	  //$('#jquery_flash_warning').center();
	  $('html, body').animate({ scrollTop: $("#jquery_flash_warning").offset().top }, 200);
	} else {
	  $('#jquery_flash_warning').hide();
	}
}

// Borra mensajes 'flash' generador por jquery
function clear_jquery_flash(){
	$('#content .jquery_flash').remove();
}
