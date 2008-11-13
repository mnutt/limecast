$(document).ready(function(){
  $('li.review, div.review').map(function(){
    var show_div  = $(this).find('div.show');
    var edit_form = $(this).find('form.edit');

    show_div.find('a.edit').click(function(){
      show_div.hide();
      edit_form.show();

      return false;
    });

    if(this.tagName == 'LI'){
      edit_form.find('input.cancel').click(function(){
        show_div.show(); edit_form.hide();
        return false;
      });
    } else {
      edit_form.find('input.cancel').click(function(){
        window.location = edit_form.attr('action');
        return false;
      })
    };

    edit_form.submit(function(){
      show_div.show();
      edit_form.hide();

      $.ajax({
        type: 'post',
        url:  $(this).attr('action'),
        data: $(this).serialize()
      });

      var form_comment_title = $(this).find('#comment_title').val();
      var form_comment_body  = $(this).find('#comment_body').val().trim();
      form_comment_body = form_comment_body.replace(/\r\n?/g, "\n");
      form_comment_body = form_comment_body.replace(/\n+/g, "¶");

      show_div.find('h4').text(form_comment_title);
      show_div.find('.body').text(form_comment_body);

      return false;
    });
  });  
});

