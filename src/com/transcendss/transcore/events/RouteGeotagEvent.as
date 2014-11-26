package com.transcendss.transcore.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class RouteGeotagEvent extends Event
	{
		public static const ROUTE_LOCAL_GEOTAG_REQUESTED:String = "routelocalGeotagEvent_routeGoetagRequested";
		public static const ROUTE_GEOTAG_REQUESTED:String = "routeGeotagEvent_routeGoetagRequested";
		public static const ROUTE_GEOTAG_READY:String = "routeGeotagEvent_routeGoetagReady";
		private var url:String;
		
		public function RouteGeotagEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true, ac:ArrayCollection=null)
		{
			super(type, bubbles, cancelable);
		}
		
		public function set serviceURL(v:String):void
		{
			url=v;
		}
		
		public function get serviceURL():String
		{
			return url;
		}
	}
}