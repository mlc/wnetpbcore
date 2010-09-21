$(function() {
  var $vlc = $("#new_value_list select#value_list_category"),
    $sel = $("#value_list_value");
  $vlc.bind("click change", function() {
    $sel.empty();
    if ($vlc.val() !== '') {
      var opts = window.value_list_choices[$vlc.val()];
      for(var i = 0, len = opts.length; i < len; ++i) {
        $("<option/>", {text: opts[i][0], value: opts[i][0]}).appendTo($sel);
      }
      $("#value_container").show();
    } else {
      $("#value_container").hide();
    }
  });
});
