#= require jquery
#= require jquery_ujs
#= require jquery-ui/slider
#= require jquery-ui/selectmenu
#= require jquery-ui/tooltip
#= require jquery-ui/autocomplete

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
  $(".fe-toggle").tooltip({tooltipClass: "search-tooltip"})
  $("#user_state").autocomplete({
    source: ["Alabama",
    "Alaska",
    "American Samoa",
    "Arizona",
    "Arkansas",
    "California",
    "Colorado",
    "Connecticut",
    "Delaware",
    "District of Columbia",
    "Florida",
    "Georgia",
    "Hawaii",
    "Idaho",
    "Illinois",
    "Indiana",
    "Iowa",
    "Kansas",
    "Kentucky",
    "Louisiana",
    "Maine",
    "Maryland",
    "Massachusetts",
    "Michigan",
    "Minnesota",
    "Mississipi",
    "Missouri",
    "Montana",
    "Nebraska",
    "Nevada",
    "New Hampshire",
    "New Jersey",
    "New Mexico",
    "New York",
    "North Carolina",
    "North Dakota",
    "Ohio",
    "Oklahoma",
    "Oregon",
    "Pennsylvania",
    "Rhode Island",
    "South Carolina",
    "South Dakota",
    "Tennessee",
    "Texas",
    "Utah",
    "Vermont",
    "Virginia",
    "Washington",
    "West Virginia",
    "Wisconsin",
    "Wyoming"
    ],
    autocomplete: true
  });
