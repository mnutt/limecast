jQuery.fn.extend({
  downloadSuperbutton: function() {
    this.each(function(){
      var button = $(this);
      
      var updateDownloadButton = function(item){
        // download anchors
        button.find("div a").each(function(i, a){
          var type  = $(this).attr('rel');
          var li    = button.find("." + type + " [selected=selected]");
          var text  = li.attr('name')  + "&nbsp;▾";
          var klass = li.attr('class');
          $(a).html(text).removeClass().addClass(klass);
        });

        // download link
        var formats = button.find('.formats [selected=selected]').attr('rel').split('|');
        switch(button.find('.deliveries [selected=selected]').attr('rel')) {
          case 'web':
            button.find('a.button').attr('href', formats[0]);
            break;
          case 'torrent':
            button.find('a.button').attr('href', formats[1]);
            break;
          case 'magnet':
            button.find('a.button').attr('href', formats[2]);
            break;
        };
        
        // download events
        button.find('li').mousedown(function(){
          $(this).parent().hide().find('[selected=selected]').attr('selected', null);
          $(this).attr('selected', 'selected');
          updateDownloadButton();
          return false;
        });

        button.find('div a').click(function(e){
          $(this).focus().parent().find('menu').show();
          return false;
        }).focus(function(e){
          $(this).parent().find('menu').show();
        }).blur(function(e){
          $(this).parent().find('menu').hide();
        });
      };

      updateDownloadButton();
    });
  },

  subscribeSuperbutton: function() {
    this.each(function(){
      var button = $(this);
      
      var updateSubscribeButton = function(item){
        // subscribe anchors
        button.find('div a').each(function(i, a){
          var type  = $(this).attr('rel');
          var li    = button.find("." + type + " [selected=selected]");
          var text  = li.attr('name')  + "&nbsp;▾";
          var klass = li.attr('class');
          $(a).html(text).removeClass().addClass(klass);
        });

        // subscribe link
        var url = button.find('.deliveries [selected=selected]').attr('rel');
        switch(button.find('.destinations [selected=selected]').attr('rel')) {
          case 'rss':
            button.find('a.button').attr('href', url);
            break;
          case 'itunes':
            button.find('a.button').attr('href', url.replace(/http/, 'itpc'));
            break;
          case 'miro':
            button.find('a.button').attr('href', 'http://subscribe.getmiro.com/?url1=' + url);
            break;
        };
        
        // subscribe events
        button.find('li').mousedown(function(){
          $(this).parent().hide().find('[selected=selected]').attr('selected', null);
          $(this).attr('selected', 'selected');
          updateSubscribeButton();
          return false;
        });

        button.find('div a').click(function(e){
          $(this).focus().parent().find('menu').show();
          return false;
        }).focus(function(e){
          $(this).parent().find('menu').show();
        }).blur(function(e){
          $(this).parent().find('menu').hide();
        });
      };

      updateSubscribeButton();
    });
  }
});


$(function() {
  $('.download.superbutton').downloadSuperbutton();
  $('.subscribe.superbutton').subscribeSuperbutton();
});