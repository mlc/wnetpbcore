// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function searchHelp() {
  window.open( 
    "/static/search_help",
    "searchHelp",
    "height=600,width=750/inv,channelmode=0,dependent=0," +
    "directories=0,fullscreen=0,location=0,menubar=0," +
    "resizable=0,scrollbars=1,status=1,toolbar=0"
  );
}

function checkMerge() {
  var count = $(".mergebox input:checked").length;
  if (count >= 2)
    $("#mergebutton").removeAttr("disabled");
  else
    $("#mergebutton").attr("disabled", "disabled");
}

function checkLend() {
  var count = $(".lendbox input:checked").length;
  if (count >= 1)
    $("#lendbutton").removeAttr("disabled");
  else
    $("#lendbutton").attr("disabled", "disabled");
}

function approveMerge() {
   var titles = $(".mergebox input:checked").parents('li').children('strong');
   var message = "Are you sure you wish to merge these records?\n";
   titles.each(function(i) {
       message += "\n * " + $(this).text();
   })

   return confirm(message);
}