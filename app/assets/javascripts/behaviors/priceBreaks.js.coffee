App.registerBehavior 'PriceBreaks'

class Behavior.PriceBreaks
  constructor: ($el) ->
    @$el = $el
    $ul = $el.closest 'ul'
    @count = $ul.find('> li').length
    @$template = $ document.getElementById('template-pricebreak').innerHTML    
    $ul.on 'click', '.remove', @removePrice
    $el.click => @addNewPrice()

  addNewPrice: ->
    tmpl = @$template.clone()
    tmpl.find('.index').text @count++
    @$el.before tmpl
    
  removePrice: ->
    li = $(@).closest 'li'

    if li.find('[type=checkbox]').length > 0
      li.find('[type=checkbox]').attr 'checked', true
      li.wrap '<div class="hide"></div>'
    else
      li.remove()
