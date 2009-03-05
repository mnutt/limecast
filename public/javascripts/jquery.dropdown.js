// Jquery Dropdown
// by: aroscoe
//
// CSS:
// #overlay {
//     position: absolute;
//     z-index: 999;
//     left: 0;
//     top: 0;
//     width: 100%;
//     height: 100%;
// }

jQuery.fn.dropdown = function(value, options) {
    options = jQuery.extend({
        button: "span.button",
        dropdown: ".dropdown"
    }, options);

    value = jQuery(value);
    var button = this.find(options.button + ":first");
    var dropdown = this.find(options.dropdown + ":first");
    var body = jQuery("body");
    var overlay = null;
    var overlay_set = false;

    button.click(function(){
        dropdown.show();
        body.append("<div id=\"overlay\"></div>");
        overlay = jQuery("#overlay");
        overlay.click(function(){
            dropdown.hide();
            jQuery(this).remove();
        });
        overlay_set = true;
    });

    dropdown.find("li a").click(function(e){
        var text = jQuery(this).text();
        button.children("span").text(text).removeClass().addClass(jQuery(this).attr("class"));
        value.val(text);
        dropdown.hide();
        overlay.remove();
        overlay_set = false;
        e.preventDefault();
    });
    return(this);
};
