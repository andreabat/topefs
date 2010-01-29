/*
 * Ext JS Library 2.0.1
 * Copyright(c) 2006-2007, Ext JS, LLC.
 * licensing@extjs.com
 *
 * http://extjs.com/license
 */

/**
 * @class Ext.EventManager
 * Registers event handlers that want to receive a normalized EventObject instead of the standard browser event and provides
 * several useful events directly.
 * See {@link Ext.EventObject} for more details on normalized event objects.
 * @singleton
 */
Ext.EventManager = function(){
    var docReadyEvent, docReadyProcId, docReadyState = false;
    var resizeEvent, resizeTask, textEvent, textSize;
    var E = Ext.lib.Event;
    var D = Ext.lib.Dom;


    var fireDocReady = function(){

        if(!docReadyState){
            docReadyState = Ext.isReady = true;
            if(Ext.isGecko || Ext.isOpera) {
                document.removeEventListener("DOMContentLoaded", fireDocReady, false);
            }
        }
        if(docReadyProcId){
            clearInterval(docReadyProcId);
            docReadyProcId=null;
        }

        if(docReadyEvent){
            docReadyEvent.fire();
            docReadyEvent.clearListeners();
       }
    };

    var initDocReady = function(){
        docReadyEvent = new Ext.util.Event();

        if(Ext.isReady)return;

        E.on(window, "load", fireDocReady);

        if(Ext.isGecko || Ext.isOpera) {
            document.addEventListener("DOMContentLoaded", fireDocReady, false);

        }else if(Ext.isIE){

           docReadyProcId = setInterval(function(){

                  try {
                      // throws errors until after ondocumentready
                     Ext.isReady || ( document.documentElement.doScroll('left') );

                  } catch (e) {
                      return;
                  }

                  fireDocReady();  // no errors, fire

            }, 5);

            document.onreadystatechange = function() {
                  if (document.readyState == 'complete') {
                      document.onreadystatechange = null;
                      fireDocReady();
                  }
            };

        }else if(Ext.isSafari){
            docReadyProcId = setInterval(function(){
                var rs = document.readyState;
                if(rs == "complete") {
                    fireDocReady();
                 }
            }, 10);

        }

    };

    var createBuffered = function(h, o){
        var task = new Ext.util.DelayedTask(h);
        return function(e){
            // create new event object impl so new events don't wipe out properties
            e = new Ext.EventObjectImpl(e);
            task.delay(o.buffer, h, null, [e]);
        };
    };

    var createSingle = function(h, el, ename, fn){
        return function(e){
            Ext.EventManager.removeListener(el, ename, fn);
            h(e);
        };
    };

    var createDelayed = function(h, o){
        return function(e){
            // create new event object impl so new events don't wipe out properties
            e = new Ext.EventObjectImpl(e);
            setTimeout(function(){
                h(e);
            }, o.delay || 10);
        };
    };

    var listen = function(element, ename, opt, fn, scope){
        var o = (!opt || typeof opt == "boolean") ? {} : opt;
        fn = fn || o.fn; scope = scope || o.scope;
        var el = Ext.getDom(element);
        if(!el){
            throw "Error listening for \"" + ename + '\". Element "' + element + '" doesn\'t exist.';
        }
        var h = function(e){
            e = Ext.EventObject.setEvent(e);
            var t;
            if(o.delegate){
                t = e.getTarget(o.delegate, el);
                if(!t){
                    return;
                }
            }else{
                t = e.target;
            }
            if(o.stopEvent === true){
                e.stopEvent();
            }
            if(o.preventDefault === true){
               e.preventDefault();
            }
            if(o.stopPropagation === true){
                e.stopPropagation();
            }

            if(o.normalized === false){
                e = e.browserEvent;
            }

            fn.call(scope || el, e, t, o);
        };
        if(o.delay){
            h = createDelayed(h, o);
        }
        if(o.single){
            h = createSingle(h, el, ename, fn);
        }
        if(o.buffer){
            h = createBuffered(h, o);
        }
        fn._handlers = fn._handlers || [];
        fn._handlers.push([Ext.id(el), ename, h]);

        E.on(el, ename, h);
        if(ename == "mousewheel" && el.addEventListener){ // workaround for jQuery
            el.addEventListener("DOMMouseScroll", h, false);
            E.on(window, 'unload', function(){
                el.removeEventListener("DOMMouseScroll", h, false);
            });
        }
        if(ename == "mousedown" && el == document){ // fix stopped mousedowns on the document
            Ext.EventManager.stoppedMouseDownEvent.addListener(h);
        }
        return h;
    };

    var stopListening = function(el, ename, fn){
        var id = Ext.id(el), hds = fn._handlers, hd = fn;
        if(hds){
            for(var i = 0, len = hds.length; i < len; i++){
                var h = hds[i];
                if(h[0] == id && h[1] == ename){
                    hd = h[2];
                    hds.splice(i, 1);
                    break;
                }
            }
        }
        E.un(el, ename, hd);
        el = Ext.getDom(el);
        if(ename == "mousewheel" && el.addEventListener){
            el.removeEventListener("DOMMouseScroll", hd, false);
        }
        if(ename == "mousedown" && el == document){ // fix stopped mousedowns on the document
            Ext.EventManager.stoppedMouseDownEvent.removeListener(hd);
        }
    };

    var propRe = /^(?:scope|delay|buffer|single|stopEvent|preventDefault|stopPropagation|normalized|args|delegate)$/;
    var pub = {

    /**
     * Appends an event handler to an element.  The shorthand version {@link #on} is equivalent.  Typically you will
     * use {@link Ext.Element#addListener} directly on an Element in favor of calling this version.
     * @param {String/HTMLElement} el The html element or id to assign the event handler to
     * @param {String} eventName The type of event to listen for
     * @param {Function} handler The handler function the event invokes
     * @param {Object} scope (optional) The scope in which to execute the handler
     * function (the handler function's "this" context)
     * @param {Object} options (optional) An object containing handler configuration properties.
     * This may contain any of the following properties:<ul>
     * <li>scope {Object} : The scope in which to execute the handler function. The handler function's "this" context.</li>
     * <li>delegate {String} : A simple selector to filter the target or look for a descendant of the target</li>
     * <li>stopEvent {Boolean} : True to stop the event. That is stop propagation, and prevent the default action.</li>
     * <li>preventDefault {Boolean} : True to prevent the default action</li>
     * <li>stopPropagation {Boolean} : True to prevent event propagation</li>
     * <li>normalized {Boolean} : False to pass a browser event to the handler function instead of an Ext.EventObject</li>
     * <li>delay {Number} : The number of milliseconds to delay the invocation of the handler after te event fires.</li>
     * <li>single {Boolean} : True to add a handler to handle just the next firing of the event, and then remove itself.</li>
     * <li>buffer {Number} : Causes the handler to be scheduled to run in an {@link Ext.util.DelayedTask} delayed
     * by the specified number of milliseconds. If the event fires again within that time, the original
     * handler is <em>not</em> invoked, but the new handler is scheduled in its place.</li>
     * </ul><br>
     * <p>See {@link Ext.Element#addListener} for examples of how to use these options.</p>
     */
        addListener : function(element, eventName, fn, scope, options){
            if(typeof eventName == "object"){
                var o = eventName;
                for(var e in o){
                    if(propRe.test(e)){
                        continue;
                    }
                    if(typeof o[e] == "function"){
                        // shared options
                        listen(element, e, o, o[e], o.scope);
                    }else{
                        // individual options
                        listen(element, e, o[e]);
                    }
                }
                return;
            }
            return listen(element, eventName, options, fn, scope);
        },

        /**
         * Removes an event handler from an element.  The shorthand version {@link #un} is equivalent.  Typically
         * you will use {@link Ext.Element#removeListener} directly on an Element in favor of calling this version.
         * @param {String/HTMLElement} el The id or html element from which to remove the event
         * @param {String} eventName The type of event
         * @param {Function} fn The handler function to remove
         * @return {Boolean} True if a listener was actually removed, else false
         */
        removeListener : function(element, eventName, fn){
            return stopListening(element, eventName, fn);
        },

        /**
         * Fires when the document is ready (before onload and before images are loaded). Can be
         * accessed shorthanded as Ext.onReady().
         * @param {Function} fn The method the event invokes
         * @param {Object} scope (optional) An object that becomes the scope of the handler
         * @param {boolean} options (optional) An object containing standard {@link #addListener} options
         */
         onDocumentReady : function(fn, scope, options){
            if(!docReadyEvent){
                    initDocReady();
                }

            if(docReadyState || Ext.isReady){ // if it already fired
                options || (options = {});
                fn.defer(options.delay||0,scope);
            }else{

                docReadyEvent.addListener(fn, scope, options);
            }
        },


        /**
         * Fires when the window is resized and provides resize event buffering (50 milliseconds), passes new viewport width and height to handlers.
         * @param {Function} fn        The method the event invokes
         * @param {Object}   scope    An object that becomes the scope of the handler
         * @param {boolean}  options
         */
        onWindowResize : function(fn, scope, options){
            if(!resizeEvent){
                resizeEvent = new Ext.util.Event();
                resizeTask = new Ext.util.DelayedTask(function(){
                    resizeEvent.fire(D.getViewWidth(), D.getViewHeight());
                });
                E.on(window, "resize", this.fireWindowResize, this);
            }
            resizeEvent.addListener(fn, scope, options);
        },

        // exposed only to allow manual firing
        fireWindowResize : function(){
            if(resizeEvent){
                if((Ext.isIE||Ext.isAir) && resizeTask){
                    resizeTask.delay(50);
                }else{
                    resizeEvent.fire(D.getViewWidth(), D.getViewHeight());
                }
            }
        },

        /**
         * Fires when the user changes the active text size. Handler gets called with 2 params, the old size and the new size.
         * @param {Function} fn        The method the event invokes
         * @param {Object}   scope    An object that becomes the scope of the handler
         * @param {boolean}  options
         */
        onTextResize : function(fn, scope, options){
            if(!textEvent){
                textEvent = new Ext.util.Event();
                var textEl = new Ext.Element(document.createElement('div'));
                textEl.dom.className = 'x-text-resize';
                textEl.dom.innerHTML = 'X';
                textEl.appendTo(document.body);
                textSize = textEl.dom.offsetHeight;
                setInterval(function(){
                    if(textEl.dom.offsetHeight != textSize){
                        textEvent.fire(textSize, textSize = textEl.dom.offsetHeight);
                    }
                }, this.textResizeInterval);
            }
            textEvent.addListener(fn, scope, options);
        },

        /**
         * Removes the passed window resize listener.
         * @param {Function} fn        The method the event invokes
         * @param {Object}   scope    The scope of handler
         */
        removeResizeListener : function(fn, scope){
            if(resizeEvent){
                resizeEvent.removeListener(fn, scope);
            }
        },

        // private
        fireResize : function(){
            if(resizeEvent){
                resizeEvent.fire(D.getViewWidth(), D.getViewHeight());
            }
        },
        /**
         * Url used for onDocumentReady with using SSL (defaults to Ext.SSL_SECURE_URL)
         */
        ieDeferSrc : false,
        /**
         * The frequency, in milliseconds, to check for text resize events (defaults to 50)
         */
        textResizeInterval : 50
    };
     /**
     * Appends an event handler to an element.  Shorthand for {@link #addListener}.
     * @param {String/HTMLElement} el The html element or id to assign the event handler to
     * @param {String} eventName The type of event to listen for
     * @param {Function} handler The handler function the event invokes
     * @param {Object} scope (optional) The scope in which to execute the handler
     * function (the handler function's "this" context)
     * @param {Object} options (optional) An object containing standard {@link #addListener} options
     * @member Ext.EventManager
     * @method on
     */
    pub.on = pub.addListener;
    /**
     * Removes an event handler from an element.  Shorthand for {@link #removeListener}.
     * @param {String/HTMLElement} el The id or html element from which to remove the event
     * @param {String} eventName The type of event
     * @param {Function} fn The handler function to remove
     * @return {Boolean} True if a listener was actually removed, else false
     * @member Ext.EventManager
     * @method un
     */
    pub.un = pub.removeListener;

    pub.stoppedMouseDownEvent = new Ext.util.Event();
    return pub;
}();
/**
  * Fires when the document is ready (before onload and before images are loaded).  Shorthand of {@link Ext.EventManager#onDocumentReady}.
  * @param {Function} fn        The method the event invokes
  * @param {Object}   scope    An  object that becomes the scope of the handler
  * @param {boolean}  override If true, the obj passed in becomes
  *                             the execution scope of the listener
  * @member Ext
  * @method onReady
 */
Ext.onReady = Ext.EventManager.onDocumentReady;

Ext.onReady(function(){
    var bd = Ext.getBody();
    if(!bd){ return; }

    var cls = [
            Ext.isIE ? "ext-ie " + (Ext.isIE6 ? 'ext-ie6' : 'ext-ie7')
            : Ext.isGecko ? "ext-gecko"
            : Ext.isOpera ? "ext-opera"
            : Ext.isSafari ? "ext-safari" : ""];

    if(Ext.isMac){
        cls.push("ext-mac");
    }
    if(Ext.isLinux){
        cls.push("ext-linux");
    }
    if(Ext.isBorderBox){
        cls.push('ext-border-box');
    }
    if(Ext.isStrict){ // add to the parent to allow for selectors like ".ext-strict .ext-ie"
        var p = bd.dom.parentNode;
        if(p){
            p.className += ' ext-strict';
        }
    }
    bd.addClass(cls.join(' '));
});

/**
 * @class Ext.EventObject
 * EventObject exposes the Yahoo! UI Event functionality directly on the object
 * passed to your event handler. It exists mostly for convenience. It also fixes the annoying null checks automatically to cleanup your code
 * Example:
 * <pre><code>
 function handleClick(e){ // e is not a standard event object, it is a Ext.EventObject
    e.preventDefault();
    var target = e.getTarget();
    ...
 }
 var myDiv = Ext.get("myDiv");
 myDiv.on("click", handleClick);
 //or
 Ext.EventManager.on("myDiv", 'click', handleClick);
 Ext.EventManager.addListener("myDiv", 'click', handleClick);
 </code></pre>
 * @singleton
 */
Ext.EventObject = function(){

    var E = Ext.lib.Event;

    // safari keypress events for special keys return bad keycodes
    var safariKeys = {
        63234 : 37, // left
        63235 : 39, // right
        63232 : 38, // up
        63233 : 40, // down
        63276 : 33, // page up
        63277 : 34, // page down
        63272 : 46, // delete
        63273 : 36, // home
        63275 : 35  // end
    };

    // normalize button clicks
    var btnMap = Ext.isIE ? {1:0,4:1,2:2} :
                (Ext.isSafari ? {1:0,2:1,3:2} : {0:0,1:1,2:2});

    Ext.EventObjectImpl = function(e){
        if(e){
            this.setEvent(e.browserEvent || e);
        }
    };
    Ext.EventObjectImpl.prototype = {
        /** The normal browser event */
        browserEvent : null,
        /** The button pressed in a mouse event */
        button : -1,
        /** True if the shift key was down during the event */
        shiftKey : false,
        /** True if the control key was down during the event */
        ctrlKey : false,
        /** True if the alt key was down during the event */
        altKey : false,

        /** Key constant @type Number */
        BACKSPACE : 8,
        /** Key constant @type Number */
        TAB : 9,
        /** Key constant @type Number */
        RETURN : 13,
        /** Key constant @type Number */
        ENTER : 13,
        /** Key constant @type Number */
        SHIFT : 16,
        /** Key constant @type Number */
        CONTROL : 17,
        /** Key constant @type Number */
        ESC : 27,
        /** Key constant @type Number */
        SPACE : 32,
        /** Key constant @type Number */
        PAGEUP : 33,
        /** Key constant @type Number */
        PAGEDOWN : 34,
        /** Key constant @type Number */
        END : 35,
        /** Key constant @type Number */
        HOME : 36,
        /** Key constant @type Number */
        LEFT : 37,
        /** Key constant @type Number */
        UP : 38,
        /** Key constant @type Number */
        RIGHT : 39,
        /** Key constant @type Number */
        DOWN : 40,
        /** Key constant @type Number */
        DELETE : 46,
        /** Key constant @type Number */
        F5 : 116,

           /** @private */
        setEvent : function(e){
            if(e == this || (e && e.browserEvent)){ // already wrapped
                return e;
            }
            this.browserEvent = e;
            if(e){
                // normalize buttons
                this.button = e.button ? btnMap[e.button] : (e.which ? e.which-1 : -1);
                if(e.type == 'click' && this.button == -1){
                    this.button = 0;
                }
                this.type = e.type;
                this.shiftKey = e.shiftKey;
                // mac metaKey behaves like ctrlKey
                this.ctrlKey = e.ctrlKey || e.metaKey;
                this.altKey = e.altKey;
                // in getKey these will be normalized for the mac
                this.keyCode = e.keyCode;
                this.charCode = e.charCode;
                // cache the target for the delayed and or buffered events
                this.target = E.getTarget(e);
                // same for XY
                this.xy = E.getXY(e);
            }else{
                this.button = -1;
                this.shiftKey = false;
                this.ctrlKey = false;
                this.altKey = false;
                this.keyCode = 0;
                this.charCode =0;
                this.target = null;
                this.xy = [0, 0];
            }
            return this;
        },

        /**
         * Stop the event (preventDefault and stopPropagation)
         */
        stopEvent : function(){
            if(this.browserEvent){
                if(this.browserEvent.type == 'mousedown'){
                    Ext.EventManager.stoppedMouseDownEvent.fire(this);
                }
                E.stopEvent(this.browserEvent);
            }
        },

        /**
         * Prevents the browsers default handling of the event.
         */
        preventDefault : function(){
            if(this.browserEvent){
                E.preventDefault(this.browserEvent);
            }
        },

        /** @private */
        isNavKeyPress : function(){
            var k = this.keyCode;
            k = Ext.isSafari ? (safariKeys[k] || k) : k;
            return (k >= 33 && k <= 40) || k == this.RETURN || k == this.TAB || k == this.ESC;
        },

        isSpecialKey : function(){
            var k = this.keyCode;
            return (this.type == 'keypress' && this.ctrlKey) || k == 9 || k == 13  || k == 40 || k == 27 ||
            (k == 16) || (k == 17) ||
            (k >= 18 && k <= 20) ||
            (k >= 33 && k <= 35) ||
            (k >= 36 && k <= 39) ||
            (k >= 44 && k <= 45);
        },
        /**
         * Cancels bubbling of the event.
         */
        stopPropagation : function(){
            if(this.browserEvent){
                if(this.browserEvent.type == 'mousedown'){
                    Ext.EventManager.stoppedMouseDownEvent.fire(this);
                }
                E.stopPropagation(this.browserEvent);
            }
        },

        /**
         * Gets the key code for the event.
         * @return {Number}
         */
        getCharCode : function(){
            return this.charCode || this.keyCode;
        },

        /**
         * Returns a normalized keyCode for the event.
         * @return {Number} The key code
         */
        getKey : function(){
            var k = this.keyCode || this.charCode;
            return Ext.isSafari ? (safariKeys[k] || k) : k;
        },

        /**
         * Gets the x coordinate of the event.
         * @return {Number}
         */
        getPageX : function(){
            return this.xy[0];
        },

        /**
         * Gets the y coordinate of the event.
         * @return {Number}
         */
        getPageY : function(){
            return this.xy[1];
        },

        /**
         * Gets the time of the event.
         * @return {Number}
         */
        getTime : function(){
            if(this.browserEvent){
                return E.getTime(this.browserEvent);
            }
            return null;
        },

        /**
         * Gets the page coordinates of the event.
         * @return {Array} The xy values like [x, y]
         */
        getXY : function(){
            return this.xy;
        },

        /**
         * Gets the target for the event.
         * @param {String} selector (optional) A simple selector to filter the target or look for an ancestor of the target
         * @param {Number/Mixed} maxDepth (optional) The max depth to
                search as a number or element (defaults to 10 || document.body)
         * @param {Boolean} returnEl (optional) True to return a Ext.Element object instead of DOM node
         * @return {HTMLelement}
         */
        getTarget : function(selector, maxDepth, returnEl){
            var t = Ext.get(this.target);
            return selector ? t.findParent(selector, maxDepth, returnEl) : (returnEl ? t : this.target);
        },

        /**
         * Gets the related target.
         * @return {HTMLElement}
         */
        getRelatedTarget : function(){
            if(this.browserEvent){
                return E.getRelatedTarget(this.browserEvent);
            }
            return null;
        },

        /**
         * Normalizes mouse wheel delta across browsers
         * @return {Number} The delta
         */
        getWheelDelta : function(){
            var e = this.browserEvent;
            var delta = 0;
            if(e.wheelDelta){ /* IE/Opera. */
                delta = e.wheelDelta/120;
            }else if(e.detail){ /* Mozilla case. */
                delta = -e.detail/3;
            }
            return delta;
        },

        /**
         * Returns true if the control, meta, shift or alt key was pressed during this event.
         * @return {Boolean}
         */
        hasModifier : function(){
            return ((this.ctrlKey || this.altKey) || this.shiftKey) ? true : false;
        },

        /**
         * Returns true if the target of this event equals el or is a child of el
         * @param {Mixed} el
         * @param {Boolean} related (optional) true to test if the related target is within el instead of the target
         * @return {Boolean}
         */
        within : function(el, related){
            var t = this[related ? "getRelatedTarget" : "getTarget"]();
            return t && Ext.fly(el).contains(t);
        },

        getPoint : function(){
            return new Ext.lib.Point(this.xy[0], this.xy[1]);
        }
    };

    return new Ext.EventObjectImpl();
}();




 /*
  * Author: Doug Hendricks. doug[always-At]theactivegroup.com
  * Copyright 2007-2008, Active Group, Inc.  All rights reserved.
  *
  * This extension adds EventManager Support to Ext.lib.Ajax (if
  *    Ext.util.Observable is present in the stack)
  ************************************************************************************
  *   This file is distributed on an AS IS BASIS WITHOUT ANY WARRANTY;
  *   without even the implied warranty of MERCHANTABILITY or
  *   FITNESS FOR A PARTICULAR PURPOSE.
  ************************************************************************************

  License: ext-basex is licensed under the terms of the Open Source LGPL 3.0 license.
  Commercial use is permitted to the extent that the code/component(s) do NOT become
  part of another Open Source or Commercially licensed development library or toolkit
  without explicit permission.

  * Donations are welcomed: http://donate.theactivegroup.com
  */

if(Ext.util.Observable){
  Ext.apply( Ext.lib.Ajax ,{

   events:{request     :true,
           beforesend  :true,
           response    :true,
           exception   :true,
           abort       :true,
           timeout     :true,
      readystatechange :true
    }

   /*
     onStatus
     define eventListeners for a single (or array) of HTTP status codes.
   */
   ,onStatus:function(status,fn,scope,options){
        var args = Array.prototype.slice.call(arguments, 1);
        status = [].concat(status||[]);
        Ext.each(status,function(statusCode){
            statusCode = parseInt(statusCode,10);
            if(!isNaN(statusCode)){
                var ev = 'status_'+statusCode;
                this.events[ev] || (this.events[ev] = true);
                this.on.apply(this,[ev].concat(args));
            }
        },this);
   }
   /*
        unStatus
        unSet eventListeners for a single (or array) of HTTP status codes.
   */
   ,unStatus:function(status,fn,scope,options){
           var args = Array.prototype.slice.call(arguments, 1);
           status = [].concat(status||[]);
           Ext.each(status,function(statusCode){
                statusCode = parseInt(statusCode,10);
                if(!isNaN(statusCode)){
                    var ev = 'status_'+statusCode;
                    this.un.apply(this,[ev].concat(args));
                }
           },this);
      }
    ,onReadyState : function(){
         this.fireEvent.apply(this,['readystatechange'].concat(Array.prototype.slice.call(arguments, 0)));
    }

  }, new Ext.util.Observable());

}

 /*
  * Author: Doug Hendricks. doug[always-At]theactivegroup.com
  * Copyright 2007-2008, Active Group, Inc.  All rights reserved.
  *
  * These Ext.lib.Ajax overrides:

    - adds Synchronous Ajax Support ( options.async =false )
    - Permits IE7 to Access Local File Systems using IE's older ActiveX interface
      via the forceActiveX property
    - Pluggable Form encoder (encodeURIComponent is still the default encoder)
    - Corrects the Content-Type Headers for posting JSON (application/json)
      and XML (text/xml) data payloads and sets only one value (per RFC)
    - Adds fullStatus:{ isLocal, isOK, isError, error, status, statusText}
      object to the existing Response Object.
    - Adds standard HTTP Auth support to every request (userId, password config options)
    - options.method prevails over any method derived by the lib.Ajax stack (DELETE, PUT, HEAD etc).
  *
  */


Ext.apply( Ext.lib.Ajax ,
{
  /* set True as needed, to coerce IE to use older ActiveX interface */
  forceActiveX:false,

  /* Global default may be toggled at any time */
  async       :true,

  createXhrObject:function(transactionId)
        {
            var obj={  status:{isError:false}
                     , tId:transactionId}, http;
            try
            {
              if(Ext.isIE7 && !!this.forceActiveX){throw("IE7forceActiveX");}
              obj.conn= new XMLHttpRequest();
            }
            catch(eo)
            {
                for (var i = 0; i < this.activeX.length; ++i) {
                    try
                    {
                        obj.conn= new ActiveXObject(this.activeX[i]);

                        break;
                    }
                    catch(e) {
                    }
                }
            }
            finally
            {
                obj.status.isError = typeof(obj.conn) == 'undefined';
            }
            return obj;

        }

        /* Replaceable Form encoder */
    ,encoder : encodeURIComponent

    ,serializeForm : function(form) {
                if(typeof form == 'string') {
                    form = (document.getElementById(form) || document.forms[form]);
                }

                var el, name, val, disabled, data = '', hasSubmit = false;
                for (var i = 0; i < form.elements.length; i++) {
                    el = form.elements[i];
                    disabled = form.elements[i].disabled;
                    name = form.elements[i].name;
                    val = form.elements[i].value;

                    if (!disabled && name){
                        switch (el.type)
                                {
                            case 'select-one':
                            case 'select-multiple':
                                for (var j = 0; j < el.options.length; j++) {
                                    if (el.options[j].selected) {
                                        if (Ext.isIE) {
                                            data += this.encoder(name) + '=' + this.encoder(el.options[j].attributes['value'].specified ? el.options[j].value : el.options[j].text) + '&';
                                        }
                                        else {
                                            data += this.encoder(name) + '=' + this.encoder(el.options[j].hasAttribute('value') ? el.options[j].value : el.options[j].text) + '&';
                                        }
                                    }
                                }
                                break;
                            case 'radio':
                            case 'checkbox':
                                if (el.checked) {
                                    data += this.encoder(name) + '=' + this.encoder(val) + '&';
                                }
                                break;
                            case 'file':

                            case undefined:

                            case 'reset':

                            case 'button':

                                break;
                            case 'submit':
                                if(hasSubmit == false) {
                                    data += this.encoder(name) + '=' + this.encoder(val) + '&';
                                    hasSubmit = true;
                                }
                                break;
                            default:
                                data += this.encoder(name) + '=' + this.encoder(val) + '&';
                                break;
                        }
                    }
                }
                data = data.substr(0, data.length - 1);
                return data;
    }
    ,getHttpStatus: function(reqObj){

            var statObj = {  status:0
                    ,statusText:''
                    ,isError:false
                    ,isLocal:false
                    ,isOK:false
                    ,error:null};

            try {
                if(!reqObj){throw('noobj');}
                statObj.status = reqObj.status;

                statObj.isLocal = !reqObj.status && location.protocol == "file:" ||
                           Ext.isSafari && reqObj.status === undefined;

                statObj.isOK = (statObj.isLocal || (statObj.status > 199 && statObj.status < 300));
                statObj.statusText = reqObj.statusText || '';
               } catch(e){ //status may not avail/valid yet (or called too early).
                         }

            return statObj;

     }
    ,handleTransactionResponse:function(o, callback, isAbort){

        callback = callback || {};
        var responseObject=null;

        if(!o.status.isError){
            o.status = this.getHttpStatus(o.conn);
            /* create and enhance the response with proper status and XMLDOM if necessary */
            responseObject = this.createResponseObject(o, callback.argument, isAbort);
        }

        if(o.status.isError){
         /* checked again in case exception was raised - ActiveX was disabled during XML-DOM creation?
          * And mixin everything the XHR object had to offer as well
          */
           responseObject = Ext.apply({},responseObject||{},this.createExceptionObject(o.tId, callback.argument, (isAbort ? isAbort : false)));

        }

        responseObject.options = o.options;
        responseObject.fullStatus = o.status;

        if(!this.events || this.fireEvent('status_'+o.status.status ,o.status.status, o, responseObject, callback, isAbort) !== false){

             if (o.status.isOK && !o.status.isError) {
                if(!this.events || this.fireEvent('response',o, responseObject, callback, isAbort) !== false){
                    if (callback.success) {
                        callback.success.call(callback.scope||null,responseObject);
                    }
                }
             } else {
                  if(!this.events || this.fireEvent('exception',o ,responseObject, callback, isAbort) !== false){
                    if (callback.failure) {
                        callback.failure.call(callback.scope||null,responseObject);
                    }
                  }
             }
        }

        if(o.options.async){
            this.releaseObject(o);
            responseObject = null;
        }else{
            this.releaseObject(o);
            return responseObject;
        }

    },

    createResponseObject:function(o, callbackArg, isAbort){
        var obj = {responseXML   :null,
                   responseText  :'',
                   getResponseHeader : {},
                   getAllResponseHeaders : ''
                   };

        var headerObj = {},headerStr='';

        if(isAbort !== true){
            try{  //to catch bad encoding problems here
                obj.responseText = o.conn.responseText;
                obj.responseStream = o.conn.responseStream||null;
            }catch(e){
                o.status.isError = true;
                o.status.error = e;
            }

            try{
                obj.responseXML = o.conn.responseXML || null;
            } catch(ex){}

            try{
                headerStr = o.conn.getAllResponseHeaders()||'';
            } catch(ex){}
        }

        if(o.status.isLocal){

           o.status.isOK = !o.status.isError && ((o.status.status = (!!obj.responseText.length)?200:404) == 200);

           if(o.status.isOK && (!obj.responseXML || obj.responseXML.childNodes.length === 0)){

                var xdoc=null;
                try{   //ActiveX may be disabled
                    if(typeof(DOMParser) == 'undefined'){
                        xdoc=new ActiveXObject("Microsoft.XMLDOM");
                        xdoc.async="false";
                        xdoc.loadXML(obj.responseText);
                    }else{
                        var domParser=null;
                        try{  //Opera 9 will fail parsing non-XML content, so trap here.
                            domParser = new DOMParser();
                            xdoc = domParser.parseFromString(obj.responseText, 'application\/xml');
                        }catch(ex){}
                        finally{domParser = null;}
                    }
                } catch(exd){
                    o.status.isError = true;
                    o.status.error = exd;
                }
                obj.responseXML = xdoc;
            }
            if(obj.responseXML){
                var parseBad =  (obj.responseXML.documentElement && obj.responseXML.documentElement.nodeName == 'parsererror') ||
                            (obj.responseXML.parseError || 0) !== 0 ||
                            obj.responseXML.childNodes.length === 0;
                if(!parseBad){
                    headerStr = 'Content-Type: ' + (obj.responseXML.contentType || 'text\/xml') + '\n' + headerStr ;
                }
            }
        }
        var header = headerStr.split('\n');
        for (var i = 0; i < header.length; i++) {
            var delimitPos = header[i].indexOf(':');
            if (delimitPos != -1) {
                headerObj[header[i].substring(0, delimitPos)] = header[i].substring(delimitPos + 2);
            }
        }

        obj.tId = o.tId;
        obj.status = o.status.status;
        obj.statusText = o.status.statusText;
        obj.getResponseHeader = headerObj;
        obj.getAllResponseHeaders = headerStr;
        obj.fullStatus = o.status;

        if (typeof callbackArg != 'undefined') {
            obj.argument = callbackArg;
        }

        return obj;
    },
    setDefaultPostHeader:function(contentType){
        this.defaultPostHeader = contentType;
    },

    setDefaultXhrHeader:function(bool){
        this.useDefaultXhrHeader = bool||false;
    },
    request : function(method, uri, cb, data, options) {

        options = Ext.apply({
               async    :this.async || false,
               headers  :false,
               userId   :null,
               password :null,
               xmlData  :null,
               jsonData :null }, options||{});

        if(!this.events || this.fireEvent('request', method, uri, cb, data, options) !== false){

               var hs = options.headers;
               if(hs){
                    for(var h in hs){
                        if(hs.hasOwnProperty(h)){
                            this.initHeader(h, hs[h], false);
                        }
                    }
               }
               if(options.xmlData){
                    this.initHeader('Content-Type', 'text/xml', false);
                    method = 'POST';
                    data = options.xmlData;
               } else if(options.jsonData){
                    this.initHeader('Content-Type', 'application/json', false);
                    method = 'POST';
                    data = typeof options.jsonData == 'object' ? Ext.encode(options.jsonData) : options.jsonData;
               } else if(data && this.useDefaultHeader){
                    this.initHeader('Content-Type', this.defaultPostHeader);
               }
                //options.method prevails over any derived method.
               return this.makeRequest(options.method || method, uri, cb, data, options);
        }
        return null;

    },

    makeRequest:function(method, uri, callback, postData, options){
        var o = this.getConnectionObject();

        if (!o || o.status.isError) {
                return Ext.apply(o,this.handleTransactionResponse(o, callback));
        } else {
                o.options = options;
                try{
                    o.conn.open(method, uri, options.async, options.userId, options.password);
                    o.conn.onreadystatechange=this.onReadyState ?
                           this.onReadyState.createDelegate(this,[o],0):Ext.emptyFn;
                } catch(ex){
                    o.status.isError = true;
                    o.status.error = ex;

                    var r=this.handleTransactionResponse(o, callback);
                    return Ext.apply(o,r);
                }

                if (this.useDefaultXhrHeader) {
                    if (!this.defaultHeaders['X-Requested-With']) {
                    this.initHeader('X-Requested-With', this.defaultXhrHeader, true);
                    }
                }

                if (this.hasDefaultHeaders || this.hasHeaders) {
                    this.setHeader(o);
                }

                if(o.options.async){ //Timers for syncro calls won't work here, as it's a blocking call
                    this.handleReadyState(o, callback);
                }

                try{
                  if(!this.events || this.fireEvent('beforesend', o, method, uri, callback, postData, options) !== false){
                       o.conn.send(postData || null);
                  }
                } catch(ex){}

                return options.async?o:Ext.apply(o,this.handleTransactionResponse(o, callback));
            }
    }

   ,abort:function(o, callback, isTimeout){
            if (this.isCallInProgress(o)) {
                o.conn.abort();
                window.clearInterval(this.poll[o.tId]);
                delete this.poll[o.tId];
                if (isTimeout) {
                    delete this.timeout[o.tId];
                }
                if(this.events){
                    this.fireEvent(isTimeout?'timeout':'abort', o, callback)
                }

                this.handleTransactionResponse(o, callback, true);

                return true;
            }
            else {
                return false;
            }
    }

    ,clearAuthenticationCache:function(url) {
       // Default to a non-existing page (give error 500).
       // An empty page is better, here.
       url || ( url = '.force_logout');
       try{

         if (Ext.isIE) {
           // IE clear HTTP Authentication
           document.execCommand("ClearAuthenticationCache");
         }
         else {
           // create an xmlhttp object
           var xmlhttp;
           if( xmlhttp = this.createXhrObject()){
               // prepare invalid credentials
               xmlhttp.conn.open("GET", url , true, "logout", "logout");
               // send the request to the server
               xmlhttp.conn.send("");
               // abort the request
               xmlhttp.conn.abort();
               xmlhttp.conn = null;
               xmlhttp = null;
           }
         }
       } catch(e) {
         // There was an error
         return;
       }
     }
});


/*
forEach Iteration
  based on previous work by: Dean Edwards (http://dean.edwards.name/weblog/2006/07/enum/)
  Gecko already supports forEach for Arrays : see http://developer.mozilla.org/en/docs/Core_JavaScript_1.5_Reference:Objects:Array:forEach
*/

/* Fix for Opera, which does not seem to include the map function on Array's */

Ext.applyIf( Array.prototype,{
   map : function(fun,scope){
    var len = this.length;
    if(typeof fun != "function"){
        throw new TypeError();
    }
    var res = new Array(len);

    for(var i = 0; i < len; i++){
        if(i in this){
        try{res[i] = fun.call(scope||this, this[i], i, this);}catch(e){}
        }
    }
        return res;
     }
  ,forEach : function(block, scope) {
    var i=0,length = this.length;
    while(i < length){
       try{block.apply(scope||this, [this[i], i++, this]);}catch(e){}
      }
   }
});

   // generic enumeration
Ext.applyIf(Function.prototype,{
   forEach : function(object, block, context) {
        context = context || object;
        for (var key in object) {
        if (typeof this.prototype[key] == "undefined") {
            try{block.apply(context, [object[key], key, object]);}catch(e){}
        }
       }

      }
});

   // character enumeration
Ext.applyIf(String.prototype,{
   forEach : function(block, context) {
        var str = this.toString();
        context = context || this;
        var ar = str.split("")||[];
    ar.forEach( function(chr, index) {
         try{block.apply(context,[ chr, index, str]);}catch(e){}
    },ar);
   }
});

   // globally resolve forEach enumeration
var forEach = function(object, block, context) {
        context = context || object;
    if (object) {
        var resolve = Object; // default
        if (object instanceof Function) {
            // functions have a "length" property
            resolve = Function;
        } else if (object.forEach instanceof Function) {
            // the object implements a custom forEach method so use that
            object.forEach(block, context);
            return;
        }
        resolve.forEach(object, block, context);
    }
};

if(Ext.util.Observable){
   /*
    * @class Ext.ux.ModuleManager
    * Version:  RC-1
    * Author: Doug Hendricks. doug[always-At]theactivegroup.com
    * Copyright 2007-2008, Active Group, Inc.  All rights reserved.
    *
    ************************************************************************************
    *   This file is distributed on an AS IS BASIS WITHOUT ANY WARRANTY;
    *   without even the implied warranty of MERCHANTABILITY or
    *   FITNESS FOR A PARTICULAR PURPOSE.
    ************************************************************************************

    License: Ext.ux.ModuleManager is licensed under the terms of the Open Source
    LGPL 3.0 license.  Commercial use is permitted to the extent
    that the code/component(s) do NOT become part of another Open Source or Commercially
    licensed development library or toolkit without explicit permission.

    Donations are welcomed: http://donate.theactivegroup.com

    License details: http://www.gnu.org/licenses/lgpl.html


   Sample Usage:

    YourApp.CodeLoader = new Ext.ux.ModuleManager({modulePath:yourBasePath });
    YourApp.CodeLoader.on({
            'beforeload':function(manager, module, response){

                //return false to prevent the script from being evaled.
                return response.fullStatus.isLocal ||
                    module.contentType.toLowerCase().indexOf('javascript') !== -1;

            }
            ,scope:YourApp.CodeLoader
            });

    //Create a useful 'syntax' for you App.

    YourApp.needs = YourApp.CodeLoader.load.createDelegate(YourApp.CodeLoader);
    YourApp.provide = YourApp.CodeLoader.provides.createDelegate(YourApp.CodeLoader);

    YourApp.needs('ext/layouts','js/dragdrop','js/customgrid','style/custom.css');

*/

  (function(){

    Ext.ux.ModuleManager = function(config){

        Ext.apply(this,
            config||{},
            { modulePath:function(){  //based on current page
                   var d= location.href.indexOf('\/') != -1 ? '\/':'\\';
                   var u=location.href.split(d);
                   u.pop(); //this page
                   return u.join(d) + d;
                    }()
             });

        Ext.ux.ModuleManager.superclass.constructor.call(this);
        this.addEvents({
                /**
                * @event loadexception
                * Fires when any exception is raised
                * returning false prevents any subsequent pending module load requests
                * @param {Ext.ux.ModuleManager} this
                * @param {String} module -- the module name
                * @param {Object} error -- An error object containing: httpStatus, httpStatusText, error object
                */
                "loadexception" : true,

                /**
               * @event alreadyloaded
               * Fires when the ModuleManager determines that the requested module has already been loaded
               * @param {Ext.ux.ModuleManager} this
               * @param {String} module -- the module name
               */
                "alreadyloaded" : true,

               /**
                * @event load
                * Fires when the retrieved content has been successfully evaled into the current context.
                * @param {Ext.ux.ModuleManager} this
                * @param {String} module -- the module name
                */
                "load" : true,

                /**
                 * @event beforeload
                 * Fires when the request has successfully completed and just prior to eval
                 * returning false prevents the content (of this module) from being loaded (eval'ed)
                 * @param {Ext.ux.ModuleManager} this
                 * @param {String} module -- the module name
                 * @param {Object} response - the Ajax response object
                 * @param {String} theScript -- the source String to be evaled.
                 */
                "beforeload" : true,

                /**
                 * @event complete
                 * Fires when all module load request have completed (successfully or not)
                 * @param {Ext.ux.ModuleManager} this
                 * @param {Boolen} success
                 * @param {Array} modules -- the modules now available as a result of (or previously -- already loaded) the last load operation.
                 */
                "complete" : true
        });


    };

    Ext.extend(Ext.ux.ModuleManager, Ext.util.Observable,{

     disableCaching: false

    ,modules : {}

    ,method:'GET'

    ,asynchronous : false

    ,loaded:function(name){
        return this.modules[name] && this.modules[name].loaded===true;
    }

    /* A mechanism for modules to identify their presence */
    ,provides : function(){
        Ext.each(arguments,function(module){
           var modName = module.trim().split('\/').pop().toLowerCase()
              ,fullName   = module.indexOf('.') !== -1 ? module.trim() : module.trim() + '.js';

           this.modules[modName] || (this.modules[modName] =
             {
                 name       :modName.trim()
                ,fullName   :fullName.trim()
                ,extension  :fullName.split('.').pop().trim()
                ,path       :''
                ,url        :''
                ,loaded     :true
                ,contentType    :''
                });

        },this);

    }
    ,load:function(){

      var result = true
         ,keepItUp = true
         ,StopIter = "StopIteration"
         ,options = {async:this.asynchronous,headers:this.headers||false}
         ,evaled = []
         ,callback = {
            success:function(response){
                var module     = response.argument.module
               ,moduleName = response.argument.module.name;

               try{
                     module.contentType = response.getResponseHeader['Content-Type'] || '';

                     if(this.fireEvent('beforeload', this, module, response) !== false){
                        this.currentModule = moduleName;
                        module.loaded = true;
                        var exception = this.globalEval( response.responseText );
                        if(exception===true){

                            evaled.push(moduleName);
                            this.modules[moduleName] = module;
                            try{
                              this.fireEvent('load', this, module);
                            }catch(ex){}

                        } else {
                        //coerce to actual module URL
                         throw Ext.applyIf({fileName:module.url ,lineNumber:exception.lineNumber||0 },exception );

                        }
                     }

                }catch(ex) {
                   keepItUp = this.fireEvent('loadexception', this, module, {
                        error         :ex
                       ,httpStatus    :response.status
                       ,httpStatusText:response.statusText
                       });

                      result = false;

                }

           }
           ,failure:function(response){
               var module = response.argument.module;
               module.contentType = response.getResponseHeader['Content-Type'] || '';

            keepItUp = this.fireEvent('loadexception', this, module,{
                    error         :response.fullStatus.error
                   ,httpStatus    :response.status
                   ,httpStatusText:response.statusText
                   });

            result = false;

           }
           ,scope:this
       };

       /* Iterate the desired modules in there implied dependency order */
       try{

         Ext.each(arguments , function(module){
             //strip relative path leaving module name
             var moduleName = module.trim().split('\/').pop().toLowerCase()
                ,fullModule = module.indexOf('.') !== -1 ? module : module + '.js';

             if(!this.loaded(moduleName) || this.forced){

               var moduleObj = {
                         name       :moduleName.trim()
                        ,fullName   :fullModule.trim()
                        ,extension  :fullModule.split('.').pop().trim()
                        ,path       :this.modulePath
                        ,url        :this.modulePath + fullModule
                        ,loaded     :false
                        ,contentType    :''
                       };

               if(this.method == 'GET' && this.disableCaching === true){
                    fullModule += '?_dc=' + (new Date().getTime());
               }

               Ext.apply(callback,{argument:{module:moduleObj}});

               Ext.lib.Ajax.request(this.method||'GET',this.modulePath + fullModule, callback,null,options);
             } else {
               keepItUp = this.fireEvent('alreadyloaded', this, this.modules[moduleName]);
               evaled.push(moduleName);
             }
             if(keepItUp===false){throw StopIter;}
          },this);

       } catch(ex){
        if (ex != StopIter)
            {throw ex;}
       }

      this.fireEvent('complete', this, result, evaled);
      this.forced = false;
      return result;
    }

    ,globalEval: function( data , scope, context ) {
        scope || (scope = window);

        data = String(data||"").trim();

        if(data.length===0){return false;}
        try{
            if(scope.execScript){
                // window.execScript in IE fails when scripts include HTML comment tag.
                scope.execScript(data.replace(/^<!--/,"").replace(/-->$/, ""));
            }else if (Ext.isSafari){
                // safari doesn't provide a synchronous global eval
                scope.setTimeout(data, 0);
            }else{
                // context (target namespace) is only support on Gecko.
                eval.call(scope,data,context || null);
            }
            return true;
        }catch(ex){return ex;}

        }
    });

  }());
}