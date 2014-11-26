package com.transcendss.transcore.events
{
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class SignEvent extends Event
	{
		private var _serviceURL:String = "";
		private var _dp:ArrayCollection = new ArrayCollection();
		public static const GETMILEPOSTDATA:String="signEvent_getMPData";
		public static const MILEPOSTREADY:String="signEvent_MPDataReady";
		
		public static const GETSIGNDATA:String="signEvent_getSignData";
		public static const SIGNFORMLOADED:String="signEvent_signFormLoaded";
		public static const UPDATE_SIGN_DATA:String="signEvent_updateSignData";
		//		public static const CULVERT_UPDATED_FROM_RA:String="CulvertupdatedFromRA";
		
		
		
		public var fromStorage:Boolean;
		public var nrouteObj:Object;
		public var nscale:Number;
		public var nview:Number;
		
		
		public function SignEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true,dp:ArrayCollection = null,route:Object=null)
		{
			super(type, bubbles, cancelable);
			_dp = dp;	
			nrouteObj = route;	
		}
		public function get serviceURL():String
		{
			return _serviceURL;
		}
		public function set serviceURL(gt:String):void
		{
			_serviceURL= gt;
		}
		public function get dataProviderAC():ArrayCollection
		{
			return _dp;
		}
		public function set dataProviderAC(gt:ArrayCollection):void
		{
			_dp= gt;
		}
		
	}
}