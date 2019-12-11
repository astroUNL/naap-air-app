/*
PageView.as
naap-air-app
astro.unl.edu
2019-12-09
*/

package astroUNL.naap.views {
	
	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.classaction.browser.views.ResourceWindowsManager;
	import astroUNL.naap.events.StateChangeRequestEvent;
	
	import astroUNL.naap.views.BackgroundPageView;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	
	public class PageView extends SWCPageView {
		
		protected var _backgroundPage:Object = null;
		
		protected var _backgroundPageView:BackgroundPageView;
		
		protected var _minWidth:Number = 845;
		protected var _minHeight:Number = 500;
		
		protected var _viewWidth:Number;
		protected var _viewHeight:Number;
		
		protected var _page:Object = null;
		
		protected var _needsDimensionsUpdate:Boolean = true;
		//protected var _needsContentScaleUpdate:Boolean = true;
		protected var _needsPageUpdate:Boolean = true;
		protected var _needsPreviewUpdate:Boolean = true;
		
		protected const _backgroundPageViewY:Number = 67;
		
		public function PageView(w:Number, h:Number) {
			
			
			_backgroundPageView = new BackgroundPageView();
			_backgroundPageView.x = 0;
			_backgroundPageView.y = _backgroundPageViewY;
			addChild(_backgroundPageView);
			
			header.leftButton.addEventListener(MouseEvent.CLICK, onLeftButtonClick);
			header.rightButton.addEventListener(MouseEvent.CLICK, onRightButtonClick);
			
			previewImage.addEventListener(MouseEvent.CLICK, onPreviewImageClick);
			previewImage.addEventListener(Event.COMPLETE, onPreviewImageLoaded);
			
			setDimensions(w, h);
		}
		
		override public function set visible(visibleNow:Boolean):void {
			var previouslyVisible:Boolean = super.visible;
			super.visible = visibleNow;
			if (!previouslyVisible && visibleNow) {
				redraw();
			}
		}
		
		public function setDimensions(w:Number, h:Number):void {
			_viewWidth = w;
			_viewHeight = h;
			_needsDimensionsUpdate = true;
			//_needsContentScaleUpdate = true;
			_needsPreviewUpdate = true;
			redraw();
		}
		
		public function setPage(page:Object):void {
			_page = page;
			_needsPageUpdate = true;
			//_needsContentScaleUpdate = true;
			_needsPreviewUpdate = true;
			redraw();
		}
		
		protected function redraw():void {
			if (!super.visible) {
				return;
			}
			
			if (_needsDimensionsUpdate) {
				doDimensionsUpdate();
			}
			
			if (_needsPageUpdate) {
				doPageUpdate();
			}
			
			if (_needsPreviewUpdate) {
				doPreviewUpdate();
			}
		}
		
		protected function doDimensionsUpdate():void {
			
			if (_viewWidth < _minWidth) {
				_viewWidth = _minWidth;
			}
			
			if (_viewHeight < _minHeight) {
				_viewHeight = _minHeight;
			}
			
			header.x = 0.5*_viewWidth;
						
			_backgroundPageView.setDimensions(_viewWidth, _viewHeight - _backgroundPageViewY);
			
			_needsDimensionsUpdate = false;
		}
		
		protected function doPageUpdate():void {
						
			if (_page == null) {
				trace("ERROR: _page is null in doPageUpdate in PageView");
				header.titleField.text = "error";
				return;
			}
			
			header.titleField.text = _page.title;
			
			if (_page.prevPage != null) {
				header.leftButton.label = "Previous Page";
			} else {
				header.leftButton.label = "Return to Lab";
			}
			
			if (_page.nextPage != null) {
				header.rightButton.label = "Next Page";
			} else {
				header.rightButton.label = "Return to Lab";
			}
			
			if (_page.isBackground) {
				
				previewMessage.visible = false;
				previewImage.visible = false;
				
				_backgroundPageView.setBackgroundPage(_page);

				_backgroundPageView.visible = true;
				
			} else if (_page.isSimulator) {
				_backgroundPageView.visible = false;
				previewMessage.visible = true;
				previewImage.visible = true;
				
				_backgroundPageView.setBackgroundPage(null);
			
				var prequest:URLRequest = new URLRequest(_page.preview);
				
				var pcontext:LoaderContext = new LoaderContext();
				pcontext.applicationDomain = new ApplicationDomain(null);		
				
				previewImage.load(prequest, pcontext);
				
			} else {
				trace("ERROR: unknown page type in PageView");
				
				_backgroundPageView.visible = false;
				previewMessage.visible = false;
				previewImage.visible = false;
				
				_backgroundPageView.setBackgroundPage(null);
			}
			
			_needsPageUpdate = false;
		}
		
		protected function doPreviewUpdate():void {
			if (previewImage.content != null) {
				previewImage.x = 0.5*(_viewWidth - previewImage.content.width);
			}
			previewMessage.x = 0.5*(_viewWidth - previewMessage.width);
			_needsPreviewUpdate = false;
		}
		
		/*
		protected function onContentLoaded(evt:Event):void {
			doContentScaleUpdate();
		}
		*/
		
		protected function onPreviewImageLoaded(evt:Event):void {
			doPreviewUpdate();
		}
		
		protected function onLeftButtonClick(evt:MouseEvent):void {
			if (_page == null) {
				trace("ERROR: left button clicked when _page is null in PageView");
			} else if (_page.prevPage == null) {
				dispatchEvent(new StateChangeRequestEvent(_page.lab, null));
			} else {
				dispatchEvent(new StateChangeRequestEvent(_page.lab, _page.prevPage));
			}
		}
		
		protected function onRightButtonClick(evt:MouseEvent):void {
			if (_page == null) {
				trace("ERROR: right button clicked when _page is null in PageView");
			} else if (_page.nextPage == null) {
				dispatchEvent(new StateChangeRequestEvent(_page.lab, null));
			} else {
				dispatchEvent(new StateChangeRequestEvent(_page.lab, _page.nextPage));
			}
		}
		
		protected function onPreviewImageClick(evt:MouseEvent):void {
			if (_page == null) {
				trace("ERROR: preview image clicked when _page is null in PageView");
			} else if (!_page.isSimulator) {
				trace("ERROR: preview image clicked when not showing a simulator page");
			} else {
				ResourceWindowsManager.open(_page.resourceItem);
			}
		}
	}
	
}