function extendObject(a, b) {
  for (var key in b) {
    a[key] = b[key];
  }
  return a;
}
function JavaEmbed(options) {
  var defaults = {
    containerId:"",
    code:"",
    archive:"",
    alt:"Your browser is not configured to view the applet. Please install Jave Runtime JRE 1.5 or higher.",
    params:{}
  };
  options = extendObject( defaults, options );
  if (!options.containerId) return null;
  var container = document.getElementById(options.containerId);
  if (!container) return null;

  var markup = '<applet';
  options.code && (markup += ' code="'+options.code+'"');
  options.archive && (markup += ' archive="'+options.archive+'"');
  options.width && (markup += ' width="'+options.width+'"');
  options.height && (markup += ' height="'+options.height+'"');
  options.alt && (markup += ' alt="'+options.alt+'"');
  options.id && (markup += ' id="'+options.id+'"');
  markup += '>';
  for (var key in options.params) {
    markup += '<PARAM name="'+key+'" value="'+options.params[key]+'">';
  }
  markup += '</applet>';
  container.innerHTML = markup;
  var applet = container.getElementsByTagName("applet")[0]; 
  return applet;
}
