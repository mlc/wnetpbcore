$.fn.ipblock = function() {
  var iptostr = function(ip) {
    var octets = [(ip >> 24 & 0xFF),
                  (ip >> 16 & 0xFF),
                  (ip >>  8 & 0xFF),
                  (ip & 0xFF)];
    return octets.join('.');
  };

  return $(this).each(function() {
    var $this = $(this);
    var $preview = $('<span/>');
    var $ipedit = $this.find('.ipedit');
    var $netmaskedit = $this.find('.netmaskedit');

    var updpreview = function () {
      var octets = $ipedit.val().split('.');
      var cidr = parseInt($netmaskedit.val());

      if (cidr === 0) {
        $preview.text("(all IP addresses)");
      } else if (cidr === 32) {
        $preview.text("(" + octets.join(".") + " only)");
      } else {
        // all numbers in Javascript are floating-point, so there may be some
        // problems with doing this bit-arithmetic
        var mask = 0x7FFFFFFF >> (cidr - 1);
        var ip = (octets[0] << 24 | octets[1] << 16 | octets[2] << 8 | octets[3]);
        var start = ip & ~mask;
        var end = ip | mask;
        $preview.text("(" + iptostr(start) + '\u2013' + iptostr(end) + ")");
      }
    };
    updpreview();

    $ipedit.ipaddress();
    $this.find('.ipedit, .netmaskedit').change(updpreview);
    $this.find('.ip_octet').blur(updpreview);

    $netmaskedit.after($('<a/>', {
      "text": 'remove',
      "class": 'destroy_link',
      "click": function() { $this.remove(); },
      "css": { "cursor": "pointer" }
    })).after(' ').after($preview).after(' ');
  });
};

$(function() {
  $("p.ipblock").ipblock();
  var $strings = $("#strings");
  if ($strings[0]) {
    $strings.after($('<p/>').append($('<a/>', {
      "text": "Add another\u2026",
      "css": { "cursor": "pointer" },
      "click": function() {
        var $p = $("<p/>", {"class": "ipblock"});
        $p.append($("<input/>", {"name": "ipranges[]", "type": "text", "class": "ipedit"}));
        $p.append(" / ");
        var $sel = $("<select/>", {"name": "netmasks[]", "class": "netmaskedit"}), i;
        for (i = 32; i >= 0; --i) {
          $sel.append($("<option/>", {"value": i, "text": i, "selected": (i == 24)}));
        }
        $p.append($sel);
        $strings.append($p);
        $p.ipblock();
      }
    })));
  }
});