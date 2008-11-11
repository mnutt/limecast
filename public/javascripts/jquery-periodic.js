/* 
 * jquery-periodic.js 
 * 
 * Adds a "periodic" function to $ which takes a callback and options for the frequency (in seconds) and a 
 * boolean for allowing parallel execution of the callback function (shielded from exceptions by a try..finally block. 
 * The first parameter passed to the callback is a controller object. 
 * 
 * Return falsy value from the callback function to end the periodic execution. 
 * 
 * For a callback which initiates an asynchronous process: 
 * There is a boolean in the controller object which will prevent the callback from executing while it is "true". 
 *   Be sure to reset this boolean to false when your asynchronous process is complete, or the periodic execution 
 *   won't continue. 
 * 
 * To stop the periodic execution, you can also call the "stop" method of the controller object, instead of returning 
 * false from the callback function. 
 * 
 */ 
$.periodic = function (callback, options) {
  callback = callback || (function() { return false; }); 
  options = $.extend({}, { frequency: 10, allowParallelExecution: false }, options); 

  var currentlyExecuting = false; 
  var timer; 
  var controller = { 
    stop: function () { 
      if(timer) { 
        window.clearInterval(timer); 
        timer = null; 
      } 
    }, 
    currentlyExecuting: false, 
    currentlyExecutingAsync: false 
  }; 
  timer = window.setInterval(function() { 
    if(options.allowParallelExecution || !(controller.currentlyExecuting || controller.currentlyExecutingAsync)) { 
      try { 
        controller.currentlyExecuting = true; 
        if(!(callback(controller))) { controller.stop(); } 
      } finally { 
        controller.currentlyExecuting = false; 
      } 
    } 
  },
  options.frequency * 1000); 
};

