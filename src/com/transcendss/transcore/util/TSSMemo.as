package com.transcendss.transcore.util
{
	import com.transcendss.transcore.sld.models.components.GeoTag;
	import com.transcendss.transcore.events.CameraEvent;
	import com.transcendss.transcore.events.TextMemoEvent;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import spark.components.Image;
	
	public class TSSMemo extends Image
	{
		private var _label:String;
		private var _image:Image;
		private var _bitmap:Bitmap;
		private var _memo:String;
		private var _geoLocalId:String;
		private var _geoTag:GeoTag;
		
		
		public function TSSMemo()
		{
			super();
			this.doubleClickEnabled=true;
			//this.addEventListener(MouseEvent.CLICK, openText);
			this.addEventListener(MouseEvent.MOUSE_DOWN, FlexGlobals.topLevelApplication.processClick);
			this.addEventListener(MouseEvent.MOUSE_UP,  FlexGlobals.topLevelApplication.processClick);
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

		private function openText(e:Event):void
		{
			//Alert.show(_label, "Note Contents");
			var tmpEvent:TextMemoEvent = new TextMemoEvent(TextMemoEvent.OPENMEMO, true, true);
			//tmpEvent.tsspicture = this;
			tmpEvent.memo=this.memo;
			dispatchEvent(tmpEvent);
		
			
		}
		
		public function clone():TSSMemo
		{
			var t:TSSMemo = new TSSMemo();
			
			t.source = this.source;
			t.memo=this.memo;
			t.label = this.memo;
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
			openText(null);
		}

	}
	
	
}

