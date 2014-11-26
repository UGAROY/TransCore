package com.transcendss.transcore.util
{
	import flash.display.Sprite;
	import flash.filters.BitmapFilter;
	import flash.filters.DropShadowFilter;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import mx.controls.Text;
	import mx.core.LayoutContainer;
	
	
	public class Tooltip extends Sprite
	{
		
		private var tooltip:Sprite = new Sprite();
		private var bmpFilter:BitmapFilter;
		
		private var textfield:TextField = new TextField();
		private var textformat:TextFormat = new TextFormat();
		
		
		
		public function Tooltip(w:int, h:int, cornerRadius:int, txt:String, color:uint, tipBorderColor:uint, txtColor:uint, alfa:Number, useArrow:Boolean, dir:String, dist:int):void
		{
			name = "tooltip";
			textfield = TextFieldUtils.textField(this, txt, "Arial", false, 13, txtColor, w);
			
			tooltip = new Sprite();
			tooltip.graphics.lineStyle(1,tipBorderColor);
			tooltip.graphics.beginFill(color, alfa);
			tooltip.graphics.drawRoundRect(0, 0, w, h+4, cornerRadius, cornerRadius);
			
			var x1:int = (tooltip.width / 2) - 6;
			var y1:int = (tooltip.height) + 2;
			
			var x2:int = (tooltip.width / 2);
			var y2:int = (tooltip.height) + 14;		
			
			var x3:int = (tooltip.width / 2) + 6;
			var y3:int = (tooltip.height) + 2;	
			
			if (useArrow && dir == "up")
			{
				tooltip.graphics.moveTo(x1, y1);
				tooltip.graphics.lineTo(x2, y2);
				tooltip.graphics.lineTo(x3, y3);
			}
			
			if (useArrow && dir == "down")
			{
				tooltip.graphics.moveTo(x1, y1);
				tooltip.graphics.lineTo(x2, -14);
				tooltip.graphics.lineTo(x3, y3);
			}
			
			tooltip.graphics.endFill();
			
			
			/* Filter */
			bmpFilter = new DropShadowFilter(1,90,color,1,2,2,1,15);
			tooltip.filters = [bmpFilter];
			
			/* Add to Stage */
			tooltip.addChild(textfield);
			addChild(tooltip);
		}
	}
}