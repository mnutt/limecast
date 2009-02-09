$(document).ready(function(){
  opts = {
    confirm: 'Are you SURE you want to delete this episode? It will be removed from this podcast!',
    success: function() { window.location = $('#podcast_link a').attr('href'); }
  };
  $('span.delete a').restfulDelete(opts);
});