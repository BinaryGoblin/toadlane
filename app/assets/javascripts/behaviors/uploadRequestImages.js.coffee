App.registerBehavior 'UploadRequestImages'

class Behavior.UploadRequestImages
  constructor: ($el) ->
    @$el = $el
    @options = $el.data 'options'
    @count = $el.find('.item').length
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
    @count = @$el.find('.item').length
    $html = $ $(@options.template)[0].innerHTML
    tmpl = $html.clone()
    first_name_string = 'product[request_attributes][request_images_attributes]['
    last_name_string = '][image]'
    first_id_string = 'product_request_attributes_request_images_attributes_'
    last_id_string = '_image'
    name = first_name_string + @count + last_name_string
    id = first_id_string + @count + last_id_string
    input = tmpl.find('[type=file]')
    input.attr('name', name)
    input.attr('id', id)
    @$el.append tmpl
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
    item.find('.item_ds').attr 'value', true
    if @$el.find('.item').length is 0 then do @$el.hide else do @$el.show
