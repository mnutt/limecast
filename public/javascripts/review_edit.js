$(document).ready(function(){
  $('li.review, div.review').map(function(){
    var show_div  = $(this).find('div.show');
    var edit_form = $(this).find('form.edit');

    show_div.find('a.edit').click(function(){
      show_div.hide();
      edit_form.show();

      return false;
    });

    edit_form.find('input.cancel').click(function(){
      show_div.show();
      edit_form.hide();
      return false;
    });

  });  
});

