/**
 * reflection.js v1.6 for jquery
 *
 * Contributors: Cow http://cow.neondragon.net
 *               Gfx http://www.jroller.com/page/gfx/
 *               Sitharus http://www.sitharus.com
 *               Andreas Linde http://www.andreaslinde.de
 *               Tralala, coder @ http://www.vbulletin.org
 *				 Danny Ferguson, jquery plugin http://www.brendoman.com/dbc
 *
 * Freely distributable under MIT-style license.
 */

jQuery.fn.reflect = function(settings) {
	settings = jQuery.extend({
		height: 0.5,
		opacity: 0.5,
		inline: false
	}, settings);
	
	this.each( function() {
		var rheight = null;
		var ropacity = null;
		
		if (settings["inline"])
		{
			for (j=0;j<classes.length;j++) {
				if (classes[j].indexOf("rheight") == 0) {
					settings["height"] = classes[j].substring(7)/100;
				} else if (classes[j].indexOf("ropacity") == 0) {
					settings["opacity"] = classes[j].substring(8)/100;
				}
			}
		}

		jQuery.Reflection.add(this, settings);
		
	})
	return this;
}

jQuery.Reflection = {
	
	add: function(image, options) {
		jQuery.Reflection.remove(image);
			
		try {
			var d = document.createElement('div');
			var p = image;
			
			var newClasses = p.className.replace(/reflect/gi, "");

			var reflectionHeight = Math.floor(p.height*options['height']);
			var divHeight = Math.floor(p.height*(1+options['height']));
			var reflectionWidth = p.width;
			
			if (document.all && !jQuery.browser.opera) {
				/* Copy original image's classes & styles to div */
				d.className = newClasses;
				p.className = 'reflected';
				
				d.style.cssText = p.style.cssText;
				p.style.cssText = 'vertical-align: bottom';
			
				var reflection = document.createElement('img');
				$(reflection).attr({src: p.src});
				$(reflection).css({width: reflectionWidth+'px', marginBottom: "-"+(p.height-reflectionHeight)+'px', filter: 'flipv progid:DXImageTransform.Microsoft.Alpha(opacity='+(options['opacity']*100)+', style=1, finishOpacity=0, startx=0, starty=0, finishx=0, finishy='+(options['height']*100)+')'});
				
				$(d).css({width: reflectionWidth+'px', height: divHeight+'px'});
				p.parentNode.replaceChild(d, p);
				
				$(d).append(p, reflection);
			} else {
				var canvas = document.createElement('canvas');
				if (canvas.getContext) {
					/* Copy original image's classes & styles to div */
					d.className = newClasses;
					p.className = 'reflected';
					
					d.style.cssText = p.style.cssText;
					p.style.cssText = 'vertical-align: bottom';
			
					var context = canvas.getContext("2d");
					
					$(canvas).css({height: reflectionHeight+'px', width: reflectionWidth+'px'})
					$(canvas).attr({height: reflectionHeight, width: reflectionWidth});
					
					$(d).css({width: reflectionWidth+'px', height: divHeight+'px'});
					p.parentNode.replaceChild(d, p);
					
					$(d).append(p, canvas);
					
					context.save();
					
					context.translate(0,image.height-1);
					context.scale(1,-1);
					
					context.drawImage(image, 0, 0, reflectionWidth, image.height);
	
					context.restore();
					
					context.globalCompositeOperation = "destination-out";
					var gradient = context.createLinearGradient(0, 0, 0, reflectionHeight);
					
					gradient.addColorStop(1, "rgba(255, 255, 255, 1.0)");
					gradient.addColorStop(0, "rgba(255, 255, 255, "+(1-options['opacity'])+")");
		
					context.fillStyle = gradient;
					if (jQuery.browser.safari) {
						context.fill();
					} else {
						context.fillRect(0, 0, reflectionWidth, reflectionHeight*2);
					}
				}
			}
		} catch (e) {
	    }
	},
	
	remove : function(image) {
		if (image.className == "reflected") {
			image.className = image.parentNode.className;
			image.parentNode.parentNode.replaceChild(image, image.parentNode);
		}
	}
}
