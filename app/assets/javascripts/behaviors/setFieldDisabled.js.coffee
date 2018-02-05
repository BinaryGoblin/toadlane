App.registerBehavior 'SetFieldDisabled'

class Behavior.SetFieldDisabled
  constructor: ($el) ->
    @options = $el.data 'options'
    @radios  = $el.find '[type=radio]'

    @radios.on 'change', => do @setDisabled

    do @setDisabled

  setDisabled: =>
    value = radio.value for radio in @radios when radio.checked
    for field in @options.fields
      $(field).attr 'disabled', @options.true_condition is value
