$(function() {
  $('#subscribe_options').tabs({
    fxFade: true,
    fxSpeed: 'fast'
  });
});

$(function(){
  function read_cookie(){
    var id = $.cookie('podcast_' + PODCAST_ID + '_subscription');
    return id;
  }

  function update_cookie(id){
    $.cookie('podcast_' + PODCAST_ID + '_subscription', id);
  }

  function update_subscribe_button(link){
    var url  = link.attr('href');
    var type = link.parents('div').attr('id');
    var info = link.parents('li').find('p').text() + " - " + link.text();

    $("#subscribe a").attr("href", url);
    $("#subscribe p").html(type + " <span>(" + info + ")</span>");
    $("#subscribe").attr("class", type + "_feed");
  }

  function update_selected_link(link){
    $("#subscribe_options .pane a").removeClass("circle");
    link.addClass("circle");
  }

  var default_link = "#rss a.primary";
  var name = read_cookie() || default_link;
  var link = $(name);
  if( link.length != 1 ) {
    link = $(default_link);
  }
  update_subscribe_button(link);
  update_selected_link(link);
 
  if(name.match(/miro/)) {
    $('#subscribe_options').triggerTab(2);
  } else if(name.match(/rss/)) {
    $('#subscribe_options').triggerTab(3);
  }

  $("#subscribe_options .pane a").click(function(e){
    update_subscribe_button($(this));
    update_selected_link($(this));

    update_cookie("#" + $(this).attr('id'));

    $("#subscribe_options_container").slideUp("fast");
    $("#s_options_toggle").toggle();

    e.preventDefault();
  });

});

