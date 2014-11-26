package com.transcendss.transcore.sld.models.managers
{
	
	import com.transcendss.transcore.events.*;
	
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.core.ByteArrayAsset;
	import mx.core.FlexGlobals;
	

	public class NavManager
	{
		public var dispatcher:IEventDispatcher;
		
		public function NavManager()
		{
		}

		
		public function onClick(event:NavControlEvent):void
		{
			event.stopPropagation();
			dispatcher.dispatchEvent(new NavControlEvent(NavControlEvent.START_RUN,true, true));				
		}
	}
}