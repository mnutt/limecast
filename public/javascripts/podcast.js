function podcastTagEdit() {
  $('#podcast_tag_form').submit(function(){
    var tag_form = $(this);
    var tag_url = tag_form.attr('action');

    if(!LOGGED_IN) { $('#podcast_tag_form_cluetip_link').click(); }
    $.post(tag_url, 
           tag_form.serialize(), 
           function(resp) { 
             $('#tags_block').html(resp.html); // update tags partial
             podcastTagEdit(); // reattach events
             $("#user_tagging_tag_string").inputDefaultText();
             $('#podcast_edit_tags_link a').click();
             $("#user_tagging_tag_string").attr('value', '').blur();
           }, 
          'json');
    return false;
  });
  $('#podcast_edit_tags_link, #podcast_tags_link').click(function(){ 
    $('#podcast_tags').toggle(); 
    $('#podcast_edit_tags').toggle();
    $('#podcast_edit_tags_link a').toggle();
  });
  $('.tags .delete').restfulDelete({ confirmed:function(link){ link.parent().fadeOut(); } });
}

function podcastEpisodesLinks() {
  $('.expanded a.toggle').click(function(){
    var parent = $(this).parents('.expanded');
    parent.hide();
    var collapsed_id = parent.attr('id').replace(/expanded/, 'collapsed');
    $("#"+collapsed_id).show();
    return false;
  });
  $('.collapsed a.toggle').click(function(){
    var parent = $(this).parents('.collapsed');
    parent.hide();
    var expanded_id = parent.attr('id').replace(/collapsed/, 'expanded');
    var expanded = $("#"+expanded_id);
    expanded.show();
    hook_up_preview(expanded.find('.preview .container img')); // FIXME
    return false;
  });
}

$(document).ready(function() {
  podcastTagEdit();
  podcastEpisodesLinks();
  
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