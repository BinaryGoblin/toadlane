App.registerBehavior 'CheckOutsideUS'

class Behavior.CheckOutsideUS
  constructor: ($el) ->
    @$el = $el

    @$func = {
      'display_true': @show_and_changes,
      'display_false': @hide_and_changes
    }

    do @$func['display_' + $(@$el).is(':checked')]

    $(@$el).on 'ifChanged', => do @changes

  changes: =>
    do @$func['display_' + $(@$el).is(':checked')]

  show_and_changes: =>
    $('#fly_buy_profile_country').closest('.col-md-6').removeClass('hide')
    $('#fly_buy_profile_eic_attachment').closest('.form-group').find('a.view').addClass('hide')
    $('#fly_buy_profile_business_documents').closest('.col-md-6').removeClass('hide')
    $('#fly_buy_profile_tin_number').closest('.form-group').find('label').text('Business Tax Number:')
    $('#fly_buy_profile_eic_attachment').closest('.form-group').find('label').text('Tax Document:')
    $('#fly_buy_profile_ssn_number').closest('.form-group').find('label').text('GOVERNMENT IDENTIFICATION NUMBER:')

  hide_and_changes: =>
    $('#fly_buy_profile_country').closest('.col-md-6').addClass('hide')
    $('#fly_buy_profile_eic_attachment').closest('.form-group').find('a.view').removeClass('hide')
    $('#fly_buy_profile_business_documents').closest('.col-md-6').addClass('hide')
    $('#fly_buy_profile_tin_number').closest('.form-group').find('label').text('EIN Number:')
    $('#fly_buy_profile_eic_attachment').closest('.form-group').find('label').text('EIN Document:')
    $('#fly_buy_profile_ssn_number').closest('.form-group').find('label').text('SOCIAL SECURITY NUMBER:')
