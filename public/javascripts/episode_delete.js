$(document).ready(function(){
  $('li.delete, div.delete').map(function(){
    var episode_delete = $(this);

    episode_delete.find('a.delete').restfulDelete().click(function(){
      window.location = $('#podcast_link a').attr('href');
    })
  });
});

