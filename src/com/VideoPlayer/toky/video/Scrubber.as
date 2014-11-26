package com.VideoPlayer.toky.video
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class Scrubber extends MovieClip
	{
		public var _bufferbar:MovieClip;
		public var _hasplayedbar:MovieClip;
		public var _totalbar:MovieClip;
		private var _isdragging:Boolean;
		private var _draggedposition:Number;
		private var _activeflag:Boolean;
		
		public function Scrubber()
		{
			_isdragging = false;
			_activeflag = false;
		}
		
		protected function init():void {
			_hasplayedbar.mouseChildren = false;
			_hasplayedbar.mouseEnabled = false;
		}
		
		
		private function bufferclick(me:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, buffermouseup);
			_isdragging = true;
			var evt:Event = new Event("DRAG_ON");
			this.dispatchEvent(evt);
		}
		
		private function buffermouseup(me:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, buffermouseup);
			var evt:Event = new Event("DRAG_OFF");
			this.dispatchEvent(evt);
			_isdragging = false;
		}

		
		internal function activate():void {
			if (_activeflag == false) {
				_bufferbar.addEventListener(MouseEvent.MOUSE_DOWN, bufferclick);
				_activeflag = true;	
			}
		}
		
		protected function registerUI(bufferbarmc:MovieClip, hasplayedbarmc:MovieClip, totalbarmc:MovieClip):void {
			//need to assign, play & pause clips
			_bufferbar = bufferbarmc;
			_hasplayedbar = hasplayedbarmc;
			_totalbar = totalbarmc;
		}
		
		internal function setprogress(pct:Number):void {
			if (!_isdragging) {
				//follow playhead
				_hasplayedbar.width = pct * _totalbar.width;
			} else if (_isdragging && mouseX < _totalbar.width) {
				//follow mouse
				_hasplayedbar.width = mouseX - _hasplayedbar.x;
			}
		}
		
		internal function setbuffered(pct:Number):void {
			//set percentage loaded
			_bufferbar.width = pct * _totalbar.width;
		}
		
		internal function getdraggedpct():Number {
			var pct:Number = _hasplayedbar.width / _totalbar.width;
			return pct;	
		}
		
		/**
		 * PUBLIC FUNCITONS
		 * */
		
		public function show():void {
			this.alpha = 1;
			this.visible = true;			
		}
		
		public function hide():void {
			this.alpha = 0;
			this.visible = false;
		}
		
		public function reset():void {
			_bufferbar.removeEventListener(MouseEvent.MOUSE_DOWN, bufferclick);
			_hasplayedbar.width = 0;
			_bufferbar.addEventListener(MouseEvent.MOUSE_DOWN, bufferclick);
		}

		public function destroy():void {
			
		}
		
	}
}