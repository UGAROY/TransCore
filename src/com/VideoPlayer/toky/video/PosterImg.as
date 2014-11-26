package com.VideoPlayer.toky.video
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	
	public class PosterImg extends MovieClip
	{
		private var _hw:Point;
		
		public function PosterImg(str:String, w:int, h:int)
		{
			_hw = new Point(w, h);
			//trace(_hw.x + " " + _hw.y);
			var ldr:Loader = new Loader();
			var req:URLRequest = new URLRequest(str);
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, posterloaded);
			ldr.load(req);
		}
		
		private function posterloaded(e:Event):void {
			//addChild(e.target.data);
			var evt:Event = new Event("POSTER_LOADED");
			dispatchEvent(evt);
			
			var img:Bitmap = e.target.content;
			img.smoothing = true;
			
			//size for width
			img.height = _hw.y;
			img.scaleX = img.scaleY;
			
			//check for width hangover
			if (img.width > _hw.x) {
				img.width = _hw.x;
				img.scaleY = img.scaleX;
			}
			
			//center
			img.y = _hw.y/2 - img.height/2;
			img.x = _hw.x/2 - img.width/2;
			
			addChild(img);
			
			init();
		}
		
		private function init():void {
			this.addEventListener(MouseEvent.CLICK, clickposter);
		}
		
		private function clickposter(me:MouseEvent):void {
			//hide
			this.removeEventListener(MouseEvent.CLICK, clickposter);
			this.hide();
			var evt:Event = new Event("CLICK_POSTER", true);
			dispatchEvent(evt);
			//start playing movie
		}
		
		/**
		 * PUBLIC FUNCTIONS
		 **/
		
		public function reset():void {
			this.show();
			this.addEventListener(MouseEvent.CLICK, clickposter);
		}
		
		public function hide():void {
			this.alpha = 0;
			this.visible = false;
		}
		
		public function show():void {
			this.alpha = 1;
			this.visible = true;
		}
		

	}
}