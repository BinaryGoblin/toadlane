App.registerBehavior 'InspectionDate'

class Behavior.InspectionDate
  constructor: ($el) ->
    @$el = $el
    $ul = $el.closest 'ul'
    @count = $ul.find('> li').length
    @$template = $ document.getElementById('template-inspectiondate').innerHTML
    $ul.on 'click', '.remove', @removeInspectionDate
    $el.click => @addNewInspectionDate()


  addNewInspectionDate: ->
    tmpl = @$template.clone()
    common_string = 'product[inspection_dates_attributes]['
    date = common_string + @count + '][date]'
    tmpl.find('.inspection-date').attr('name', date)
    tmpl.find('.index').text @count++
    @$el.before tmpl
    if @count == 6
      $(".add-inspectiondate").hide()

  removeInspectionDate: ->
    li = $(@).closest 'li'

    if li.find('[type=checkbox]').length > 0
      li.find('[type=checkbox]').attr 'checked', true
      li.find('[type=hidden]').attr 'value', true
      li.wrap '<div class="hide"></div>'
    else
      li.remove()
