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
    tmpl.find('.index').text @count++
    @$el.before tmpl
    if @count == 6
      $(".add-inspectiondate").hide()

    endMonthSelected = $('#product_end_date_2i').val()
    monthSelect = tmpl.find('.offer-date').find('#product_inspection_date_attributes__date_2i')
    monthSelect.html ''
    monthNames = [
      'January'
      'February'
      'March'
      'April'
      'May'
      'June'
      'July'
      'August'
      'September'
      'October'
      'November'
      'December'
    ]
    j = 0
    while j < endMonthSelected - 1
      monthSelect.append '<option value="' + j + '">' + monthNames[j] + '</option>'
      j++
    return

  removeInspectionDate: ->
    li = $(@).closest 'li'

    if li.find('[type=checkbox]').length > 0
      li.find('[type=checkbox]').attr 'checked', true
      li.wrap '<div class="hide"></div>'
    else
      li.remove()
