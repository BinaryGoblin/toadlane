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