App.registerBehavior 'CalculationProduct'

class Behavior.CalculationProduct
  constructor: ($el) ->
    @$shippingEstimate     =  $ '.calc-shipping'
    @$calculationPanel     =  $ '.vp-calculation'
    @$toadlaneFee         =  $ '.toadlane-fee'
    @$flybyFee           =  $ '.fly-by-fee'
    @$progress_bar        = $ '.progress'

    @options        = @$calculationPanel.data 'options'
    @$cart          = @$calculationPanel.find '.calc-cart'
    @$subTotal      = @$calculationPanel.find '.subTotal'
    @$quantity      = @$calculationPanel.find '.calc-quantity'
    @$rebate        = @$calculationPanel.find '.calc-rebate'
    @$pcs           = @$calculationPanel.find '.calc-pcs'
    @$rebPrice      = @$calculationPanel.find '.calc-rebate-price'
    @$feePrice      = @$calculationPanel.find '.calc-fees-price'
    @$shippingPrice = @$calculationPanel.find '.calc-shipping-price'
    @$flyBuyPrice   = @$calculationPanel.find '.calc-fees-fly-buy-price'
    @$InspectionService = @$calculationPanel.find '#inspection_service'
    @$InspectionServiceNote = @$calculationPanel.find '#inspection_service_comment'
    @$MinQuantity   = @$calculationPanel.find '#minimum_order_quantity'

    @$PercentageOfItemsToInspect = @$calculationPanel.find '#number_of_items_to_inspect'
    @$NumberOfItemsToInspect = @$calculationPanel.find '.item-count'
    @$InspectServiceFee = @$PercentageOfItemsToInspect.parent().find '.pull-right'

    @fees       = parseFloat @$toadlaneFee.data('fees'), 10
    @unitPrice  = @$calculationPanel.find('[data-unit-price]').data 'unit-price'

    @feesFlyBuyOverMillion    = parseFloat @$flybyFee.data('fees-fly-buy-over-million'), 10
    @feesFlyBuyUnderMillion   = parseFloat @$flybyFee.data('fees-fly-buy-under-million'), 10

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
    @$flyBuyFeesPrice     = $ '[name="fly_buy_fee"]'
    @$flyBuyInspectionPercentage  = $ '[name="percentage_of_items_to_inspect"]'
    @$flyBuyInspectionNote  = $ '[name="inspection_service_note"]'

    @$footer = $ '.payment-button'

    @$checkout = $ '.checkout'
    @$checkOutFrom = $ 'form.text-center'

    do @calculation
    @$quantity.on 'change:quantity keyup', => do @calculation
    @$checkOutFrom.on 'submit', => do @check_minimum_quantity

  fixed: (number) =>
    number.toFixed(2).toString()

  number_to_currency: (amount) =>
    amount.replace /(\d)(?=(\d{3})+(?!\d))/g, "$1,"

  check_minimum_quantity: =>
    minimum_quantity = parseInt @$MinQuantity.val(), 10
    quantity = parseInt @$quantity.val(), 10

    if quantity < minimum_quantity
      $('html, body').animate { scrollTop: @$progress_bar.offset().top - 60}, 'fast'
      @$quantity.focus()
      return false
    else
      do @set_inspection_params

  set_inspection_params: =>
    percentage_of_inspection_service = 0
    inspection_service_note = ''
    if @$InspectionService.is(':checked')
      percentage_of_inspection_service = parseInt @$PercentageOfItemsToInspect.val(), 10
      inspection_service_note = @$InspectionServiceNote.val()
    else
      inspection_service_note = @$InspectionServiceNote.val()
    @$flyBuyInspectionPercentage.val percentage_of_inspection_service
    @$flyBuyInspectionNote.val inspection_service_note

  calculation: =>
    total         = 0
    rebate        = 0
    fees_fly_buy  = 0
    charge_inspection_per_unit = 1
    quantity = parseInt @$quantity.val(), 10
    quantity = 1 unless quantity
    inspection_service_fee = 0

    if @$InspectionService.is(':checked')
      percentage_of_inspection_service = parseInt @$PercentageOfItemsToInspect.val(), 10
      number_of_items_for_inspection_service = Math.round((percentage_of_inspection_service * quantity)/100)
      inspection_service_fee = number_of_items_for_inspection_service * charge_inspection_per_unit

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
      without_reduction_fees = total * (@fees || 0) / 100
      reduction_in_fees = without_reduction_fees * 75 / 100
      fees = without_reduction_fees - reduction_in_fees
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

    if total > 1000000
      unless isNaN(@feesFlyBuyOverMillion)
        fees_fly_buy = @feesFlyBuyOverMillion * total / 100
    else
      unless isNaN(@feesFlyBuyOverMillion)
        fees_fly_buy = @feesFlyBuyUnderMillion * total / 100

    rebatep           = (rebate * 100) / (@unitPrice * quantity)
    cart              = total + fees + shipping_cost - rebate + fees_fly_buy + inspection_service_fee

    if total > 1
      @$checkout.removeClass 'disabled'
    else
      @$checkout.addClass 'disabled'

    if shipping_cost > 0
      @$footer.show()
    else
      @$footer.hide()

    total_fees = fees + fees_fly_buy

    @$rebate.text @fixed rebatep
    @$pcs.text quantity
    @$feePrice.text @number_to_currency(@fixed total_fees)
    @$shippingPrice.text @number_to_currency(@fixed shipping_cost)
    @$rebPrice.text @number_to_currency(@fixed rebate)
    @$NumberOfItemsToInspect.text number_of_items_for_inspection_service
    @$InspectServiceFee.text @number_to_currency(@fixed inspection_service_fee)
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
    @$flyBuyFeesPrice.val fees_fly_buy.toFixed 2

    @$stripeButtonScript.attr 'data-amount', cart.toFixed 2
