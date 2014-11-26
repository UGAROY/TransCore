package com.transcendss.transcore.events
{
	import flash.events.Event;
	
	public class ViewMileEvent extends Event
	{
		public static const VIEWMILE_SET:String = "ViewMileEvent_set";
		
		public function ViewMileEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}
	}
}