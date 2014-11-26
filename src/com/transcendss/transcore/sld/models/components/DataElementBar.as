package com.transcendss.transcore.sld.models.components
{
	import com.transcendss.transcore.util.Tippable;
	
	import flash.display.Sprite;
	
	public class DataElementBar extends Sprite
	{
		private var _segments:Vector.<Tippable>;
		public function DataElementBar()
		{
			super();
			_segments = new Vector.<Tippable>();	
			draw();
		}
		
		private function draw():void
		{
			
		}
	}
}