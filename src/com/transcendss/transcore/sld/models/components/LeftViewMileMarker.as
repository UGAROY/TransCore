package com.transcendss.transcore.sld.models.components
{
	import com.transcendss.transcore.sld.models.components.graphics.CallOut;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class LeftViewMileMarker extends Sprite
	{
		private var diagramWidth:Number;
		private var diagramHeight:Number;
		
			public function LeftViewMileMarker()
			{
				name = "markers";
				super();
			}
			
			public function addCallOut(dWidth:Number,dHeight:Number,txtString:String,mkrPtX:Number,cLine:uint,cText:uint, lineWidth:Number, cName:String):void{
				diagramWidth = dWidth;
				diagramHeight = dHeight;
				var mkrPtY:Number = diagramHeight/2 - 6;
				var txtX:Number = mkrPtX;
				var txtY:Number = diagramHeight-67;
				var callOut:CallOut = new CallOut();
				callOut.draw(mkrPtX,mkrPtY,txtX,txtY,txtString,diagramWidth,lineWidth,cLine,cText);
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
			
			public function updateMarkerX(xVal:Number, cName:String):void{
				CallOut(this.getChildByName(cName)).x = xVal;
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