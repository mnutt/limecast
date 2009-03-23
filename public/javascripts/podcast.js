function podcastEpisodeSorting() {
  var title = { "bSortable": false };
  var description = { "bVisible":    false, "bSortable": false };
  var runtime = { "bSortable": false };
  var date_released = null;

  $('#podcast_episodes').dataTable({
    "aaSorting": [[ 3, "desc" ]],
    "aoColumns": [ title, description, runtime, date_released ],
    "bStateSave": true,
    "bProcessing": true
  });
}

$(document).ready(function() {
  podcastEpisodeSorting();
}