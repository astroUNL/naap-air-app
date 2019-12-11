/*
Lab.as
naap-air-app
astro.unl.edu
2019-12-04
*/

package astroUNL.naap.data {
	
	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.utils.logger.Logger;
	
	public class Lab {
		
		public var id:String = "";
		public var name:String = "";
		public var description:String = "";
		public var studentGuide:String = "";
		
		// Each object in the sections array has these properties:
		//	title - either a string or null
		//	pages - an array of page objects
		// All page objects have these properties:
		//	lab - a reference to the owning Lab instance
		//	prevPage - the previous page in the sequence (will be null for the first page)
		//	nextPage - the next page in the sequence (will be null for the last page)
		//	isBackground - boolean indicates if the page is a background page
		//	isSimulator - booelan indicates if the page is a simulator page
		//	title - a string
		// These page object properties are for simulators only:
		//	file - (for simulator only) path to simulator SWF
		//	name - (for simulator only) a string
		//	preview - (for simulator only) path to associated preview image (the initial "files/" is automatically prepended)
		//	width, height - (for simulator only) numbers
		//	resourceItem - (for simulator only) the ResourceItem instance for the simulator
		// These page object properties are for background pages only:
		//	swfs - (for background only) an array of background page SWF objects, to be rendered back to front
		// Each swf object in swfs (for background pages) has these properties:
		//	file - path to SWF (the initial "files/" is automatically prepended)
		//	x, y - coordinates for the upper left corner of the SWF
		//	width, height - dimensions of the SWFs content (outside area should be masked)
		//	scale - the scale to apply to the SWF (e.g. 1.0)
		

		public var sections:Array = [];
		
		
		public function Lab(labXML:XML) {
			
			var prevPage:Object = null;
			var nextPage:Object = null;
			
			try {
				id = labXML.attribute("id").toString();
				name = labXML.Name;
				description = labXML.Description;
				sections = [];
				studentGuide = "files/" + labXML.StudentGuide;
				
				for each (var sectionXML:XML in labXML["Content"].elements()) {
					
					var section:Object = {};
					section.title = sectionXML.attribute("title").toString();
					section.pages = [];
					
					for each (var pageXML:XML in sectionXML.elements()) {
						var page:Object = {};
						page.lab = this;
						page.prevPage = prevPage;
						page.nextPage = null;
						page.swfs = [];
						
						if (pageXML.localName() == "BackgroundPage") {
							page.isBackground = true;
							page.isSimulator = false;
							
							for each (var swfXML:XML in pageXML.elements()) {
								if (swfXML.localName() != "SWF") {
									continue;
								}
								var swfObj:Object = {
											   file: "files/" + swfXML.File.toString(),
											   x: parseFloat(swfXML.X.toString()),
											   y: parseFloat(swfXML.Y.toString()),
											   width: parseFloat(swfXML.Width.toString()),
											   height: parseFloat(swfXML.Height.toString()),
											   scale: parseFloat(swfXML.Scale.toString())
								};
								if (swfObj.file == "" || isNaN(swfObj.x) || isNaN(swfObj.y) || isNaN(swfObj.width) || isNaN(swfObj.height) || isNaN(swfObj.scale)) {
									trace("ERROR: invalid properties for a background page SWF");
								}
								page.swfs.push(swfObj);
							}
							
							page.title = pageXML.Title.toString();
						} else if (pageXML.localName() == "Simulator") {
							page.isBackground = false;
							page.isSimulator = true;
							page.file = pageXML.File.toString();
							page.name = pageXML.Name.toString();
							page.preview = "files/" + pageXML.Preview.toString();
							page.title = page.name;
							page.width = parseFloat(pageXML.width.toString());
							page.height = parseFloat(pageXML.height.toString());
							page.resourceItem = new ResourceItem(ResourceItem.ANIMATION, pageXML);
						} else {
							trace("ERROR: element of unknown type in labs XML");
							continue;
						}
						
						section.pages.push(page);
						
						if (prevPage != null) {
							prevPage.nextPage = page;
						}
						prevPage = page;
					}
					
					sections.push(section);
				}
			} catch (err:Error) {
				Logger.report("Failed to initialize Lab object from XML.");
			}
		}
		
	}
}
