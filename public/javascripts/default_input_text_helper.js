// Sets up default text in input boxes
$(document).ready(function(){
  $('label.default').map(function(){
    var default_label = $(this);
    var input = $('#' + default_label.attr('for'));
  
    var set_to_blank = function(){
      if(input.val() == default_label.text())
        input.val('');
    };
  
    var set_to_label_text = function(){
      if(input.val() == '')
        input.val(default_label.text());
    };
  
    input.focus(set_to_blank);
    input.blur(set_to_label_text);
  
    set_to_label_text();
  });
});
