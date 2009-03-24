// Jquery Default Text
// by: aroscoe
jQuery.fn.extend({
  inputDefaultText: function(value, options) {
    options = jQuery.extend({
        blurColor: "#a9a9a9",
        focusColor: "#171717"
    }, options);
  
    this.each(function(){
      var input = $(this);
  
      var label = input.parent().find("label[for='" + input.attr("id") + "']");
      var defaultTxt = label.text();
      label.hide();
      
      var blur = function(){
        if (input.val() == "") {
          input.val(defaultTxt).css("color", options.blurColor);
        }
      }
      var focus = function(){
        if(input.val() == defaultTxt) {
          input.val("").css("color", options.focusColor);
        }
      };

      blur();
      input.focus(focus);
      input.blur(blur);

      input.parents('form').submit(function(){
        if(input.val() == defaultTxt) input.val('');
      });
    });
  
    return this;
  }
});
