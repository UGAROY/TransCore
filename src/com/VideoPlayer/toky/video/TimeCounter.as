package com.VideoPlayer.toky.video
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	
	public class TimeCounter extends Sprite
	{
		public var _txt:TextField;
		
		public function TimeCounter()
		{
			//trace("time elapsed");
		}
		
		protected function formatTimecode(num:Number):String  {
			// thanks lee
			var t:Number = Math.round(num);
			var min:Number = Math.floor(t/60);
			var sec:Number = t%60;
			var tc:String = new String("");
				
			if(min < 10) {
				tc += "0";
			}
				
			if(min >= 1) {
				tc += min.toString();
			} else {
				tc += "0";
			}
				
			tc += ":";
				
			if(sec < 10) {
				tc += "0";
				tc += sec.toString();
			} else {
				tc += sec.toString();
			} return tc;	
		}
		
		protected function registerUI(txt:TextField):void {
			_txt = txt;
		}
		
		/**
		 * 
		 * PUBLIC FUNCITONS
		 * 
		 **/
		
		public function setTimeCounter(curtime:Point):void {
			_txt.text = formatTimecode(curtime.x) + " / " + formatTimecode(curtime.y);
		}

	}
}