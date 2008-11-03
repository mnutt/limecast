jQuery(document).ready(function(){
  jQuery('li.review').map(function(){
    var show_div  = jQuery(this).find('div.show');
    var edit_form = jQuery(this).find('form.edit');

    show_div.find('a.edit').click(function(){
      show_div.hide();
      edit_form.show();
      return false;
    });

    edit_form.submit(function(){
      show_div.show();
      edit_form.hide();

      jQuery.ajax({
        type: 'post',
        url:  jQuery(this).attr('action'),
        data: jQuery(this).serialize()
      });

      var form_comment_title = jQuery(this).find('#comment_title').val();
      var form_comment_body  = jQuery(this).find('#comment_body').val();

      show_div.find('h4').text(form_comment_title);
      show_div.find('.body').text(form_comment_body);

      return false;
    });
  });
});

