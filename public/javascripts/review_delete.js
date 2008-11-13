$(document).ready(function(){
  $('li.review, div.review').map(function(){
    var review_li = $(this);

    review_li.find('a.delete')
      .show()
      .restfulDelete()
      .click(function(){
        review_li.replaceWith('');
        return false;
      });
  });
});

