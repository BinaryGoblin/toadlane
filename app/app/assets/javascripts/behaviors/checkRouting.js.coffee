App.registerBehavior 'CheckRouting'

class Behavior.CheckRouting
  constructor: ($el) ->
    @options = $el.data 'options'

  #   $el.on 'keyup blur', (e) => @doLookup e.currentTarget.value

  # doLookup: (rn) =>
  #   $.ajax
  #     url: 'http://www.routingnumbers.info/api/name.json?rn=' + rn
  #     dataType: 'jsonp'
  #     success: @onLookupSuccess

  # onLookupSuccess: (data) =>
  #   if data.code is 200
  #     @options.hiddenField
  #   else
      
