/* S3_Upload V0.1
	Copyright (c) 2008 Elctech,
	This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
*/

function s3_swf_init(id, options)
{
  width           = (options.width == undefined) ? 300 : options.width
  height          = (options.height == undefined) ? 35 : options.height
  version         = (options.version == undefined) ? '9.0.0' : options.version
  onFileSelected  = (options.onFileSelected == undefined) ? function(){} : options.onFileSelected
  onSuccess       = (options.onSuccess == undefined) ? function(){} : options.onSuccess
  onFailed        = (options.onFailed == undefined) ? function(){} : options.onFailed
  onCancel        = (options.onCancel == undefined) ? function(){} : options.onCancel

  flashvars = {
    signature_query_url: window.location.protocol + '//' + window.location.host + '/s3_uploads',
    id: id
  }
  var s3_swf = {
    obj: function() { return document.getElementById(id); },
    upload: function(prefix) { this.obj().upload(prefix); },
    onSuccess: onSuccess,
    onFailed: onFailed,
    onSelected: onFileSelected, 
    onCancel: onCancel
  }
  
  swfobject.embedSWF("/swf/s3_upload.swf", id, width, height, version, null, flashvars);
  
  return(s3_swf);
}