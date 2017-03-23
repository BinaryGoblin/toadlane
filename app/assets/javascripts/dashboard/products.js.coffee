$(document).ready ->
  convertDateTime = (value) ->
    dateTime = value.split(' ')
    date = dateTime[0].split('-')
    yyyy = date[0]
    mm = date[1] - 1
    dd = date[2]
    time = dateTime[1].split(':')
    h = time[0]
    m = time[1]
    s = parseInt(time[2])

    new Date(yyyy, mm, dd, h, m, s)

  sell_starting_date = new Date
  sell_starting_date.setHours(0,0,0,0)
  sell_starting_date.setDate sell_starting_date.getDate()
  date_format = 'YYYY-MM-DD hh:mm a'

  if($('.product_edit').length > 0)
    sell_starting_date = convertDateTime($('#product_start_date').val())
  $('#product_start_date, #start-date').datetimepicker
    minDate: sell_starting_date
    useCurrent: false
    format: date_format
  $('#product_end_date, #end-date').datetimepicker
    useCurrent: false
    minDate: sell_starting_date
    format: date_format
  $('#start-date').on 'dp.change', (e) ->
    $('#end-date').data('DateTimePicker').minDate e.date
    return
  $('#end-date').on 'dp.change', (e) ->
    $('#start-date').data('DateTimePicker').maxDate e.date
    return

  $('body').on 'click', '.inspection-date', ->
    $(this).datetimepicker({
      minDate: sell_starting_date
      useCurrent: false
      format: date_format
    }).focus();
    return