package com.transcendss.transcore.events
{

	import com.transcendss.transcore.util.TSSVideo;
	
	import flash.events.Event;
	//import flash.filesystem.FileStream;
	import flash.media.Video;
	
	public class videoEvent extends Event
	{
		public static const NEWVIDEO:String="videoEvent_NewVideo";
		public static const OPENCONTROL:String ="videoEvent_OpenControl";
		public static const OPENVIDEO:String="videoEvent_OpenVideo";
		
		public function videoEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}
		
		private var _video:Video;
		private var _memo:String;
		private var _tssvideo:TSSVideo;
		private var _path:String;
		private var _media:*;
		//private var _source:String ="";
		
//		public function get eventSource():String
//		{
//			return _source;
//		}
//		
//		public function set eventSource(value:String):void
//		{
//			_source = value;
//		}
		
		public function get path():String
		{
			return _path;
		}

		public function set path(value:String):void
		{
			_path = value;
		}

		public function get tssvideo():TSSVideo
		{
			return _tssvideo;
		}

		public function set tssvideo(value:TSSVideo):void
		{
			_tssvideo = value;
		}

		public function get memo():String
		{
			return _memo;
		}

		public function set memo(value:String):void
		{
			_memo = value;
		}

		public function get video():Video
		{
			return _video;
		}

		public function set video(value:Video):void
		{
			_video = value;
		}

		public function get media():*
		{
			return _media;
		}

		public function set media(value:*):void
		{
			_media = value;
		}


	}
}