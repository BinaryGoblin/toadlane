App.registerBehavior 'AddAddressBlock'

class Behavior.AddAddressBlock
  constructor: ($el) ->
    @$el = $el
    $row = $el.closest('.address-block')
    $ul = $el.closest 'ul'
    @count = $ul.find('> li').length
    @$template = $ document.getElementById('template-addressblock').innerHTML
    $el.click (event) => 
      event.preventDefault()
      @addNewAddressBlock()

  addNewAddressBlock: ->
    tmpl = @$template.clone()
    tmpl.find('h4').text("Address #"+ @count++)
    @$el.before tmpl

    if @count == 7
      $(".add-address-button").hide()
    

