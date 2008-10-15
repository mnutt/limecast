jQuery.fn.extend({
  superButton: function(){
    var me = jQuery(this);

    function magnet_url(url){ return "magnet:?xs=" + url; }

    jQuery(this).find('.submit').click(function(){
      var delivery = me.find('select.delivery').val();
      var url      = me.find('select.format').val();

      switch(delivery) {
        case "magnet":
          url = magnet_url(url);
          break;
      }

      window.location = url;
    });
  }
})
