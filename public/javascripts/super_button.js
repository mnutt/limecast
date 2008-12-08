$.fn.extend({
  superButton: function(){
    /* Hide all unselected drop-down elements if they're not already hidden */
    $(this).find('ul li:not(:first-child)').hide();
    $(this).find('ul').each(function(ul) {
      /* Remove link visuals if there is only one element in the list */
      if($(this).find('li').length == 1) {
        $(this).find('li').addClass('single');
        $(this).find('li.single').click(function() { return false; });
      } else {
        /* First element gets the drop-down arrow */
        $(this).find('li:first-child').addClass('selected');
      }
    });

    function selectElement() {
      me = $(this);
      field = me.parent();
      if(!me.hasClass('selected')) {
        field.find('li').removeClass('selected');
        me.prependTo(field);
        me.addClass('selected');
        updateUrl(me);
      }

      if(field.hasClass('expanded')) {
        field.removeClass('expanded');
        field.find('li:not(:first-child)').hide();
      } else {
        field.addClass('expanded');
        field.find('li').show();
      }
      return false;
    };

    function updateUrl(me) {
      form = $(me).parent().parent().parent();
      var delivery = $.trim(form.find('.delivery .selected').text());
      var format = form.find('.format .selected input').attr('value');

      if(form.hasClass('download')) {
        form.find('.button.submit a')[0].href = downloadUrl(form, delivery, format);
      } else {
        form.find('.button.submit a').attr('href', subscribeUrl(form, delivery, format));
      }
    };

    function hideOrShowITunes(me, id) {
      if(me.find('#itunes_' + id).length) {
        me.find('.itunes_wrapper').show();
      } else {
        me.find('.itunes_wrapper').hide();
      }
    };

    function subscribeUrl(me, delivery, id) {
      hideOrShowITunes(me, id);
      var url = me.find('#url_' + id).val();
      if(delivery == "Miro") {
        return "http://subscribe.getmiro.com/?url1=" + url;
      } else if(delivery == "iTunes") {
        var iTunes_id = me.find('#itunes_' + id).val();
        return "http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewPodcast?id=" + iTunes_id;
      }
      return url;
    };

    function downloadUrl(me, delivery, base_url) {
      if(delivery == "Magnet") {
        return "magnet:?xs=" + base_url;
      }
      return base_url;
    };

    $(this).find('li.select').click(selectElement);

    if($(this).hasClass('subscribe')) {
      hideOrShowITunes($(this), $(this).find('span.format ul li.selected input').val());
    }

    return $(this);
  }
});
