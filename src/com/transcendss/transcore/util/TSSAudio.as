package com.transcendss.transcore.util
{
	import com.transcendss.transcore.events.CameraEvent;
	import com.transcendss.transcore.events.VoiceEvent;
	import com.transcendss.transcore.sld.models.components.GeoTag;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	
	import mx.core.FlexGlobals;
	
	import spark.components.Image;
	
	public class TSSAudio extends Image
	{
		private var _label:String;
		private var _image:Image;
		private var _bitmap:Bitmap;
		private var _soundBytes:ByteArray;
		private var volume:Number;
		private var pan:Number;
		private var soundMap:Object;
		private var _geoLocalId:String;
		private var _geoTag:GeoTag;
		private var _sourceURL:String;
		
		public function get soundBytes():ByteArray
		{
			return _soundBytes;
		}

		public function set soundBytes(value:ByteArray):void
		{
			_soundBytes = value;
		}
		
		public function get sourceURL():String
		{
			return _sourceURL;
		}
		
		public function set sourceURL(value:String):void
		{
			_sourceURL = value;
		}

		public function TSSAudio()
		{
			super();
			//this.addEventListener(MouseEvent.CLICK, playEcho);
			this.addEventListener(MouseEvent.MOUSE_DOWN, FlexGlobals.topLevelApplication.processClick);
			this.addEventListener(MouseEvent.MOUSE_UP,  FlexGlobals.topLevelApplication.processClick);
		}
		
		public function get bitmap():Bitmap
		{
			return _bitmap;
		}

		public function set bitmap(value:Bitmap):void
		{
			_bitmap = value;
		}

		public function get image():Image
		{
			return _image;
		}

		public function set image(value:Image):void
		{
			_image = value;
		}

		public function get label():String
		{
			return _label;
		}

		public function set label(value:String):void
		{
			_label = value;
		}

		private function playEcho(event:MouseEvent):void
		{	
			this.graphics.drawRect(this.x, this.y, this.width, this.height);
			this.volume = 1;
			this.pan = 1;
			this.soundMap = new Object();
			startPlayback();
		}
		
		private function startPlayback():void
		{
			var soundCopy:ByteArray = new ByteArray();
			soundCopy.writeBytes(_soundBytes);
			soundCopy.position = 0;
			var sound:Sound = new Sound();
			this.soundMap[sound] = soundCopy;
			sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSamplePlayback);
			sound.play();
			
			
			//snd.play();
		}
		
		private function onSamplePlayback(event:SampleDataEvent):void
		{
			var sound:Sound = event.target as Sound;
			var soundCopy:ByteArray = ByteArray(this.soundMap[sound]);
			var sample:Number;
			for (var i:int =0;i<2048;i++){
				if (soundCopy.bytesAvailable > 0){
					sample=soundCopy.readFloat();
					
					event.data.writeFloat(sample);
					event.data.writeFloat(sample);
					event.data.writeFloat(sample);
					event.data.writeFloat(sample);
					
					event.data.writeFloat(sample);
					event.data.writeFloat(sample);
					event.data.writeFloat(sample);
					event.data.writeFloat(sample);
				}
			}
			
			while (event.data.length < 65536)
				event.data.writeFloat(0);
		}
		
		public function clone():TSSAudio
		{
			var tmpImage:TSSAudio = new TSSAudio();
			tmpImage.source = this.source;
			tmpImage.soundBytes = this.soundBytes;
			
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
			playEcho(null);
		}
	}
}