
function update_selected_link(link){
  $("#download_dropdown a").removeClass("circle");
  link.addClass("circle");
}

function update_selected_type(type){
  $("input[type=radio][value=" + type + "]").attr("checked", "checked");
}

function downloadUrl(delivery, id) {
  if(delivery == "LimeWire") {
    return $('#' + id + '_magnet').attr('href');
  }
  return $('#' + id).attr('href');
};

function read_cookie(){
  var id = $.cookie('podcast_' + PODCAST_ID + '_download');
  return id;
}

function update_cookie(id){
  $.cookie('podcast_' + PODCAST_ID + '_download', id);
}

function update_download_button(link, type){
  var url  = link.attr('href');
  var info = link.parents('li:first').find('p').text() + " - " + link.text();

  $("#download_button a.download").attr("href", downloadUrl(type, link.attr('id')));
  $("#download_button a.download span").text(type + " | " + info);
}

$(function(){
  var default_link = "#download_dropdown li a:first-child";
  var default_type = "Web";
  var cookie = read_cookie();
  // Sets the default download link on the page
  var name = default_link;
  if(cookie) { name = "#" + cookie.split(',')[0]; }

  var link = $(name);
  if(link.length != 1) {
    link = $(default_link);
  }

  // Sets the download type on the page
  var type = default_type;
  if(cookie) {
    type = cookie.split(',')[1];
  }

  update_download_button(link, type);
  update_selected_link(link);
  update_selected_type(type);

  $("#download_dropdown li a").click(function(e) {
    var type = $("input[type=radio]:checked").attr('value');
    update_download_button($(this), type);
    update_selected_link($(this));

    // XXX: %23 is # ... Doesnt seem to be working in firefox. Bug with encoding? should be able to take '#' out.
    update_cookie($(this).attr('id') + "," + type);
  });

  $("#download_button a.opener, #download_dropdown a").click(function() {
    $("#download_dropdown").toggle()
    return false;
  });
});

