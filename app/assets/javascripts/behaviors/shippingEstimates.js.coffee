App.registerBehavior 'ShippingEstimates'

class Behavior.ShippingEstimates
  constructor: ($el) ->
    @$el = $el
    $ul = $el.closest 'ul'
    @count = $ul.find('> li').length
    @$template = $ document.getElementById('template-shippingestimate').innerHTML    
    $ul.on 'click', '.remove', @removeShippingEstimate
    $el.click => @addShippingEstimate()

  addShippingEstimate: ->
    tmpl = @$template.clone()
    tmpl.find('.cost').attr('name', "product[shipping_estimates_attributes][" + (@count - 1) + "][cost]")
    tmpl.find('.cost').attr('id', "product_shipping_estimates_attributes_" + (@count - 1) + "_cost")
    tmpl.find('.description').attr('name', "product[shipping_estimates_attributes][" + (@count - 1) + "][description]")
    tmpl.find('.description').attr('id', "product_shipping_estimates_attributes_" + (@count - 1) + "_description")
    tmpl.find('.delete').attr('name', "product[shipping_estimates_attributes][" + (@count - 1) + "][_destroy]")
    tmpl.find('.delete').attr('name', "product_shipping_estimates_attributes_" + (@count - 1) + "__destroy")    
    tmpl.find('.index').text @count++
    @$el.before tmpl
    
  removeShippingEstimate: ->
    li = $(@).closest 'li'
    field = li.find('.delete')
    
    if field.attr('value') is "true"
      field.attr('value', false)
      li.removeClass('estimate-delete')
      li.addClass('estimate')
    else
      field.attr('value', true)
      li.removeClass('estimate')
      li.addClass('estimate-delete')