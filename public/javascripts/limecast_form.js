// LimeCast Form JS
//
$(document).ready(function() {
  $('#edit_link').click(function() { 
    $('.limecast_form').toggle(); 
    $(this).hide(); 
    return false; 
  })
  $('#edit_actions').show(); // we hide the edit link until ready in case the user clicks it

  $('.limecast_form .cancel').click(function(){ 
    $('#edit_link').show(); 
    $(this).parents(".limecast_form").hide(); 
    return false;
  });
});