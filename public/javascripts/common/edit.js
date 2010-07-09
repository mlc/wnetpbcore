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

var FormEditor = (function($) {
  $(function() {
    if ((FormEditor.objid = $("#edit_id").text()))
      FormEditor.load();
  });
                    
  var xml, picklists;
  var field_counter = 0;
  var made_form = false;
  var safe_log = function(obj) {
    if (console !== undefined && (typeof console.log === 'function'))
      console.log(obj);
  };
                    
  var cbi = function(box) {
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

  var simple_maker = function(field, required, picklistfield) {
    return function(where, obj) {
      safe_log(obj);
      var ret = $("<div>", {"class": "form_field_container " + field});

      ++field_counter;
      ret.append($("<label>", {
        "text": field.capitalize() + ":",
        "for": "input_" + field_counter
      }));
      ret.append(' ');
      ret.append($("<input>", {
        "class": required ? "required" : '',
        "id": "input_" + field_counter,
        "size": 30,
        "type": "text",
        "name": field,
        "value": $(obj).find(field).text()
      }));
      ret.append(' ');
      if (picklistfield) {
        var box = $("<input>", {
          "id": "combobox_" + (++field_counter),
          "name": picklistfield,
          "value": $(obj).find(picklistfield).text(),
          "size": 25
        });
        box.autocomplete({
          "source": picklists[picklistfield.capitalize()],
          "minLength": 0
        });
        ret.append(box);
        cbi(box);
        ret.append(' ');
      }
      ret.append($("<a>", {
        "href": "#",
        "text": "remove",
        "click": function() {
          ret.remove();
          return false;
        }
      }));
      where.append(ret);
    };
  };
                    
  return {
    "objid": null,
    "load": function() {
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
      mkfields("identifiers", "pbcoreIdentifier", simple_maker("identifier", true, "identifierSource"));
      mkfields("titles", "pbcoreTitle", simple_maker("title", true, "titleType"));
    }
  };
})(jQuery);

