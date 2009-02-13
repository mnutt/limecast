$(function() {
  $tabs = $('#subscribe_options').tabs({
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
    var info = link.parents('li:first').find('p').text() + " - " + link.text();

    $("#subscribe a").attr("href", url);
    $("#subscribe p").html(type + " <span>(" + info + ")</span>");
    $("#subscribe").attr("class", type + "_feed");
  }

  function update_selected_link(link){
    $("#subscribe_options .pane a").removeClass("circle");
    link.addClass("circle");
  }

  function select_tab(name) {
    $('#subscribe_options .tabs-nav li').removeClass("tabs-selected");
    $('#subscribe_options a.' + name).parents("li").addClass("tabs-selected");
    $('#subscribe_options .tabs-container').addClass("tabs-hide").attr("style", "");
    $('#subscribe_options .tabs-container#' + name).removeClass("tabs-hide").css("display", "block");
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
    //$('#subscribe_options').triggerTab(2);
    select_tab("miro");
  } else if(name.match(/rss/)) {
    select_tab("rss");
  }

  $("#subscribe_options .pane a").click(function(e){
    update_subscribe_button($(this));
    update_selected_link($(this));

    // XXX: %23 is # ... Doesnt seem to be working in firefox. Bug with encoding? should be able to take '#' out.
    update_cookie("#" + $(this).attr('id'));

    $("#subscribe_options_container").slideUp("fast");

    e.preventDefault();
  });

});

