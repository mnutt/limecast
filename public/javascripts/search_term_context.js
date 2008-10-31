// jQuery("<p>this <span>is a</span> bunch of text</p>").searchTermContext({query: 'this a bunch', wordsOfContext: 3, format: function(s){ return "<b>" + s + "</b>"; }}).text()

jQuery.fn.extend({
  searchTermContext: function(opts) {
    var text = jQuery(this).text();
    var terms = opts['query'].split(' ');
    var wordsOfContext = opts['wordsOfContext'] || 15;
    var format = opts['format'] || function(s) { return '<em>' + s + '</em>'; };

    var phrases = [];
    var separator = "[\\s.,()\\[\\]]+";
    var separator = "[\\s.,()\\[\\]]+";

    // Finds the phrases in the text
    for(var i = 0, n = terms.length; i < n; ++i) {
      for(var j = i+1; j < n+1; ++j) {
        var phrase = new RegExp(terms.slice(i,j).join(separator));
        if(text.match(phrase)) {
          phrases.push(phrase);
        }
      }
    }

    // Finds the largest phrase of all the phrases
    var sortedPhrases = phrases.sort(function(a,b) {
      var p1 = text.match(a).join('');
      var p2 = text.match(b).join('');

      return p2.length - p1.length;
    });
    var largestPhrase = sortedPhrases[0];

    function lastNWords(s, n) {
      var contextBefore = new RegExp("\\w+(\\W+\\w+){" + (n-1) + "}\\W+$");
      var m = s.match(contextBefore);
      if(m) { s = '...' + m[0]; }
      return s;
    }
    function firstNWords(s, n) {
      var contextAfter = new RegExp("^\\W+(\\w+\\W+){" + (n-1) + "}\\w+");
      var m = s.match(contextAfter);
      if(m) { s = m[0] + '...'; }
      return s;
    }

    if(largestPhrase) {
      // Gets the text that matched the largest phrase, as well as the text
      // before and after the largest phrase.
      var matched   = text.match(largestPhrase).join("");
      var unmatched = text.split(largestPhrase);
      var before    = unmatched[0];
      var after     = unmatched.slice(1, unmatched.length).join("");

      var formattedString = [
        lastNWords(before, wordsOfContext),
        format(matched),
        firstNWords(after, wordsOfContext)
      ].join("");
  
      jQuery(this).html(formattedString);
    } else {
      jQuery(this).html(firstNWords(text, wordsOfContext * 2));
    }

    return jQuery(this);
  }
});

