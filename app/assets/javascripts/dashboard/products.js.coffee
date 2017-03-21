$(document).ready ->
  sell_starting_date = new Date
  sell_starting_date.setHours(0,0,0,0)
  sell_starting_date.setDate sell_starting_date.getDate()
  date_format = 'YYYY-MM-DD hh:mm a'

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