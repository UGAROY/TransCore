package com.VideoPlayer.toky.video
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class Volume extends Sprite
	{
		public var _clickable:MovieClip;
		protected var _volpct:Number;
		
		public function Volume()
		{
			//trace("volume");
			_clickable.addEventListener(MouseEvent.CLICK, clickbg);
		}
		
		internal function clickbg(me:MouseEvent):void {
			trace("click");
			_volpct = this.mouseX / _clickable.width;
			
			var evt:Event = new Event("VOLUME_CHANGE", true);
			dispatchEvent(evt);
		}
		
		internal function getVolumePct():Number {
			return _volpct;
		}
		
		public function show():void {
			this.alpha = 1;
			this.visible = true;			
			
		}
		
		public function hide():void {
			this.alpha = 0;
			this.visible = false;
		}
	}
}