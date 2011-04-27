/*
 * JavaScript/JQuery PBCore Editor!
 * 
 * Basic theory of operation: we load in an XML object and a JSON of
 * the various "picklists." Then, we make some form fields, using some
 * JQuery UI autocomplete magic to have comboboxes as appropriate. And
 * when the user presses Submit, a new XML document is generated and
 * posted to the server.
 * 
 * It is probably possible to adapt this JS for use outside the
 * wnetpbcore project. If you have a project for which this would be
 * helpful, let me know.
 */
var FormEditor = (function($, undefined) {
  var PASTA_NS = "http://vermicel.li/pbcore-extensions",
      PBCORE_NS = "http://www.pbcore.org/PBCore/PBCoreNamespace.html";

  var xml, picklists, valuelists, extension_names;
  var field_counter = 0;
  var made_form = false;
  var obj_type;

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
  Style.ONLY_TEXTAREA = new Style("only textarea");
  Style.TWO_PLAIN = new Style("two plain");
  Style.SELECT = new Style("two plain");

  var safe_log = function(obj, level) {
    if (typeof console === 'object') {
      if (level !== undefined && typeof console[level] === 'function')
        console[level](obj);
      else if (typeof console.log === 'function')
        console.log(obj);
    }
  };

  var autocompleteopts = function(name) {
    var picklist = picklists[name.capitalize()], cache = {};
    switch(typeof picklist) {
    case 'string':
      return {
        "source": function(request, response) {
          if (request.term in cache) {
            response(cache[request.term]);
            return;
          }
          
          $.ajax({
            url: picklist,
            dataType: 'json',
            data: request,
            success: function(data) {
              cache[request.term] = data;
              response(data);
            }
          });
        },
        "minLength": 2,
        "delay": 300
      };
    case 'object':
      if (!is_array(picklist))
        return undefined;

      return {
        "source": picklist,
        "minLength": 0,
        "delay": 0
      };
    }
    return undefined;
  };
                    
  var makecombo = function(box) {
    var btn = document.createElement("button");
    // btn.type = "button";
    $(btn).attr({
      "text": '\u00a0',
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
 
  var mkfields = function(div, pbcore, callback, rejector) {
    var $div = $("#" + div);
    xml.find(pbcore).each(function(i) {
      if (!(rejector && rejector(this)))
        callback(pbcore, $div, this, i);
    });
    $div.after($("<p>").append($("<a>", {
      "href": "#",
      "text": "Add another\u2026",
      "class": "adder",
      "click": function() {
        callback(pbcore, $div);
        return false;
      }
    })));
  };

  var mkboxes = function(div, pbcore, field) {
    var $div = $("#" + div).addClass("pbcorechecks").attr("pbcore", pbcore);
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

  var mkremove = function(div) {
    return $("<a>", {
      "href": "#",
      "text": "remove",
	  "class": "remove",
      "click": function() {
        div.remove();
        return false;
      }
    });
  };

  /*
   * This is a function which returns a function. The returned function is
   * a callback passed to mkfields(), above. Um, yay, Javascript.
   */
  var pbcore_maker = function(field, picklistfield, style, locked) {
    return function(pbcore, where, obj) {
      var label, formfield, remove, box, boxlabel;
      style = style || Style.PLAIN;
      var textarea = (style == Style.TEXTAREA || style == Style.ONLY_TEXTAREA);
      var ret = $("<div>", {"class": "form_field_container " + field, "pbcore": pbcore});

      if (field) {
        ++field_counter;
        label = $("<label>", {
          "text": field.capitalize().addspaces() + ":",
          "for": "input_" + field_counter
        });
        var args = {
          "class": "pbcorefield " + field,
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
        if (style === Style.TWO_PLAIN) {
          box = $("<input>", {
            "id": "input_" + (++field_counter),
            "class": "pbcorefield " + picklistfield,
            "name": picklistfield,
            "value": $(obj).find(picklistfield).text(),
            "size": 30,
            "type": "text"
          });
        } else if (style === Style.SELECT) {
          box = $("<select>", {
            "id": "select_" + (++field_counter),
            "class": "picklistbox " + picklistfield,
            "name": picklistfield
          });
          var opts = picklists[picklistfield.capitalize()];
          for (var i = 0, len = opts.length; i < len; ++i) {
            box.append($("<option>", { value: opts[i], text: opts[i] }));
          }
          box.val($(obj).find(picklistfield).text());
        } else {
          box = $("<input>", {
            "id": "combobox_" + (++field_counter),
            "class": "picklistbox " + picklistfield,
            "name": picklistfield,
            "value": $(obj).find(picklistfield).text(),
            "size": (style == Style.VERBOSE ? 15 : 25),
            "readonly": locked
          });
          box.autocomplete(autocompleteopts(picklistfield));
        }
      }
      remove = mkremove(ret);
      if (style === Style.VERBOSE || style === Style.SELECT) {
        boxlabel = $("<label>", {
          "text": picklistfield.capitalize().addspaces() + ":",
          "for": "combobox_" + field_counter
        });        
      } else if (style === Style.TWO_PLAIN) {
        boxlabel = $("<label>", {
          "text": picklistfield.capitalize().addspaces() + ":",
          "for": "input_" + field_counter
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
      case Style.SELECT:
        ret.append(boxlabel).append(' ').append(box).append(' ').append(label).append(' ').append(formfield).append(' ').append(remove);
        break;
      case Style.SIMPLE:
        ret.append(box).append(' ').append(remove);
        break;
      case Style.ONLY_TEXTAREA:
        ret.append(label).append(' ').append(remove).append(' ').append(formfield);
        break;
      case Style.TWO_PLAIN:
        ret.append(label).append(' ').append(formfield).append($("<br/>")).append(boxlabel).append(' ').append(box).append(' ').append(remove);
        break;
      default:
        safe_log("warning! unexpected style!", "warn");
        safe_log(style, "warn");
      }

      if (box && style !== Style.TWO_PLAIN && style !== Style.SELECT)
        makecombo(box);

      /* deal with value lists */
      if ((style == Style.PLAIN || style == Style.VERBOSE) && valuelists[picklistfield.capitalize()]) {
        (function() { // create a new scope
          var fieldlists = valuelists[picklistfield.capitalize()],
            have_autocomplete = false;
          var maybe_valuelist = function(event, ui) {
            var str, fieldlist;
            if (event && event.type === 'autocompleteselect')
              str = ui.item.value;
            else
              str = box.val();

            if ((fieldlist = fieldlists[str])) {
              if (have_autocomplete) {
                formfield.autocomplete('option', 'source', fieldlist);
              } else {
                /* TODO: consider possibility of using autocompleteopts here */
                formfield.autocomplete({
                  "source": fieldlist,
                  "minLength": 0,
                  "delay": 0
                });
                makecombo(formfield);
                have_autocomplete = true;
              }
            } else if (have_autocomplete) {
              formfield.autocomplete('destroy');
              formfield.next('button').remove(); // rm combobox button
              have_autocomplete = false;
            }
            return true;
          };
          box.bind("autocompleteselect change", maybe_valuelist);
          maybe_valuelist();
        })();
      }
      
      where.append(ret);
    };
  };

  var mksubmit = function() {
    var btn = document.createElement("button");
    // btn.type = "button";

    $("#submit_area").append($(btn)
      .text("Save record")
      .click(function() {
        var xml = FormEditor.to_xml();
        var field = $("#xml_from_editor"), form = field.closest('form');
        field.val(OraXML.serialize(xml));
        $.ajax({
          "type": "POST",
          "url": form.attr("action"),
          "dataType": "script",
          "data": form.serialize()
        });
        return false;
      })
      .button()
    );
  };

  /* SUBJECT / GENRE FUNCTIONS */

  var subject_maker = function(field) {
    var authority_field = field + "AuthorityUsed";

    var stringify_with_authority = function(obj) {
      var $obj = $(obj),
        ret = $obj.find(field).text(),
        authority = $obj.find(authority_field).text();

      if (authority) {
        ret = ret + " (" + authority + ")";
      }

      return ret;
    };

    return function(pbcore, where, obj) {
      var ret = $("<div>", {"class": "form_field_container " + field, "pbcore": pbcore});
      var box = $("<input>", {
        "id": "comboxbox_" + (++field_counter),
        "class": "picklistbox " + field,
        "name": field,
        "value": stringify_with_authority(obj),
        "size": 50
      });
      box.autocomplete(autocompleteopts(field));
      ret.append(box).append(' ').append(mkremove(ret));
      makecombo(box);

      where.append(ret);
    };
  };

  var SUBJECT_PARSING_REGEX = /^(.+\S)\s+\(\s*(.+\S)\s*\)\s*$/;

  var serialize_subject = function(doc, xml, html, mkelt) {
    var input = html.find("input"),
      field = input.attr("name"),
      entered_text = input.val(),
      match = SUBJECT_PARSING_REGEX.exec(entered_text),
      subject_elt = mkelt(field);

    xml.appendChild(subject_elt);
    subject_elt.appendChild(doc.createTextNode(match ? match[1] : entered_text));
    if (match) {
      var authority_elt = mkelt(field + "AuthorityUsed");
      xml.appendChild(authority_elt);
      authority_elt.appendChild(doc.createTextNode(match[2]));
    }
  };

  /* EXTENSIONS FUNCTIONS */

  var parse_extension = function(obj) {
    var $obj = $(obj),
    extension = $obj.find("extension").text(),
    extension_authority_used = $obj.find("extensionAuthorityUsed").text(),
    colon = extension.indexOf(":"),
    extension_key, extension_value;

    if (colon < 0) {
      extension_key = null;
      extension_value = extension;
    } else {
      extension_key = extension.substr(0, colon);
      extension_value = extension.substr(colon + 1);
    }

    return {
      "authority": extension_authority_used,
      "key": extension_key,
      "value": extension_value
    };
  };

  var fill_extension_select = function(select, extension) {
    var i, len = extension_names.length, extension_name, match;
    for(i = 0; i < len; ++i) {
      extension_name = extension_names[i];
      match = (extension.authority === extension_name.authority && extension.key === extension_name.key);
      if (match || extension_name.visible) {
        select.append($("<option>", {
          "value": i,
          "selected": match,
          "text": extension_name.description
        }));
      }
    }
  };

  var serialize_extension = function(doc, xml, html, mkelt) {
    var extension_name = extension_names[html.find("select").val()],
      value = html.find("textarea").val(),
      extension_elt = mkelt("extension"),
      authority_elt = mkelt("extensionAuthorityUsed"),
      extension_str = '';

    xml.appendChild(extension_elt);
    if (extension_name && extension_name.key) {
      extension_str = extension_name.key + ':';
    }
    extension_str += value;
    extension_elt.appendChild(doc.createTextNode(extension_str));
    if (extension_name && extension_name.authority) {
      xml.appendChild(authority_elt);
      authority_elt.appendChild(doc.createTextNode(extension_name.authority));
    }
  };

  var extension_maker = function(pbcore, where, obj) {
    var div = $("<div/>", {"class": "form_field_container extension", "pbcore": "pbcoreExtension"}),
    select,
    extension = parse_extension(obj);

    ++field_counter;
    div.append($("<label/>", {text: "Extension Type: ", "for": "ext_type_" + field_counter}));
    select = $("<select/>", {id: "ext_type_" + field_counter});
    div.append(select).append(mkremove(div));
    fill_extension_select(select, extension);
    div.append($("<br/>"));
    div.append($("<label/>", {text: "Extension Value: ", "for": "ext_value_" + field_counter}));
    div.append($("<br/>"));
    div.append($("<textarea>", {
      text: extension.value,
      id: "ext_value_" + field_counter,
      "class": "pbcore extension_value",
      cols: 80,
      rows: 5
    }));
    where.append(div);
  };

  /* ESSENCE TRACK FUNCTIONS */

  var essence_track_maker = function(pbcore, where, obj) {
    var div = $("<div/>", {"class": "form_field_container essence_track", "pbcore":"pbcoreEssenceTrack"}), p = $("<p/>"), $obj = $(obj);

    function plain_field(ignored, name) {
      name = name || ignored;
      var textarea = (name === 'Annotation');

      ++field_counter;
      p.append($("<label/>", {text: name.addspaces() + ": ", "for": "etpf_" + field_counter}));
      var attrs = {id: "etpf_" + field_counter, name: "essenceTrack" + name, "class": "pbcoreField essenceTrack" + name};
      attrs[textarea ? 'text' : 'value'] = $obj.find("essenceTrack" + name).text();
      if (textarea) {
        attrs.css = { width: "560px" };
        attrs.rows = 3;
      } else {
        attrs.size = (name === "Identifier" ? 40 : 25);
        attrs.type = 'text';
      }
      p.append($(textarea ? "<textarea/>" : "<input/>", attrs));
      p.append($("<br/>"));
    }

    ++field_counter;
    div.append($("<h4/>", {text: "Essence Track"}));
    div.append(p.append(mkremove(div)));
    p.append($("<br/>"));
    p.append($("<label/>", {text: "Type: ", "for": "ett_" + field_counter}));
    var ett = $("<input>", {
      "id": "ett_" + field_counter,
      "class": "picklistbox essence_track_type",
      "name": "essenceTrackType",
      "value": $obj.find("essenceTrackType").text(),
      "size": 25
    });
    ett.autocomplete(autocompleteopts("essenceTrackType"));
    p.append(ett);
    makecombo(ett);
    p.append($("<br/>"));

    plain_field("Identifier");

    ++field_counter;
    p.append($("<label/>", {text: "Identifier Source: ", "for": "etis_" + field_counter}));
    ett = $("<input>", {
      "id": "etis_" + field_counter,
      "class": "picklistbox essence_track_identifier_source",
      "name": "essenceTrackIdentifierSource",
      "value": $obj.find("essenceTrackIdentifierSource").text(),
      "size": 25
    });
    ett.autocomplete(autocompleteopts("essenceTrackIdentifierSource"));
    p.append(ett);
    makecombo(ett);
    p.append($("<br/>"));

    $.each(["Standard", "Encoding", "DataRate", "TimeStart", "Duration", "BitDepth", "SamplingRate", "FrameSize", "AspectRatio", "FrameRate", "Annotation"], plain_field);

    ++field_counter;
    p.append($("<label/>", {text: "Language: ", "for": "etl_" + field_counter}));
    var etlang = $("<input>", {
      id: "etl_" + field_counter,
      value: $obj.find("essenceTrackLanguage").text(),
      name: "essenceTrackLanguage",
      "class": "pbcoreField essenceTrackLanguage",
      "type": "hidden"
    });
    p.append(etlang);
    etlang.langedit();
    where.append(div);
  };

  /*
   * Create and fill in the basic (non-repeatable) instantiation fields
   */
  var basic_instantiation_fields = function() {
    var $p = $("<p/>").appendTo($("#instantiation_info"));

    var text_field = function(name) {
      $p.append($("<input/>", {
        'id': "if_" + field_counter,
        'type': 'text',
        'value': xml.find(name).text(),
        'class': 'pbcorefield instantiationfield ' + name,
        'name': name
      }));
    },
    picklist_field = function(name) {
      var input = $("<input/>", {
        'id': "if_" + field_counter,
        'type': 'text',
        'value': xml.find(name).text(),
        'class': 'picklistbox instantiationfield ' + name,
        'name': name
      });
      input.autocomplete(autocompleteopts(name));
      $p.append(input);
      makecombo(input);
      return input;
    },
    format_field = function(name) {
      var picklist = picklist_field(name),
      span = $("<span/>").insertBefore(picklist),
      mkradio = function(str) {
        ++field_counter;
        var radio = $("<input/>", {
          'id': "rad_" + field_counter,
          'type': "radio",
          'name': 'format_type',
          'value': str,
          'checked': !!(xml.find("format" + str).text())
        });
        span.append(radio);
        span.append($("<label/>", {
          'for': "rad_" + field_counter,
          'text': str
        }));
        span.append(' \u00a0 ');

        return radio;
      },
      radios = mkradio('Physical').add(mkradio('Digital')),
      updatepicklist = function() {
        var which = span.find("input:checked").val();
        if (which) {
          picklist.attr("disabled", false);
          picklist.autocomplete('option', 'source',  picklists["Format" + which]).autocomplete('option', 'minLength', 0);
        } else {
          picklist.attr("disabled", true);
        }
      };

      picklist.val(xml.find("formatPhysical, formatDigital").text());
      updatepicklist();
      radios.bind('change', updatepicklist);

      /* make change event be fired on IE */
      if ($.browser.msie) {
        radios.click(function () {
          $(this).blur().focus();
        });
      }
    },
    language_field = function(name) {
      var input = $("<input/>", {
        'id': "if_" + field_counter,
        'type': 'hidden',
        'value': xml.find(name).text(),
        'class': 'pbcorefield instantiationfield ' + name,
        'name': name
      });
      $p.append(input);
      input.langedit();
    };

    $.each([
      [text_field, "dateCreated"],
      [text_field, "dateIssued"],
      [format_field, "format"],
      [text_field, "formatLocation"],
      [picklist_field, "formatMediaType"],
      [picklist_field, "formatGenerations", "identifies the particular use or manner in which a version or rendition of a media item is used"],
      [text_field, "formatFileSize"],
      [text_field, "formatTimeStart"],
      [text_field, "formatDuration"],
      [text_field, "formatDataRate"],
      [picklist_field, "formatColors"],
      [text_field, "formatTracks"],
      [text_field, "formatChannelConfiguration"],
      [language_field, "language"],
      [text_field, "alternativeModes", "identifies equivalent alternatives to the primary visual, sound or textual information that exists in a media item. These are modes that offer alternative ways to see, hear, and read the content of a media item. Examples include DVI (Descriptive Video Information), SAP (Supplementary Audio Program), ClosedCaptions, OpenCaptions, Subtitles, Language Dubs, and Transcripts."]
    ], function() {
      var name = this[1];
      ++field_counter;
      $p.append($("<label/>", {
        'text': name.capitalize().addspaces() + ": ",
        'for': "if_" + field_counter,
        'title': this[2]
      }));
      this[0](name);
      $p.append($("<br/>"));
    });
  };

  var form_creators = {
    "asset": function() {
      mkfields("identifiers", "pbcoreIdentifier", pbcore_maker("identifier", "identifierSource"), function(elt) {
        return $(elt).find("identifierSource").text() === "pbcore XML database UUID";
      });
      mkfields("titles", "pbcoreTitle", pbcore_maker("title", "titleType"));
      mkfields("subjects", "pbcoreSubject", subject_maker("subject"));
      mkfields("descriptions", "pbcoreDescription", pbcore_maker("description", "descriptionType", Style.TEXTAREA));
      mkfields("genres", "pbcoreGenre", subject_maker("genre"));
      mkfields("relations", "pbcoreRelation", pbcore_maker("relationIdentifier", "relationType", Style.VERBOSE));
      mkfields("coverages", "pbcoreCoverage", pbcore_maker("coverage", "coverageType", Style.SELECT, true));
      mkboxes("audience_levels", 'pbcoreAudienceLevel', 'audienceLevel');
      mkboxes("audience_ratings", 'pbcoreAudienceRating', 'audienceRating');
      mkfields("creators", "pbcoreCreator", pbcore_maker("creator", "creatorRole", Style.VERBOSE));
      mkfields("contributors", "pbcoreContributor", pbcore_maker("contributor", "contributorRole", Style.VERBOSE));
      mkfields("publishers", "pbcorePublisher", pbcore_maker("publisher", "publisherRole", Style.VERBOSE));
      mkfields("rights_summaries", "pbcoreRightsSummary", pbcore_maker("rightsSummary", undefined, Style.ONLY_TEXTAREA));
      mkfields("extensions", "pbcoreExtension", extension_maker);
    },
    "instantiation": function() {
      mkfields("format_ids", "pbcoreFormatID", pbcore_maker("formatIdentifier", "formatIdentifierSource"), function(elt) {
        return $(elt).find("formatIdentifierSource").text() === 'pbcore XML database UUID';
      });
      basic_instantiation_fields();
      mkfields("essence_tracks", "pbcoreEssenceTrack", essence_track_maker);
      mkfields("date_availables", "pbcoreDateAvailable", pbcore_maker("dateAvailableStart", "dateAvailableEnd", Style.TWO_PLAIN));
      mkfields("annotations", "pbcoreAnnotation", pbcore_maker("annotation", undefined, Style.ONLY_TEXTAREA));
    }
  };

  var root_elt_names = {
    "asset": "PBCoreDescriptionDocument",
    "instantiation": "pbcoreInstantiation"
  };

  return {
    "load": function(provided_obj_type) {
      obj_type = provided_obj_type;
      made_form = false;
      $.ajax({
        "url": $('link[rel="picklists"]').attr("href"),
        "dataType": "json",
        "type": "GET",
        "success": function(data, textStatus, xhr) {
          picklists = data.picklists;
          valuelists = data.valuelists;
          extension_names = data.extension_names;
          safe_log("got picklists!");
          if (xml)
            FormEditor.create_form();
        }
      });
      $.ajax({
        "url": $('link[rel="toedit"]').attr("href"),
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
      if (form_creators[obj_type]) {
        form_creators[obj_type]();
        mksubmit();
      } else {
        safe_log("unknown obj type " + obj_type, "error");
      }
    },
    "to_xml": function() {
      var doc = OraXML.newDocument(root_elt_names[obj_type], PBCORE_NS);
      var mkelt = ((typeof doc.createElementNS === 'function') ?
        (function(tagName) {
          return doc.createElementNS(PBCORE_NS, tagName);
        })
        :
        (function(tagName) {
           return doc.createNode(1, tagName, PBCORE_NS);
        })
      );
      var root = doc.documentElement;
      root.appendChild(doc.createComment("serialized in JavaScript at " + (new Date()).toString()));
      $("div.form_field_container").each(function() {
        var $this = $(this), pbcorename = $this.attr("pbcore");
        var elt = mkelt(pbcorename);
        root.appendChild(elt);
        switch(pbcorename) {
        case 'pbcoreSubject':
        case 'pbcoreGenre':
          serialize_subject(doc, elt, $this, mkelt);
          break;

        case 'pbcoreExtension':
          serialize_extension(doc, elt, $this, mkelt);
          break;

        default:
          $("input, select, textarea", $this).each(function() {
            var subelt = mkelt(this.name);
            elt.appendChild(subelt);
            subelt.appendChild(doc.createTextNode(this.value));
          });
          break;
        }
      });

      // NB: PBCore requires that the elements appear in a specific order; we
      // violate this by just sticking checkboxes at the end of the document.
      // If this bothers you, futz with the code yourself.
      $("div.pbcorechecks").each(function() {
        var $this = $(this), pbcore = $this.attr("pbcore");
        $("input:checked", $this).each(function() {
          var elt = mkelt(pbcore), subelt = mkelt(this.name);
          root.appendChild(elt);
          elt.appendChild(subelt);
          subelt.appendChild(doc.createTextNode(this.value));
        });
      });

      // Similarly, there are some strings directly under pbcoreInstantiation
      // which will end up at the bottom of the document rather than anywhere
      // else.
      if (obj_type === 'instantiation') {
        $("input.instantiationfield").each(function() {
          var name = this.name, elt;
          if (name === 'format') {
            name += $('input[name="format_type"]:checked').val();
          }
          elt = mkelt(name);
          root.appendChild(elt);
          elt.appendChild(doc.createTextNode(this.value));
        });
      }

      return doc;
    },
    "get_obj_type": function() {
      return obj_type;
    }
  };
})(jQuery);

