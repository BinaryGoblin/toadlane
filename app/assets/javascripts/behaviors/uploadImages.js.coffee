App.registerBehavior 'UploadImages'

class Behavior.UploadImages
  constructor: ($el) ->
    @$el = $el
    @options = $el.data 'options'

    $(@options.btnAdd).on 'click', => do @addItem

    changeFile = @changeFile
    $el.on 'change', '.new [type=file]', -> changeFile @

    deleteFile = @deleteFile
    $el.on 'click', @options.deleteImage, -> deleteFile @

  setupReader: (file, callback) =>
    reader = new FileReader()
    reader.readAsDataURL file
    reader.onload = callback

  addItem: =>
    $html = $ $(@options.template)[0].innerHTML
    @$el.append $html.clone()
    do @$el.show if @$el.find('.item').length > 0

  changeFile: (input) =>
    if input.files && input.files[0]
      @setupReader input.files[0], (e) ->
        $image = $ '<div class="image-tag"></div>'
        $image.css 'background-image', 'url(' + e.currentTarget.result + ')'
        $(input).closest('.new').removeClass('new').find('.photo').prepend $image
    
  deleteFile: (_this) =>
    item = $(_this).closest('.item').removeClass('item').hide()
    item.find('[type=file]').remove()
    item.find('[type=checkbox]').attr 'checked', true
    if @$el.find('.item').length is 0 then do @$el.hide else do @$el.show
