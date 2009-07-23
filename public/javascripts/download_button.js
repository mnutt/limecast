$(function(){
  var updateDownloadAnchors = function(){
    $("#download div a").each(function(i, a){
      var type = $(this).attr('rel');
      var list = $("#download ." + type);
      var val  = list.find(".selected").attr('name');
      $(a).html(val + "&nbsp;▾");
    });
  };

  var updateDownloadButton = function(item){
    updateDownloadAnchors();
    
    // download link
    var formats = $('#download .formats .selected').attr('rel').split('|');
    switch($('#download .deliveries .selected').attr('rel')) {
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
    $(this).parent().hide().find('.selected').removeClass('selected');
    $(this).addClass('selected');
    updateDownloadButton();
    return false;
  });

  $("#download div a").click(function(e){
    $(this).focus().parent().find('ul').show();
  }).focus(function(e){
    $(this).parent().find('ul').show();
  }).blur(function(e){
    $(this).parent().find('ul').hide();
  });

  updateDownloadButton();
  // alert(document.createElement('video').nodeType);
});
