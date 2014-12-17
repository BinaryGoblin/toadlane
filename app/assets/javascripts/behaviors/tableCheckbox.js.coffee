App.registerBehavior 'TableCheckbox'

class Behavior.TableCheckbox
  constructor: ($el) ->
    defaultOptions = paramName: 'products_ids'

    @options = $.extend {}, defaultOptions, $el.data 'options'

    @$headCheckbox = $el.find 'thead [type=checkbox]'
    @$bodyCheckbox = $el.find 'tbody [type=checkbox]'
    @$dataRemote = $ '[data-remote=true]'
      
    @$headCheckbox.on 'ifClicked', (e) => @ifClicked e

    @$bodyCheckbox.on 'ifChecked', => do @ifChecked

    @$bodyCheckbox.on 'ifUnchecked', => do @ifUnchecked

    do @ajaxSuccess

  ajaxSuccess: =>
    @$dataRemote.bind 'ajax:success', -> window.location.reload true

  setParams: =>
    params = []
    paramsOptions = {}

    @$bodyCheckbox.each (i, el) ->
      params.push el.value if el.checked

    paramsOptions[@options.paramName] = params

    @$dataRemote.data 'params', $.param paramsOptions

  ifClicked: (e) =>
    @$bodyCheckbox.iCheck if e.currentTarget.checked then 'uncheck' else 'check'
    do @setParams

  ifChecked: =>
    do @setParams

  ifUnchecked: =>
    @$headCheckbox.iCheck 'uncheck'
    do @setParams
