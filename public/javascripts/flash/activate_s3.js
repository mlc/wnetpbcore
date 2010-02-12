/*
 * Create the S3 upload
 */
$(function() {
    var s3form = $("#s3_form");

    if (s3form[0]) {
	var prefix = ($("#s3_prefix").text() || "videos") + "/";
	var btn = $('<button/>', {
	    text: 'Upload Video',
	    type: 'button',
	    disabled: 'disabled',
	    click: function() {
		btn.attr("disabled", "disabled").text("Uploading\u2026");
		window.s3_swf.upload(prefix);
	    }
	});
	btn.reenable = function() {
	    this.removeAttr("disabled").text("Upload Video");
	};

	// we have to stick this in the window object so that the flash can
	// see it and call the callbacks.
	// I think the JS provided by the plugin author may actually be buggy
	// in this regard.
	window.s3_swf = s3_swf_init('s3_swf', function() {
	    var fn;

	    return {
		width: 300,
		height: 35,
		onFileSelected: function(filename, size) {
		    fn = prefix + filename;
		    btn.removeAttr('disabled');
		},
		onSuccess: function() {
		    $('#uploaded_filename').val(fn);
		    s3form.submit();
		},
		onCancel: function() {
		    btn.reenable();
		},
		onFailed: function(status) {
		    var msg = 'Sorry, the upload failed.';
		    if (typeof status !== 'undefined') {
			msg += '\n\n' + msg;
		    }
		    alert(msg);
		    btn.reenable();
		}
	    };
	}());

	btn.appendTo(s3form);
    }
});