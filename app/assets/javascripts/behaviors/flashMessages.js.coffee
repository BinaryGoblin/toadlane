App.registerBehavior 'FlashMessages'

class Behavior.FlashMessages
  constructor: ($el) ->
    $el.delay(5 * 2000).fadeOut()