
package astroUNL.naap.views {
	
	import astroUNL.naap.data.Lab;
	import astroUNL.naap.events.StateChangeRequestEvent;
	
	import astroUNL.classaction.browser.views.elements.ClickableText;
	
	import astroUNL.utils.logger.Logger;	
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	public class Breadcrumbs extends Sprite {
		
		protected var _homepageLink:ClickableText;
		protected var _labLink:ClickableText;
		
		protected var _lab:Lab;
		
		protected var _content:Sprite;
		protected var _mask:Shape;
		
		protected var _separator:String = "»";
		protected var _separator1:ClickableText;
		protected var _separator2:ClickableText;
		
		protected var _separatorTextFormat:TextFormat;
		protected var _linkTextFormat:TextFormat;
		
		protected var _spacing:Number = 4;
		
		
		public function Breadcrumbs() {
			
			_linkTextFormat = new TextFormat("Verdana", 12, 0x0, true);
			_separatorTextFormat = new TextFormat("Verdana", 11, 0x707070, true);
			
			_content = new Sprite();
			addChild(_content);
			
			//_mask = new Shape();
			//_mask.cacheAsBitmap = true;
			//addChild(_mask);
			
			//cacheAsBitmap = true;
			//mask = _mask;
			
			_separator1 = new ClickableText(_separator, null, _separatorTextFormat);
			_separator1.visible = false;
			_separator1.setClickable(false);
			_content.addChild(_separator1);
			
			_separator2 = new ClickableText(_separator, null, _separatorTextFormat);
			_separator2.visible = false;
			_separator2.setClickable(false);
			_content.addChild(_separator2);
			
			_homepageLink = new ClickableText("NAAP Labs", null, _linkTextFormat);
			_homepageLink.addEventListener(ClickableText.ON_CLICK, onHomepageClicked);
			_homepageLink.visible = false;
			_content.addChild(_homepageLink);
			
			_labLink = new ClickableText("", null, _linkTextFormat);
			//_labLink.addEventListener(ClickableText.ON_CLICK, onLabClicked);
			_labLink.visible = false;
			_content.addChild(_labLink);

		}
		
		protected var _maxWidth:Number = 0;
		protected var _maxWidthLimit:Number = 5000;
		protected var _fadeoutDistance:Number = 10;
		
		public function get maxWidth():Number {
			return _maxWidth;
		}
		
		public function set maxWidth(arg:Number):void {
			// maxWidth is the maximum amount of horizontal space the breadcrumbs get
			if (!isNaN(arg) && arg>0 && arg!=Number.NEGATIVE_INFINITY) {
				_maxWidth = arg;
				redrawMask();
			}
		}
		
		protected function redrawMask():void {
			
			/*
			_mask.graphics.clear();
			
			var w:Number = Math.min(_maxWidth, _maxWidthLimit);
			var fx:Number = Math.floor(_maxWidth - _fadeoutDistance);
			var h:Number = _labLink.height + 20;			
			var m:Matrix = new Matrix();
			m.createGradientBox(_fadeoutDistance, h, 0, fx, 0);
			
			// draw the solid part
			_mask.graphics.beginFill(0x00ff00);
			_mask.graphics.drawRect(0, _labLink.y-10, fx, h);
			_mask.graphics.endFill();
			
			// draw the fadeout part
			_mask.graphics.beginGradientFill("linear", [0x00ff00, 0x00ff00], [1, 0], [0, 0xff], m);
			_mask.graphics.drawRect(fx, _labLink.y-10, _fadeoutDistance, h);
			_mask.graphics.endFill();
			*/
		}
		
		
		protected function onHomepageClicked(evt:Event):void {
			dispatchEvent(new StateChangeRequestEvent(null, true));
		}
		
		
		public function setState(lab:Lab):void {
			
			_lab = lab;
			
			_homepageLink.visible = true;
			
						
			if (_lab!=null) {
				_homepageLink.setClickable(true);
				
				_labLink.setText(_lab.name);
				_labLink.visible = true;
				_labLink.setClickable(false);
				
				_separator1.visible = true;
				_separator2.visible = false;
			}
			else {
				_homepageLink.setClickable(false);
				
				_labLink.visible = false;
				
				_separator1.visible = false;
				_separator2.visible = false;
			}
			
			reposition();
		}
		
		protected function reposition():void {
			_homepageLink.x = 0;
			_separator1.x = _homepageLink.x + _homepageLink.width + _spacing;
			_labLink.x = _separator1.x + _separator1.width + _spacing;
			if (_lab!=null) {
				_separator2.x = _labLink.x + _labLink.width + _spacing;
			}
		}
		
	}	
}

