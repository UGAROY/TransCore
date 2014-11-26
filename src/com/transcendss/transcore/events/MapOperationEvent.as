package com.transcendss.transcore.events
{
	import com.google.maps.MapEvent;
	import com.google.maps.MapType;
	import com.google.maps.View;
	
	import mx.collections.ArrayCollection;
	
	public class MapOperationEvent extends MapEvent
	{
		
		public static const MAP_SCALE_CHANGED:String = "mapInitEvent_mapScaleChanged";

		public function MapOperationEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}

	}
}