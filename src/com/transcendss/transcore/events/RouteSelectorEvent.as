package com.transcendss.transcore.events
{
	import com.transcendss.transcore.sld.models.components.Route;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;

	public class RouteSelectorEvent extends Event
	{
		public static const ROUTE_LIST_REQUESTED:String = "RouteSelectorEvent_RteListRequested";
		public static const ROUTE_SELECTOR_POPULATE:String = "RouteSelectorEvent_populate";
		public static const ROUTE_LIST_READY:String = "RouteSelectorEvent_routeListReady";
		public static const MIN_MAX_REQUESTED:String = "RouteSelectorEvent_minmaxRequested";
		public static const MIN_MAX_READY:String = "RouteSelectorEvent_minMaxReady";
		public static const ROUTE_SELECTION_COMPLETE:String = "RouteSelectorEvent_routeSectionComplete";
		public static const ROUTE_SELECTION_MAP_REDRAW:String = "RouteSelectorEvent_routeSectionMapRedraw";
		public static const ROUTE_SELECTION_CHANGED:String = "RouteSelectorEvent_RteListchanged";
		public static const ROUTE_CHANGE_REQUESTED:String ="RouteSelectorEvent_RtChangeRequested"; //when clicked on intersection change the route
		
		public var serviceURL:String;
		private var _route:Route;
		private var _scale:Number;
		public var dataProviderAC:ArrayCollection = new ArrayCollection();
		private var _routeName:String; //added for INDOT
		private var _routeFullName:String; //added for INDOT
		private var _fromStorage:Boolean=false;
		public function RouteSelectorEvent(type:String, route:Route =null,scale:Number=0, bubbles:Boolean = true, cancellable:Boolean = true)
		{
			_route = route;
			_scale= scale;
			super(type, bubbles,cancellable);
		}
		
		public function get route():Route
		{
			return _route;
		}
		
		public function get scale():Number
		{
			return _scale;
		}
			
		public function set routeName(rName:String):void{
			_routeName =  rName;
		}
		public function get routeName():String{
			return _routeName;
		}
		public function set routeFullName(rName:String):void{
			_routeFullName =  rName;
		}
		public function get routeFullName():String{
			return _routeFullName;
		}
		public function get fromStorage():Boolean
		{
			return _fromStorage;
		}
		public function set fromStorage(b:Boolean):void
		{
			_fromStorage=b;
		}
	}
}