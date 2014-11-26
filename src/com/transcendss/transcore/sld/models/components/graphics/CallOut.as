package com.transcendss.transcore.sld.models.components.graphics
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.*;

	public class CallOut extends Sprite
	{
		public var callText:Sprite = new Sprite();
		public var callLine:Shape = new Shape();
	
		public function CallOut()
		{
			super();
			name = "callout";
		}
		public function draw(pinX:Number, pinY:Number, textX:Number, textY:Number, textString:String, maxPx:Number, lineWeight:int=1, lineColor:uint=0x000000, textColor:uint=0x000000, textSize:int=12, textFont:String = "Arial", leftCallout:Boolean=true):void
		{
			name = textString;
			
			var textfield:TextField = new TextField();
			textfield.name = "textField";
			if (lineWeight!=0)
			{
				callLine.graphics.lineStyle(lineWeight,lineColor,1);
				callLine.graphics.drawPath(Vector.<int>([1,2]), Vector.<Number>([pinX,pinY, textX,textY]));
				callLine.name = "callLine";
				addChild(callLine);
			}

			textfield.text = textString;
			textfield.autoSize = TextFieldAutoSize.CENTER;
			textfield.backgroundColor = 0xffffcc;
			textfield.background = true;
//			textfield.filters = [new GlowFilter(0xdfdfdf,0.6)];
			
			var txtFormat:TextFormat = new TextFormat(); 
			txtFormat.color = textColor; 
			txtFormat.font = textFont; 
			txtFormat.size = textSize;
			//txtFormat.letterSpacing = 2;
			textfield.setTextFormat(txtFormat); 
			callText.addChild( textfield );          
			var xPt:Number;
			// Now adjust the text's position to the box's center    
			if(leftCallout)
				xPt= textX ;
			else
				xPt= textX-textfield.textWidth
			var yPt:Number = textY;
			
//			if(xPt < -10){
//				xPt = -10;
//			}
			if(xPt + textfield.textWidth > maxPx + 10){
				xPt = (maxPx + 10) - textfield.textWidth;
			}
			textfield.x = xPt;          
			textfield.y = yPt; 

			addChild(callText);
		}
		
		public function moveLine(x:Number):void
		{
			var dispObj:DisplayObject = this.getChildByName("callLine");
			dispObj.x = x;
		}
		
		
		
		public function updateText(newText:String):void
		{
			var dispObj:TextField = callText.getChildByName("textField") as TextField;	
			dispObj.text = newText;
		}
	}
}