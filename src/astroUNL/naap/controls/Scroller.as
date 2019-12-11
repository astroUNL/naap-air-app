/*
Scroller.as
naap-air-app
astro.unl.edu
2019-12-03
*/


package astroUNL.naap.controls {
	
	import astroUNL.naap.data.Lab;
	
	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.classaction.browser.views.ResourceWindowsManager;
	import astroUNL.classaction.browser.views.elements.ScrollableLayoutPanes;
	import astroUNL.classaction.browser.views.elements.ClickableText;
	import astroUNL.classaction.browser.events.MenuEvent;
	
	import flash.display.Sprite;
	
	//import flash.utils.Dictionary;
	
	
	import fl.controls.ScrollBar;
	
	
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
	
	
	
	
	
	
	
	public class Scroller extends Sprite {
		
		
		protected const _scrollerWidth:Number = 25;
		protected var _scrollerHeight:Number;
		
		
		protected var _range:Number = 0;
		protected var _position:Number = 0;
		
		
		protected const _step:Number = 10;
		
		
		protected var _background:Sprite;
		
		protected var _topButton:ScrollerTopButtonSWC;
		protected var _bottomButton:ScrollerTopButtonSWC;
		
		public function Scroller() {
			
			_background = new Sprite();
			addChild(_background);
			
			_topButton = new ScrollerTopButtonSWC();
			_topButton.addEventListener(MouseEvent.MOUSE_OUT, onTopButtonMouseOut);
			_topButton.addEventListener(MouseEvent.MOUSE_OVER, onTopButtonMouseOver);
			_topButton.addEventListener(MouseEvent.MOUSE_DOWN, onTopButtonMouseDown);
			_topButton.addEventListener(MouseEvent.MOUSE_UP, onTopButtonMouseUp);
			_topButton.addEventListener(MouseEvent.CLICK, onTopButtonClick);
			addChild(_topButton);
			
			_bottomButton = new ScrollerTopButtonSWC();
			addChild(_bottomButton);
			
		}
		
		
		protected function onTopButtonMouseOver(evt:MouseEvent):void {
			trace("related object: "+evt.relatedObject);
			trace(evt.relatedObject == this);
			trace(evt.relatedObject == _topButton);
			if (evt.buttonDown && evt.relatedObject == _topButton) {
				_topButton.gotoAndStop("down");
			} else {
				_topButton.gotoAndStop("over");
			}
		}
		
		protected function onTopButtonMouseDown(evt:MouseEvent):void {
			_topButton.gotoAndStop("down");
			
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
		}
		
		protected function onStageMouseUp(evt:MouseEvent):void {
			
			
			trace("on stage mouse up");
		}
		
		protected function onTopButtonMouseUp(evt:MouseEvent):void {
			_topButton.gotoAndStop("over");
		}
		
		protected function onTopButtonMouseOut(evt:MouseEvent):void {
			_topButton.gotoAndStop("idle");
		}
		
		protected function onTopButtonClick(evt:MouseEvent):void {
			trace("Top Button Clicked");
		}
		
		public function getWidth():Number {
			return _scrollerWidth;
		}
		
		
		public function setHeight(h:Number):void {
			
			_scrollerHeight = h;
	
			redraw();
			
		}
				
		public function setRange(r:Number):void {
			
			trace("setRange: "+r);
			_range = r;
			_position = 0;
		}
		
		protected function redraw():void {
			
			_bottomButton.y = _scrollerHeight - _scrollerWidth;
			
			_background.graphics.clear();
			_background.graphics.beginFill(0xffe0e0);
			_background.graphics.drawRect(0, 0, _scrollerWidth, _scrollerHeight);
			_background.graphics.endFill();
		}
			
	}
}
	