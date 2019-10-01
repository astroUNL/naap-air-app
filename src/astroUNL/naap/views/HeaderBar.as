
package astroUNL.naap.views {
	
	import astroUNL.naap.data.Lab;
	import astroUNL.naap.views.Breadcrumbs;
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class HeaderBar extends SWCHeaderBar {
		
		
		/*
		public static const QUESTION_SELECTED:String = "questionSelected";
		public static const MODULE_SELECTED:String = "moduleSelected";
		public static const MODULES_LIST_SELECTED:String = "modulesListSelected";
		
		public static const MENU_ITEM_SELECTED:String = "menuItemSelected";
		
		public static const SEARCH:String = "Search";
		public static const ABOUT:String = "About";
				*/
				
		//protected var _navControl:NavControl;
		protected var _breadcrumbs:Breadcrumbs;
				
		protected var _width:Number = 800;
		protected const _height:Number = 29;
		protected var _dropLimit:Number = 1600;
		
		
		public function HeaderBar(width:Number) {
			
			/*
			// the navigation events dispatched by the nav control and breadcrumbs bubble up
			
			_navControl = new NavControl();
			_navControl.x = 25;
			_navControl.y = 14;
			addChild(_navControl);
			*/
			
			_breadcrumbs = new Breadcrumbs();
			_breadcrumbs.x = 15; //2*_navControl.x;
			_breadcrumbs.y = 4;
			addChild(_breadcrumbs);
			
			this.width = width;
			
			//redrawMask();
		}
		
		public function setState(lab:Lab):void {
			_breadcrumbs.setState(lab);
		}
		
		/*
		public function get modulesList():ModulesList {
			return _navControl.modulesList;
		}
		
		public function set modulesList(list:ModulesList):void {
			_navControl.modulesList = list;
		}
		*/
		/*
		protected function redrawMask():void {
			_menusMask.graphics.clear();
			_menusMask.graphics.beginFill(0xffff80);
			_menusMask.graphics.drawRect(0, _height, _width, _dropLimit);
			_menusMask.graphics.endFill();
		}
		*/
		
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
			//_breadcrumbs.maxWidth = logo.x - _breadcrumbs.x;
			//redrawMask();
		}
		
	}	
}
