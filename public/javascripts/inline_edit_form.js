$(document).ready(function() {
  $('li.edit').click(function() {
    $('#edit_form').toggle();
    return false;
  });

  $('form.edit_feed a.submit').click(function(){
    var edit_form = $(this).parent().parent();
    $.ajax({
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