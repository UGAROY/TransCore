package com.transcendss.transcore.events
{
	import com.transcendss.transcore.util.TSSPicture;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class TextMemoEvent extends Event
	{
		public static const NEWMEMO:String = "textMemoEvent_NewMemo";
		public static const OPENCONTROL:String = "textMemoEvent_OpenControl";
		public static const OPENMEMO:String = "textMemoEvent_OpenMemo";
		
		private var _memo:String;
		private var _tsspicture:TSSPicture;
		//private var _source:String ="";
		
		public function TextMemoEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}

//		public function get eventSource():String
//		{
//			return _source;
//		}
//		
//		public function set eventSource(value:String):void
//		{
//			_source = value;
//		}
		
		public function get tsspicture():TSSPicture
		{
			return _tsspicture;
		}

		public function set tsspicture(value:TSSPicture):void
		{
			_tsspicture = value;
		}

		public function get memo():String
		{
			return _memo;
		}

		public function set memo(value:String):void
		{
			_memo = value;
		}

	}
}