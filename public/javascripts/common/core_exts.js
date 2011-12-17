// TODO: This can be deleted once edit.js is gone
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

String.prototype.addspaces = function() {
  return this.replace(/([A-Z]+)([A-Z][a-z])/g, '$1 $2')
    .replace(/([a-z\d])([A-Z])/g, '$1 $2');
}

// Crockford, p. 61
function is_array(value) {
  return Object.prototype.toString.apply(value) === '[object Array]';
}