App.registerBehavior 'AddSeller'

class Behavior.AddSeller
  constructor: ($el) ->
    @$el = $el
    $ul = $el.closest 'ul'
    @count = $ul.find('> li').length
    @$template = $ document.getElementById('template-addseller').innerHTML
    $ul.on 'click', '.remove', @setToDestroy
    $el.click => @addNewSeller()

  addNewSeller: ->
    if $('form.product_form_partial').length == 1
      product_retail_price = $('#product_unit_price').val()
      if product_retail_price == ""
        @addBlock()
      else
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
          @addBlock()
        else if added_fee == product_retail_price
          $('.additional-seller-fee-exceeded-error').html("The additional seller fee is equal to the product's price. Now you cannot add another additional seller.")

    else if $('form.product_form_partial').length == 0
      @addBlock()

  setToDestroy: ->
    li = $(@).closest 'li'
    id = '#product_group_attributes_group_sellers_attributes_' + $(@).data('index') + '_id'

    if $(id).length > 0
      li.find('[type=hidden]').attr 'value', true
      li.wrap '<div class="hide"></div>'
    else
      li.remove()

  addBlock: ->
    tmpl = @$template.clone()
    tmpl.find('.index').text @count++
    common_string = 'product[group_attributes][group_sellers_attributes]['
    group_sellers_name = common_string + @count + '][user_id]'
    additional_seller_fee_name = common_string + @count + '][fee]'
    tmpl.find('.select-seller-group > select').attr('name', group_sellers_name)
    tmpl.find('.set-commision > input').attr('name', additional_seller_fee_name)

    @$el.before tmpl
    $('.chosen-select').chosen
      allow_single_deselect: true
      no_results_text: 'No results matched'
      width: '200px'
    $('.chosen-select').trigger 'chosen:updated'