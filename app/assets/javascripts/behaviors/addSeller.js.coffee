App.registerBehavior 'AddSeller'

class Behavior.AddSeller
  constructor: ($el) ->
    @$el = $el
    $ul = $el.closest 'ul'
    @count = $ul.find('> li').length
    @$template = $ document.getElementById('template-addseller').innerHTML    
    $ul.on 'click', '.remove', @removePrice
    $el.click => @addNewSeller()

  addNewSeller: ->
    product_retail_price = parseFloat($('#product_unit_price').val())
    added_additional_sellers = $('ul.sellergroups').find('li.sellergroup .set-commission-text-box')
    added_fee = 0

    jQuery.each added_additional_sellers, (i, val) ->
      added_fee = added_fee + parseFloat(val.value)
      return

    if added_fee > product_retail_price
      $('form.product_form_partial').find('input[type=submit]').prop 'disabled', true
      $('.additional-seller-fee-exceeded-error').html("The additional seller fee exceeds the product's price.")
    else if added_fee < product_retail_price
      $('form.product_form_partial').find('input[type=submit]').prop 'disabled', false
      $('.additional-seller-fee-exceeded-error').html("")
      tmpl = @$template.clone()
      tmpl.find('.index').text @count++
      @$el.before tmpl
      $('.chosen-select').chosen
        allow_single_deselect: true
        no_results_text: 'No results matched'
        width: '200px'
      $('.chosen-select').trigger 'chosen:updated'
    
  removePrice: ->
    li = $(@).closest 'li'

    if li.find('[type=checkbox]').length > 0
      li.find('[type=checkbox]').attr 'checked', true
      li.wrap '<div class="hide"></div>'
    else
      li.remove()