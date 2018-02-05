App.registerBehavior 'FieldQuantity'

class Behavior.FieldQuantity
  constructor: ($el) ->
    defaultOptions =
      min: 0
      max: Infinity

    @options = $.extend {}, defaultOptions, $el.data 'options'

    @$field  = $el.find '[type=text]'

    $el.on 'click', '.plus', => do @increase
    $el.on 'click', '.minus', => do @reduce

    @$field.on 'change', => do @fieldChange

  increase: =>
    quantity = parseInt @$field.val(), 10

    if quantity < @options.max
      @$field.val quantity + 1
      @$field.trigger 'change:quantity'

  reduce: =>
    quantity = parseInt @$field.val(), 10

    if quantity > @options.min
      @$field.val quantity - 1
      @$field.trigger 'change:quantity'

  fieldChange: =>
    quantity = parseInt @$field.val(), 10

    if !quantity || quantity < @options.min
      @$field.val @options.min
    else if quantity > @options.max
      @$field.val @options.max

    @$field.trigger 'change:quantity'
