App.registerBehavior 'CalculationProduct'

class Behavior.CalculationProduct
  constructor: ($el) ->
    @$shippingEstimate     =  $ '.calc-shipping'
    @$calculationPanel     =  $ '.vp-calculation'

    @options        = @$calculationPanel.data 'options'
    @$cart          = @$calculationPanel.find '.calc-cart'
    @$subTotal      = @$calculationPanel.find '.subTotal'
    @$quantity      = @$calculationPanel.find '.calc-quantity'
    @$rebate        = @$calculationPanel.find '.calc-rebate'
    @$pcs           = @$calculationPanel.find '.calc-pcs'
    @$rebPrice      = @$calculationPanel.find '.calc-rebate-price'
    @$feePrice      = @$calculationPanel.find '.calc-fees-price'
    @$shippingPrice = @$calculationPanel.find '.calc-shipping-price'

    @fees       = parseFloat @$calculationPanel.find('.calc-fees').text(), 10
    @unitPrice  = @$calculationPanel.find('[data-unit-price]').data 'unit-price'

    @$stripeQuantity      = $ '.stripe_quantity'
    @$stripeTotal         = $ '.stripe-total'
    @$stripeUnitTotal     = $ '.stripe-unit-total'
    @$stripeRebate        = $ '.stripe-rebate'
    @$stripeFees          = $ '.stripe-fees-price'
    @$stripeShipping      = $ '.stripe-shipping'
    @$stripeShippingPrice = $ '.stripe-shipping-price'
    @$stripeRabetePrice   = $ '.stripe-rebate-price'
    @$stripeButtonScript  = $ '.stripe-button'
    @$stripeButton        = $ '.stripe-button-el'

    @$stripeAmount        = $ '[name="total"]'
    @$stripeCount         = $ '[name="count"]'
    @$stripeFeesPrice     = $ '[name="fee"]'
    @$stripeShippingCost  = $ '[name="shipping_cost"]'
    @$stripeRebatePrice   = $ '[name="rebate"]'
    @$stripeRebatePercent = $ '[name="rebate_percent"]'

    @$footer = $ '.payment-button'

    @$checkout = $ '.checkout'

    do @calculation
    @$quantity.on 'change:quantity keyup', => do @calculation

  fixed: (number) =>
    number.toFixed(2).toString()

  number_to_currency: (amount) =>
    amount.replace /(\d)(?=(\d{3})+(?!\d))/g, "$1,"

  # this is for promisepay
  calculatePayInToadlaneFee: (amount) =>
    if amount < 1000000
      fee = (amount * 2.9 / 100) + 0.30
    else if amount >= 1000000 && amount < 2000000
      fee = (amount * 2.7 / 100) + 0.30
    else if amount >= 2000000
      fee = (amount * 2.5 / 100) + 0.30

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

    if $('.user_accounts').children().find('span').text() == "Fly & Buy"
      fees = @calculatePayInToadlaneFee(total)  # PromisePayToadlaneFeeAmount
    else
      fees              = total * (@fees || 0) / 100

    if @$shippingEstimate.data('type') == 'PerUnit'
      shipping_per_unit = parseFloat @$shippingEstimate.text(), 2
      shipping_cost     = shipping_per_unit * quantity
    else
      if @$shippingEstimateType == 'FlatRate'
        shipping_cost = parseFloat @$shippingEstimate.text(), 2
      else
        shipping_cost = 0
    rebatep           = (rebate * 100) / (@unitPrice * quantity)
    cart              = total + fees + shipping_cost - rebate

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
    @$feePrice.text @number_to_currency(@fixed fees)
    @$shippingPrice.text @number_to_currency(@fixed shipping_cost)
    @$rebPrice.text @number_to_currency(@fixed rebate)
    @$cart.text @number_to_currency(@fixed cart)
    @$subTotal.text @number_to_currency(@fixed total)

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
