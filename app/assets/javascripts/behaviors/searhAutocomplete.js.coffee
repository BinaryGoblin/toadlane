App.registerBehavior 'SearhAutocomplete'

class Behavior.SearhAutocomplete
  constructor: ($el) ->
    $form = $el.closest 'form'
    $button = $form.find '[type=submit]'
    $searchType = $form.find '[name=type]'

    searchType = $searchType.val()

    search = new Bloodhound
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name')
      queryTokenizer: Bloodhound.tokenizers.whitespace
      limit: 8
      remote: 
        url: '/search/autocomplete'
        replace: (url, query) -> url + '?query=' + query + '&type=' + searchType

    search.initialize()
 
    $el.typeahead { hint: true, minLength: 1 }, {
      name: 'search',
      displayKey: 'name',
      source: search.ttAdapter()
      templates:
        empty: '<div class="empty">No products</div>'
        suggestion: (data) ->
          '<p>' +
            '<span class="pull-right">$' + data.unit_price + ',00/Unit</span>' +
            '<b>' + data.name + ' <small>' + data.category + '</small></b>' +
          '</p>'
    }

    $el.on 'change keyup', (e) -> $button.attr 'disabled', $(@).val() isnt ''

    $el.on 'typeahead:selected', (e, data) ->
      select = $form.find 'select'
      select.val data.cat_id
      select.selectmenu 'refresh'
      do $form.submit

    $searchType.on 'change', -> searchType = @.value
