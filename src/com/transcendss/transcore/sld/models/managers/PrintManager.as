package com.transcendss.transcore.sld.models.managers
{
	import com.transcendss.transcore.events.*;
	import flash.events.IEventDispatcher;
	
	public class PrintManager
	{
		public var dispatcher:IEventDispatcher

		public function PrintManager()
		{
		}
		
		public function onClick(event:MenuBarEvent):void
		{
			event.stopPropagation();
			
			dispatcher.dispatchEvent(new PrintEvent(PrintEvent.PRINT_PREVIEW_ENABLED,true, true));
		}
	}
}