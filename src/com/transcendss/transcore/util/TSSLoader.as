package com.transcendss.transcore.util
{
	import flash.display.Loader;
	
	public class TSSLoader extends Loader
	{
		
		private var _picture:TSSPicture;
		private var _video:TSSVideo;
		private var _audio:TSSAudio;
		private var _memo:TSSMemo;
		
		public function TSSLoader()
		{
			super();
		}
		
		public function get memo():TSSMemo
		{
			return _memo;
		}
		
		public function set memo(value:TSSMemo):void
		{
			_memo = value;
		}
		
		public function get audio():TSSAudio
		{
			return _audio;
		}
		
		public function set audio(value:TSSAudio):void
		{
			_audio = value;
		}
		
		public function get video():TSSVideo
		{
			return _video;
		}
		
		public function set video(value:TSSVideo):void
		{
			_video = value;
		}
		
		public function get picture():TSSPicture
		{
			return _picture;
		}
		
		public function set picture(value:TSSPicture):void
		{
			_picture = value;
		}
		
	}
}