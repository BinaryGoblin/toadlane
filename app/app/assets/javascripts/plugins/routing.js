$.validator.addMethod('routing', function(value, element) {
  if (this.optional(element)) {
    return true;
  }

  $(element).removeClass('spinner');

  if (!(/^\d{9}$/.test(value))) {
    return false;
  }

  $(element).addClass('spinner');

  $.ajax({
    url: 'http://www.routingnumbers.info/api/name.json?rn=' + element.value,
    dataType: 'jsonp'
  })
  .done(function(data) {
    if(data.code == 404) {
      element.value = element.value + ' '
      $(element).trigger('blur').select()
    }

    $(element).removeClass('spinner');
  });

  return true;

}, 'Please specify a valid Routing number');
