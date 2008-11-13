$.fn.extend({
  updateDeliveryForSubscribe: function(){
    var me = $(this);

    function hideOrShowITunes(id) {
      if(me.find('#itunes_' + id).length) {
        me.find('option.itunes').show();
      } else {
        me.find('option.itunes').hide();
      }
    }

    hideOrShowITunes(me.find('select.id').val());

    me.find('select.id').change(function(){
      var id = $(this).val();
      hideOrShowITunes(id);
    });
  },

  superButton: function(){
    var subscribe_url = function(me, delivery, id) {
      var url = me.find('#url_' + id).val();
      if(delivery == "miro") {
        return "http://subscribe.getmiro.com/?url1=" + url;
      } else if(delivery == "itunes") {
        var iTunes_id = me.find('#itunes_' + id).val();
        return "http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewPodcast?id=" + iTunes_id;
      }
      return url;
    };

    var download_url = function(me, delivery, base_url) {
      if(delivery == "magnet") {
        return "magnet:?xs=" + base_url;
      }
      return base_url;
    };

    
    $(this).map(function(){
      me = $(this);
      
      update_url = function() {
        console.log("changing select");
        var delivery = me.find('select.delivery').val();
        var item = me.find('select.item').val();

        if(me.hasClass('download')) {
          me.find('a.super_button_button')[0].href = download_url(me, delivery, item);
        } else {
          me.find('a.super_button_subscribe').attr('href', subscribe_url(me, delivery, item));
        }
      }

      me.find('select').change(update_url);

      me.find('select').each(update_url);
    });

    return $(this);
  }
});
