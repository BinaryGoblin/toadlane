#= require jquery
#= require jquery_ujs
#= require jquery-ui/slider
#= require jquery-ui/selectmenu
#= require jquery-ui/tooltip
#= require jquery-ui/autocomplete
#= require html5lightbox

#= require jquery.bxslider.min

#= require ./plugins/jquery.validate
#= require_tree ../../../vendor/assets/javascripts/.
#= require_tree ./plugins

#= require bootstrap

#= require elemental

#= require_tree ./initializers/
#= require_tree ./helpers/
#= require_tree ./behaviors/

$(document).ready ->
  Elemental.addNamespace App
  Elemental.load document
  $(".fe-toggle").tooltip({tooltipClass: "search-tooltip"})
  $('.bxslider').bxSlider
    slideWidth: 240
    minSlides: 1
    maxSlides: 4
    slideMargin: 38
    moveSlides: 1
    pager: false
  $("#user_state").autocomplete({
    source: ["Alabama",
    "Alaska",
    "Arizona",
    "Arkansas",
    "California",
    "Colorado",
    "Connecticut",
    "Delaware",
    "District of Columbia",
    "Florida",
    "Georgia",
    "Hawaii",
    "Idaho",
    "Illinois",
    "Indiana",
    "Iowa",
    "Kansas",
    "Kentucky",
    "Louisiana",
    "Maine",
    "Maryland",
    "Massachusetts",
    "Michigan",
    "Minnesota",
    "Mississipi",
    "Missouri",
    "Montana",
    "Nebraska",
    "Nevada",
    "New Hampshire",
    "New Jersey",
    "New Mexico",
    "New York",
    "North Carolina",
    "North Dakota",
    "Ohio",
    "Oklahoma",
    "Oregon",
    "Pennsylvania",
    "Rhode Island",
    "South Carolina",
    "South Dakota",
    "Tennessee",
    "Texas",
    "Utah",
    "Vermont",
    "Virginia",
    "Washington",
    "West Virginia",
    "Wisconsin",
    "Wyoming"
    ],
    autocomplete: true
  });

  $(".html5lightbox").html5lightbox()

  $('#set_new_inspection').click ->
    if $(".set_inspection_date").is(':visible')
      $(".set_inspection_date").hide()
      $(".confirm-inspection-date-btn").show()
    else
      $(".set_inspection_date").show()
      $(".confirm-inspection-date-btn").hide()

  $('.related_searches a').click (event) ->
    event.preventDefault()
    rs = $(this).html()
    $('input#query').val(rs)
    $('form#search_form').submit()
    return

  $("#green_order_phone").mask("999-999-9999");

  if $('.vp-calculation-checkout').is(':visible')
    $('input[name="stripe_order[shipping_estimate_id]"]:first, input[name="green_order[shipping_estimate_id]"]:first, input[name="amg_order[shipping_estimate_id]"]:first, input[name="emb_order[shipping_estimate_id]"]:first').trigger('click');

  jQuery.validator.addMethod 'zipcode', ((value, element) ->
    @optional(element) or /^\d{5}(?:-\d{4})?$/.test(value)
  ), 'Please provide a valid zipcode.'

  jQuery.validator.addMethod 'validEmail', ((value, element) ->
    @optional(element) or /^(([^<>()\[\]\.,;:\s@\"]+(\.[^<>()\[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i.test(value)
  ), 'Please enter a valid email address.'

  jQuery.validator.addMethod 'filesize', ((value, element, param) ->
    mult_param = param * 1048576
    @optional(element) or (element.files[0].size <= mult_param)
  ), 'File size must be less than {0} MB'

  $('select#green_order_address_country').change (event) ->
    select_wrapper = $('.order_state_code_wrapper')

    $('select', select_wrapper).attr('disabled', true)

    country_code = $(this).val()

    url = "/products/subregion_options?parent_region=#{country_code}&parent_object_sym=green_order"
    select_wrapper.load(url)

  $('.inspection_date_select').children().closest('label').find('input:first').prop("checked", true)

  $('select#amg_order_address_country').change (event) ->
    select_wrapper = $('.order_state_code_wrapper')

    $('select', select_wrapper).attr('disabled', true)

    country_code = $(this).val()

    url = "/products/subregion_options?parent_region=#{country_code}&parent_object_sym=amg_order"
    select_wrapper.load(url)

  $('select#emb_order_address_country').change (event) ->
    select_wrapper = $('.order_state_code_wrapper')

    $('select', select_wrapper).attr('disabled', true)

    country_code = $(this).val()

    url = "/products/subregion_options?parent_region=#{country_code}&parent_object_sym=emb_order"
    select_wrapper.load(url)

  $('form#new_green_order').validate
    rules:
      "green_order[email_address]":
        required: true
        validEmail: true
      "green_order[routing_number]":
        required: true
        minlength: 9
        maxlength: 9
        number: true
      "green_order[address_zip]":
        required: true
        zipcode: true
      "green_order[account_number]":
        required: true
        number: true
    submitHandler: (form) ->
      $('form#new_green_order').find('input[type=submit]').prop 'disabled', true
      form.submit()
      return

  $('form#new_amg_order').validate
    rules:
      "amg_order[email_address]":
        required: true
        validEmail: true
      "amg_order[address_zip]":
        required: true
        zipcode: true
      "billing-cc-number":
        required: true
        creditcard: true
    submitHandler: (form) ->
      $('form#new_amg_order').find('input[type=submit]').prop 'disabled', true
      form.submit()
      return

  $('form#new_emb_order').validate
    rules:
      "emb_order[email_address]":
        required: true
        validEmail: true
      "emb_order[address_zip]":
        required: true
        zipcode: true
      "billing-cc-number":
        required: true
        creditcard: true
    submitHandler: (form) ->
      $('form#new_emb_order').find('input[type=submit]').prop 'disabled', true
      form.submit()
      return

  $('form.product_form_partial').validate
    rules:
      "product[videos_attributes][]":
        required: false
        filesize: 5

  (new Fingerprint2).get (result) ->
    $('#fly_buy_profile_fingerprint').val(result)
    return

  $('form.create_fly_buy_profile').submit ->
    $(this).find(':submit').prop 'disabled', true
    $('*').css 'cursor', 'wait'
    return

  $('#product_default_payment').change ->
    if $('#product_default_payment').find(":selected").text() == "Fly And Buy"
      $('.insert_inspection_dates').show()
    else
      $('.insert_inspection_dates').hide()

  $('form.edit_armor_profile').validate
    rules:
      "armor_profile[phone]":
        required: true
        remote:
          url: "/dashboard/accounts/check_valid_phone_number"
          type: "GET"
      "armor_profile[addresses][state]":
        required: true
        remote:
          url: "/dashboard/accounts/check_valid_state"
          type: "GET"
    messages:
      "armor_profile[phone]":
        remote: "Phone number is not valid."
      "armor_profile[addresses][state]":
        remote: "State is not valid. "
    errorPlacement: (error, element) ->
      # this is done for displaying the error message for agreed_terms checkbox
      # # below the checkbox
      if element.attr('name') == "armor_profile[agreed_terms]"
        error.insertAfter(element.parent().parent())
      else
        error.insertAfter element
      return

  $('form#new_promise_account').validate
    rules:
      "promise_account[bank_name]":
        required: true
      "promise_account[account_name]":
        required: true
      "promise_account[routing_number]":
        required: true
        minlength: 9
        maxlength: 9
        number: true
      "promise_account[account_number]":
        required: true
        minlength: 10
        maxlength: 10
        number: true
    errorPlacement: (error, element) ->
      # this is done for displaying the error message for DIRECT DEBIT AGREEMENT
      # # below the checkbox
      if element.attr('name') == "promise_account[direct_debit_agreement]"
        error.insertAfter(element.parent().parent())
      else
        error.insertAfter element
      return
    submitHandler: (form) ->
      $('form#new_promise_account').find('input[type=submit]').prop 'disabled', true
      $('*').css 'cursor', 'wait'
      form.submit()
      return

  $('.synapse-kyc-btn').click ->
    oauth_key = $('.synapse-kyc-btn').data('oauth-key')
    fingerprint = $('.synapse-kyc-btn').data('fingerprint')
    development_mode = $('.synapse-kyc-btn').data('development_mode')

    $('a.synapse-kyc-btn').addClass( "disabled" )
    $('*').css 'cursor', 'wait'

    iframeInfo =
      physical_id:
        collect: true
        message: 'To continue, please attach a EIN letter.'
        no_webcam: true
      development_mode: development_mode
      no_ac_rt: false
      do_kyc: true
      do_banks: false
      kyc_done: false
      userInfo:
        oauth_key: oauth_key
        fingerprint: fingerprint
      colors:
        'trim': '#059db1'
        'unfocused': 'UNFOCUSED_COLOR'
        'text': '#059db1'
      messages:
        'kyc_message': 'Please click on the button above to verify your identity before creating a transaction.'
        'bank_message': 'Please click on the button above to link a bank account to your profile.'
        'trans_mesage': 'Please click on the button above to create a transaction.'
      receiverLogo: 'https://cdn.synapsepay.com/static_assets/logo@2x.png'

    setupSynapseiFrame iframeInfo
    $('#synapse_iframe').css 'visibility', 'visible'
    $('#synapse_iframe').css 'height', '100%'
    $('#synapse_iframe').css 'width', '100%'
    $('#synapse_iframe').css 'left', '0px'

  expressReciver = (e) ->
    try
      json = JSON.parse(e.data)
      if json.success or json.close
        $('a.synapse-kyc-btn').removeClass( "disabled" )
        $('*').css 'cursor', 'default'
        $('#synapse_iframe').css 'visibility', 'hidden'
        $('#synapse_iframe').css 'height', '0%'
        $('#synapse_iframe').css 'width', '0%'
        $('#synapse_iframe').css 'left', '0px'
        $('#synapse_iframe').prop 'src', ''
        self.set 'enableButton', true
    catch e
      # console.log(e);
    return

  window.addEventListener 'message', expressReciver, false
