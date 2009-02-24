jQuery.fn.formatXml = function(value, options) {
  var xml = this.html();
  var formatted = '';
  var reg = /(\&gt\;)(\&lt\;)(\/*)/g;
  xml = xml.replace(reg, '$1\r\n$2$3');
  var pad = 0;
  jQuery.each(xml.split('\r\n'), function(index, node) {
    var indent = 0;
		if (node.match( /.+\&lt\;\/\w[^\&gt\;]*>$/ )) {
      indent = 0;
		} else if (node.match( /^\&lt\;\/\w/ )) {
      if (pad != 0) {
        pad -= 1;
      }
	} else if (node.match( /^\&lt\;\w[^\&gt\;]*[^\/]\&gt\;.*$/ )) {
      indent = 1;
    } else {
      indent = 0;
    }

    var padding = '';
    for (var i = 0; i < pad; i++) {
      padding += '  ';
    }

    formatted += padding + node + '\r\n';
    pad += indent;
  });
  console.log(formatted);
  this.text(formatted);
  return(this);
};

$(document).ready(function(){
  jQuery('pre.formatted-xml').formatXml();
});