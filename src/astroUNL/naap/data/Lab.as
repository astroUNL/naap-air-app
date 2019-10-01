/*
Lab.as
2019-09-18
*/

package astroUNL.naap.data {
	
	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.utils.logger.Logger;
	
	public class Lab {
		
		protected var _id:String = "";
		protected var _name:String = "";
		
		public var backgroundSWFs:Array = [];
		public var mainSWFs:Array = [];
		
		
		public function Lab(labXML:XML) {
			var itemXML:XML;
			var item:ResourceItem;
			
			try {
				_id = labXML.attribute("id").toString();
				_name = labXML.Name;
				for each (itemXML in labXML["BackgroundSWFs"].elements()) {
					item = new ResourceItem(ResourceItem.ANIMATION, itemXML);
					backgroundSWFs.push(item);
				}
				for each (itemXML in labXML["MainSWFs"].elements()) {
					item = new ResourceItem(ResourceItem.ANIMATION, itemXML);
					mainSWFs.push(item);
				}
			} catch (err:Error) {
				Logger.report("Failed to initialize Lab object from XML.");
			}
		}
		
		public function get name():String {
			return _name;
		}
	}
	
}

