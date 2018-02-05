App.registerBehavior 'inspectionServicePercentageField'

class Behavior.inspectionServicePercentageField
  constructor: ($el) ->
    @$el = $el
    @$field = $('.quantity').find '[type=text]'

    $(@$el).on 'change', => do @changes

  changes: =>
    @$field.trigger 'change:quantity'