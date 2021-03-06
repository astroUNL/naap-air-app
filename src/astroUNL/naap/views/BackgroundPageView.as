﻿/*
BackgroundPageView.as
naap-air-app
astro.unl.edu
2020-01-02
*/

package astroUNL.naap.views {
	
	//import astroUNL.naap.controls.Scroller;
	
	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.classaction.browser.views.ResourceWindowsManager;
	import astroUNL.classaction.browser.views.elements.ScrollableLayoutPanes;
	import astroUNL.classaction.browser.views.elements.ClickableText;
	import astroUNL.classaction.browser.events.MenuEvent;
	
	import flash.display.Sprite;
	import flash.display.InteractiveObject;
	
	//import flash.utils.Dictionary;
	
	

	
	import flash.display.Loader;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	//import flash.events.IOErrorEvent;

	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.system.ApplicationDomain;

	import flash.display.LoaderInfo;
	import flash.system.LoaderContext;
	
	
	
	
	
	public class BackgroundPageView extends BackgroundPageViewSWC {
		
		protected var _backgroundPage:Object = null;
		
		//protected var _scroller:Scroller;
		
		protected var _viewWidth:Number;
		protected var _viewHeight:Number;
		
		// These contain the children of _content.
		protected var _masks:Array = [];
		protected var _swfs:Array = [];
		
		
		protected var _scrollerMargin:Number = 10;
		
		// The purpose of the _mouseOverlay layer is to prevent halting behavior when the mouse
		//	rolls over interactive areas of the background page (e.g. selectable text blocks) during scrolling.
		// The mouse overlay is transparent and usually not visible (therefore allowing interactivity on the
		//	background page). When scrolling occurs it is made *visible* (but still transparent), blocking
		//	interactivity.
		protected var _mouseOverlay:Sprite;
		
		public function BackgroundPageView() {
			
			// _content is the permanent container for background page SWFs. When a new
			// page is loaded reset is called, removing and unloading all of its children.
			
			scroller.addEventListener("scroll", onScroll);
			scroller.addEventListener("mouseDown", onMouseDownOnScroller);
			
			_content = new Sprite();
			addChild(_content);
			
			_contentMask = new Sprite();
			addChild(_contentMask);
			
			_content.mask = _contentMask;
			
			_mouseOverlay = new Sprite();
			_mouseOverlay.visible = false;
			_mouseOverlay.addEventListener("mouseDown", onMouseDownOnMouseOverlay);
			addChild(_mouseOverlay);
			
		}
		
		
		protected var _stageMouseUpListenerActive:Boolean = false;
		
		protected function onMouseDownOnScroller(evt:Event):void {
			// Activate the mouse overlay.
			//trace("onMouseDownOnScroller");
			_mouseOverlay.visible = true;
			if (!_stageMouseUpListenerActive) {
				try {	
					stage.addEventListener("mouseUp", onMouseUpFromStage);
					_stageMouseUpListenerActive = true;
				} catch (e:Error) {
					trace("ERROR");
				}
			}
		}
		
		protected function onMouseUpFromStage(evt:Event):void {
			// Deactivate the mouse overlay.
			//trace("onMouseUpFromStage");
			deactivateStageMouseUpListener();
		}
		
		protected function onMouseDownOnMouseOverlay(evt:Event):void {
			// This is a fail-safe in case the overlay is still visible
			//	when scrolling has stopped (maybe if another program 
			//	interrupts?).
			trace("*** WARNING *** onMouseDownOnMouseOverlay");
			deactivateStageMouseUpListener();
		}
		
		protected function deactivateStageMouseUpListener():void {
			_mouseOverlay.visible = false;
			if (_stageMouseUpListenerActive) {
				try {
					stage.removeEventListener("mouseUp", onMouseUpFromStage);
					_stageMouseUpListenerActive = false;
				} catch (e:Error) {
					trace("ERROR");
				}
			}
		}
		
		
		public function onScroll(evt:Event):void {
			//trace("onScroll: "+scroller.scrollPosition);
			_content.y = -scroller.scrollPosition;
		}
		
		override public function set visible(visibleNow:Boolean):void {
			trace("setting visible: "+visibleNow);
			super.visible = visibleNow;
			redraw();
		}
		
		
		protected var _pageSideMargin:Number;
		
		public function setDimensions(w:Number, h:Number):void {
			//trace("setDimensions");
			//trace(" w: "+w);
			//trace(" h: "+h);
			
			var r:Number = w/h;
			//trace(" r: "+r);
			
			// Note: the zodiac interactive in Motions of the Sun / Seasons and the Zodiac
			//  may be the tallest interactive.
			const maxR:Number = 1.421;
			
			if (r > maxR) {
				var rw:Number = maxR * h;
				_pageSideMargin = 0.5*(w - rw);
				w = rw;
			} else {
				_pageSideMargin = 0;
			}
			
			_viewWidth = w;
			_viewHeight = h;
			
			redraw();
		}
		
		public function setBackgroundPage(backgroundPage:Object):void {
			if (backgroundPage != null) {
				trace("setBackgroundPage: "+backgroundPage.title);
			} else {
				trace("setBackgroundPage: <null>");
			}
			
			reset();
			
			_backgroundPage = backgroundPage;
			
			if (_backgroundPage != null) {
				
				// Background page SWFs (which include text as well as animations) are added to the display
				// 	list in the order they are defined. However, the SWFs are not actually added until they
				//	load successfully. This is necessary to prevent global variable clobbering. (I don't entirely
				//	understand it, but waiting until the COMPLETE event before adding the SWFs to _content
				//	solves a lot of problems with SWFs interfering, e.g. the component styles of one SWF
				//	affecting another's.)
				// To maintain the correct ordering given that the COMPLETE events may be out of order, a placeholder
				//	is added at 2*i. (2*i + 1 is for the mask.) When the SWF is loaded it is swapped with the placeholder.
				
				for each (var swfObj:Object in _backgroundPage.swfs) {
					
					var req:URLRequest = new URLRequest(swfObj.file);
					
					var placeholder:Sprite = new Sprite();
					_content.addChild(placeholder);
					
					var ctx:LoaderContext = new LoaderContext();
					ctx.allowCodeImport = true;
					ctx.applicationDomain = new ApplicationDomain(null);
					
					var swf:Loader = new Loader();
					swf.x = swfObj.x;
					swf.y = swfObj.y;
					swf.scaleX = swfObj.scale;
					swf.scaleY = swfObj.scale;
					swf.contentLoaderInfo.addEventListener(Event.COMPLETE, onSWFLoaded);
					// Don't addChild until onSWFLoaded.
					
					_swfs.push(swf);
					
					var m:Sprite = new Sprite();
					m.x = swfObj.x;
					m.y = swfObj.y;
					m.graphics.beginFill(0xff0000, 0.1);
					m.graphics.drawRect(0, 0, swfObj.width, swfObj.height);
					m.graphics.endFill();
					_content.addChild(m);
					
					_masks.push(m);
					
					swf.mask = m;
					
					swf.load(req, ctx);
					
					var h:Number = swfObj.y + swfObj.height;
					if (h > _contentHeight) {
						_contentHeight = h;
					}
				}
				
				_content.y = 0;
								
				updateScroller(0);
			}
		}
		
		protected function onSWFLoaded(evt:Event):void {
			// Add the SWF after it has been successfully loaded -- see comments in setBackgroundPage.
			for (var i:Number = 0; i < _swfs.length; ++i) {
				var swf:Loader = _swfs[i];
				if (swf == evt.target.loader) {
					/*
					swf.addEventListener("mouseOver", onMouseOverSWF);
					swf.focusRect = false;
					swf.mouseEnabled = true;
					swf.tabEnabled = true;
					swf.tabIndex = 10 + i;
					*/
					_content.addChild(swf);
					var newIndex:Number = _content.getChildIndex(swf);
					_content.swapChildrenAt(2*i, newIndex);
					break;
				} else {
					continue;
				}
			}
			
			/*
			trace("onSWFLoaded");
			trace(" evt.target: "+evt.target);
			trace(" swfVersion: "+evt.target.swfVersion);
			trace(" url: "+evt.target.url);
			trace(" applicationDomain: "+evt.target.applicationDomain);
			trace(" actionScriptVersion: "+evt.target.actionScriptVersion);
			*/
		}
		
		/*
		protected function onMouseOverSWF(evt:MouseEvent):void {
			trace("onMouseOverSWF");
			trace(" evt.target: "+evt.target);
			stage.focus = evt.target as InteractiveObject;
		}
		*/
		
		protected function redraw():void {
			trace("BackgroundPageView redraw");
			
			if (!super.visible) {
				trace("...not visible, will abort");
				return;
			}
			
			trace("...is visible");
			
			var savedPosition:Number = getUnscaledScrollPosition();

			
			var contentAvailableViewWidth:Number = _viewWidth - scroller.width - _scrollerMargin;
			
			_content.scaleX = contentAvailableViewWidth/_contentWidth;
			_content.scaleY = _content.scaleX;
			
			_content.x = _pageSideMargin;
			
			scroller.x = _content.x + contentAvailableViewWidth + _scrollerMargin;
			scroller.y = 0;
			scroller.height = _viewHeight;
			
			_contentMask.graphics.clear();
			_contentMask.graphics.beginFill(0xe0ffa0);
			_contentMask.graphics.drawRect(_pageSideMargin, 0, contentAvailableViewWidth, _viewHeight);
			_contentMask.graphics.endFill();
			
			_mouseOverlay.graphics.clear();
			_mouseOverlay.graphics.beginFill(0x0000ff, 0);
			_mouseOverlay.graphics.drawRect(_pageSideMargin, 0, contentAvailableViewWidth, _viewHeight);
			_mouseOverlay.graphics.endFill();			
			
			updateScroller(savedPosition);
		}
		
		protected function getUnscaledScrollPosition():Number {
			return scroller.scrollPosition / _content.scaleY;
		}
		
		protected function updateScroller(unscaledScrollPosition:Number):void {
			//trace(" updateScroller: "+unscaledScrollPosition);
			var scaledContentHeight:Number = _content.scaleY * _contentHeight;
			var maxScrollPosition:Number = Math.max(0, scaledContentHeight - _viewHeight);
			
			scroller.setScrollProperties(_viewHeight, 0, maxScrollPosition, 20);
			
			scroller.update();
			
			var sp:Number = Math.min(maxScrollPosition, unscaledScrollPosition * _content.scaleY);
			scroller.scrollPosition = sp;
						
			// Sometimes the onScroll handler is not invoked when it should be.
			onScroll(null);
		}
		
		protected const _contentWidth:Number = 820;
		
		protected var _contentHeight:Number = 0;
		
		protected var _content:Sprite = null;
		protected var _contentMask:Sprite = null;
		
		
		protected function reset():void {
			
			_contentHeight = 0;
			
			for each (var m:Sprite in _masks) {
				_content.removeChild(m);
			}
			
			for each (var swf:Loader in _swfs) {
				try {
					swf.unloadAndStop(true);
				} catch (e:Error) {
					trace("ERROR: failed to unload a background page SWF");
				}
				
				try {
					_content.removeChild(swf);
				} catch (e:Error) {
					trace("ERROR: failed to remove a background page SWF");
				}
			}
			
			_masks.splice(0);
			_swfs.splice(0);
		}
		
	}
	
}