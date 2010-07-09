if (!String.prototype.capitalize) {
  String.prototype.capitalize = function() {
    switch(this.length) {
    case 0:
      return this;
    case 1:
      return this.toUpperCase();
    default:
      return this.slice(0,1).toUpperCase() + this.slice(1);
    }
  };
}

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
  var STYLE_PLAIN = 0,
    STYLE_TEXTAREA = 1,
    STYLE_VERBOSE = 2,
    STYLE_SIMPLE = 3;
                    
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

  var simple_maker = function(field, picklistfield, style, locked) {
    return function(where, obj) {
      safe_log(obj);
      var label, formfield, remove, box, boxlabel;
      style = style || STYLE_PLAIN;
      var textarea = (style == STYLE_TEXTAREA);
      var required = false; /* for now */
      var ret = $("<div>", {"class": "form_field_container " + field});

      if (field) {
        ++field_counter;
        label = $("<label>", {
          "text": field.capitalize() + ":",
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
          "size": (style == STYLE_VERBOSE ? 15 : 25),
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
      if (style == STYLE_VERBOSE) {
        boxlabel = $("<label>", {
          "text": picklistfield.capitalize() + ":",
          "for": "combobox_" + field_counter
        });        
      }
      
      switch(style) {
      case STYLE_PLAIN:
        ret.append(label).append(' ').append(formfield).append(' ').append(box).append(' ').append(remove);
        break;
      case STYLE_TEXTAREA:
        ret.append(label).append(' ').append(box).append(' ').append(remove).append(' ').append(formfield);
        break;
      case STYLE_VERBOSE:
        ret.append(boxlabel).append(' ').append(box).append(' ').append(label).append(' ').append(formfield).append(' ').append(remove);
        break;
      case STYLE_SIMPLE:
        ret.append(box).append(' ').append(remove);
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
      mkfields("identifiers", "pbcoreIdentifier", simple_maker("identifier", "identifierSource"));
      mkfields("titles", "pbcoreTitle", simple_maker("title", "titleType"));
      mkfields("subjects", "pbcoreSubject", simple_maker(null, "subject", STYLE_SIMPLE));
      mkfields("descriptions", "pbcoreDescription", simple_maker("description", "descriptionType", STYLE_TEXTAREA));
      mkfields("genres", "pbcoreGenre", simple_maker(null, "genre", STYLE_SIMPLE));
      mkfields("relations", "pbcoreRelation", simple_maker("relationIdentifier", "relationType", STYLE_VERBOSE));
      mkfields("coverages", "pbcoreCoverage", simple_maker("coverage", "coverageType", STYLE_VERBOSE, true));
    }
  };
})(jQuery);

