/*
Main.as
naap-air-app
astro.unl.edu
2019-12-03
*/

package astroUNL.naap {
	
	import astroUNL.classaction.browser.views.ResourceWindowsManager;
	import astroUNL.classaction.browser.download.Downloader;
	import astroUNL.classaction.browser.events.MenuEvent;
	
	import astroUNL.naap.data.LabsList;
	import astroUNL.naap.data.Lab;
	
	import astroUNL.naap.views.HeaderBar;
	
	import astroUNL.naap.views.RootView;
	import astroUNL.naap.views.LabView;
	import astroUNL.naap.views.PageView;

	import astroUNL.naap.events.StateChangeRequestEvent;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;

	public class Main extends Sprite {
		
		protected var _labsList:LabsList;
		
		protected var _header:HeaderBar;
		
		protected var _rootView:RootView;
		protected var _labView:LabView;
		protected var _pageView:PageView;
		
		public function Main() {
			
			trace("Main constructor");
			trace(" stage.stageWidth: "+stage.stageWidth);
			trace(" stage.stageHeight: "+stage.stageHeight);
			trace(" stage.width: "+stage.width);
			trace(" stage.height: "+stage.height);
			
			stage.color = 0xffffff;
			stage.nativeWindow.addEventListener(Event.CLOSING, onMainWindowClosing);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		
		protected const _minWidth:Number = 845;
		protected const _minHeight:Number = 600;		
		protected const _homepageMargins:Object = {left: 20, right: 5, top: 20, bottom: 10};
		protected const _labViewMargins:Object = {left: 20, right: 5, top: 15, bottom: 10}; 
		
		
		protected function onAddedToStage(evt:Event):void {
			trace("onAddedToStage");
			
			// updateDimensions gets called at the end the loading sequence (before the views are first made
			// visible), but some components need dimensions at initialization and so we might as well give
			// them the correct information now and save a few milliseconds
			var windowWidth:Number = Math.max(stage.stageWidth, _minWidth);
			var windowHeight:Number = Math.max(stage.stageHeight, _minHeight);
			stage.stageWidth = windowWidth;
			stage.stageHeight = windowHeight;
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, onStageResized);
			
			Downloader.init("files/");
			
			_labsList = new LabsList("labs.xml");
			_labsList.addEventListener(LabsList.LOAD_FINISHED, onLabsListLoadFinished);
			
			_rootView = new RootView(stage.stageWidth, stage.stageHeight);
			_rootView.addEventListener(StateChangeRequestEvent.STATE_CHANGE_REQUESTED, onStateChangeRequested);
			_rootView.visible = false;
			addChild(_rootView);
			
			_labView = new LabView(stage.stageWidth, stage.stageHeight);
			_labView.addEventListener(StateChangeRequestEvent.STATE_CHANGE_REQUESTED, onStateChangeRequested);
			_labView.visible = false;
			addChild(_labView);
			
			_pageView = new PageView(stage.stageWidth, stage.stageHeight);
			_pageView.addEventListener(StateChangeRequestEvent.STATE_CHANGE_REQUESTED, onStateChangeRequested);
			_pageView.visible = false;
			addChild(_pageView);
			
			_header = new HeaderBar(windowWidth);
			_header.addEventListener(StateChangeRequestEvent.STATE_CHANGE_REQUESTED, onStateChangeRequested);
			_header.x = 0;
			_header.y = 0;
			addChild(_header);
			
			updateDimensions();
			
			setView(null, null);
		}
		
		protected function onStageResized(evt:Event):void {
			updateDimensions();
		}
		
		protected function onStateChangeRequested(evt:StateChangeRequestEvent):void {
			setView(evt.lab, evt.page);			
		}
		
		protected function setView(lab:Lab=null, page:Object=null):void {
						
			_header.setState(lab, page);
			
			if (lab == null) {
								
				_rootView.visible = true;
				_labView.visible = false;
				_pageView.visible = false;
				
			} else if (page == null) {
				
				_labView.setLab(lab);
				
				_rootView.visible = false;
				_labView.visible = true;
				_pageView.visible = false;
				
			} else {
				
				_pageView.setPage(page);
				
				_rootView.visible = false;
				_labView.visible = false;
				_pageView.visible = true;
			}
		}
		
		protected var _windowWidth:Number = -1;
		protected var _windowHeight:Number = -1;
		
		protected function updateDimensions():void {
			
			var t:Number = Math.random();

/*			
			trace("Main Window, updateDimensions");
			trace(" stage.stageWidth (before): "+stage.stageWidth);
			trace(" stage.stageHeight (before): "+stage.stageHeight);
			trace(t);
*/
			
			if (stage.stageWidth == _windowWidth && stage.stageHeight == _windowHeight) {
//				trace(" WARNING: redundant call to updateDimensions, will abort");
				return;
			}
			
			_windowWidth = Math.max(stage.stageWidth, _minWidth);
			_windowHeight = Math.max(stage.stageHeight, _minHeight);
			
			if (_windowWidth != stage.stageWidth) {
				stage.stageWidth = _windowWidth;
			}
			
			if (_windowHeight != stage.stageHeight) {
				stage.stageHeight = _windowHeight;
			}

/*
			trace(" stage.stageWidth (after): "+stage.stageWidth);
			trace(" stage.stageHeight (after): "+stage.stageHeight);
			trace(t);
*/

			_header.width = _windowWidth;
			
			var freeVerticalSpace:Number = _windowHeight - Math.ceil(_header.height);
			
			_rootView.x = _homepageMargins.left;
			_rootView.y = _header.height + _homepageMargins.top;	
			_rootView.setDimensions(_windowWidth-_homepageMargins.left-_homepageMargins.right, freeVerticalSpace-_homepageMargins.top-_homepageMargins.bottom);
			
			_labView.x = _labViewMargins.left;
			_labView.y = _header.height + _labViewMargins.top;	
			_labView.setDimensions(_windowWidth-_labViewMargins.left-_labViewMargins.right, freeVerticalSpace-_labViewMargins.top-_labViewMargins.bottom);
			
			_pageView.x = 0;
			_pageView.y = _header.height;
			_pageView.setDimensions(_windowWidth, freeVerticalSpace);
		}
		
		protected function onLabsListLoadFinished(evt:Event):void {
			_rootView.labsList = _labsList;
			
		}
		
		protected function onMainWindowClosing(evt:Event):void {
			trace("Main window is closing, resource windows should follow.");
			ResourceWindowsManager.closeAll();
		}
	}
}
