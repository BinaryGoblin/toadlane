App.registerBehavior 'SliderRates'

class Behavior.SliderRates
  constructor: ($el) ->
    @options = $el.data 'options'

    $container = $el.closest '.product'

    @$cost = $container.find '.pb-cost'
    @$save = $container.find '.pb-save'

    $el.slider
      range: 'max'
      min: 0
      max: @options.max
      value: 1
      slide: (e, ui) => @calculation e, ui
      stop: (e, ui) => @remove_class e, ui
      start: (e, ui) => @remove_class e, ui
      change: (e, ui) => @remove_class e, ui

  remove_class: (e, ui) =>
    ui.handle.classList.remove("ui-state-focus")

  calculation: (e, ui) =>
    @remove_class e, ui
    cost = 0
    save = 0

    if @options.pricebreaks.length > 0
      for pricebreak, i in @options.pricebreaks
        prevQuantity = if i > 0 then @options.pricebreaks[i-1].quantity else 0

        if i is 0
          cost = ui.value * @options.unit_price

        else if prevQuantity < ui.value <= pricebreak.quantity
          cost = ui.value * @options.pricebreaks[i-1].price
          save = ui.value * (@options.unit_price - @options.pricebreaks[i-1].price)

      lastPricebreak = @options.pricebreaks[@options.pricebreaks.length-1]

      if lastPricebreak.quantity < ui.value <= @options.max
        cost = ui.value * lastPricebreak.price
        save = ui.value * (@options.unit_price - lastPricebreak.price)

    else
      cost = ui.value * @options.unit_price
    
    @$cost.text '$' + cost.toFixed(2).toString()
    @$save.text '$' + save.toFixed(2).toString()
