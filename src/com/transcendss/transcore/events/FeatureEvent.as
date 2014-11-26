package com.transcendss.transcore.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	
	public class FeatureEvent extends Event
	{
		public static const FEATURE_REQUEST:String = "featureEvent_featureRequest";
		public static const ASSET_REQUEST:String = "featureEvent_featureRequest2";
		public static const GETMILEPOSTDATA:String="signEvent_getMPData";
		public static const CNTY_LIST_READY:String = "featureEvent_cnytListReady";
		private var _featureType:String;
		private var _routeName:String;
		private var _begMile:Number;
		private var _endMile:Number;
		private var _responder:IResponder;
		private var _routeFullName:String;
		private var _serviceURL:String ;
		private var _eventLayerID:Number ;
		public var featureAC:ArrayCollection= new ArrayCollection();
		public var diagramObj:Object;
		
		public function FeatureEvent(eventType:String,featureName:String, ftArrayC:ArrayCollection=null, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(eventType, bubbles, cancelable);
			featureAC = ftArrayC;
			_featureType = featureName;
		}
		
		public function get eventLayerID():Number{
			return _eventLayerID;
		}
		
		public function set eventLayerID(val:Number):void{
			 _eventLayerID=val;
		}
		public function get featureName():String{
			return _featureType;
		}
		public function get routeName():String{
			return _routeName;
		}
		public function get begMile():Number{
			return _begMile;
		}
		public function get endMile():Number{
			return _endMile;
		}
		public function get routeFullName():String{
			return _routeFullName;
		}
		public function set routeFullName(r:String):void{
			_routeFullName=r;
		}
		public function set featureName(typ:String):void{
			 _featureType=type;
		}
		public function set routeName(name:String):void{
			_routeName=name;
		}
		public function set begMile(mile:Number):void{
			_begMile=mile;
		}
		public function set endMile(mile:Number):void{
			 _endMile=mile;
		}
		
		public function set serviceURL(url:String):void{
			_serviceURL =  url;
		}
		public function get serviceURL():String{
			return _serviceURL;
		}

		public function get responder():IResponder
		{
			return _responder;
		}

		public function set responder(value:IResponder):void
		{
			_responder = value;
		}

	}
}