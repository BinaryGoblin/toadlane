#= require jquery
#= require jquery_ujs
#= require jquery-ui/slider
#= require jquery-ui/selectmenu

#= require ./plugins/jquery.validate
#= require_tree ./plugins

#= require bootstrap/transition
#= require bootstrap/carousel
#= require bootstrap/modal

#= require elemental

#= require_tree ./initializers/
#= require_tree ./helpers/
#= require_tree ./behaviors/

$(document).ready ->
  Elemental.addNamespace App
  Elemental.load document
