$.fn.extend({
  invisible: function(){
    var p = $(this);
    while(p.get(0) != document) {
      if(p.css('display') == 'none') {
        return true;
      }
      p = p.parent();
    }
    return false;
  },
  visible: function(){
    return !$(this).invisible();
  }
});
