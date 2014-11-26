package com.transcendss.transcore.sld.models.components
{
	import com.transcendss.transcore.util.*;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.*;
	import flash.text.engine.*;
	
	import mx.core.UIComponent;
	
	public class Ruler extends Sprite 
	{
		private var markerPxLength:int = 10;
		private var txtSize:int = 12;
		private var txtFont:String = "Arial";
		public static const FIFTYMILE:Number = 50;
		public static const TWTYFIVEMILE:Number = 25;
		public static const TENMILE:Number = 10;
		public static const MILE:Number = 1;
		public static const HALFMILE:Number = 0.5;
		public static const QTRMILE:Number = 0.25;
		
		public function Ruler(mkLen:int=10)
		{
			clearContainer();
			name = "ruler";
			markerPxLength = mkLen;
		}
	
		public function draw(rteBm:Number, rteEm:Number, diagramScale:Number, units:int=1):void{
			clearContainer();  // must clear to draw/redraw
			var ruler:Sprite = new Sprite();
			var rIntrvl:Number = 1;
			var rIntOffset:Number = 0;
			var rDist:Number = Math.abs(rteEm - rteBm);
			
			addChild(drawBaseLine(rteBm, rteEm, diagramScale,units)); // draw white background rect
			
			//ToDo: use units (add support kilometers and county miles)

			if (rDist <= 100){
				if (diagramScale <= 10000){
					ruler = drawRulesByValue(rteBm, rteEm, diagramScale, Ruler.QTRMILE, units);
				}
				else if (diagramScale > 10000 && diagramScale <= 100000){
					ruler = drawRulesByValue(rteBm, rteEm, diagramScale, Ruler.HALFMILE, units);
				}
				else if (diagramScale > 100000 && diagramScale <= 195000){
					ruler = drawRulesByValue(rteBm, rteEm, diagramScale, Ruler.MILE, units);
				}	
				else if (diagramScale > 195000 && diagramScale <= 500000){
					ruler = drawRulesByValue(rteBm, rteEm, diagramScale, Ruler.TENMILE, units);
				}
				else if (diagramScale > 500000 && diagramScale <= 750000){
					ruler = drawRulesByValue(rteBm, rteEm, diagramScale, Ruler.TWTYFIVEMILE, units);
				}				
				else{
					ruler = drawRulesByValue(rteBm, rteEm, diagramScale, Ruler.FIFTYMILE, units);
				} 	
			}
			else{
				if (diagramScale <= 10000){
					ruler = drawRulesByValue(rteBm, rteEm, diagramScale, Ruler.QTRMILE, units);
				}
				else if (diagramScale > 10000 && diagramScale <= 75000){
					ruler = drawRulesByValue(rteBm, rteEm, diagramScale, Ruler.HALFMILE, units);
				} 
				else if (diagramScale > 75000 && diagramScale <= 150000){
					ruler = drawRulesByValue(rteBm, rteEm, diagramScale, Ruler.MILE, units);
				} 
				else if (diagramScale > 150000 && diagramScale <= 250000){
					ruler = drawRulesByValue(rteBm, rteEm, diagramScale, Ruler.TENMILE, units);
				}					
				else if (diagramScale > 250000 && diagramScale <= 500000){
					ruler = drawRulesByValue(rteBm, rteEm, diagramScale, Ruler.TWTYFIVEMILE, units);
				}				
				else {
					ruler = drawRulesByValue(rteBm, rteEm, diagramScale, Ruler.FIFTYMILE, units);
				} 	
			}
			addChild(ruler);
		}
		
		private function drawBaseLine(rteBm:Number, rteEm:Number, diagramScale:Number, units:int=1):Shape{
			var diagramWidth:Number = Converter.scaleMileToPixel(Math.ceil(Math.abs(rteEm-rteBm))+1,diagramScale);
			var baseRect:Shape = new Shape();
			// draw with paths in order to override lineto and rect expansion issues at very diagram dimensions
			baseRect.graphics.beginFill(0xdfdfdf);
			baseRect.graphics.drawPath(
				Vector.<int>([1,2,2,2]),
				Vector.<Number>([-20,27, diagramWidth+40,27, diagramWidth+40,0, -20,0]));
			//baseRect.graphics.endFill();
			baseRect.graphics.beginFill(0x888888); // draw border as 1 px wide path rectangle
			baseRect.graphics.drawPath(
				Vector.<int>([1,2,2,2]),
				Vector.<Number>([-20,28, diagramWidth+40,28, diagramWidth+40,27, -20,27]));
			return baseRect;
		}

		
		private function drawRulesByValue(rteBm:Number,rteEm:Number, diagramScale:Number, intLvl:Number, units:int=1):Sprite
		{
			var RuleSprite:Sprite = new Sprite();
			var ruleLine:Shape = new Shape();
			var lvlArray:Array = [];
			var numLevels:int = 1;
			var lineWidth:int = 2;
			var lineOpacity:Number = 1;
			var colorArray:Array = new Array(0x000000, 0x888888, 0xbbbbbb);
			var markerLength:int = markerPxLength;
			var interval:Number = 1;

			switch (intLvl){
				case Ruler.QTRMILE:
					numLevels  = 3;
					interval = Ruler.QTRMILE;
					break;
				case Ruler.HALFMILE:
					numLevels  = 2;
					interval = Ruler.HALFMILE;
					break;
				case Ruler.MILE:
					numLevels = 1;
					break;
				case Ruler.TENMILE:
					numLevels  = 1;
					interval = Ruler.TENMILE
					lineWidth = 1;
					break;
				case Ruler.TWTYFIVEMILE:
					numLevels  = 1;
					interval = Ruler.TWTYFIVEMILE
					lineWidth = 1;
					break;
				case Ruler.FIFTYMILE:
					numLevels  = 1;
					interval = Ruler.FIFTYMILE
					lineWidth = 1;
					lineOpacity = 0.70;
					break;
			}
			var curIntNum:Number = interval;
			for(var i:int = numLevels; i > 0; i--){
				
				ruleLine.graphics.lineStyle(lineWidth,colorArray[i-1],lineOpacity);
				lvlArray = genRuleMiLine(rteBm, rteEm, diagramScale, curIntNum, (markerLength/i));
				ruleLine.graphics.drawPath(lvlArray[0],lvlArray[1],"evenOdd");
				
				if(curIntNum%1 == 0) // miles or ten of miles
				{
				
					var labelArray:Vector.<String>;
					var coordArray:Vector.<Number>;
					var lblPxOffset:int = 0;
					
					labelArray = lvlArray[2];
					coordArray = lvlArray[1];
					
					var xPt:Number, yPt:Number;
					var lblCnt:int = 0;
					
					for(var j:int = 2; j < coordArray.length; j=j+4){ 
						// get marker end point (every other coord pair in coordArray path vector)
	
						var text:TextField = new TextField();  
						xPt = coordArray[j];
						yPt = coordArray[j+1]; // inc by 1 for y
						//trace("point : " + xPt + ", " +yPt);						
						text.text = labelArray[lblCnt].toString();
						//trace("label : " + labelArray[lblCnt].toString());
						text.autoSize = TextFieldAutoSize.CENTER;   
						text.backgroundColor = 0xffffff;
						
						var txtFormat:TextFormat = new TextFormat(); 
						txtFormat.color = colorArray[0]; 
						txtFormat.font = txtFont; 
						txtFormat.size = txtSize;
						txtFormat.letterSpacing = 2;
						text.setTextFormat(txtFormat); 
						RuleSprite.addChild( text );          
        
						// Now adjust the text's position to the box's center         
						text.x = xPt-(text.width/2);          
						text.y = yPt+lblPxOffset; 						

						lblCnt++;
					}
				}
				curIntNum = curIntNum * 2;
			}
			RuleSprite.addChild(ruleLine);
			return RuleSprite;
		}
			
		private function genRuleMiLine(rteBm:Number,rteEm:Number, diagramScale:Number,intVal:Number,markerLength:int):Array
		{
			//ToDo: handle negative routes
			var pArray:Array = [];
			var vCmds:Vector.<int> = new Vector.<int>();
			var vData:Vector.<Number> = new Vector.<Number>();
			var vText:Vector.<String> = new Vector.<String>();
			
			var startY:int = 0; // top of drawing
			var startMi:int = Math.ceil(rteBm);
			var endMi:int = Math.ceil(rteEm);
			
			// calc rteDistance from 0 to em regardless of bm
			var rteDistance:Number = Converter.scaleMileToPixel(Math.abs(endMi-0)+1,diagramScale);
			var pxPerMile:Number = Converter.scaleMileToPixel(1,diagramScale);
			
			var pxInc:Number = pxPerMile*intVal;	
			var mkrCnt:int = Math.ceil((rteDistance/pxInc));
			
			var beginPx:Number = 0;
			if(rteBm != 0){ 
				// calculate pixels from 0 for all begin points gt or lt 0
				beginPx = Converter.scaleMileToPixel(rteBm,diagramScale);
			}			
			
			var curDist:Number = 0 - beginPx;
			
			for(var i:int = 0; i <= mkrCnt; i++)
			{
//				if (curDist >= beginPx)
//				{
					vCmds.push(1);
					vData.push(curDist);
					vData.push(startY);
					//draw begin pt (long mark)
					vCmds.push(2);
					vData.push(curDist);
					vData.push(startY+markerLength);
					//trace("MOD intVal%1 = " + intVal%1);
					if(intVal%1 == 0){ // miles or ten of miles
						vText.push(i*intVal);
					}
//				}
				curDist += pxInc;
			}
			// add vectors to array
			pArray[0] = vCmds;
			pArray[1] = vData;
			pArray[2] = vText;
			return pArray;
		}	
	
		public function clearContainer():void{
			// clear all children of container
			while (this.numChildren > 0)
			{
				this.removeChildAt(0);
			}
		}
	
		public function get markerLength():int
		{
			return markerPxLength;
		}
		public function set markerLength(mkLen:int):void
		{
			markerPxLength = mkLen;
		}	
		
		public function get textSize():int
		{
			return txtSize;
		}
		public function set textSize(tSize:int):void
		{
			txtSize = tSize;
		}
		
		public function get textFont():String
		{
			return txtFont;
		}
		public function set textFont(tFont:String):void
		{
			txtFont = tFont;
		}
	}
}