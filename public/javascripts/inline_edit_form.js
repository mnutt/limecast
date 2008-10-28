jQuery(document).ready(function() {
  jQuery('li.edit').click(function() {
    jQuery('#edit_form').toggle();
    return false;
  });

  jQuery('form.edit_feed a.submit').click(function(){
    var edit_form = jQuery(this).parent();
    console.log(edit_form);
    jQuery.ajax({
      type: 'post',
      url: edit_form.attr('action'),
      data: edit_form.serialize(),
      dataType: 'json',
      success: function(resp){
      }
    });
    return false;
  });
});