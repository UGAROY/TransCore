package com.VideoPlayer.toky.video
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class PlayPause extends Sprite
	{
		public var _play:MovieClip;
		public var _pause:MovieClip;
		public var _isplaying:Boolean;	
		
		public function PlayPause(autoplay:Boolean = false)
		{
			_isplaying = autoplay;
			this.addEventListener(MouseEvent.CLICK, mouseclick);
			//init();
		}
		
		protected function init():void {
			//find out if we need to start w/ play or pause.		
			if (_isplaying) {
				showpause();
				
			} else if (!_isplaying) {
				showplay();
			}
		}
		
		protected function mouseclick(me:MouseEvent):void {
			//clickplaypause
			var evt:Event = new Event("CLICK_PLAYPAUSE", true);
			this.dispatchEvent(evt);
		}
		
		protected function registerUI(playmc:MovieClip, pausemc:MovieClip):void {
			//need to assign, play & pause clips
			_play = playmc;
			_pause = pausemc;
		}
		
		/**
		 * PUBLIC FUNCTIONS
		 * 
		 **/
		
		public function showplay():void {
			//overwrite this
			_play.alpha = 1;
			_play.visible = true;
			_pause.alpha = 0;	
			_pause.visible = false;
		}
		
		public function showpause():void {
			//overwrite this
			_play.alpha = 0;
			_play.visible = false;
			_pause.alpha = 1;
			_pause.visible = true;
		}
		
		public function show():void {
			this.alpha = 1;
			this.visible = false;	
		}
		
		public function hide():void {
			this.alpha = 0;
			this.visible = true;
		}

		public function reset():void {
			
		}
		
		public function destroy():void {
			
		}
		

	}
}