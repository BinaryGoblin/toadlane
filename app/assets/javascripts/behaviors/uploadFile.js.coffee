App.registerBehavior 'UploadFile'

class Behavior.UploadFile
  constructor: ($el) ->
    @$el = $el
    @options = $el.data 'options'

    @inputFile = $el.find '[type=file]'
    @inputText = $el.find '[type=text]'
    @inputCheckbox = $el.find '[type=checkbox]'

    $(@options.deleteBtn).on 'click', => do @deleteFile

    change = @change
    @inputFile.on 'change', -> change @

  change: (input) =>
    @inputText.val input.files[0].name
    @inputCheckbox.attr 'checked', false

  deleteFile: =>
    @inputText.val ''
    @inputCheckbox.attr 'checked', true
