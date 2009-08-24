// Jquery Tabs
// by: tzaharia
//
jQuery.fn.extend({
  tabs: function() {
    this.each(function(){
      var container = $(this);
      container.find('ul:first').show();
      container.find('nav a').click(function(){
        container.find('nav a').removeClass('selected');
        container.find('ul').hide();
        $(this).addClass('selected');
        $($(this).attr('href')).show();
        return false;
      });
      container.find('nav a:first-child').click();
    });
  }
});
