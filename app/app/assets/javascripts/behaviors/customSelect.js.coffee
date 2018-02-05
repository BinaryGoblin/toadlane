App.registerBehavior 'CustomSelect'

class Behavior.CustomSelect
  constructor: ($el) ->
    $el.selectmenu()
       .selectmenu 'menuWidget'
       .addClass $el.attr 'class'

    @selectQuery = $el.data 'selectQuery'

    if @selectQuery
      $el.on 'selectmenuchange', (e, ui) => @setQuery e, ui

  setQuery: (e, ui) =>
    url = window.location.search
    reg = new RegExp @selectQuery + '=.*?(&|$)', 'i'

    if url.match reg
      params = url.replace reg, @selectQuery + '=' + ui.item.value + '$1'
    else
      params = url + '&' + @selectQuery + '=' + ui.item.value

    window.location.search = params
