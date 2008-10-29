jQuery(document).ready(function() {
  jQuery('li.edit').click(function() {
    jQuery('#edit_form').toggle();
    return false;
  });

  jQuery('form.edit_feed a.submit').click(function(){
    var edit_form = jQuery(this).parent().parent();
    jQuery.ajax({
      type: 'post',
      url: edit_form.attr('action'),
      data: edit_form.serialize(),
      success: function(resp){
	edit_form.find(".status").text("Feed updated.");
      },
      error: function(resp){
	edit_form.find(".status").text("Error updating feed.");
      }
    });
    return false;
  });
});