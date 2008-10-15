jQuery.fn.extend({
  superButton: function(){
    jQuery(this).map(function(){
      var me = jQuery(this);

      function magnet_url(url){ return "magnet:?xs=" + url; }
      function miro_url(url)  { return "http://subscribe.getmiro.com/?url1=" + url; }
      function iTunes_url(id) { return "http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewPodcast?id=" + id; }

      hideOrShowITunes(me.find('select.id').val());

      me.find('select.id').change(function(){
        var id = jQuery(this).val();
        hideOrShowITunes(id);
      });

      function hideOrShowITunes(id) {
        if(me.find('#itunes_' + id).length) {
          me.find('option.itunes').show();
        } else {
          me.find('option.itunes').hide();
        }
      }

      jQuery(this).find('.submit').click(function(){
        var download = me.hasClass('download');
        var delivery = me.find('select.delivery').val();

        var url = "";

        alert(download);
        if(download) {
          url = me.find('select.url').val();

          switch(delivery) {
          case "magnet":
            url = magnet_url(url);
            break;
          }
        } else {
          var id = me.find('select.id').val();

          // Use rss feed as default url
          url = me.find('#url_' + id).val();

          switch(delivery) {
          case "miro":
            url = miro_url(url);
            break;
          case "itunes":
            var iTunes_id = me.find('#itunes_' + id).val();
            url = iTunes_url(iTunes_id);
            break;
          }
        }

        window.location = url;
      });
    });

    return jQuery(this);
  }
});
