$.fn.extend({
  hoverAndFocusBehavior: function() {
    $(this).mouseover(function() { $(this).addClass('hover'); })
           .mousedown(function() { $(this).addClass('active'); })
           .mouseup(function() { $(this).removeClass('active'); })
           .mouseout(function() { $(this).removeClass('hover active'); })
           .focus(function() { $(this).addClass('focus').removeClass('active hover'); })
           .blur(function() { $(this).removeClass('focus hover active'); });
  }
});
