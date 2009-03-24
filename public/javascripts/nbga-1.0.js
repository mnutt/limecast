/**
 * nbga.js - Non-Blocking Google Analytics
 * http://925html.com/code/non-blocking-google-analytics-integration/
 * 
 * Copyright (c) 2008 Eric Ferraiuolo - http://eric.ferraiuolo.name
 * MIT License - http://www.opensource.org/licenses/mit-license.php
 * 
 * @version 1.0
 */

function ga( adapter ){
	
	// Private
	
	var _adapters, _defaults, _config, _initialized;
	
	_adapters = {
		
		yui3 : {
			merge : function( defaults, options ) {
				var result;
				YUI().use('object', function(Y){
					result = Y.merge( defaults, options );
				});
				return result;
			},
			getScript : function( url, callback ) {
				YUI().use('get', function(Y){
					Y.Get.script( url, { onSuccess : callback } );
				});
			}
		},
		
		yui2 : {
			merge : function( defaults, options ) {
				return YAHOO.lang.merge( defaults, options );
			},
			getScript : function( url, callback ) {
				YAHOO.util.Get.script( url, { onSuccess : callback } );
			}
		},
		
		jquery : {
			merge : function( defaults, options ) {
				return jQuery.extend( {}, defaults, options );
			},
			getScript : function( url, callback ) {
				jQuery.getScript( url, callback );
			}
		}
		
	};
	
	if ( typeof adapter !== 'undefined' ) {
		adapter = adapter;
	} else if ( typeof YUI !== 'undefined' ) {
		adapter = _adapters.yui3;
	} else if ( typeof YAHOO !== 'undefined' ) {
		adapter = _adapters.yui2;
	} else if ( typeof jQuery !== 'undefined' ) {
		adapter = _adapters.jquery;
	}
	
	_defaults = {
		url: {
			http: 'http://www.google-analytics.com/ga.js',
			https: 'https://ssl.google-analytics.com/ga.js'
		}
	};
	_config = null;
	_initialized = false;
	
	function init() {
		var isSecure, gaURL;
		
		isSecure = (document.location.protocol == 'https:');
		gaURL = (isSecure && _config.url.https) ? (_config.url.https || _config.url)
			: (_config.url.http || _config.url);
		
		adapter.getScript( gaURL, function(){
			_config.tracker = _gat._getTracker( _config.id );
			_initialized = true;
			while ( _config.queue.length > 0 )
				Public.track( _config.queue.shift() );
		} );
	}
	
	// Public
	
	var Public = {
		
		config: function( options ) {
			options = adapter.merge( _defaults, (options || {}) );
			if ( !_config && options.id ) {
				_config = options;
				_config.queue = [];
				init();
			}
			return this;
		},
		
		track: function( url ) {
			if ( _initialized ) {
				if ( url )
					_config.tracker._trackPageview( url );
				else
					_config.tracker._trackPageview();
			} else if ( _config ) {
				_config.queue.push( url || null );
			}
			return this;
		}
		
	};
	return Public;
	
}
