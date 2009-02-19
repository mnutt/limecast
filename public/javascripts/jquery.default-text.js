// Jquery Default Text
// by: aroscoe
jQuery.fn.inputDefaultText = function(value, options) {
    options = jQuery.extend({
        blurColor: "#a9a9a9",
        focusColor: "#171717"
    }, options);

    var input = this;
    var label = input.parent().find("label[for='" + input.attr("id") + "']");
    var defaultTxt = label.text();
    label.hide();
    
    if(input.val() == '') input.val(defaultTxt).css("color", options.blurColor);
    input.focus(function(){
      if(input.val() == defaultTxt) {
        jQuery(input).val("").css("color", options.focusColor);
      }
    });
    input.blur(function(){
        if (jQuery(input).val() == "") {
          jQuery(input).val(defaultTxt).css("color", options.blurColor);
        }
    });
    input.parents('form').submit(function(){
      if(input.val() == defaultTxt) input.val('');
    });
    return(input);
};