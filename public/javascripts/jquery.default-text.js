// Jquery Default Text
// by: aroscoe
jQuery.fn.inputDefaultText = function(value, options) {
    options = jQuery.extend({
        blurColor: "#a9a9a9",
        focusColor: "#171717"
    }, options);

    var label = this.parent().find("label[for='" + this.attr("name") + "']");
    var defaultTxt = label.text();
    
    label.hide();
    
    this.val(defaultTxt).css("color", options.blurColor);
    this.focus(function(){
        jQuery(this).val("").css("color", options.focusColor);
    });
    this.blur(function(){
        if (jQuery(this).val() == "") {
            jQuery(this).val(defaultTxt).css("color", options.blurColor);
        }
    });
    return(this);
};