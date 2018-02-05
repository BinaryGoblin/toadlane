$(document).ready ->
  $.validator.setDefaults({ ignore: ":hidden:not(.chosen-select)" })

  $.validator.addMethod 'checkForEmail', ((value) ->
    return !/((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)*(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?/.test(value)
  ), 'Please remove email address.'

  $('form.request_form_partial').validate
    rules:
      "product[name]":
        required: true
      "product[tag_list][]":
        required: true
      "product[end_date]":
        required: true
      "product[unit_price]":
        required: true
      "product[amount]":
        required: true
        number: true
      "product[description]":
        checkForEmail: true
      "product[shipping_estimates_attributes][0][cost]":
        required: (element) ->
          return $('#product_default_payment').val()!="Fly And Buy"
    errorPlacement: (error, element) ->
      # this is done for displaying the error message for Product Start Date
      # # below the start date select boxes
      if element.attr('name') == "product[end_date]"
        $('#product_end_date').addClass('error')
        error.appendTo('.product-end-date-error')
      else if element.attr('name') == "product[tag_list][]"
        $('#product_tag_list').addClass('error')
        error.appendTo('.product-tags-error')
      else
        error.insertAfter element
      return
    submitHandler: (form) ->
      $('form.request_form_partial').find('input[type=submit]').prop 'disabled', true
      form.submit()
      return

  $("#continueAndSave").click ->
    $('form.request_form_partial').submit()
