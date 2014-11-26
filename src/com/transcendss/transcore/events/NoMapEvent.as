package com.transcendss.transcore.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class NoMapEvent extends Event
	{
		public static const NOMAP_TRUE:String = "NoMapEvent_NoMapTrue";
		public static const NOMAP_FALSE:String = "NoMapEvent_NoMapFalse";

		public function NoMapEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}