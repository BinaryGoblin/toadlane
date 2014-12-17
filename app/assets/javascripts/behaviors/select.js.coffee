App.registerBehavior 'Select'

class Behavior.Select
  constructor: ($el) ->
    defaultOptions = sortField: 'text'

    @options = $.extend {}, defaultOptions, $el.data 'options'

    if $el.data 'subcategory'
      @subCategory = @initSubCategory $el.data 'subcategory'
      @options.onInitialize = => @sync $el.find(':selected').val()
      @options.onChange = (id) => @sync id, true

    $el.selectize @options

  sync: (id, change=false) =>
    return unless id > 0

    @subCategory.clearOptions() if change

    @subCategory.load (callback) ->
      xhr && xhr.abort()
      xhr = $.ajax
        url: '/categories/' + id + '/sub_categories',
        success: (results) -> 
          callback results.sub_categories
        error: -> 
          callback()

  initSubCategory: (subcat) ->
    $subCategory = $(subcat).selectize
      plugins: ['remove_button']
      valueField: 'id'
      labelField: 'name'
      searchField: ['name']

    $subCategory[0].selectize
