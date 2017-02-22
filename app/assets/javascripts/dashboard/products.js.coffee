$(document).ready ->
  starting_date = new Date
  starting_date.setHours(0,0,0,0);
  starting_date.setDate starting_date.getDate() + 1
  $('#product_start_date, #start-date').datetimepicker
    minDate: starting_date
    format: 'YYYY-MM-DD hh:mm'
  $('#product_end_date, #end-date').datetimepicker
    useCurrent: false
    minDate: starting_date
    format: 'YYYY-MM-DD hh:mm'
  $('#start-date').on 'dp.change', (e) ->
    $('#end-date').data('DateTimePicker').minDate e.date
    return
  $('#end-date').on 'dp.change', (e) ->
    $('#start-date').data('DateTimePicker').maxDate e.date
    return