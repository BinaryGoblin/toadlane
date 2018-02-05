#= require jquery
#= require jquery_ujs

#= require ./plugins/jquery.validate
#= require_tree ./plugins

#= require elemental

#= require_tree ./initializers/
#= require_tree ./helpers/
#= require_tree ./behaviors/
#= require_tree ./admin/
#= require_tree ./dashboard/

#= require bootstrap
#= require moment
#= require bootstrap-datetimepicker

$(document).ready ->
  Elemental.addNamespace App
  Elemental.load document

  jQuery.validator.addMethod 'filesize', ((value, element, param) ->
    mult_param = param * 1048576
    @optional(element) or (element.files[0].size <= mult_param)
  ), 'File size must be less than {0} MB'

  $('form.product_form_partial').validate
    rules:
      "product[videos_attributes][]":
        required: false
        filesize: 5
