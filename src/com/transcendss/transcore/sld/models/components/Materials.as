package com.transcendss.transcore.sld.models.components
{
	import com.transcendss.transcore.util.*;
	import com.transcendss.transcore.util.Tooltip;
	
	import flash.display.GraphicsPath;
	import flash.display.IGraphicsData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.UIComponent;
	
	[Bindable]
	public class Materials extends Tippable
	{
		private var descName:String;
		private var descId:Number;
		
		public function Materials(descName:String)
		{
			super(Tippable.SLD);
			clearContainer();
			name = "description";
			description = descName;
		}
		
		public function clearContainer():void
		{
			while(this.numChildren > 0)
			{
				this.removeChildAt(0);
			}
		}
		
		public function get description():String
		{
			return descName;
		}
		
		public function set description(name:String):void
		{
			descName = name;
		}
		
		
	}
}