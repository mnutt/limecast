$(function(){
  var updateDownloadAnchors = function(){
    $("#download div a").each(function(i, a){
      var type  = $(this).attr('rel');
      var li    = $("#download ." + type).find("[selected=selected]");
      var text  = li.attr('name')  + "&nbsp;▾";
      var klass = li.attr('class');
      $(a).html(text).removeClass().addClass(klass);
    });
  };

  var updateDownloadButton = function(item){
    updateDownloadAnchors();
    
    // download link
    var formats = $('#download .formats [selected=selected]').attr('rel').split('|');
    switch($('#download .deliveries [selected=selected]').attr('rel')) {
      case 'web':
        $('#download a.button').attr('href', formats[0]);
        break;
      case 'torrent':
        $('#download a.button').attr('href', formats[1]);
        break;
      case 'magnet':
        $('#download a.button').attr('href', formats[2]);
        break;
    };
  };

  $("#download li").mousedown(function(){
    $(this).parent().hide().find('[selected=selected]').attr('selected', null);
    $(this).attr('selected', 'selected');
    updateDownloadButton();
    return false;
  });

  $("#download div a").click(function(e){
    $(this).focus().parent().find('menu').show();
    return false;
  }).focus(function(e){
    $(this).parent().find('menu').show();
  }).blur(function(e){
    $(this).parent().find('menu').hide();
  });

  updateDownloadButton();
});
