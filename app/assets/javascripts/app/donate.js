$(document).ready( function(){
  var info = $('#donationWidget');
  if (info.length) {
    var form = $('form#donator-form');
    var errorDiv = $("#donation-errors");

    $('.plan-code-inputs label').on('click', function(){
      $('.plan-code-inputs label').removeClass('active');
      $(this).addClass('active');
    });

    $('.payment-engine-selector').on('change', function(){
      $('#moip-fields, #paypal-fields').removeClass('w-lightbox-hide');
      if($(this).val() == 'Paypal'){
        $('#moip-fields').addClass('w-lightbox-hide');
        $('.form-actions .moip').hide();
        $('.form-actions .paypal').html($('.paypal-hide-forms').html()).show().parent('.form-actions').show(); // TODO verificar aqui o resto da linha' + $('input[name=plan_monthly]:checked').val() + '.' + $('input[name=plan_monthly]:checked').val() ));
      } else {
        $('#paypal-fields').addClass('w-lightbox-hide');
        $('.form-actions .paypal').hide().parent('.form-actions').hide();
        $('.form-actions .moip').show();
      }
    });
    form.on('submit', function(event){
      if($('.payment-engine-selector:checked').val() == 'Paypal'){
        return true;
      }
      event.preventDefault();
      errorDiv.empty();

      var moip = new MoipAssinaturas(info.data('token'));

      var customer = new Customer({
        fullname: $("#fullname").val(),
        email: $("#email").val(),
        code: info.data('id'),
        fullname : $("#fullname").val(),
        cpf: $("#cpf").val(),
        birthdate_day: $("#donator_birthdate_3i").val(),
        birthdate_month: $("#donator_birthdate_2i").val(),
        birthdate_year: $("#donator_birthdate_1i").val(),
        phone_area_code: $("#ddd").val(),
        phone_number: $("#phone").val(),
        billing_info: new BillingInfo({
          fullname: $("#holder_name").val(),
          expiration_month: $("#expiration_month").val(),
          expiration_year: $("#expiration_year").val(),
          credit_card_number: $("#credit_card").val()
        }),
        address: new Address({
          street: $("#rua").val(),
          number: $("#numero").val(),
          complement: $("#complemento").val(),
          district: $("#bairro").val(),
          zipcode: $("#cep").val(),
          city: $("#cidade").val(),
          state: $("#estado").val(),
          country: "BRA"
        })
      });

      var subscription_code = '' + info.data('id') + '-' + info.data('code');

      var subscription = new Subscription()
        .with_code(subscription_code)
        .with_new_customer(customer)
        .with_plan_code($('#plan_code').val());
      moip.subscribe(subscription).callback( function(response){
        if (response.has_errors()) {
          errorDiv.empty();
          for (i = 0; i < response.errors.length; i++) {
            var erro = response.errors[i].description;
            errorDiv.append("<li>" + erro + "</li>");
          }
        } else {
          errorDiv.empty().append("<li>Assinatura criado com sucesso</li>");
          errorDiv.append("<li><strong>Próxima Cobrança:</strong> " + response.next_invoice_date.day + "/" + response.next_invoice_date.month + "/" + response.next_invoice_date.year + "</li>");
          errorDiv.append("<li><strong>Status do pagamento:</strong> " + response.invoice.status.description + "</li>");
          errorDiv.append("<li><strong>Status: </strong> " + response.status + "</li>");
          $('#donator-form').hide();
          $('form#donator-form').get(0).submit();
        }
      });
    });
  }
});
