App.registerBehavior 'Validations'

class Behavior.Validations
  constructor: ($el) ->
    @options = $el.data 'options'

    $el.validate @options
