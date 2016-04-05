App.registerBehavior 'EstimateShipping'

class Behavior.EstimateShipping
  constructor: ($el) ->
    estimate_identifier    = "shipping_estimate_cost_" + $el.attr('value')
    @$shippingEstimateCost =  $ document.getElementById(estimate_identifier)
    @$shippingEstimate     =  $ '.calc-shipping'
    @$calculationPanel     =  $ '.vp-calculation'
    
    @options        = @$calculationPanel.data 'options'
    @$cart          = @$calculationPanel.find '.calc-cart'
    @$quantity      = @$calculationPanel.find '.calc-quantity'
    @$rebate        = @$calculationPanel.find '.calc-rebate'
    @$pcs           = @$calculationPanel.find '.calc-pcs'
    @$rebPrice      = @$calculationPanel.find '.calc-rebate-price'
    @$feePrice      = @$calculationPanel.find '.calc-fees-price'
    @$shippingPrice = @$calculationPanel.find '.calc-shipping-price'

    @fees       = parseFloat @$calculationPanel.find('.calc-fees').text(), 10
    @unitPrice  = @$calculationPanel.find('[data-unit-price]').data 'unit-price'

    @$stripeQuantity      = $ '.stripe-quantity'
    @$stripeTotal         = $ '.stripe-total'
    @$stripeUnitTotal     = $ '.stripe-unit-total'
    @$stripeRebate        = $ '.stripe-rebate'
    @$stripeFees          = $ '.stripe-fees-price'
    @$stripeShipping      = $ '.stripe-shipping'
    @$stripeShippingPrice = $ '.stripe-shipping-price'
    @$stripeRabetePrice   = $ '.stripe-rabete-price'
    @$stripeButtonScript  = $ '.stripe-button'
    @$stripeButton        = $ '.stripe-button-el'

    @$stripeAmount        = $ '[name="stripe_order[total]"]'
    @$stripeCount         = $ '[name="stripe_order[count]"]'
    @$stripeFeesPrice     = $ '[name="stripe_order[fee]"]'
    @$stripeShippingCost  = $ '[name="stripe_order[shipping_cost]"]'
    @$stripeRebatePrice   = $ '[name="stripe_order[rebate]"]'
    @$stripeRebatePercent = $ '[name="stripe_order[rebate_percent]"]'

    @$checkout = $ '.checkout'

    $el.click => do @updateShippingEstimate
    
  updateShippingEstimate: =>
    @$shippingEstimate.text @fixed parseFloat @$shippingEstimateCost.val(), 2
    @calculation()
    return true
    
  fixed: (number) =>
    number.toFixed(2).toString()
    
  calculation: =>
    total  = 0
    rebate = 0
    quantity = parseInt @$quantity.val(), 10
    quantity = 1 unless quantity

    total = quantity * @unitPrice

    fees              = total * (@fees || 0) / 100
    shipping_per_unit = parseFloat @$shippingEstimateCost.val(), 2
    shipping_cost     = shipping_per_unit * quantity
    cart              = total + fees + shipping_cost
    rebatep           = (rebate * 100) / (@unitPrice * quantity)

    if total > 1
      @$checkout.removeClass 'disabled'
    else
      @$checkout.addClass 'disabled'


    @$rebate.text @fixed rebatep
    @$pcs.text quantity
    @$feePrice.text @fixed fees
    @$shippingPrice.text @fixed shipping_cost
    @$rebPrice.text @fixed rebate
    @$cart.text @fixed cart

    @$stripeQuantity.text quantity
    @$stripeTotal.text @fixed cart
    @$stripeUnitTotal.text @fixed @unitPrice * quantity
    @$stripeRebate.text @fixed rebatep
    @$stripeFees.text @fixed fees
    @$stripeShipping.text @fixed parseFloat @$shippingEstimate.text(), 2
    @$stripeShippingPrice.text @fixed shipping_cost
    @$stripeRabetePrice.text @fixed rebate

    @$stripeAmount.val cart.toFixed 2
    @$stripeCount.val quantity
    @$stripeFeesPrice.val fees.toFixed 2
    @$stripeShippingCost.val shipping_cost.toFixed 2
    @$stripeRebatePrice.val rebate.toFixed 2
    @$stripeRebatePercent.val rebatep.toFixed 2
    
    @$stripeButtonScript.attr 'data-amount', cart.toFixed 2    