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
    common_string = 'product[pricebreaks_attributes]['
    price = common_string + @count + '][price]'
    quantity = common_string + @count+ '][quantity]'
    tmpl.find("label:contains('Price')").next().attr('name', price)
    tmpl.find("label:contains('Quantity')").next().attr('name', quantity)
    tmpl.find('.index').text @count++
    @$el.before tmpl

  removePrice: ->
    li = $(@).closest 'li'
    index = $(this).data('index')
    id = '#product_pricebreaks_attributes_' + index + '_id'
    if $(id).length > 0
      li.find('[type=hidden]').attr 'value', true
      li.wrap '<div class="hide"></div>'
    else
      li.remove()