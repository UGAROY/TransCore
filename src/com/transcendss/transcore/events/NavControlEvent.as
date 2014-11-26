package com.transcendss.transcore.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class NavControlEvent extends Event
	{
		public static const CLICKED:String = "navControlEvent_Clicked";
		public static const START_RUN:String = "navControlEvent_startRun";
		public static const STOP_RUN:String ="navControlEvent_stopRun";
		public static const NEXT:String ="navControlEvent_Next";
		public static const PREVIOUS:String = "navControlEvent_Previous";
		public static const BEGINNING:String = "navControlEvent_Beginning";
		public static const END:String = "navControlEvent_End";
		public static const UTURN:String = "navControlEvent_Uturn";
		public static const CHANGE_SPEED:String = "navControlEvent_changeSpeed";
		public static const CHANGE_STEP:String = "navControlEvent_changeStep";
		public static const XY_CHANGE:String = "navControlEvent_xyChange";

		private var _x:Number;
		private var _y:Number;
		private var _mp:Number;
		private var _sliderValue:Number;
				
		public function NavControlEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}
		
		
		public function get mp():Number
		{
			return _mp;
		}

		public function set mp(value:Number):void
		{
			_mp = value;
		}

		public function get sliderValue():Number
		{
			return _sliderValue;
		}

		public function set sliderValue(value:Number):void
		{
			_sliderValue = value;
		}

		public function get y():Number
		{
			return _y;
		}

		public function set y(value:Number):void
		{
			_y = value;
		}

		public function get x():Number
		{
			return _x;
		}

		public function set x(value:Number):void
		{
			_x = value;
		}

	}
}