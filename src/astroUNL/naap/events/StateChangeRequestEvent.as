/*
StateChangeRequestEvent.as
naap-air-app
astro.unl.edu
2019-11-21
*/

package astroUNL.naap.events {
	
	import flash.events.Event;
	
	import astroUNL.naap.data.Lab;
	
	public class StateChangeRequestEvent extends Event {
		
		public static const STATE_CHANGE_REQUESTED:String = "stateChangeRequested";
		
		public var lab:Lab;
		public var page:Object;
		
		public function StateChangeRequestEvent(lab:Lab=null, page:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(StateChangeRequestEvent.STATE_CHANGE_REQUESTED, bubbles, cancelable);
			this.lab = lab;
			this.page = page;
		}
		
		override public function clone():Event {
			return new StateChangeRequestEvent(lab, page, bubbles, cancelable);
		}
		
		override public function toString():String {
			return formatToString("StateChangeRequestEvent", "lab", "page", "bubbles", "cancelable", "eventPhase"); 
		}
			
	}	
}

