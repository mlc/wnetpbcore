/*
 * JavaScript PBCore Editor!
 */
var FormEditor = (function($) {
  $(function() {
    if ((FormEditor.objid = $("#edit_id").text()))
      FormEditor.load();
  });
                    
  var xml, picklists;
  var field_counter = 0;
  var made_form = false;

  // enum pattern http://is.gd/dlQFY
  var Style = function(name) {
    this._name = name;
  };
  Style.prototype.toString = function() {
    return this._name;
  };
  Style.PLAIN = new Style('plain');
  Style.TEXTAREA = new Style('textarea');
  Style.VERBOSE = new Style('verbose');
  Style.SIMPLE = new Style('simple');
  Style.ONLY_TEXTAREA = new Style("only texarea");

  var safe_log = function(obj) {
    if (console !== undefined && (typeof console.log === 'function'))
      console.log(obj);
  };
                    
  var makecombo = function(box) {
    $("<button>", {
      "text": '\u00a0',
      "type": "button",
      "tabIndex": -1,
      "title": "Show Options"
    }).insertAfter(box).button({
      icons: { primary: "ui-icon-triangle-1-s" },
      text: false
    }).removeClass("ui-corner-all")
    .addClass("ui-corner-right ui-button-icon")
    .click(function() {
      if (box.autocomplete("widget").is(":visible")) {
        box.autocomplete("close");
      } else {
        box.autocomplete("search", "");
        box.focus();
      }
      return false;
    });    
  };
 
  var mkfields = function(div, pbcore, callback) {
    var $div = $("#" + div);
    xml.find(pbcore).each(function(i) {
      callback($div, this, i);
    });
    $div.after($("<p>").append($("<a>", {
      "href": "#",
      "text": "Add another\u2026",
      "class": "adder",
      "click": function() {
        callback($div);
        return false;
      }
    })));
  };

  var mkboxes = function(div, pbcore, field) {
    var $div = $("#" + div);
    var picklist = picklists[field.capitalize()];
    var i, len = picklist.length;

    var makebox = function(text) {
      var span = $("<span>", {
        css: { 'white-space': 'nowrap' }
      });
      ++field_counter;
      var input = $("<input>", {
        "id": "box_" + field_counter,
        "name": field,
        "type": 'checkbox',
        "value": text
      });
      span.append(input).append(' ')
      .append($("<label>", {
        "for": "box_" + field_counter,
        "text": text
      }));
      $div.append(span).append(' \u00a0\u00a0 ');
      return input;
    };

    for(i = 0; i < len; ++i) {
      makebox(picklist[i]);
    }
    xml.find(pbcore + " " + field).each(function() {
      var text = $(this).text();
      var input = $div.find("input[value='" + text + "']");
      if (input.length == 0) {
        input = makebox(text);
      }
      input.attr("checked", true);
    });
  };

  var pbcore_maker = function(field, picklistfield, style, locked) {
    return function(where, obj) {
      safe_log(obj);
      var label, formfield, remove, box, boxlabel;
      style = style || Style.PLAIN;
      var textarea = (style == Style.TEXTAREA || style == Style.ONLY_TEXTAREA);
      var required = false; /* for now */
      var ret = $("<div>", {"class": "form_field_container " + field});

      if (field) {
        ++field_counter;
        label = $("<label>", {
          "text": field.capitalize().addspaces() + ":",
          "for": "input_" + field_counter
        });
        var args = {
          "class": required ? "required" : '',
          "id": "input_" + field_counter,
          "name": field
        };
        if (textarea) {
          args.cols = 80;
          args.rows = 5;
        } else {
          args.size = 30;
          args.type = "text";
        }
        args[textarea ? "text" : "value"] = $(obj).find(field).text();
        formfield = $(textarea ? "<textarea>" : "<input>", args);
      }
      if (picklistfield) {
        box = $("<input>", {
          "id": "combobox_" + (++field_counter),
          "name": picklistfield,
          "value": $(obj).find(picklistfield).text(),
          "size": (style == Style.VERBOSE ? 15 : 25),
          "readonly": locked
        });
        box.autocomplete({
          "source": picklists[picklistfield.capitalize()],
          "minLength": 0
        });
      }
      remove = $("<a>", {
        "href": "#",
        "text": "remove",
        "click": function() {
          ret.remove();
          return false;
        }
      });
      if (style == Style.VERBOSE) {
        boxlabel = $("<label>", {
          "text": picklistfield.capitalize().addspaces() + ":",
          "for": "combobox_" + field_counter
        });        
      }
      
      switch(style) {
      case Style.PLAIN:
        ret.append(label).append(' ').append(formfield).append(' ').append(box).append(' ').append(remove);
        break;
      case Style.TEXTAREA:
        ret.append(label).append(' ').append(box).append(' ').append(remove).append(' ').append(formfield);
        break;
      case Style.VERBOSE:
        ret.append(boxlabel).append(' ').append(box).append(' ').append(label).append(' ').append(formfield).append(' ').append(remove);
        break;
      case Style.SIMPLE:
        ret.append(box).append(' ').append(remove);
        break;
      case Style.ONLY_TEXTAREA:
        ret.append(label).append(' ').append(remove).append(' ').append(formfield);
        break;
      default:
        safe_log("warning! unexpected style!");
        safe_log(style);
      }

      if (box)
        makecombo(box);
      
      where.append(ret);
    };
  };
                    
  return {
    "objid": null,
    "load": function() {
      made_form = false;
      $.ajax({
        "url": "/assets/picklists.json",
        "dataType": "json",
        "type": "GET",
        "success": function(data, textStatus, xhr) {
          picklists = data;
          safe_log("got picklists!");
          if (xml)
            FormEditor.create_form();
        }
      });
      $.ajax({
        "url": "/assets/" + FormEditor.objid + ".xml",
        "dataType": "xml",
        "type": "GET",
        "success": function(data, textStatus, xhr) {
          xml = $(data);
          safe_log("got data!");
          if (picklists)
            FormEditor.create_form();
        }
      });
    },
    "getxml": function() {
       return xml;
    },
    "create_form": function() {
      if (made_form)
        return;

      made_form = true;
      mkfields("identifiers", "pbcoreIdentifier", pbcore_maker("identifier", "identifierSource"));
      mkfields("titles", "pbcoreTitle", pbcore_maker("title", "titleType"));
      mkfields("subjects", "pbcoreSubject", pbcore_maker(null, "subject", Style.SIMPLE));
      mkfields("descriptions", "pbcoreDescription", pbcore_maker("description", "descriptionType", Style.TEXTAREA));
      mkfields("genres", "pbcoreGenre", pbcore_maker(null, "genre", Style.SIMPLE));
      mkfields("relations", "pbcoreRelation", pbcore_maker("relationIdentifier", "relationType", Style.VERBOSE));
      mkfields("coverages", "pbcoreCoverage", pbcore_maker("coverage", "coverageType", Style.VERBOSE, true));
      mkboxes("audience_levels", 'pbcoreAudienceLevel', 'audienceLevel');
      mkboxes("audience_ratings", 'pbcoreAudienceRating', 'audienceRating');
      mkfields("creators", "pbcoreCreator", pbcore_maker("creator", "creatorRole", Style.VERBOSE));
      mkfields("contributors", "pbcoreContributor", pbcore_maker("contributor", "contributorRole", Style.VERBOSE));
      mkfields("publishers", "pbcorePublisher", pbcore_maker("publisher", "publisherRole", Style.VERBOSE));
      mkfields("rights_summaries", "pbcoreRightsSummary", pbcore_maker("rightsSummary", undefined, Style.ONLY_TEXTAREA));
    }
  };
})(jQuery);

