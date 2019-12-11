/*
LabView.as
naap-air-app
astro.unl.edu
2019-12-11
*/

package astroUNL.naap.views {
	
	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.classaction.browser.views.ResourceWindowsManager;
	import astroUNL.classaction.browser.views.elements.ScrollableLayoutPanes;
	import astroUNL.classaction.browser.events.MenuEvent;
	
	import astroUNL.naap.data.Lab;	
	import astroUNL.naap.events.StateChangeRequestEvent;
	import astroUNL.naap.views.ClickableText;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.text.TextFormat;
	import flash.text.TextField;
	
	public class LabView extends SWCLabView {
				
		protected var _lab:Lab = null;
		
		protected var _sectionTitles:Dictionary;
		protected var _links:Dictionary;
		
		protected var _sectionTitleFormat:TextFormat;
		protected var _linkFormat:TextFormat;
		
		protected const PANEL_WIDTH:Number = 380;
		
		protected var _panelWidth:Number;
		protected var _panelHeight:Number;
		protected var _navButtonSpacing:Number = 20;
		protected var _panesTopMargin:Number = 0;
		protected var _panesSideMargin:Number = 15;
		protected var _panesBottomMargin:Number = 45;
		protected var _panesWidth:Number;
		protected var _panesHeight:Number;
		protected var _columnSpacing:Number = 20;
		protected var _numColumns:int = 1;
		protected var _easeTime:Number = 250;
				
		protected var _headingTopMargin:Number = 10;
		protected var _headingBottomMargin:Number = 10;
		protected var _headingMinLeftOver:Number = 25;
		protected var _itemLeftMargin:Number = 7;
		protected var _itemBottomMargin:Number = 9;
		protected var _itemMinLeftOver:Number = -9;
		
		protected var _panes:ScrollableLayoutPanes;
		
		
		protected var _newWindowIcons:Sprite;
		
		
		public function LabView(w:Number, h:Number) {
			
			_panelWidth = w;
			_panelHeight = h;
			
			_panesWidth = _panelWidth - 2*_navButtonSpacing;
			_panesHeight = _panelHeight - _panesTopMargin - _panesBottomMargin;
			
			_sectionTitles = new Dictionary();
			_links = new Dictionary();
			
			_panesTopMargin = _title.height + _title.y + 20;
						
			_panes = new ScrollableLayoutPanes(_panesWidth, _panesHeight, _navButtonSpacing, _navButtonSpacing, {topMargin: 0, leftMargin: _panesSideMargin, rightMargin: _panesSideMargin, bottomMargin: 0, columnSpacing: _columnSpacing, numColumns: _numColumns});
			_panes.x = _navButtonSpacing;
			_panes.y = _panesTopMargin;
			addChild(_panes);
			
			_newWindowIcons = new Sprite();
			addChild(_newWindowIcons);
			
			_sectionTitleFormat = new TextFormat("Verdana", 16, 0x0, true);
			_linkFormat = new TextFormat("Verdana", 14, 0x0);
		
		}
		
		public function setDimensions(w:Number, h:Number):void {
			if (w==_panelWidth && h==_panelHeight) return;
			_panelWidth = PANEL_WIDTH;
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
			for each (var sectionTitle:TextField in _sectionTitles) sectionTitle.width = _panes.columnWidth;
			for each (var link:ClickableText in _links) link.setWidth(_panes.columnWidth-_itemLeftMargin);
		
			_dimensionsUpdateNeeded = false;
		}
				
		protected function redraw():void {
			
			if (_lab == null) {
				return;
			}
			
			_title.text = _lab.name;
			
			studentGuideLink.htmlText = "<a href=\"" + _lab.studentGuide + "\">Student Guide</a>";
			
			descriptionField.text = _lab.description;
			
			if (_dimensionsUpdateNeeded) {
				doDimensionsUpdate();
			}
			
			//var oldPaneNum:int = _panes.paneNum;
			
			_panes.reset();
			
			_newWindowIcons.removeChildren();
			
			var sectionTitleParams:Object = {topMargin: _headingTopMargin, bottomMargin: _headingBottomMargin, minLeftOver: _headingMinLeftOver};
			var linkParams:Object = {columnTopMargin: 0, leftMargin: _itemLeftMargin, bottomMargin: _itemBottomMargin, minLeftOver: _itemMinLeftOver};
			
			
			trace("LabView redraw");
			
			for each (var section:Object in _lab.sections) {
				
				if (section.title != null) {
					if (_sectionTitles[section.title] == undefined) {
						var st:TextField = createSectionTitle(section.title);
						_sectionTitles[section.title] = st;
					}
					_panes.addContent(_sectionTitles[section.title], sectionTitleParams);
				}
				
				for each (var page:Object in section.pages) {
					
					if (page.isBackground) {
						if (_links[page] == undefined) {
							var bct:ClickableText = new ClickableText(page.title, page, _linkFormat, _panes.columnWidth-_itemLeftMargin);
							bct.addEventListener(ClickableText.ON_CLICK, onBackgroundPageClicked, false, 0, true);
							_links[page] = bct;
						}
						_panes.addContent(_links[page], linkParams);
					} else if (page.isSimulator) {
						if (_links[page] == undefined) {
							var sct:ClickableText = new ClickableText(page.title, page, _linkFormat, _panes.columnWidth-_itemLeftMargin);
							sct.addEventListener(ClickableText.ON_CLICK, onSimulatorClicked, false, 0, true);
							_links[page] = sct;
							
						}
						_panes.addContent(_links[page], linkParams);
						
						var nwi:NewWindowIconSWC = new NewWindowIconSWC();
						nwi.x = _panes.x + _links[page].backgroundWidth + _links[page].x;
						nwi.y = _panes.y + _links[page].y;
						_newWindowIcons.addChild(nwi);
						
					} else {
						trace("ERROR: page is of unknown type");
					}
				}
			}
			
			/*
			if (_lab.backgroundPages.length > 0) {
				_panes.addContent(_backgroundPagesHeading, headingParams);
				for (i=0; i<_lab.backgroundPages.length; i++) {
					page = _lab.backgroundPages[i];
					if (_links[page] == undefined) {
						ct = new ClickableText(page.title, page, _itemFormat, _panes.columnWidth-_itemLeftMargin);		
						ct.addEventListener(ClickableText.ON_CLICK, onBackgroundPageClicked, false, 0, true);
						_links[page] = ct;
					}
					_panes.addContent(_links[page], itemParams);
				}
			}
			
			if (_lab.backgroundSWFs.length > 0) {			
				_panes.addContent(_backgroundHeading, headingParams);
				for (i=0; i<_lab.backgroundSWFs.length; i++) {
					item = _lab.backgroundSWFs[i];
					if (_links[item] == undefined) {
						ct = new ClickableText(item.name, item, _itemFormat, _panes.columnWidth-_itemLeftMargin);		
						ct.addEventListener(ClickableText.ON_CLICK, onItemClicked, false, 0, true);
						_links[item] = ct;
					}
					_panes.addContent(_links[item], itemParams);
				}
			}
						
			_panes.addContent(_simulatorsHeading, headingParams);
			for (i=0; i<_lab.mainSWFs.length; i++) {
				item = _lab.mainSWFs[i];
				if (_links[item] == undefined) {
					ct = new ClickableText(item.name, item, _itemFormat, _panes.columnWidth-_itemLeftMargin);		
					ct.addEventListener(ClickableText.ON_CLICK, onItemClicked, false, 0, true);
					_links[item] = ct;
				}
				_panes.addContent(_links[item], itemParams);
			}
			*/
		}
		
		
		
		public function setLab(arg:Lab):void {
			_lab = arg;
			redraw();
		}
		
		protected function createSectionTitle(text:String):TextField {
			var t:TextField = new TextField();
			t.text = text;
			t.autoSize = "left";
			t.height = 0;
			t.width = _panes.columnWidth;
			t.multiline = true;
			t.wordWrap = true;			
			t.selectable = false;
			t.setTextFormat(_sectionTitleFormat);
			t.embedFonts = true;
			return t;
		}			
		
		protected function onBackgroundPageClicked(evt:Event):void {
			trace("onBackgroundPageClicked");
			var page:Object = evt.target.data;
			dispatchEvent(new StateChangeRequestEvent(_lab, page));
			
		}
		
		protected function onSimulatorClicked(evt:Event):void {
			trace("onSimulatorClicked");
			var page:Object = evt.target.data;
			ResourceWindowsManager.open(page.resourceItem);
		}
		
	}
	
}
