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

/**************************************************************
* Search
**************************************************************/
jQuery(document).ready(function(){
  var search_box   = jQuery('input.search');
  var search_label = jQuery('label.search');

  var set_to_blank = function(){
    if(search_box.val() == search_label.text())
      search_box.val('');
  };

  var set_to_label_text = function(){
    if(search_box.val() == '')
      search_box.val(search_label.text());
  };

  search_box.focus(set_to_blank);
  search_box.blur(set_to_label_text);

  set_to_label_text();
});

/**************************************************************
* Quick Login
**************************************************************/
Lime.Widgets.QuickLogin = Class.create();
Object.extend(Lime.Widgets.QuickLogin.prototype, {
  isActive: false,
  hideTimer: null,
  initialize: function(container, options) {
    if (!$(container)) {
      throw(container+" doesn't exist.");
      return false;
    }
    this.container = $(container);
    this.anchor = $$("a.link_to_" + container)[0];
    this.login_form = $$("#" + this.container.id + " form")[0];
    this.signup_button = $$("#" + this.container.id + " .signup_button")[0];
    this.signin_button = $$("#" + this.container.id + " .signin_button")[0];
    this.login_buttons = $$("#" + this.container.id + " .login_buttons")[0];
    this.login_field = $$("#" + this.container.id + " .login_field")[0];
    this.login_input_field = $$("#" + this.container.id + " .login_input_field")[0];
    this.response_container = $$("#" + this.container.id + " .response_container")[0];
    this.close = $$("#" + this.container.id + " a.close")[0];
    this.options = Object.extend({
      autoFocus: true,
      opacity: 1.0,
      hideDelay: 1.0
    }, options || {});
    this._attach();
    if(this.anchor) { this._reset(); }
  },
  _reset: function() {
    this.container.hide();
    this.container.setStyle({opacity: '0'});
    this.login_form.reset();
    this.login_field.hide();
    this.response_container.update("");
    this.login_buttons.show();
    this._clearHideTimer();
    this.isActive = false;
  },
  _attach: function() {
    if(this.anchor) { // If there is an open/close button
      Event.observe(this.anchor, 'click', function(event) {
        this._show();
        Event.stop(event);
         Event.observe(document, 'click', function(event) {
           element = event.element();
           // TODO: It's supposed to bubble! Why won't it bubble???
           if(!element.ancestors().include(this.container)) {
             this._hide();
           }
         }.bind(this), false);
      }.bind(this), false);
      Event.observe(this.close, 'click', function(event) {
        this._hide();
        Event.stop(event);
      }.bind(this), false);
    }

    Event.observe(document, 'keypress', this._keypress.bindAsEventListener(this));

    Event.observe(this.login_form, 'submit', function(event) {
      Event.stop(event);
      this.signin_button.onClick();
    });

    Event.observe(this.signup_button, 'click', function() {
      if(!this.login_field.visible()) {
        this.login_field.show();
        this.login_input_field.focus();
        this.login_buttons.hide();
      } else {
        new Ajax.Updater(this.response_container,
			 '/users',
			 { asynchronous: true,
  			   method:       'post',
			   evalScripts:  true,
			   parameters:   Form.serialize(this.login_form) });
      }
    }.bind(this));

    Event.observe(this.signin_button, 'click', function(event) {
      Event.stop(event);
      new Ajax.Updater(this.response_container,
		       '/session',
		       { asynchronous:true,
                       evalScripts:true,
                       parameters:Form.serialize(this.login_form) });
    }.bind(this));
  },
  _keypress: function(event) {
    var code = event.keyCode;
    if (code === 27) {
      this._hide();
    }
  },
  _show: function() {
    if (this.isActive === false) {
      this.container.show();
      new Effect.Fade(this.container, {
        from: 0,
        to: this.options.opacity,
        duration: 0.1,
        afterFinish: function() {
          if (this.options.autoFocus === true) {
            this.login_form.focusFirstElement();
          }
        }.bind(this)
      });
      this.isActive = true;
    }
    this._clearHideTimer();
  },
  _hide: function() {
    new Effect.Fade(this.container, {
      from: this.options.opacity,
      to: 0,
      duration: 0.2,
      afterFinish: function() {
        this._reset();
      }.bind(this)
    });
  },
  _startHideTimer: function() {
    this.hideTimer = setTimeout(function() {
      this._hide();
    }.bind(this), (this.options.hideDelay*1000));
  },
  _clearHideTimer: function() {
    if (this.hideTimer) {
      clearTimeout(this.hideTimer);
      this.hideTimer = null;
    }
  }
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

/**************************************************************
* Add Podcast
**************************************************************/

// Lime.Widgets.Add = Class.create();
// Lime.Widgets.Add.Podcast = Class.create();
// Object.extend(Lime.Widgets.Add.Podcast, {
//   list: Array
// });
// Object.extend(Lime.Widgets.Add.Podcast.prototype, {
//   initialize: function() {
//     feed_url = $('podcast_feed_url').value;
//     $('new_podcast').reset();
//     form_html = $('form_clone').innerHTML.replace(/CHANGE/, feed_url);

//     status = Builder.node('div', { className: "status" });
//     form = Builder.node('div', { className: "form" });
//     form.innerHTML = form_html;
//     podcast = Builder.node('div', { className: "added_podcast" }, [ form, status ]);
//     $('added_podcast_list').appendChild(podcast);
//     this._updater = new Ajax.PeriodicalUpdater(status, '/status',
//                                                { method: 'get', frequency: 1, decay: 2, stopOnText: "status_message", postBody: feed_url });

//     if($('inline_login')) { $('inline_login').show(); }
//   }
// });