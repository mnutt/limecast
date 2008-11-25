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
        data: $(this).serialize(),
      });

      var form_review_title = $(this).find('#review_title').val();
      var form_review_body  = $(this).find('#review_body').val();
      form_review_body = form_review_body.replace(/\r\n?/g, "\n");
      form_review_body = form_review_body.replace(/^[\n\t ]*/, '').replace(/[\n\t ]*$/, '')
      form_review_body = form_review_body.replace(/\n+/g, "¶");

      show_div.find('h4').text(form_review_title);
      show_div.find('.body').text(form_review_body);

      return false;
    });
  });  
});

