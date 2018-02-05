$(document).ready ->
  convertDateTime = (value) ->
    dateTime = value.split(' ')
    date = dateTime[0].split('-')
    yyyy = date[0]
    mm = date[1] - 1
    dd = date[2]
    time = dateTime[1].split(':')
    h = time[0]
    m = time[1]
    s = 0

    new Date(yyyy, mm, dd, h, m, s)

  sell_starting_date = new Date
  sell_starting_date.setHours(0,0,0,0)
  sell_starting_date.setDate sell_starting_date.getDate()
  date_format = 'YYYY-MM-DD hh:mm a'

  if($('.product_edit, .product_update').length > 0)
    sell_starting_date = convertDateTime($('#product_start_date').val())

  $('#start-date').datetimepicker
    minDate: sell_starting_date
    useCurrent: false
    format: date_format
  $('#end-date').datetimepicker
    useCurrent: false
    minDate: sell_starting_date
    format: date_format
  $('#start-date').on 'dp.change', (e) ->
    $('#end-date').data('DateTimePicker').minDate e.date
    return
  $('#end-date').on 'dp.change', (e) ->
    $('#start-date').data('DateTimePicker').maxDate e.date
    return

  $('body').on 'click', '.inspection-date', ->
    $(this).datetimepicker({
      minDate: sell_starting_date
      useCurrent: false
      format: date_format
    }).focus();
    return

  $('#product_default_payment').change ->
    if $('#product_default_payment').find(":selected").text() == "Fly And Buy"
      $('.insert_inspection_dates').show()
      endYearSelected = $('#product_end_date_1i').val()
      startYearSelected = $('#product_start_date_1i').val()

      yearSelectBox = $('#product_inspection_date_attributes__date_1i')

      yearSelectBox.html ''

      start_year = parseInt(startYearSelected)
      end_year = parseInt(endYearSelected)

      while start_year <= end_year
        yearSelectBox.append '<option value="' + start_year + '">' + start_year + '</option>'
        start_year++
      yearSelectBox.val
      return
    else
      $('.insert_inspection_dates').hide()

  $.validator.setDefaults({ ignore: ":hidden:not(.chosen-select)" })

  $('form.product_form_partial').validate
    rules:
      "product[name]":
        required: true
      "product[videos_attributes][]":
        required: false
        filesize: 5
      "product[start_date]":
        required: true
      "product[end_date]":
        required: true
      "product[unit_price]":
        required: true
      "product[amount]":
        required: true
      "product[group_attributes][name]":
        required: (element) ->
          id = '#product_group_attributes_group_sellers_attributes_0_user_id'
          return ($(id).length > 0) && ($(id).val() != "")
      "product[group_attributes][group_sellers_attributes][0][user_id]":
        required: (element) ->
          return $("#product_group_attributes_name").val()!=""
      "product[group_attributes][group_sellers_attributes][0][fee]":
        required: (element) ->
          return $("#product_group_attributes_name").val()!=""
        check_fee_exceeds_product_price: true
      "product[group_attributes][group_sellers_attributes][0][role_id]":
        required: (element) ->
          return $("#product_group_attributes_name").val()!=""
      "product[shipping_estimates_attributes][0][cost]":
        required: (element) ->
          return $('#product_default_payment').val()!="Fly And Buy"
    errorPlacement: (error, element) ->
      # this is done for displaying the error message for Product Start Date
      # # below the start date select boxes
      if element.attr('name') == "product[start_date]"
        $('#product_start_date').addClass('error')
        error.appendTo('.product-start-date-error')
      else if element.attr('name') == "product[end_date]"
        $('#product_end_date').addClass('error')
        error.appendTo('.product-end-date-error')
      else if element.attr('name').match(/user_id/)
        added_additional_sellers_ids = $('ul.sellergroups').find('li.sellergroup .chosen-container')
        error = error
        jQuery.each added_additional_sellers_ids, (i, val) ->
          error.insertAfter val
          return
      else
        error.insertAfter element
      return
    submitHandler: (form) ->
      $('form.product_form_partial').find('input[type=submit]').prop 'disabled', true
      form.submit()
      return

  $.validator.addClassRules('set-commission-text-box', {
    required: true,
    check_fee_exceeds_product_price: true
  });

  $.validator.addClassRules('role-dropdown', {
    required: true
  });

  $.validator.addClassRules('gr-members', {
    required: true
  });

  jQuery.validator.addMethod 'check_fee_exceeds_product_price', ((value, element) ->
    if $('li.sellergroup .set-commission-text-box').val() != '' && $('#product_unit_price').val() != ''
      product_retail_price = parseFloat($('#product_unit_price').val())
      added_additional_sellers = $('ul.sellergroups').find('li.sellergroup .set-commission-text-box')
      added_fee = 0

      jQuery.each added_additional_sellers, (i, val) ->
        if val.value != ''
          added_fee = added_fee + parseFloat(val.value)
        return

      return added_fee < product_retail_price
    else
      return true
  ), "The additional seller fee exceeds the product's price."

  $('form.product_form_partial .btn-success').click (event)->
    if $('.product_form_partial').valid() == true
      if $('#product_default_payment').val() != "Fly And Buy"
        event.preventDefault()
        $('#modalPopupToVerifyPayment').modal('show')
      else if $('#product_default_payment').val() == "Fly And Buy"
        $('form.product_form_partial').submit()

  $('#product_group_attributes_name').change ->
    $('#product_default_payment').val("Fly And Buy")
    $('.insert_inspection_dates').show()

  $(".chosen-select, .set-commission-text-box").change ->
    $('#product_default_payment').val("Fly And Buy")
    $('.insert_inspection_dates').show()

  $("#continueAndSave").click ->
    $('form.product_form_partial').submit()