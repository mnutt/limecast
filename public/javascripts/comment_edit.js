jQuery(document).ready(function(){
  jQuery('li.review').map(function(){
    var show_div = jQuery(this).find('div.show_review');
    var edit_div = jQuery(this).find('div.edit_review');

    show_div.find('a.edit').click(function(){
      show_div.hide();
      edit_div.show();
      return false;
    });

    edit_div.find('form').submit(function(){
      show_div.show();
      edit_div.hide();

      jQuery.ajax({
        type: 'post',
        url:  jQuery(this).attr('action'),
        data: jQuery(this).serialize()
      });

      var form_comment_title = jQuery(this).find('#comment_title').val();
      var form_comment_body  = jQuery(this).find('#comment_body').val();

      show_div.find('h4').text(form_comment_title);
      show_div.find('span.comment_body').text(form_comment_body);

      return false;
    });
  });
});

