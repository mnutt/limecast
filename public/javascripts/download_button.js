$(function(){
  var updateDownloadLabels = function(){
    $("#download label").each(function(i, label){
      var type = $(this).attr('for');
      var select = $("#download select#" + type);
      var val  = select[0].options[select[0].selectedIndex].innerHTML;
      $(label).html(val + "&nbsp;▾");
    });
  };

  var updateDownloadButton = function(){
    updateDownloadLabels();

    // download link
    var formats = $('#download select#format').val().split('|');
    switch($('#download select#delivery').val()) {
      case 'web':
        $('#download a.submit').attr('href', formats[0]);
        break;
      case 'torrent':
        $('#download a.submit').attr('href', formats[1]);
        break;
      case 'magnet':
        $('#download a.submit').attr('href', formats[2]);
        break;
    };
  };

  $("#download select").change(updateDownloadButton);
  updateDownloadButton();
});

