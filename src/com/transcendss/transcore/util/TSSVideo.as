package com.transcendss.transcore.util
{
	
	import com.transcendss.transcore.sld.models.components.GeoTag;
	import com.transcendss.transcore.events.videoEvent;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SampleDataEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.ByteArray;
	
	import mx.core.FlexGlobals;
	
	import spark.components.Image;
	
	
	public class TSSVideo extends Image
	{
		private var _filePath:String;
		private var image:Image;
		private var bitmap:Bitmap;
		private var _video:Video;
		private var _geoLocalId:String;
		private var _geoTag:GeoTag;
		private var _label:String;
		
		public function TSSVideo()
		{
			super();
			this.doubleClickEnabled=true;
			//this.addEventListener(MouseEvent.CLICK,playVideo);
			this.addEventListener(MouseEvent.MOUSE_DOWN, FlexGlobals.topLevelApplication.processClick);
			this.addEventListener(MouseEvent.MOUSE_UP,  FlexGlobals.topLevelApplication.processClick);
		}
		
		
		public function get filePath():String
		{
			return _filePath;
		}

		public function set filePath(value:String):void
		{
			_filePath = value;
		}

		public function get video():Video
		{
			return _video;
		}

		public function set video(value:Video):void
		{
			_video = value;
		}

		private function playVideo(event:MouseEvent):void{
			var tmpEvent:videoEvent = new videoEvent(videoEvent.OPENVIDEO, true, true);
			tmpEvent.tssvideo=this;
			dispatchEvent(tmpEvent);
			
		}
		
		
		public function clone():TSSVideo
		{
			var tmpImage:TSSVideo = new TSSVideo();
			tmpImage.source = this.source;
			tmpImage.video = this.video;
			tmpImage.filePath = this.filePath;
			tmpImage.width = 40;
			tmpImage.height = 40;
			return tmpImage;
		}

		public function get geoLocalId():String
		{
			return _geoLocalId;
		}

		public function set geoLocalId(value:String):void
		{
			_geoLocalId = value;
		}

		public function get geoTag():GeoTag
		{
			return _geoTag;
		}

		public function set geoTag(value:GeoTag):void
		{
			_geoTag = value;
		}
		
		public function open():void
		{
			playVideo(null);
		}
		public function get label():String
		{
			return _label;
		}
		
		public function set label(value:String):void
		{
			_label = value;
		}
		
	}
}