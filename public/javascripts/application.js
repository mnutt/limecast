if(typeof Prototype=='undefined') throw("application.js requires the Prototype JavaScript framework.");

Lime = Class.create();
Lime.Widgets = Class.create();

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
    Event.observe(this.container, 'mouseover', function(event) {
      this._show();
      Event.stop(event);
    }.bind(this), false);
    Event.observe(this.container, 'mouseout', function(event) {
      this._startHideTimer();
      Event.stop(event);
    }.bind(this), false);
    Event.observe(this.anchor, 'mouseover', function(event) {
      this._show();
      Event.stop(event);
    }.bind(this), false);
    Event.observe(this.anchor, 'mouseout', function(event) {
      this._startHideTimer();
      Event.stop(event);
    }.bind(this), false);
    Event.observe(this.login_form, "submit", this._hide.bind(this), false);
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
