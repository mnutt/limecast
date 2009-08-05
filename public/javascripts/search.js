$(document).ready(function() {
  // Hook up all of the search term highlighting
  var searchLabel = $('label[for=q]').text();
  var searchBox   = $('input#q').val();
  if($(document).searchTermContext && searchLabel != searchBox) {
    $('#primary li .searched').map(function(){
      $(this).searchTermContext({
        query: searchBox,
        wordsOfContext: 5,
        format: function(s) { return '<mark>' + s + '</mark>'; }
      });
    });
  }

  // and the tabs
  $('.tabify').tabs({
    navClass: 'tabs',
    containerClass: 'tabs-cont'
  });
});