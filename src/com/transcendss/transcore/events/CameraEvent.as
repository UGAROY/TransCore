package com.transcendss.transcore.events
{
	import com.transcendss.transcore.util.TSSPicture;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	
	public class CameraEvent extends Event
	{
		public static const NEWPICTURE:String = "cameraEvent_NewPicture";
		public static const OPENCONTROL:String = "cameraEvent_OpenControl";
		public static const OPENIMAGE:String = "cameraEvent_OpenImage";
		
		//private var _source:String ="";
		private var _bitmap:Bitmap;
		private var _memo:String;
		private var _tsspicture:TSSPicture;
				
		public function CameraEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
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

		public function get bitmap():Bitmap
		{
			return _bitmap;
		}

		public function set bitmap(value:Bitmap):void
		{
			_bitmap = value;
		}

	}
}