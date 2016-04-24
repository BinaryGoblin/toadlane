App.registerBehavior 'CalculationProduct'

class Behavior.CalculationProduct
  constructor: ($el) ->
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
    
    @$footer = $ '.payment-button'

    @$checkout = $ '.checkout'

    do @calculation
    @$quantity.on 'change:quantity keyup', => do @calculation

  fixed: (number) =>
    number.toFixed(2).toString()

  calculation: =>
    total  = 0
    rebate = 0
    quantity = parseInt @$quantity.val(), 10
    quantity = 1 unless quantity
    
    if quantity <= @options.maxquantity
      if @options.pricebreaks.length > 0
        for pricebreak, i in @options.pricebreaks
          prevQuantity = if i > 0 then @options.pricebreaks[i-1].quantity else 0

          if i is 0
            total  = quantity * @unitPrice

          else if prevQuantity < quantity <= pricebreak.quantity
            total  = quantity * @options.pricebreaks[i-1].price
            rebate = quantity * (@unitPrice - @options.pricebreaks[i-1].price)

        lastPricebreak = @options.pricebreaks[@options.pricebreaks.length-1]

        if lastPricebreak.quantity < quantity <= @options.maxquantity
          total  = quantity * lastPricebreak.price
          rebate = quantity * (@unitPrice - lastPricebreak.price)

      else
        total = quantity * @unitPrice

    total = quantity * @unitPrice

    fees              = total * (@fees || 0) / 100
    if @$shippingEstimate.data('type') == 'PerUnit'
      shipping_per_unit = parseFloat @$shippingEstimate.text(), 2
      shipping_cost     = shipping_per_unit * quantity
    else 
      if @$shippingEstimateType == 'FlatRate' 
        shipping_cost = parseFloat @$shippingEstimate.text(), 2
      else 
        shipping_cost = 0
    cart              = total + fees + shipping_cost
    rebatep           = (rebate * 100) / (@unitPrice * quantity)

    if total > 1
      @$checkout.removeClass 'disabled'
    else
      @$checkout.addClass 'disabled'

    if shipping_cost > 0
      @$footer.show()
    else
      @$footer.hide()

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