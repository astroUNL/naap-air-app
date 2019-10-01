
package astroUNL.naap.events {
	
	import flash.events.Event;
	
	import astroUNL.naap.data.Lab;
	
	
	public class StateChangeRequestEvent extends Event {
		
		public static const STATE_CHANGE_REQUESTED:String = "stateChangeRequested";
		
		public var lab:Lab;
		
		public function StateChangeRequestEvent(lab:Lab=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(StateChangeRequestEvent.STATE_CHANGE_REQUESTED, bubbles, cancelable);
			this.lab = lab;
		}
		
		override public function clone():Event {
			return new StateChangeRequestEvent(lab, bubbles, cancelable);
		}
		
		override public function toString():String {
			return formatToString("StateChangeRequestEvent", "module", "bubbles", "cancelable", "eventPhase"); 
		}
			
	}	
}

