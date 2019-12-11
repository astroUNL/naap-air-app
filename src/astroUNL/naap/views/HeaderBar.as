/*
HeaderBar.as
naap-air-app
astro.unl.edu
2019-11-21
*/

package astroUNL.naap.views {
	
	import astroUNL.naap.data.Lab;
	import astroUNL.naap.views.Breadcrumbs;
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class HeaderBar extends SWCHeaderBar {
		
		protected var _breadcrumbs:Breadcrumbs;
				
		protected var _width:Number = 800;
		protected const _height:Number = 29;
		protected var _dropLimit:Number = 1600;
		
		
		public function HeaderBar(width:Number) {
						
			_breadcrumbs = new Breadcrumbs();
			_breadcrumbs.x = 15;
			_breadcrumbs.y = 4;
			addChild(_breadcrumbs);
			
			this.width = width;
		}
		
		public function setState(lab:Lab, page:Object):void {
			_breadcrumbs.setState(lab, page);
		}
		
		override public function get height():Number {
			return _height;
		}
		
		override public function set height(arg:Number):void {
			//
		}
		
		override public function get width():Number {
			return _width;			
		}
		
		override public function set width(arg:Number):void {			
			_background.width = arg;
			_width = arg;
		}
		
	}	
}
