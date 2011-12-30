function remove_fields(link) {
  $(link).parent("fieldset").find("input[type=hidden]").val("1");
  $(link).closest("fieldset").hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).parent().before(content.replace(regexp, new_id));
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
   });

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
      var tracks = $this.parent().next(".tracks");

      tracks.toggle(flag);
      if (flag)
        tracks.highlight("slow");
        
      $this.find(".showhidelabel").text(flag ? "Hide" : "Show");

      return false;
    };
  };

  $('a.showtracks').toggle(mkshower(true), mkshower(false));
});

$(function() {
  var $submit;
  $("#asset_history input").bind("click change", function() {
    $submit = $submit || $("#diff_submit");

    $submit.attr("disabled", $("#asset_history input:checked").length !== 2);
  });
});

$(function() {
  $("#chooseFields").click(function() {
    $(this).closest("tr").remove();
    $("#fieldChooser").show();
    return false;
  });

  $("#all_fields_box").change(function() {
    $(".search_field_box").attr('checked', false);
    $(this).attr('checked', true);
  });
  $(".search_field_box").change(function() {
    $("#all_fields_box").attr('checked', $(".search_field_box:checked").length === 0);
  });
});

function create_autocomplete (obj) {
  obj.autocomplete({
    source: obj.data("autocomplete-source"),
    minLength: 2
  });
}


function autocomplete_source_for_format_type(type) {
  switch(type) {
    case "FormatDigital":
      return "/format_digitals"
      break;
    case "FormatPhysical":
      return "/format_physicals"
      break;
  }
}

// Autocomplete for Edit Form
$(function() { 
  $(".pbcore-autocomplete").live("keydown.autocomplete", function() {
    if (!$(this).hasClass('ui-autocomplete-input')) {
      create_autocomplete($(this));
    }
  });
 
  $(".pbcore-combobox-button").live("click", function() {
    var textField = $(this).prev();
    if (!textField.hasClass('ui-autocomplete-input')) {
      create_autocomplete(textField);
    }
    
    if (textField.autocomplete("widget").is(":visible")) {
      textField.autocomplete("close");
    } else {
      var minLength = textField.autocomplete('option', 'minLength');
      textField.autocomplete('option', 'minLength', 0);
      textField.autocomplete('search', '');
      textField.autocomplete('option', 'minLength', minLength);
    }
  });
 
  $("#asset_subject_tokens").tokenInput("/subjects.json", {
    crossDomain: false,
    prePopulate: $(this).data("pre")
  });
  
  $("#asset_genre_tokens").tokenInput("/genres.json", {
    crossDomain: false,
    prePopulate: $(this).data("pre")
  });
  
  $("#instantiation_language_tokens, input.language-tokens").tokenInput("/languages.json", {
    crossDomain: false,
    prePopulate: $(this).data("pre")
  });
  
  $("#instantiation_instantiation_generation_tokens").tokenInput("/instantiation_generations.json", {
    crossDomain: false,
    prePopulate: $(this).data("pre")
  });
  
  $("input[name='instantiation[format_type]']").change(function() {
    var autocomplete_source = autocomplete_source_for_format_type($(this).attr('value'));
    $("#instantiation_format_name").attr('value', '');
    $("#instantiation_format_name").autocomplete({ source: autocomplete_source });
    $("#instantiation_format_name").attr("data-autocomplete-source", autocomplete_source);
  });
});
