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
Lime.Widgets.Search = Class.create();
Object.extend(Lime.Widgets.Search.prototype, {
  initialize: function(container) {
    if (!$(container)) {
      throw(container+" doesn't exist.");
      return false;
    }
    this.container = $(container);
    if(this.container.value == '') {
      this._attach();
    }
  },
  _attach: function() {
    this.label = this.container.previous();
    this.label.hide();
    this.text = this.label.innerHTML;
    this.container.value = this.text;
    Event.observe(this.container, 'focus', function(event) {
      if (this.container.value == this.text) this.container.value = '';
      Event.stop(event);
    }.bind(this));
    Event.observe(this.container, 'blur', function(event) {
      if (this.container.value == '') this.container.value = this.text;
      Event.stop(event);
    }.bind(this));
  }
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
    this.anchor = $$("a." + this.container.id)[0];
    this.login_form = $$("#" + this.container.id + " form")[0];
    this.options = Object.extend({
      autoFocus: true,
      opacity: 1.0,
      hideDelay: 1.0
    }, options || {});
    this._attach();
    this._reset();
  },
  _reset: function() {
    this.container.hide();
    this.container.setStyle({opacity: '0'});
    this._clearHideTimer();
    this.isActive = false;
  },
  _attach: function() {
    Event.observe(this.anchor, 'click', function(event) {
      this._show();
      Event.stop(event);
      Event.observe(document, 'click', function(event) {
        element = event.element();
        // TODO: It's supposed to bubble! Why won't it bubble???
        if(!element.ancestors().include($('quick_signin'))) {
          this._hide();
        }
      }.bind(this), false);
    }.bind(this), false);
    // Event.observe(this.login_form, "submit", this._hide.bind(this), false);
    Event.observe(document, 'keypress', this._keypress.bindAsEventListener(this));
  },
  _keypress: function(event) {
    var code = event.keyCode;
    if (code === 27) {
      this._hide();
    } else if (code === 9) {
      this._show();
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
Lime.Widgets.Toggle = Class.create();
Object.extend(Lime.Widgets.Toggle.prototype, {
  initialize: function(options) {
    this.options = Object.extend({
      toggle: 'span.expand',
      classNames: {
        expanded: 'expanded'
      }
    }, options || {});
    this._attach();
  },
  _attach: function() {
    $$(this.options.toggle).each(function(toggle) {
      var me = $(toggle), parent = me.up();
      me.update((parent.hasClassName(this.options.classNames.expanded))? 'Collapse' : 'Expand');
      toggle.observe('click', function(event) {
        if (parent.hasClassName(this.options.classNames.expanded) == true) {
          parent.removeClassName(this.options.classNames.expanded);
          me.update('Expand');
        } else {
          parent.addClassName(this.options.classNames.expanded);
          me.update('Collapse');
        }
        Event.stop(event);
      }.bind(this));
    }.bind(this));
  }
});

// Load defaults
document.observe('dom:loaded', function() {
  new Lime.Widgets.Behaviors;
  new Lime.Widgets.Toggle;
});