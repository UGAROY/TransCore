package com.transcendss.transcore.util
{
	import com.transcendss.transcore.events.CameraEvent;
	import com.transcendss.transcore.sld.models.components.GeoTag;
	import com.transcendss.transcore.vlog.TSSImage;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	import mx.rpc.Responder;
	
	import spark.components.Image;

	
	public class TSSPicture extends Image
	{
		private var _label:String;
		private var _image:Image;
		private var _bitmap:Bitmap;
		private var _geoLocalId:String;
		private var _geoTag:GeoTag;
		private var _sourceURL:String;
		
		public function TSSPicture()
		{
			super();
			this.doubleClickEnabled=true;
			this.mouseChildren = false;
			//this.addEventListener(MouseEvent.CLICK, processClick);
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
		
		public function get sourceURL():String
		{
			return _sourceURL;
		}
		
		public function set sourceURL(value:String):void
		{
			_sourceURL = value;
		}
		
		private function openFullImage(e:Event):void
		{
				this.graphics.drawRect(this.x, this.y, this.width, this.height);
				var tmpEvent:CameraEvent = new CameraEvent(CameraEvent.OPENIMAGE, true, true);
				tmpEvent.tsspicture = this;
				dispatchEvent(tmpEvent);
			
		}
		
		public function clone():TSSImage
		{
			var t:TSSImage = new TSSImage();
			
			t.source = this.source;
			t.width = 40;
			t.height = 40;
			return t;
		}

		public function get geoLocalId():String
		{
			return _geoLocalId;
		}

		public function set geoLocalId(value:String):void
		{
			_geoLocalId = value;
		}
		
		public function open():void
		{
			openFullImage(new MouseEvent(MouseEvent.CLICK));
		}
		
		public function get geoTag():GeoTag
		{
			return _geoTag;
		}
		
		public function set geoTag(value:GeoTag):void
		{
			_geoTag = value;
		}

	}
}