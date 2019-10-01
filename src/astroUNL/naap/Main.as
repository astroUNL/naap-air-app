/*
Main.as
2019-09-19
*/

package astroUNL.naap {
	
	import astroUNL.classaction.browser.views.ResourceWindowsManager;
	import astroUNL.classaction.browser.download.Downloader;
	import astroUNL.classaction.browser.events.MenuEvent;
	
	import astroUNL.naap.data.LabsList;
	import astroUNL.naap.data.Lab;
	import astroUNL.naap.views.Homepage;
	import astroUNL.naap.views.LabView;
	import astroUNL.naap.views.HeaderBar;
	import astroUNL.naap.events.StateChangeRequestEvent;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;

	public class Main extends Sprite {
		
		protected var _labsList:LabsList;
		
		protected var _header:HeaderBar;
		protected var _homepage:Homepage;
		protected var _labView:LabView;
		
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
		
		
		protected const _minWidth:Number = 400;
		protected const _minHeight:Number = 200;		
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
			
			_labsList = new LabsList("files.xml");
			_labsList.addEventListener(LabsList.LOAD_FINISHED, onLabsListLoadFinished);
			
			_homepage = new Homepage(stage.stageWidth, stage.stageHeight);
			_homepage.addEventListener(Homepage.LAB_SELECTED, onLabSelected);
			_homepage.visible = false;
			addChild(_homepage);
			
			_labView = new LabView(stage.stageWidth, stage.stageHeight);
			_labView.visible = false;
			addChild(_labView);
			
			_header = new HeaderBar(windowWidth);
			_header.addEventListener(StateChangeRequestEvent.STATE_CHANGE_REQUESTED, onStateChangeRequested);
			_header.x = 0;
			_header.y = 0;
			addChild(_header);
			
			updateDimensions();
			
			setView(null);
		}
		
		protected function onStageResized(evt:Event):void {
			trace("onStageResized");
			updateDimensions();
		}
		
		protected function onLabSelected(evt:MenuEvent):void {
			setView(evt.data);
		}
		
		protected function onStateChangeRequested(evt:StateChangeRequestEvent):void {
			setView(evt.lab);			
		}
		
		protected var _selectedLab:Lab = null;
		
		protected function setView(lab:Lab=null):void {
			
			_homepage.visible = false;
			_labView.visible = false;
						
			_selectedLab = lab;
			
			_header.setState(_selectedLab);
			
			if (_selectedLab == null) {
				_homepage.visible = true;
			} else {
				_labView.lab = _selectedLab;
				_labView.visible = true;
			}
		}
		
		
				
		protected function updateDimensions():void {
			
			trace("Main Window, updateDimensions");
			trace(" stage.stageWidth (before): "+stage.stageWidth);
			trace(" stage.stageHeight (before): "+stage.stageHeight);
			
			var windowWidth:Number = Math.max(stage.stageWidth, _minWidth);
			var windowHeight:Number = Math.max(stage.stageHeight, _minHeight);
			stage.stageWidth = windowWidth;
			stage.stageHeight = windowHeight;
			
			_header.width = windowWidth;
			
			var freeVerticalSpace:Number = windowHeight - Math.ceil(_header.height);
			
			_homepage.x = _homepageMargins.left;
			_homepage.y = _header.height + _homepageMargins.top;	
			_homepage.setDimensions(windowWidth-_homepageMargins.left-_homepageMargins.right, freeVerticalSpace-_homepageMargins.top-_homepageMargins.bottom);
			
			_labView.x = _labViewMargins.left;
			_labView.y = _header.height + _labViewMargins.top;	
			_labView.setDimensions(windowWidth-_labViewMargins.left-_labViewMargins.right, freeVerticalSpace-_labViewMargins.top-_labViewMargins.bottom);
		}
		
		
		protected function onLabsListLoadFinished(evt:Event):void {
			trace("onLabsListLoadFinished");
			_homepage.labsList = _labsList;
			
		}
		
		protected function onMainWindowClosing(evt:Event):void {
			trace("Main window is closing, resource windows should follow.");
			ResourceWindowsManager.closeAll();
		}
	}
}
