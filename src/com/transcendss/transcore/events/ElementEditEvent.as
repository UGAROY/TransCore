package com.transcendss.transcore.events
{
	import flash.events.Event;
	
	public class ElementEditEvent extends Event
	{
		public static const EDIT_ELEMENT:String = "edit_element";
		public static const COMPLETE_ELEMENT_MERGE:String = "complete_element_merge";
		public static const CHANGE_ELEMENT_ATTRIBUTE:String = "change_element_attribute";
		private var _elem:Object;
		public var serviceURL:String;
		private var _milepoint:Number;
		private var _clickX:Number;
		private var _clickY:Number;
		
		public function get clickY():Number
		{
			return _clickY;
		}

		public function set clickY(value:Number):void
		{
			_clickY = value;
		}

		public function get clickX():Number
		{
			return _clickX;
		}

		public function set clickX(value:Number):void
		{
			_clickX = value;
		}

		public function get elem():Object
		{
			return _elem;
		}

		public function set elem(value:Object):void
		{
			_elem = value;
		}

		public function get milepoint():Number
		{
			return _milepoint;
		}

		public function set milepoint(value:Number):void
		{
			_milepoint = value;
		}

		public function ElementEditEvent(type:String, milepoint:Number, x:Number=0, y:Number=0, elem:Object=null, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
			_elem = elem;
			_milepoint = milepoint;
			_clickX = x;
			_clickY = y;
		}
		
	}
}