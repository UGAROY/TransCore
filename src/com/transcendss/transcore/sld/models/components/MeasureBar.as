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
	
	public class MeasureBar extends Sprite 
	{
		private var markerPxLength:int = 10;
		private var txtSize:int = 12;
		private var txtFont:String = "Arial";
		private var dH:Number ;
		private var dW:Number;
		private var zeroPos:Number;
		private var ruler:Sprite = new Sprite();
		
		
		public function MeasureBar(mkLen:int=10)
		{
			clearContainer();
			name = "MeasureBar";
			markerPxLength = mkLen;
		}
	
		public function draw(diagramH:Number, diagramW:Number,guideBarX:Number, diagramScale:Number, units:int=4):void{
			clearContainer();  // must clear to draw/redraw
			
			var rIntrvl:Number = 1;
			var rIntOffset:Number = 0;
			var rDist:Number = Math.abs(diagramW);
			dH=diagramH;
			zeroPos=guideBarX;
			
			addChild(drawBaseLine(0, diagramW, diagramScale)); // draw white background rect
			
			ruler = drawRulesByValue(diagramW,diagramScale,units);
			addChild(ruler);
		}
		
		private function drawBaseLine(rteBm:Number, diagramWidth:Number, diagramScale:Number):Shape{
			var baseRect:Shape = new Shape();
			// draw with paths in order to override lineto and rect expansion issues at very diagram dimensions
			baseRect.graphics.beginFill(0xdfdfdf);
			baseRect.graphics.drawPath(
				Vector.<int>([1,2,2,2]),
				Vector.<Number>([rteBm-20,dH, diagramWidth + 50,dH, diagramWidth + 50,dH-30, rteBm-20,dH-30]));
			//baseRect.graphics.endFill();
			baseRect.graphics.beginFill(0x888888); // draw border as 1 px wide path rectangle
			baseRect.graphics.drawPath(
				Vector.<int>([1,2,2,2]),
				Vector.<Number>([rteBm-21,dH+1, diagramWidth+51,dH+1, diagramWidth+51,dH-31, rteBm-21,dH-31]));
			return baseRect;
		}

		
		private function drawRulesByValue(rulerWidth:Number, diagramScale:Number, units:int=4):Sprite
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
			var labelArray:Vector.<String>;
			var coordArray:Vector.<Number>;
			var lblPxOffset:int = 0;
			var lblCnt:int = 0;
			
			ruleLine.graphics.lineStyle(lineWidth,colorArray[0],lineOpacity);
			lvlArray = genRuleMiLine( rulerWidth, diagramScale,  markerLength,units);
			ruleLine.graphics.drawPath(lvlArray[0],lvlArray[1],"evenOdd");
			
			coordArray = lvlArray[1];
			labelArray = lvlArray[2];
			
			for(var j:int = 2; j < coordArray.length; j=j+4)
			{
				var text:TextField = new TextField(); 
				text.text = labelArray[lblCnt]+" " + Units.getLabelByUnit(units);
				text.autoSize = TextFieldAutoSize.CENTER;   
				text.backgroundColor = 0xffffff;
				var txtFormat:TextFormat = new TextFormat(); 
				txtFormat.color = 0x000000; 
				txtFormat.font = txtFont; 
				txtFormat.size = txtSize;
				txtFormat.letterSpacing = 2;
				text.setTextFormat(txtFormat); 
				RuleSprite.addChild( text );          
				
				// Now adjust the text's position to the box's center         
				text.x = coordArray[j]-(text.width/2);          
				text.y = coordArray[j+1]-20; 		
				lblCnt++;
				if(lblCnt==labelArray.length)
					lblCnt =0;
			}
			
			
			RuleSprite.addChild(ruleLine);
			return RuleSprite;
		}
			
		private function genRuleMiLine(rulerWidth:Number, diagramScale:Number,markerLength:int, units:int=4):Array
		{
			//ToDo: handle negative routes
			var pArray:Array = [];
			var vCmds:Vector.<int> = new Vector.<int>();
			var vData:Vector.<Number> = new Vector.<Number>();
			var vText:Vector.<String> = new Vector.<String>();
			
			var startY:int = dH-2; //bottom of stick diagram
			var measure:Number = getMeasureByScale(diagramScale,units); //distance between markers in units
			var measureInMiles:Number = Converter.convertToMile(measure, units);
			var pxPerMeasure:Number =Converter.scaleMileToPixel(measureInMiles,diagramScale);
			
			
			var mkrCnt:int = 11;
			
			var centerPx:Number =rulerWidth/2;//center 		
			
			var markerPos:Number = centerPx ; //start from center
			var feet:Number;
			var i:int;

			markerPos = centerPx ;
			for(i=0; i < mkrCnt/2; i++) //draw from center to left
			{
				vCmds.push(1);
				vData.push(markerPos);
				vData.push(startY);
				//draw begin pt (long mark)
				vCmds.push(2);
				vData.push(markerPos);
				vData.push(startY-markerLength);
				feet= Converter.convertFromMile( Converter.scalePixelToMile(pxPerMeasure,diagramScale),units) * i; //convert from pixel to mile and then to the measure
				feet= (Number)( feet.toFixed(2));
				vText.push(feet);
				/*if((feet*100)%100 ==0)
					vText.push(feet.toFixed(0));
				else if((feet*100)%100 >=10)
					vText.push(feet.toFixed(1));
				else if((feet*100)%100 <10)
					vText.push(feet.toFixed(2));*/
				markerPos -= pxPerMeasure;
			}
			markerPos = centerPx ; //reset to center
			
			for(;i <= mkrCnt; i++)//draw from center to right
			{
					vCmds.push(1);
					vData.push(markerPos);
					vData.push(startY);
					//draw begin pt (long mark)
					vCmds.push(2);
					vData.push(markerPos);
					vData.push(startY-markerLength);
					
					markerPos += pxPerMeasure;
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
	
		public function moveMeasureBar(xPos:Number):void{
			this.x=xPos;
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
		
		private function getMeasureByScale(scale:Number, unit:Number):Number
		{
			switch(unit)
			{
				case Units.MILE:
					return scale;
				case Units.KILOMETER:
					return Converter.mileToKMeter(scale);
				case Units.COUNTYMILE:
					return scale;
				case Units.FEET:
					return Converter.mileToFeet(scale);
				case Units.METER:
					return Converter.milesToMeters(scale);
			}
			return -1;
			
		}
		
	}
}