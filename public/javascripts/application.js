if(typeof Prototype=='undefined') throw("application.js requires the Prototype JavaScript framework.");

Lime = Class.create();
Lime.Widgets = Class.create();

/**************************************************************
* Hover/Focus Behaviors
**************************************************************/
Lime.Widgets.Behaviors = Class.create();
Object.extend(Lime.Widgets.Behaviors.prototype, {
  initialize: function(options) {
    this.options = Object.extend({
      prefix: '_',
      classNames: {
        hover: 'hover',
        focus: 'focus'
      }
    }, options || {});
    this._attach();
  },
  _attach: function() {
    this.elements = $$('input, textarea, button');
    this.elements.each(function(element) {
      var type = element.readAttribute('type');
      if (type != 'hidden') {
        if (type == 'image') {
          var filename = element.readAttribute('src');
          var dot = filename.lastIndexOf('.');
          var filename_hover = filename.substr(0, dot) + this.options.prefix + this.options.classNames.hover + filename.substr(dot);
          var filename_focus = filename.substr(0, dot) + this.options.prefix + this.options.classNames.focus + filename.substr(dot);
        }
        Event.observe(element, 'mouseover', function(event) {
          if (type == 'image') element.writeAttribute('src', filename_hover);
          element.addClassName(this.options.classNames.hover);
        }.bind(this));
        Event.observe(element, 'mouseout', function(event) {
          if (type == 'image') element.writeAttribute('src', filename);
          element.removeClassName(this.options.classNames.hover);
        }.bind(this));
        Event.observe(element, 'focus', function(event) {
          if (type == 'image') element.writeAttribute('src', filename_focus);
          element.removeClassName(this.options.classNames.hover)
                 .addClassName(this.options.classNames.focus);
        }.bind(this));
        Event.observe(element, 'blur', function(event) {
          if (type == 'image') element.writeAttribute('src', filename);
          element.removeClassName(this.options.classNames.hover)
                 .removeClassName(this.options.classNames.focus);
        }.bind(this));
      }
    }.bind(this));
  }
});

jQuery(document).ready(function(){
  var login_box      = jQuery('#quick_signin');
  var show_box_link  = jQuery('a.sign_up');
  var close_box_link = login_box.find('a.close');
  var sign_in_button = login_box.find('input.signin_button');
  var sign_up_button = login_box.find('input.signup_button');
  var sign_up_fields = login_box.find('.sign_up');
  var login_field    = login_box.find('#user_login');
  var email_field    = login_box.find('.sign_up input');
  var form           = login_box.find('form');

  // Keypress to handle pressing escape to close box.
  login_box.find('input').keydown(function(e){
    if(e.keyCode == 27)
      login_box.hide();
  });

  // When any of the appropriate things are clicked, the login box will disappear.
  jQuery.each([show_box_link,close_box_link], function(i, x){
    x.click(function(){
      sign_up_fields.hide();
      sign_in_button.show();
      login_box.toggle();
      login_field.focus();
      form.attr('action', '/sessions');

      return false;
    });
  });

  sign_up_button.click(function(){
    // We only want to submit the form if the sign in button is no longer there.
    var should_submit = sign_in_button.css('display') == 'none';

    sign_up_fields.show();
    email_field.focus();
    sign_in_button.hide();
    form.attr('action', '/users');

    return should_submit;
  });

  form.bind('submit', function(){
    jQuery.ajax({
      type:    'post',
      url:     jQuery(this).attr('action'),
      data:    jQuery(this).serialize(),
      dataType: "json",
      success: function(resp){
        if(resp.success) {
          jQuery('#account_bar .signup').html(resp.html);
          login_box.hide();
        } else {
          login_box.find('div.response_container').html(resp.html);
        }
      }
    });

    return false;
  });
});

/**************************************************************
* Toggle
**************************************************************/
jQuery(document).ready(function(){
  jQuery('li.expandable').map(function(){
    var expandable_li = jQuery(this);

    expandable_li.find('span.expand').click(function(){
      if(expandable_li.hasClass('expanded')) {
        expandable_li.removeClass('expanded');
        expandable_li.find('span.expand').text('Collapse');
      } else {
        expandable_li.addClass('expanded');
        expandable_li.find('span.expand').text('Expand');
      }
    });
  });
});

// Load defaults
document.observe('dom:loaded', function() {
  new Lime.Widgets.Behaviors;
});
