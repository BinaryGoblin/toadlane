App.registerBehavior 'CalculationProduct'

class Behavior.CalculationProduct
  constructor: ($el) ->
    @options   = $el.data 'options'
    @$cart     = $el.find '.calc-cart'
    @$quantity = $el.find '.calc-quantity'
    @$rebate   = $el.find '.calc-rebate'
    @$pcs      = $el.find '.calc-pcs'
    @$rebPrice = $el.find '.calc-rebate-price'
    @$feePrice = $el.find '.calc-fees-price'

    @fees     = parseFloat $el.find('.calc-fees').text(), 10
    @unitPrice = $el.find('[data-unit-price]').data 'unit-price'

    @$stripeQuantity      = $ '.stripe-quantity'
    @$stripeTotal         = $ '.stripe-total'
    @$stripeUnitTotal     = $ '.stripe-unit-total'
    @$stripeRebate        = $ '.stripe-rebate'
    @$stripeFees          = $ '.stripe-fees-price'
    @$stripeRabetePrice   = $ '.stripe-rabete-price'
    @$stripeButtonScript  = $ '.stripe-button'
    @$stripeButton        = $ '.stripe-button-el'

    @$stripeAmount        = $ '[name="stripe_order[total]"]'
    @$stripeCount         = $ '[name="stripe_order[count]"]'
    @$stripeFeesPrice     = $ '[name="stripe_order[fee]"]'
    @$stripeRebatePrice   = $ '[name="stripe_order[rebate]"]'
    @$stripeRebatePercent = $ '[name="stripe_order[rebate_percent]"]'

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

    fees   = total * (@fees || 0) / 100
    cart    = total + fees
    rebatep = (rebate * 100) / (@unitPrice * quantity)

    if total > 1
      @$checkout.removeClass 'disabled'
    else
      @$checkout.addClass 'disabled'


    @$rebate.text @fixed rebatep
    @$pcs.text quantity
    @$feePrice.text @fixed fees
    @$rebPrice.text @fixed rebate
    @$cart.text @fixed cart

    @$stripeQuantity.text quantity
    @$stripeTotal.text @fixed cart
    @$stripeUnitTotal.text @fixed @unitPrice * quantity
    @$stripeRebate.text @fixed rebatep
    @$stripeFees.text @fixed fees
    @$stripeRabetePrice.text @fixed rebate

    @$stripeAmount.val cart.toFixed 2
    @$stripeCount.val quantity
    @$stripeFeesPrice.val fees.toFixed 2
    @$stripeRebatePrice.val rebate.toFixed 2
    @$stripeRebatePercent.val rebatep.toFixed 2
    
    @$stripeButtonScript.attr 'data-amount', cart.toFixed 2    