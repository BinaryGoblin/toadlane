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
#= require moment
#= require bootstrap-datetimepicker

#= require elemental

#= require_tree ./initializers/
#= require_tree ./helpers/
#= require_tree ./behaviors/
#= require_tree ./dashboard/

$(document).ready ->
  mq = window.matchMedia('(min-width: 480px)')
  if mq.matches == false
    $('.tabs').find('ul').addClass 'collapse'
    $('.logo-div').hide()

  # $('html,body').animate { scrollTop: 0 }, 100
  #
  # $(window).scroll ->
  # scroll = $(window).scrollTop()
  # sticky = $('.wrap')
  # alert(scroll)
  # if scroll >= 70
  #   sticky.addClass 'headerFixed'
  # else
  #   sticky.removeClass 'headerFixed'


  Elemental.addNamespace App
  Elemental.load document
  $(".fe-toggle").tooltip({tooltipClass: "search-tooltip"})
  $('.bxslider').bxSlider
    slideWidth: 240
    minSlides: 1
    maxSlides: 3
    slideMargin: 38
    moveSlides: 1
    pager: false,
    infiniteLoop: false,
    hideControlOnEnd: true
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

  $('.ui-slider-handle').click ->
    if jQuery.inArray( "ui-state-focus", this.classList ) >= 0
      this.classList.remove("ui-state-focus")

  $(".html5lightbox").html5lightbox()

  $('#set_new_inspection').click ->
    if $(".set_inspection_date").is(':visible')
      $(".set_inspection_date").hide()
      $(".confirm-inspection-date-btn").show()
    else
      $(".set_inspection_date").show()
      $(".confirm-inspection-date-btn").hide()

  $('.show-address-block-button').click (e)->
    e.preventDefault()
    $('.flybuy-address-block input:checked').prop('checked', false)

    $('.show-address-block-button').removeClass('hide')
    $('.show-address-block-button').addClass('show')
    $(this).hide()

    #$('.insert-new-address-block').show()
    $('.insert-new-address-block').removeClass('hide')
    $('.insert-new-address-block').addClass('show')

  $('.fly-buy-profile-address').click (e)->
    $('.insert-new-address-block').removeClass('show')
    $('.insert-new-address-block').addClass('hide')
    $('.show-address-block-button').removeClass('hide')
    $('.show-address-block-button').addClass('show')

  $('.related_searches a').click (event) ->
    event.preventDefault()
    rs = $(this).html()
    $('input#query').val(rs)
    $('form#search_form').submit()
    return

  $("#green_order_phone").mask("999-999-9999");
  retrieveValue = (ev) ->
    $this = $(this)
    val = $this.data('value')
    if val
      $this.val val
    return

  hideValue = (ev) ->
    $this = $(this)
    $this.data 'value', $this.val()
    $this.val $this.val().replace(/^\d{5}/, '*****')
    return

  $('#fly_buy_profile_tin_number, #fly_buy_profile_ssn_number').focus retrieveValue
  $('#fly_buy_profile_tin_number, #fly_buy_profile_ssn_number').blur hideValue

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

  jQuery.validator.addMethod 'country_mismatch', ((value, element) ->
    if value != ''
      if $('.fly-buy-profile-address:checked').length > 0
        text = $('.fly-buy-profile-address:checked').closest('td').find('label').text().split(', ')
        country = text[text.length - 1]
        return country == value

      if $('.fly-buy-profile-address-country').length > 0
        $('.fly-buy-profile-address-country').val()
        return $('.fly-buy-profile-address-country').val() == value
    else
      return true

  ), 'Country mismatch in address section.'

  jQuery.validator.addMethod 'select_except_us', ((value, element) ->
    if value != ''
      return value != 'US'
    else
      return true

  ), 'Please select country except United States.'

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

  $('form#new_group').validate
    rules:
      "group[name]":
        required: true
        remote:
          url: "/dashboard/groups/validate_group_name"
          type: "GET"
          data:
            group_name: $("#group_name").val()
    messages:
      "group[name]":
        remote: "This group name has already been taken."
    submitHandler: (form) ->
      $('form#new_group').find('input[type=submit]').prop 'disabled', true
      form.submit()
      return

  (new Fingerprint2).get (result) ->
    $('#fly_buy_profile_fingerprint').val(result)
    return

  $('#group_product_id').change ->
    $('.error-message').html('')
    checkSelectedDataForGroup()

  $('.new_group .iCheck-helper, .edit_group .iCheck-helper').click ->
    $('.error-message').html('')
    checkSelectedDataForGroup()

  checkSelectedDataForGroup = ->
    if $('.group-submit-btn').is(":disabled") == true
      if $('#group_create_new_product:checked').length == 0
        $('.group-submit-btn').prop 'disabled', false
      else if $('#group_create_new_product:checked').length == 0 && $('#group_product_id').val() != "" ||
      $('#group_create_new_product:checked').length == 1 && $('#group_product_id').val() == ""
        $('.group-submit-btn').prop 'disabled', false
        $('form.new_group, form.edit_group').submit()
      else
        $('.group-submit-btn').prop 'disabled', true
        $('.error-message').html('You can either select a product or create new product.')
    else if $('.group-submit-btn').is(":disabled") == true
      if $('#group_create_new_product:checked').length == 0 && $('#group_product_id').val() != "" ||
      $('#group_create_new_product:checked').length == 1 && $('#group_product_id').val() == ""
        $('.group-submit-btn').prop 'disabled', false
        $('form.new_group, form.edit_group').submit()
      else
        $('.error-message').html('You can either select a product or create new product.')
        $('.group-submit-btn').prop 'disabled', true


  $('.group-submit-btn').click ->
    if $('#group_create_new_product:checked').length == 0 && $('#group_product_id').val() != "" ||
    $('#group_create_new_product:checked').length == 1 && $('#group_product_id').val() == ""
      $(this).prop 'disabled', false
      $('form.new_group, form.edit_group').submit()
    else if $('#group_create_new_product:checked').length == 0 && $('#group_product_id').val() == ""
      $(this).prop 'disabled', true
      $('.error-message').html('You have to select a product or create new product.')
    else
      $('.error-message').html('You can either select a product or create new product.')
      $(this).prop 'disabled', true


  $('.peopleInviteIcon').on 'click', ->
    $('.InvitePpl').toggle()
    if $('.logOutOptions').is(':visible')
      $('.logOutOptions').hide()
    return

  $('.logoutIcon').on 'click', ->
    $('.logOutOptions').toggle()
    if $('.InvitePpl').is(':visible')
      $('.InvitePpl').hide()
    return

  $ ->
    # enable chosen js
    $('.chosen-select').chosen
      allow_single_deselect: true
      no_results_text: 'No results matched'
      width: '200px'
  $('.chosen-select').trigger 'chosen:updated'

  $ ->
    $('.assign_role_to_additional_seller').change ->
      $('form#'+ this.id).submit()
      return
    return

  $('.group-table .iCheck-helper').click ->
    if this.parentElement.classList.contains("checked")
      this.parentElement.firstChild.value=0
    else
      this.parentElement.firstChild.value=1

    $('form#'+ this.parentNode.parentElement.id).submit()
    return

  validator = $('form.create_fly_buy_profile').validate(
                rules:
                  "fly_buy_profile[company_email]":
                    required: true
                    email: true
                  "fly_buy_profile[ssn_number]":
                    minlength: 4
                    maxlength: 10
                  "fly_buy_profile[tin_number]":
                    minlength: 4
                    maxlength: 10
                  "fly_buy_profile[eic_attachment]":
                    extension: "jpeg|jpg|png|pdf"
                  "fly_buy_profile[bank_statement]":
                    extension: "jpeg|jpg|png|pdf"
                  "fly_buy_profile[gov_id]":
                    extension: "jpeg|jpg|png|pdf"
                  "fly_buy_profile[dob(1i)]":
                    check_date_of_birth: true
                  "country[name]":
                    country_mismatch: true,
                    select_except_us: true
                messages:
                  "fly_buy_profile[ssn_number]":
                    required: "Please enter no more than 10 digits."
                  "fly_buy_profile[tin_number]":
                    required: "Please enter no more than 10 digits."
                  "fly_buy_profile[eic_attachment]":
                    extension: "Only file extension jpg, jpeg and png is allowed. "
                errorPlacement: (error, element) ->
                  # this is done for displaying the error message for DIRECT DEBIT AGREEMENT
                  # # below the checkbox
                  if element.attr('name') == "fly_buy_profile[terms_of_service]"
                    error.insertAfter(element.parent().parent())
                  else
                    error.insertAfter element
                  return
                submitHandler: (form) ->
                  $('form.create_fly_buy_profile').find('input[type=submit]').prop 'disabled', true
                  $('*').css 'cursor', 'wait'
                  form.submit()
                  return
              )
  $('a.group_member_message.fa.fa-envelope').click ->
    id = @id.split('_')
    $('#form_message input[id=message_group_member_id]').val id[1]
    return

  if($('.wrap-full').length > 0) && (mq.matches == true)
    $('.tabs').hide()
    $('.tabs').addClass('my-profile-search-page')
    $('.close-collapse').show()
    $('.my-profile-open-link').click ->
      $('.tabs').fadeIn()
    $('.close-collapse').click ->
      $('.tabs').fadeOut()