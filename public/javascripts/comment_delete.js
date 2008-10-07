jQuery(document).ready(function(){
  jQuery('li.review').map(function(){
    var review_li = jQuery(this);

    review_li.find('a.delete')
      .show()
      .restfulDelete()
      .click(function(){
        review_li.replaceWith('');
        return false;
      });
  });
});

