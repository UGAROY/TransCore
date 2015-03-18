package com.transcendss.transcore.events
{
	import com.transcendss.transcore.sld.models.components.Route;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	
	public class ElementEvent extends Event
	{
		public static const ELEMENT_REQUEST:String = "elementEvent_elementRequest";
		public static const ELEMENT_LOAD_COMPLETED:String = "elementEvent_elementsloaded";
		public static const DRAW_ROADWAY_LANES:String = "attributeEvent_drawRoadwayLanes";
		
		private var _serviceURL:String ;
		private var _scale:Number;
		private var _route:Route;
		private var _elementType:String;
		private var _routeName:String;
		private var _routeFullName:String;
		private var _begMile:Number;
		private var _endMile:Number;
		private var _eventLayerID:int;
		public var responder:IResponder;
		public var featureAC:ArrayCollection= new ArrayCollection();
		
		public function ElementEvent(type:String,elemArrayC:ArrayCollection= null, currScale:Number=-1, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			featureAC = elemArrayC;
			scale = currScale;
		}
		
		
		public function set scale(value:Number):void
		{
			_scale = value;
		}

		public function get scale():Number
		{
			return _scale;
		}

		public function set eventLayerID(id:int):void{
			_eventLayerID =  id;
		}
		public function get eventLayerID():int{
			return _eventLayerID;
		}
		
		public function set serviceURL(url:String):void{
			_serviceURL =  url;
		}
		public function get serviceURL():String{
			return _serviceURL;
		}
		
		public function set elementType(url:String):void{
			_elementType =  url;
		}
		public function get elementType():String{
			return _elementType;
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
		
		
		public function get begMile():Number{
			return _begMile;
		}
		public function get endMile():Number{
			return _endMile;
		}
		public function set begMile(mile:Number):void{
			_begMile=mile;
		}
		public function set endMile(mile:Number):void{
			_endMile=mile;
		}
	}
}
