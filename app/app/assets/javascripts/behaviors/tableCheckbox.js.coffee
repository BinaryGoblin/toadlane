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

  setParamsForOrder: =>
    params = []
    paramsOptions = {}

    @$bodyCheckbox.each (i, el) ->
      if el.checked
        params.push(el.value+',' + el.dataset.orderType)
    paramsOptions[@options.paramName] = params

    @$dataRemote.data 'params', $.param paramsOptions

  ifClicked: (e) =>
    @$bodyCheckbox.iCheck if e.currentTarget.checked then 'uncheck' else 'check'
    if @options.paramName == "order_details"
      do @setParamsForOrder
    else
      do @setParams

  ifChecked: =>
    if @options.paramName == "order_details"
      do @setParamsForOrder
    else
      do @setParams

  ifUnchecked: =>
    @$headCheckbox.iCheck 'uncheck'
    if @options.paramName == "order_details"
      do @setParamsForOrder
    else
      do @setParams
