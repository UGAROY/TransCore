package com.transcendss.transcore.sld.models.components
{
	import com.transcendss.transcore.sld.models.components.graphics.CallOut;
	import com.transcendss.transcore.util.Converter;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class ViewMileValueMarkers extends Sprite
	{
		private var diagramWidth:Number;
		private var diagramHeight:Number;
		private var lineColor:uint;
		private var textColor:uint;
		private var callOutName:String;
		private var lineWidth:Number;
		
		public function ViewMileValueMarkers()
		{
			name = "markers";
			super();
		}
		
		public function addCallOut(dWidth:Number,dHeight:Number,txtString:String,mkrPtX:Number,cLine:uint,cText:uint, lWidth:Number, cName:String):void{
			diagramWidth = dWidth;
			diagramHeight = dHeight;
			lineColor = cLine;
			textColor = cText;
			lineWidth = lWidth;
			callOutName = cName;
			var mkrPtY:Number = diagramHeight/2 - 6;
			var txtX:Number = mkrPtX;
			var txtY:Number = diagramHeight-67;
			var callOut:CallOut = new CallOut();
			callOut.draw(mkrPtX,mkrPtY,txtX,txtY,txtString,diagramWidth,lineWidth,lineColor,textColor);
			callOut.name = cName;
			addChild(callOut);
		}
		
		public function clear():void{
			// clear all children of container
			while (this.numChildren > 0)
			{
				this.removeChildAt(0);
			}
		}
		
		public function updateMarkerX(x:Number, cName:String):void{
			this.getChildByName(cName).x = x;
		}
		
		
		public function updateCallOutVal(txtString:String, cName:String):void{
			var dispObj:CallOut = this.getChildByName(cName) as CallOut;
			dispObj.updateText(txtString);
			dispObj.visible = true;
		}
		
		public function hideCallOutVal( cName:String):void{
			var dispObj:DisplayObject = this.getChildByName(cName);
			dispObj.visible = false;
		}
	}
}