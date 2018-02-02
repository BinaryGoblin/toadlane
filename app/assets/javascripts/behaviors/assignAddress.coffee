App.registerBehavior 'AssignAddress'

class Behavior.AssignAddress
  constructor: ($el) ->
    @$radioButton         = $el
    @$submitButtonScript  = $ '.create_fly_buy_submit_btn'

    if $('input[name="fly_buy_profile[address_id]"]:first').length>0
      $('input[name="fly_buy_profile[address_id]"]:first').trigger('click')

    @$radioButton.click => do @assign

  assign: =>
    if @$radioButton.val() >= 0
      @$submitButtonScript.attr('data-address-id', this.$radioButton.val())
    else
      @$submitButtonScript.attr('data-address-id', '')
