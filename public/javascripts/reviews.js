$(document).ready(function(){
  // review rating links
  $('li.review').map(function(){
    var review = $(this);

    review.find('a.rate').click(function(){
      var link = $(this);
      var id = link.attr('rel');

      $.ajax({
        url: link.attr('href'),
        dataType: 'json',
        success: function(resp,ev) {
          if(resp.logged_in) {
            window.location.reload();
          } else {
            // if not logged in, show quick signin
            $.quickSignIn.attach($('li#review_'+id+' .quick_signin_container.after_rating'), 
              {message:'Sign up or sign in to rate this review.'});
          }
        }
      });

      return false;
    });
  });


  var enableReviewLinks = function() {
    // review form toggle
    $('li.review, div.review').map(function(){
      var review_form = $(this);
      var show        = $(this).find('.show_review');
      var edit        = $(this).find('.edit_review');

      show.find('a.edit').click(function(){
        show.hide(); edit.show(); return false;
      });

      show.find('a.delete').restfulDelete({
        success: function(resp){ 
          alert(resp.html);
          $('.reviews.list').replaceWith(resp.html).css('border', 'solid 1px red');
          enableReviewLinks('li.review, div.review');
          enableReviewForm('.review_form');
        }
      });

      edit.find('a.cancel').click(function(){
        show.show(); edit.hide(); return false;
      });
    });  
  };

  var enableReviewForm = function() {
    // review form ajax
    $('.review_form').submit(function(){
      var review_form = $(this);

      // setup the cluetip link
      review_form.find('.cluetip_link').cluetip({
        local: true, 
        hideLocal: true, 
        arrows: true, 
        width: 350,  
        sticky: true,
        showTitle: false, 
        activation: 'click', 
        topOffset: -100,
        onShow: function(){ $.quickSignIn.setup(); }
      })

      // send the review create/update
      $.ajax({
        type:    'post',
        url:     review_form.attr('action'),
        data:    review_form.serialize(),
        dataType: 'json',
        success: function(resp){
          if(resp.success) {
            if(resp.login_required) {
              review_form.find('.cluetip_link').click();
            } else { 
              $('.reviews.list').replaceWith(resp.html);
              enableReviewLinks('li.review, div.review');
              enableReviewForm('.review_form');
            };
          } else {
            review_form.find('.errors').html(resp.errors).show();
          }
        }
      });
      return false;
    });
  ;}
  
  // enable 'new review'/'edit review' links
  enableReviewLinks();

  // enable 'new review'/'edit review' form
  enableReviewForm();


  // REFACTOR with Events/live when we switch to JQuery 1.3
});

