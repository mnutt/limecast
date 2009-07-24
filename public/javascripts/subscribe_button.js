$(function(){
  var updateSubscribeAnchors = function(){
    $("#subscribe div a").each(function(i, a){
      var type  = $(this).attr('rel');
      var li    = $("#subscribe ." + type).find("[selected=selected]");
      var text  = li.attr('name')  + "&nbsp;▾";
      var klass = li.attr('class');
      $(a).html(text).removeClass().addClass(klass);
    });
  };

  var updateSubscribeButton = function(item){
    updateSubscribeAnchors();
    
    // subscribe link
    var url = $('#subscribe .deliveries [selected=selected]').attr('rel');
    switch($('#subscribe .destinations [selected=selected]').attr('rel')) {
      case 'rss':
        $('#subscribe a.button').attr('href', url);
        break;
      case 'itunes':
        $('#subscribe a.button').attr('href', url.replace(/http/, 'itpc'));
        break;
      case 'miro':
        $('#subscribe a.button').attr('href', 'http://subscribe.getmiro.com/?url1=' + url);
        break;
    };
  };

  $("#subscribe li").mousedown(function(){
    $(this).parent().hide().find('[selected=selected]').attr('selected', null);
    $(this).attr('selected', 'selected');
    updateSubscribeButton();
    return false;
  });

  $("#subscribe div a").click(function(e){
    $(this).focus().parent().find('menu').show();
    return false;
  }).focus(function(e){
    $(this).parent().find('menu').show();
  }).blur(function(e){
    $(this).parent().find('menu').hide();
  });

  updateSubscribeButton();
});
