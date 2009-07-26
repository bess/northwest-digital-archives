// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


// any div with class "below_appliedParams" gets a top margin == appliedParams.height()
// this is to allow the EAD navigation to appear next to the actual EAD content, instead of floating
// above it
$(document).ready(function() {
  // adds classes for zebra striping table rows
  var h = $("#appliedParams").height();
  $('div.below_appliedParams').attr("style","margin-top: " + h + "px");
});