jQuery(document).ready(function() {
  jQuery('li.edit').click(function() {
    jQuery('#edit_form').toggle();
    return false;
  });
});