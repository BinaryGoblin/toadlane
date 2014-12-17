App.registerBehavior 'UploadImage'

class Behavior.UploadImage
  constructor: ($el) ->
    @$el = $el
    @options = $el.data 'options'

    readURL = @readURL
    $el.on 'change', -> readURL @

    $(@options.deleteBtn).on 'click', => do @deleteImage

  readURL: (input) =>
    @setupReader input.files[0] if input.files && input.files[0]

  setupReader: (file) =>
    $tmpl = $('<div class="image-tag"></div>')

    $(@options.conteiner).siblings('[type=checkbox]').remove()

    reader = new FileReader()

    reader.onload = (e) =>
      $(@options.conteiner).html $tmpl.css('background-image', 'url(' + e.target.result + ')')

    reader.readAsDataURL file

  deleteImage: =>
    $checkbox = $ '<input type="checkbox" name="user[delete_asset]" checked="checked" class="hide">'

    $(@options.conteiner).after($checkbox).find('.image-tag').remove()

    @$el.val ''
