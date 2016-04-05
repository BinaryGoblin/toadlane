App.registerBehavior 'AssignShipping'

class Behavior.AssignShipping
  constructor: ($el) ->
    @$radioButton         = $el
    @$stripeButtonScript  = $ '.stripe-button'

    @$radioButton.click => do @assignShippingAddress
    
  assignShippingAddress: =>
    if @$radioButton.val() >= 0
      @$stripeButtonScript.attr 'data-shipping-address', false
    else
      @$stripeButtonScript.attr 'data-shipping-address', true