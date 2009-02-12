// Jquery Default Text
// by: aroscoe
jQuery.fn.inputDefaultText = function(value, options) {
    options = jQuery.extend({
        blurColor: "#808080",
        focusColor: "#313131"
    }, options);

    var defaultTxt = this.parent().find("label[for='" + this.attr("name") + "']").text();

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