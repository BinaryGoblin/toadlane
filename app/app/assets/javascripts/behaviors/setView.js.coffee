App.registerBehavior 'SetView'

class Behavior.SetView
  constructor: ($el) ->
    @options = $el.data 'options'

    $el.on 'click', => do @set

  reload: =>
    document.location.reload true

  set: =>
    document.cookie = k + '=' + v for k, v of @options    
    do @reload
