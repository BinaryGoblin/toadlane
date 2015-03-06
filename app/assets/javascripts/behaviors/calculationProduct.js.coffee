App.registerBehavior 'CalculationProduct'

class Behavior.CalculationProduct
  constructor: ($el) ->
    @options   = $el.data 'options'
    @$cart     = $el.find '.calc-cart'
    @$quantity = $el.find '.calc-quantity'
    @$rebate   = $el.find '.calc-rebate'
    @$pcs      = $el.find '.calc-pcs'
    @$rebPrice = $el.find '.calc-rebate-price'
    @$taxPrice = $el.find '.calc-taxes-price'

    @taxes     = parseInt $el.find('.calc-taxes').text(), 10
    @unitPrice = $el.find('[data-unit-price]').data 'unit-price'

    @$armorQuantity    = $ '.armor-quantity'
    @$armorTotal       = $ '.armor-total'
    @$armorUnitTotal   = $ '.armor-unit-total'
    @$armorRebate      = $ '.armor-rebate'
    @$armorTaxes       = $ '.armor-taxes-price'
    @$armorRabetePrice = $ '.armor-rabete-price'

    @$armorAmount        = $ '[name="armor_order[amount]"]'
    @$armorCount         = $ '[name="armor_order[count]"]'
    @$armorTaxesPrice    = $ '[name="armor_order[taxes_price]"]'
    @$armorRebatePrice   = $ '[name="armor_order[rebate_price]"]'
    @$armorRebatePercent = $ '[name="armor_order[rebate_percent]"]'

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

    taxes   = total * (@taxes || 0) / 100
    cart    = total + taxes
    rebatep = (rebate * 100) / (@unitPrice * quantity)

    if total > 10
      @$checkout.removeClass 'disabled'
    else
      @$checkout.addClass 'disabled'


    @$rebate.text @fixed rebatep
    @$pcs.text quantity
    @$taxPrice.text @fixed taxes
    @$rebPrice.text @fixed rebate
    @$cart.text @fixed cart

    @$armorQuantity.text quantity
    @$armorTotal.text @fixed cart
    @$armorUnitTotal.text @fixed @unitPrice * quantity
    @$armorRebate.text @fixed rebatep
    @$armorTaxes.text @fixed taxes
    @$armorRabetePrice.text @fixed rebate

    @$armorAmount.val cart.toFixed 2
    @$armorCount.val quantity
    @$armorTaxesPrice.val taxes.toFixed 2
    @$armorRebatePrice.val rebate.toFixed 2
    @$armorRebatePercent.val rebatep.toFixed 2
