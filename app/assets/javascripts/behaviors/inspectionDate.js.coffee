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

    endYearSelected = $('#product_end_date_1i').val()
    startYearSelected = $('#product_start_date_1i').val()

    yearSelectBox = tmpl.find('select#product_inspection_date_attributes__date_1i')

    yearSelectBox.html ''

    start_year = parseInt(startYearSelected)
    end_year = parseInt(endYearSelected)

    while start_year <= end_year
      yearSelectBox.append '<option value="' + start_year + '">' + start_year + '</option>'
      start_year++
    yearSelectBox.val
    return

    tmpl.find('select#product_inspection_date_attributes__date_1i').change ->
      month_select_box = tmpl.find('select#product_inspection_date_attributes__date_2i')[0]

      $(month_select_box).each ->
        # inspection_date_value = $('#product_hidden_field_name').val()
        # inspection_date_array = inspection_date_value.split("-")
        # selectedYear = inspection_date_array[0]
        # selectedMonth = inspection_date_array[1]
        # selectedDay = inspection_date_array[2]
        monthSelectBox = $(this)

        endMonthSelected = $('#product_end_date_2i').val()
        endYearSelected = $('#product_end_date_1i').val()

        yearSelectBox = $(this).siblings('select#product_inspection_date_attributes__date_1i')

        monthSelectBox.html ''
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
        if yearSelectBox.val() == endYearSelected
          while j < parseInt(endMonthSelected) - 1
            month_count = j + 1
            monthSelectBox.append '<option value="' + month_count + '">' + monthNames[j] + '</option>'
            j++
          monthSelectBox.val(0)
          if monthSelectBox.val() == null
            monthSelectBox.val(0)
          return
        else
          while j < 12
            month_count = j + 1
            monthSelectBox.append '<option value="' + month_count + '">' + monthNames[j] + '</option>'
            j++
          if monthSelectBox.val() == null
            monthSelectBox.val(0)
          return
      return

    # endMonthSelected = $('#product_end_date_2i').val()
    # monthSelect = tmpl.find('.offer-date').find('#product_inspection_date_attributes__date_2i')
    # monthSelect.html ''
    # monthNames = [
    #   'January'
    #   'February'
    #   'March'
    #   'April'
    #   'May'
    #   'June'
    #   'July'
    #   'August'
    #   'September'
    #   'October'
    #   'November'
    #   'December'
    # ]
    # j = 0
    # while j < endMonthSelected - 1
    #   monthSelect.append '<option value="' + j + '">' + monthNames[j] + '</option>'
    #   j++
    # return

  removeInspectionDate: ->
    li = $(@).closest 'li'

    if li.find('[type=checkbox]').length > 0
      li.find('[type=checkbox]').attr 'checked', true
      li.wrap '<div class="hide"></div>'
    else
      li.remove()
