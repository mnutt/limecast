$(document).ready(function(){
  $('li.review, div.review').map(function(){
    var review_li = $(this);

    review_li.find('a.delete')
      .show()
      .restfulDelete({
        confirmed: function() {
          review_li.replaceWith('');
        }
      });
  });
});

