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
    $(this).find('ul li:not(:first-child)').hide();
    $(this).find('ul li:first-child').addClass('selected');

    $(this).find('li.select').click(function() {
      field = $(this).parent();
      if (!$(this).hasClass('selected')) {
	selectElement($(this));
      }
      toggleDropDown($(this));
      return false;
    });

    function selectElement(me) {
      field = me.parent();
      field.find('li').removeClass('selected');
      me.prependTo(field);
      me.addClass('selected');
      updateUrl(me);
    }

    function toggleDropDown(me) {
      field = me.parent();
      if(field.hasClass('expanded')) {
        field.removeClass('expanded');
        field.find('li:not(:first-child)').hide();
      } else {
        field.addClass('expanded');
        field.find('li').show();
      }
    }

    var subscribe_url = function(me, delivery, id) {
      var url = me.find('#url_' + id).val();
      if(delivery == "Miro") {
        return "http://subscribe.getmiro.com/?url1=" + url;
      } else if(delivery == "iTunes") {
        var iTunes_id = me.find('#itunes_' + id).val();
        return "http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewPodcast?id=" + iTunes_id;
      }
      return url;
    };

    var download_url = function(me, delivery, base_url) {
      if(delivery == "Magnet") {
        return "magnet:?xs=" + base_url;
      }
      return base_url;
    };

    var updateUrl = function(me) {
      form = $(me).parent().parent().parent();
      var delivery = form.find('.delivery .selected').text();
      var format = form.find('.format .selected').attr('value');

      if(form.hasClass('download')) {
	form.find('.button.submit a')[0].href = download_url(form, delivery, format);
      } else {
        form.find('.button.submit a').attr('href', subscribe_url(form, delivery, format));
      }
    };

    return $(this);
  }
});
