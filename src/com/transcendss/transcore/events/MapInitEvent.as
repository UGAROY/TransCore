package com.transcendss.transcore.events
{
	import com.google.maps.MapEvent;
	import com.google.maps.MapType;
	import com.google.maps.View;
	
	import mx.collections.ArrayCollection;
	
	public class MapInitEvent extends MapEvent
	{
		
		public static const MAP_PREINITIALIZE:String = "mapevent_mappreinitialize";
//		public static const MAP_READY:String = "map_ready";
		public static const MAP_OPTIONS_READY:String = "map_op_ready";
		public static const MAP3D_OPTIONS_READY:String = "3d_map_op_ready";
		public static const MAP_ROUTE_INFO_READY:String = "mapInitEvent_mapRouteInfoReady";
		
		private var mType:int;
		private var mapOp:Object;
		private var _routeCoords:ArrayCollection;
		
		public function MapInitEvent(type:String, feature:Object=null, mtype:int=-1, bubbles:Boolean = true, cancellable:Boolean = true)
		{
			super(type,feature, bubbles,cancellable);
			mType = mtype;
		}
		
		public function set MapOptions(obj:Object):void
		{
			mapOp = obj;
		}
		
		public function get MapOptions():Object
		{
			return mapOp;
		}
		
		public function get MapType():int
		{
			return mType;
		}
		
		public function set routeCoords(coords:ArrayCollection):void
		{
			_routeCoords = coords;
		}
		
		public function get routeCoords():ArrayCollection
		{
			return _routeCoords;
		}
	}
}