/* make transparent PNGs work in IE6 */
$(function(){$('body').supersleight({shim: '/imgages/x.gif'})});

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

$(function() {
    $("#super-dangerous").submit(function() {
	var prompt = 'Are you sure you wish to permanently destroy all ' + $("#total_entries").text() + ' records ';
	prompt += 'matching the query \u201c' + $("#destroy_found_set_q").val() + '\u201d?';
	prompt += "\n\nThis functionality is EXTREMELY dangerous, and there is NO undo available.";
	if (confirm(prompt)) {
            $("#super-dangerous input[type='submit']").attr("value", "Please wait\u2026").attr("disabled", true);
            return true;
	} else {
            return false;
	}
    });
    /* default to disabling the button, so it can not be clicked without JS */
    $("#super-dangerous input:disabled").removeAttr("disabled");

    $('#thumbnail_form').submit(function() {
	$("input[type='submit']").attr({"disabled": true, "value": "Uploading\u2026"});
	return true;
    });

    $('a.popmeup').click(function() {
	window.open(
	    $(this).attr("href"),
	    "pbcorePopup",
	    "height=600,width=700/inv,channelmode=0,dependent=0," +
		"directories=0,fullscreen=0,location=0,menubar=0," +
		"resizable=0,scrollbars=1,status=1,toolbar=0"
	);
	return false;
    });

    var mkshower = function(flag) {
	return function() {
	    var $this = $(this);
	    var tracks = $this.parent().next("table.tracks");

	    tracks.toggle(flag);
	    if (flag)
		tracks.highlight("slow");
	    $this.find(".showhidelabel").text(flag ? "Hide" : "Show");
	    
	    return false;
	};
    };

    $('a.showtracks').toggle(mkshower(true), mkshower(false));
});
