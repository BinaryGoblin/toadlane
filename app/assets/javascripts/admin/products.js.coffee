$ ->
  $('.status').on 'change', ->
    self = $ @
    url  = self.data 'url'
    val  = self.val()

    $.ajax
      url: url
      type: 'PUT'
      data: product: status_action: val
    .done ->
      self.closest('tr').find('.saved').removeClass('hide').delay(1000).fadeOut()
