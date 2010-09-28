(function($, undefined){
  var langdialog, langselect, create_lang_dialog = function() {
    if (langdialog !== undefined)
      return;

    var form;
    langselect = $("<select/>", {css: {width: "280px"}}); /* jquery UI dialog default width is 300px */
    for(var codes = Iso6391.by_en_name(), len = codes.length, i = 0; i < len; ++i) {
      var code = codes[i];
      langselect.append($("<option/>", {
        'value': code[1],
        'text': code[0],
        'selected': (code[1] === 'eng')
      }));
    };
    form = $("<form>").append($("<p/>").append(langselect));

    langdialog = $("<div/>")
      .append($("<p/>", {text: "Choose a language:"}))
      .append(form)
      .dialog({
        autoOpen: false,
        title: 'Add Language'
      });
  };

  $.fn.langedit = function() {
    return $(this).each(function() {
      var $this = $(this), span = $("<span/>", {"class": "languages-wrapper"}), languages, button;

      function appendlang(code) {
        var lang = Iso6391.get_code(code);
        if (!lang)
          return;

        var langspan = $("<span/>", {
          "class": "removable-language",
          "text": lang.en,
          "title": code
        })
        .append($('<button type="button"></button>')
          .text("remove")
          .click(function() {
            langspan.remove();
            normalizeinput();
          })
          .button({
            "text": false,
            "icons": { "primary": "ui-icon-close" }
          })
        );
        languages.append(langspan).append(' ');
      }

      function normalizeinput() {
        var langs = [];
        languages.find(".removable-language").each(function() {
          langs.push(this.title);
        });
        $this.val(langs.join(";"));
      }

      $this.after(span);

      languages = $("<span/>", {"class": "languages"}),
      button = $('<button type="button"></button>')
        .text("Add Another\u2026")
        .click(function() {
          create_lang_dialog();
          langdialog.dialog('option', 'buttons', {
            'Ok': function() {
              appendlang(langselect.val());
              normalizeinput();
              $(this).dialog("close");
            },
            'Cancel': function() {
              $(this).dialog('close');
            }
          });
          langdialog.dialog('open');
          langselect.focus();
        })
        .button();

      var origlangs = $this.val().split(/[;,]\s+/);
      for (var len = origlangs.length, i = 0; i < len; ++i) {
        appendlang(origlangs[i]);
      }

      span.append(languages).append(button);
    });
  };
})(jQuery);