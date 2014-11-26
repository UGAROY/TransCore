package com.transcendss.transcore.events
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	
	public class VoiceEvent extends Event
	{
		public static const NEWMEMO:String = "voiceEvent_NewMemo";
		public static const OPENCONTROL:String = "voiceEvent_OpenControl";
		
		private var _source:String ="";
		
		private var _byteArray:ByteArray;
		private var _begmilepoint:Number;
		private var _endmilepoint:Number;
		
		public function VoiceEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}
		
		public function get evenSource():String
		{
			return _source;
		}
		
		public function set evenSource(value:String):void
		{
			_source = value;
		}
		
		
		public function get byteArray():ByteArray
		{
			return _byteArray;
		}
		
		public function set byteArray(value:ByteArray):void
		{
			_byteArray = value;
		}
		
		public function get endmilepoint():Number
		{
			return _endmilepoint;
		}
		
		public function set endmilepoint(value:Number):void
		{
			_endmilepoint = value;
		}
		
		public function get begmilepoint():Number
		{
			return _begmilepoint;
		}
		
		public function set begmilepoint(value:Number):void
		{
			_begmilepoint = value;
		}
		
		
		
	}
}