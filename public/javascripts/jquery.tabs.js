// Jquery Tabs
// by: tzaharia
//
// Example:
// 
//
jQuery.fn.extend({
  tabs: function() {
    this.each(function(){
      var container = $(this);
      container.find('ul:first').show();
      container.find('nav a').click(function(){
        container.find('ul').hide();
        $($(this).attr('href')).show();
        return false;
      });
    });
  }
});
