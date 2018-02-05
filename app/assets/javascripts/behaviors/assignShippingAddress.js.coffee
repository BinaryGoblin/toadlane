App.registerBehavior 'AssignShippingAddress'

class Behavior.AssignShippingAddress
  constructor: ($el) ->
    @$radioButton         = $el
    @$stripeButtonScript  = $ '.stripe-button'

    @$radioButton.click => do @assign

  assign: =>
    if @$radioButton.val() >= 0
      @$stripeButtonScript.attr 'data-shipping-address', false
    else
      @$stripeButtonScript.attr 'data-shipping-address', true
