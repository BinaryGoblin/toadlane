#= require jquery
#= require jquery_ujs

#= require ./plugins/jquery.validate
#= require_tree ./plugins

#= require elemental

#= require_tree ./initializers/
#= require_tree ./helpers/
#= require_tree ./behaviors/
#= require_tree ./admin/

#= require bootstrap

$(document).ready ->
  Elemental.addNamespace App
  Elemental.load document
