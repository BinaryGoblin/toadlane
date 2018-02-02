App.registerBehavior 'optInInspectionService'

class Behavior.optInInspectionService
  constructor: ($el) ->
    @$el = $el
    @$field = $('.quantity').find '[type=text]'

    @$variables = {
      'block': '#inspection_service_block'
    }

    @$func = {
      'display_true': @show_and_changes,
      'display_false': @hide_and_changes
    }

    do @$func['display_' + $(@$el).is(':checked')]

    $(@$el).on 'ifChanged', => do @changes

  changes: =>
    do @$func['display_' + $(@$el).is(':checked')]
    @$field.trigger 'change:quantity'

  show_and_changes: =>
    $(@$variables['block']).removeClass('hide')
  hide_and_changes: =>
    $(@$variables['block']).addClass('hide')