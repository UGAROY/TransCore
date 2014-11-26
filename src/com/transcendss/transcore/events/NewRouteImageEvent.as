package com.transcendss.transcore.events
{
	import com.transcendss.transcore.sld.models.components.Route;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class NewRouteImageEvent extends Event
	{
		
		public static const NEW_ROUTE:String = "NewRouteImageEvent_NewRoute";
		private var _routeID:String;
		private var _routeDir:String;
		private var _minMP:String;
		private var _maxMP:String;
		
		
		
		public function NewRouteImageEvent(type:String, rtid:String, rtdir:String, minmp:String, maxmp:String, bubbles:Boolean = true, cancellable:Boolean = true)
		{
			super(type, bubbles,cancellable);
			this.routeID = rtid;
			this.routeDir = rtdir;
			this.minMP = minmp;
			this.maxMP = maxmp;
		}
		
		
		
		public function get maxMP():String
		{
			return _maxMP;
		}
		
		public function set maxMP(value:String):void
		{
			_maxMP = value;
		}
		
		public function get minMP():String
		{
			return _minMP;
		}
		
		public function set minMP(value:String):void
		{
			_minMP = value;
		}
		
		public function get routeDir():String
		{
			return _routeDir;
		}
		
		public function set routeDir(value:String):void
		{
			_routeDir = value;
		}
		
		public function get routeID():String
		{
			return _routeID;
		}
		
		public function set routeID(value:String):void
		{
			_routeID = value;
		}
		
	}
}