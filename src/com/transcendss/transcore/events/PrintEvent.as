package com.transcendss.transcore.events
{
	import flash.events.Event;
	
	
	public class PrintEvent extends Event
	{
		public static const PRINT_PREVIEW_ENABLED:String = "printEvent_previewEnabled";

		
		public function PrintEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}
	}
}