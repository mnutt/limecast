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
  var signin_container = jQuery('#quick_signin');

  function reset_container() {
    signin_container.hide();
    signin_container.find('.sign_up').hide();
    signin_container.find('form').attr('action', '/session');
    signin_container.find('input.signin_button').show();
  }

  signin_container.quickSignIn({
    success: function(resp){
      jQuery('#account_bar .signup').html(resp.html);
      reset_container();
    },
    error: function(resp){
      signin_container.find('.response_container').html(resp.html);
    }
  });

  // Keypress to handle pressing escape to close box.
  signin_container.find('input').keydown(function(e){
    if(e.keyCode == 27) { reset_container(); }
  });
  jQuery('#account_bar .signup').click(function(){
    if(signin_container.css('display') == 'none') {
      signin_container.show();
      signin_container.find('input.login').focus();
    } else {
      reset_container();
    }

    return false;
  });
  signin_container.find('a.close').click(function(){
    reset_container();
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
