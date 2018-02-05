App.registerBehavior 'CategoryProducts'

class Behavior.CategoryProducts
  constructor: ($el) ->
    @$el = $el
    @options = $el.data 'options'

    @$categories = $ @options.categories

    do @selectedCategory

    @$categories.on 'selectmenuchange', => do @selectedCategory

  selectedCategory: =>
    categoryId = @$categories.find(':selected').val()
    @syncProducts categoryId

  syncProducts: (id) =>
    $.ajax
      url: @options.remoteUrl
      type: 'POST'
      data: category: id: id
      dataType: 'json'

    .done @success

  success: (data) =>
    products = data.products_html

    html = ''

    for product, i in products
      if i % 4 is 0
        item = $ '<div class="item"></div>'

      item.addClass 'active' if i is 0
      item.append product

      if i % 4 is 3 or i is products.length - 1
        html += item[0].outerHTML

    @$el.find('.carousel-inner').html html

    App.SliderRates $ '.rates'
