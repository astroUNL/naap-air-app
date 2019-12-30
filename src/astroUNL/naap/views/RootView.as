/*
RootView.as
naap-air-app
astro.unl.edu
2019-12-29
*/

package astroUNL.naap.views {
	
	import astroUNL.naap.data.LabsList;
	import astroUNL.naap.events.StateChangeRequestEvent;
	
	import astroUNL.classaction.browser.views.elements.ScrollableLayoutPanes;
	
	import astroUNL.naap.views.ClickableText;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.text.TextFormat;
	import flash.text.TextField;
	
	public class RootView extends RootViewSWC {
				
		protected var _labsList:LabsList = null;
		
		// labLinks contains the references to the ClickableText
		// instances associated with each lab
		protected var _labLinks:Dictionary;
				
		protected var _content:Sprite;
		
		protected var _headingFormat:TextFormat;
		protected var _itemFormat:TextFormat;
		
		// Note: there's no Nav Button since there will always be enough space for all labs.
		
		protected var _panelWidth:Number;
		protected var _panelHeight:Number;
		protected var _navButtonSpacing:Number = 35;
		protected var _panesTopMargin:Number = 57;
		protected var _panesSideMargin:Number = 15;
		protected var _panesBottomMargin:Number = 45;
		protected var _panesWidth:Number;
		protected var _panesHeight:Number;
		protected var _columnSpacing:Number = 20;
		protected var _numColumns:int = 2;
		protected var _easeTime:Number = 250;
				
		protected var _headingTopMargin:Number = 10;
		protected var _headingBottomMargin:Number = 4;
		protected var _headingMinLeftOver:Number = 25;
		protected var _itemLeftMargin:Number = 7;
		protected var _itemBottomMargin:Number = 9;
		protected var _itemMinLeftOver:Number = -9;
		
		protected var _panes:ScrollableLayoutPanes;
		
		
		//protected var _standardHeading:TextField;
		
		public function RootView(w:Number, h:Number) {
			
			_panelWidth = w;
			_panelHeight = h;
			
			_panesWidth = _panelWidth - 2*_navButtonSpacing;
			_panesHeight = _panelHeight - _panesTopMargin - _panesBottomMargin;
			
			_labLinks = new Dictionary();
						
			_panes = new ScrollableLayoutPanes(_panesWidth, _panesHeight, _navButtonSpacing, _navButtonSpacing, {topMargin: 0, leftMargin: _panesSideMargin, rightMargin: _panesSideMargin, bottomMargin: 0, columnSpacing: _columnSpacing, numColumns: _numColumns});
			_panes.x = _navButtonSpacing;
			_panes.y = _panesTopMargin;
			addChild(_panes);
			
			_headingFormat = new TextFormat("Verdana", 15, 0xffffff, true);
			_itemFormat = new TextFormat("Verdana", 15, 0xffffff, true);
		
			//_standardHeading = createHeading("NAAP Labs");
			
		/*
			_leftButton = new ResourcePanelNavButton();
			_leftButton.x = _navButtonSpacing;
			_leftButton.y = _panelHeight/2;
			_leftButton.scaleX = -1;
			_leftButton.addEventListener(MouseEvent.CLICK, onLeftButtonClicked);
			_leftButton.visible = false;
			addChild(_leftButton);
			
			_rightButton = new ResourcePanelNavButton();
			_rightButton.x = _panelWidth - _navButtonSpacing;
			_rightButton.y = _panelHeight/2;
			_rightButton.addEventListener(MouseEvent.CLICK, onRightButtonClicked);
			_rightButton.visible = false;
			addChild(_rightButton);				
			*/
		}
		
		
		
		
		
		public function setDimensions(w:Number, h:Number):void {
			if (w==_panelWidth && h==_panelHeight) return;
			_panelWidth = w;
			_panelHeight = h;
			_dimensionsUpdateNeeded = true;
			if (visible) redraw();
		}
		
		override public function set visible(visibleNow:Boolean):void {
			var previouslyVisible:Boolean = super.visible;
			super.visible = visibleNow;			
			if (!previouslyVisible && visibleNow) redraw();
		}
		
		protected var _dimensionsUpdateNeeded:Boolean = true;
		
		protected function doDimensionsUpdate():void {			
		
			// adjust the panes
			_panesWidth = _panelWidth - 2*_navButtonSpacing;
			_panesHeight = _panelHeight - _panesTopMargin - _panesBottomMargin;
			_panes.setDimensions(_panesWidth, _panesHeight);
			_panes.reset(); // needed here to recalculate columnWidth -- gets called again in redraw
			
			// adjust the layout
			_panes.x = _navButtonSpacing;
			_panes.y = _panesTopMargin;
			
			// adjust the text widths
			//_standardHeading.width = _panes.columnWidth;
			for each (var link:ClickableText in _labLinks) link.setWidth(_panes.columnWidth-_itemLeftMargin);
		
			_dimensionsUpdateNeeded = false;
		}
				
		protected function redraw():void {
			
			if (_labsList == null) {
				return;
			}
			
			if (_dimensionsUpdateNeeded) {
				doDimensionsUpdate();
			}
						
			_panes.reset();
			
			var headingParams:Object = {topMargin: _headingTopMargin, bottomMargin: _headingBottomMargin, minLeftOver: _headingMinLeftOver};
			var itemParams:Object = {columnTopMargin: 45, leftMargin: _itemLeftMargin, bottomMargin: _itemBottomMargin, minLeftOver: _itemMinLeftOver};

			//_panes.addContent(_standardHeading, headingParams);
			
			var i:int;
			var ct:ClickableText;
			
			trace(_labsList.labs.length);
						
			for (i=0; i<_labsList.labs.length; i++) {
				if (_labLinks[_labsList.labs[i]] == undefined) {
					var labName:String = (i+1) + ". " + _labsList.labs[i].name;
					ct = new ClickableText(labName, _labsList.labs[i], _itemFormat, _panes.columnWidth-_itemLeftMargin);		
					ct.addEventListener(ClickableText.ON_CLICK, onLabClicked, false, 0, true);
					_labLinks[_labsList.labs[i]] = ct;
				}
				_panes.addContent(_labLinks[_labsList.labs[i]], itemParams);
			}
			
		}
		
		public function get labsList():LabsList {
			return _labsList;
		}
		
		public function set labsList(list:LabsList):void {
			_labsList = list;
			redraw();
		}
		
		protected function createHeading(text:String):TextField {
			var t:TextField = new TextField();
			t.text = text;
			t.autoSize = "left";
			t.height = 0;
			t.width = _panes.columnWidth;
			t.multiline = true;
			t.wordWrap = true;			
			t.selectable = false;
			t.setTextFormat(_headingFormat);
			t.embedFonts = true;
			return t;
		}				
		
		protected function onLabClicked(evt:Event):void {
			dispatchEvent(new StateChangeRequestEvent(evt.target.data, null));
		}
		
	}
	
}
