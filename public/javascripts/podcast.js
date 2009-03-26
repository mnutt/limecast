function podcastEpisodeSorting() {
  var title = { "bSortable": false };
  var description = { "bVisible": false, "bSortable": false };
  var runtime = { "bSortable": false };
  var date_released = null;

  $('#podcast_episodes').dataTable({
    "aaSorting": [[ 3, "desc" ]],
    "aoColumns": [ title, description, runtime, date_released ],
    "bStateSave": true,
    "bProcessing": true
  });
}

function podcastTagEdit() {
  $('#podcast_edit_tags_link, #podcast_tags_link').click(function(){ 
    $('#podcast_tags').toggle(); 
    $('#podcast_edit_tags').toggle();
    $('#podcast_edit_tags_link').toggle();
  });
  $('.tags .delete').restfulDelete({ confirmed:function(link){ link.parent().fadeOut(); } });
}

$(document).ready(function() {
  podcastEpisodeSorting();
  podcastTagEdit();
  
  $("#subscribe_options li a").click(function(){ return false; });
  $("#s_options_toggle").click(function(e){
    $("#subscribe_options_container").slideDown("fast");

    // similar to jquery.dropdown.js
    if($("#overlay").size() == 0) $('body').append("<div id=\"overlay\"></div>");
    $("#overlay").click(function(){
      $("#subscribe_options_container").slideUp("fast");
      $(this).remove();
    });

    e.preventDefault();
  });
});