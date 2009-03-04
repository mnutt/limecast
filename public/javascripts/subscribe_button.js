$(function() {
  $tabs = $('#subscribe_options').tabs({
    fxFade: true,
    fxSpeed: 'fast'
  });
});

$(function(){
  var button   = $('#subscribe');
  var dropdown = $('#subscribe_options_container');

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

    button.attr("class", type + "_feed");
    button.find("a").attr("href", url);
    button.find("p").html(type + " <span>(" + info + ")</span>");
  }

  function update_selected_link(link){
    dropdown.find(".pane ul a").removeClass("circle");
    link.addClass("circle");
  }

  function select_tab(name) {
    dropdown.find(".tabs-nav li").removeClass("tabs-selected");
    dropdown.find("a." + name).parents("li").addClass("tabs-selected");
    dropdown.find(".tabs-container").addClass("tabs-hide").attr("style", "");
    dropdown.find(".tabs-container#" + name).removeClass("tabs-hide").css("display", "block");
  }

  function select_delivery(name) {
    dropdown.find("#rss ul.v_options_list").hide();
    dropdown.find("#rss ul.v_options_list." + name).show();

    $('.delivery_method input').attr('checked', '');
    $('.delivery_method input#'+name).attr('checked', 'checked');
  }

  var default_link = "rss .web a.primary";
  var name = "#" + (read_cookie() || default_link);

  var link = $(name);
  if( link.length != 1 ) {
    link = $(default_link);
  }
  update_subscribe_button(link);
  update_selected_link(link);
 
  if(name.match(/miro/)) {
    select_tab("miro");
  } else if(name.match(/rss/)) {
    select_tab("rss");

    if(name.match(/torrent/)) {
      select_delivery("torrent");
    } else if(name.match(/magnet/)) {
      select_delivery("magnet");
    } else {
      select_delivery("web");
    }
  }

  dropdown.find("input").click(function(){
    select_delivery($(this).attr('id'));
  });

  dropdown.find(".pane ul a").click(function(e){
    update_subscribe_button($(this));
    update_selected_link($(this));

    update_cookie($(this).attr('id'));

    dropdown.slideUp("fast");

    e.preventDefault();
  });

});

