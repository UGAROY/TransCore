package com.transcendss.transcore.sld.models.components
{
	import com.transcendss.transcore.sld.models.components.graphics.CallOut;
	
	import flash.display.Sprite;
	
	public class RouteMarkers extends Sprite
	{
		private var diagramWidth:Number;
		private var diagramHeight:Number;
		
		
		public function RouteMarkers()
		{
			name = "markers";
			super();
		}
		
		public function addCallOut(dWidth:Number,dHeight:Number,txtString:String,mkrPtX:Number,cLine:uint,cText:uint, offsetValue:Number = 508):void{
			diagramWidth = dWidth;
			diagramHeight = dHeight;
			var mkrPtY:Number = diagramHeight/2 - 6; //offset
			var txtX:Number = mkrPtX;
			var txtY:Number = diagramHeight-85;
			var callOut:CallOut = new CallOut();
			callOut.draw(mkrPtX + offsetValue,mkrPtY,txtX + offsetValue,txtY,txtString,diagramWidth + offsetValue,2,cLine,cText);//offsetValue
			addChild(callOut);
		}
		
		public function clear():void{
			// clear all children of container
			while (this.numChildren > 0)
			{
				this.removeChildAt(0);
			}
		}
	}
}