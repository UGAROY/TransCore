package com.transcendss.transcore.sld.models.components
{
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.transcore.events.FeatureEvent;
	import com.transcendss.transcore.util.*;
	
	import flash.display.GraphicsPath;
	import flash.display.IGraphicsData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.*;
	
	import mx.collections.ArrayCollection;
	import mx.core.*;
	
	public class CountyLine extends Sprite
	{
		private var txtPtArray:Array;
		private var txtSize:int = 12;
		private var txtFont:String = "Arial";
		private var cntyLineID:Number;
		private var cntyLineColl:ArrayCollection = new ArrayCollection();
		private var routeName:String;
		private var beginMile:Number;
		private var endMile:Number;
		private var milePoint:Number;
		private var featureName:String;
		private var dispatcher:Dispatcher = new Dispatcher();
		private var featureConst:String;
		
		public function CountyLine(ftConst:String,rteName:String, rteBeg:Number, rteEnd:Number)
		{
			super();
			clearContainer();
			txtPtArray = []; //init array
			name = "COUNTYLINE";
			beginMile=rteBeg;
			endMile=rteEnd;
			routeName = rteName;
			featureConst = ftConst;
		}
		
		/**
		 * call service and obtain array of countylines 
		 */
		public function getCountyLines():void
		{
			var ftEvent:FeatureEvent = new FeatureEvent( FeatureEvent.FEATURE_REQUEST,featureConst);
			ftEvent.serviceURL = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.serviceURL +"XingFeatures/"+featureConst+"/"+routeName+"/"+beginMile+"/"+endMile;
			dispatcher.dispatchEvent(ftEvent);
		}
		
		public function draw(ac:ArrayCollection, diagramScale:Number, diagramHeight:Number,rteBeginMi:Number):void
		{
			clearContainer();  // must clear to draw/redraw
			cntyLineColl = ac;
			//draw each county line
				for(var i:int =0; i<cntyLineColl.length; i++)
				{
					cntyLineID = new Number(String(cntyLineColl.getItemAt(i).ID));
					milePoint = new Number(String(cntyLineColl.getItemAt(i).REFPT));
					featureName = String(cntyLineColl.getItemAt(i).FEATURE_NAME);
					drawCntyLine(Converter.scaleMileToPixel(milePoint-rteBeginMi,diagramScale), diagramHeight, featureName, cntyLineID);
				}
		}
		
		private function drawCntyLine(atPixel:Number, lineLen:Number, coLabel:String,cntyLineID:Number, xAngle:Number=90):void
		{
			graphics.beginFill(0xffffff,1);
			
			var featureShp:Shape = new Shape();
			var drawing:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
			var cntyLnSprite:Tippable = new Tippable(Tippable.SLD);
			var path:GraphicsPath;
			
			var tipBuffer:int = 7;
			var x:int = atPixel;
			var y1:Number = 0;
			var y2:Number = lineLen;
			var labelYOffset:Number = 30;
			cntyLnSprite.name = String(cntyLineID);
			cntyLnSprite.tipText = coLabel;
			featureShp = Graphics.addGradientGlow(featureShp,[0x000000, 0xFF0000],1);		
			featureShp.graphics.lineStyle(1, 0);
			//create the solid path accross the diagram for county line
			path = new GraphicsPath(Vector.<int>([1,2]),
				Vector.<Number>([x,y1, x,y2]));
			//convert the solid path to dashed path and add to sprite
			drawing.push(Graphics.pathtoDashedLine(path,15,12));
			featureShp.graphics.drawGraphicsData(drawing);
			
			featureShp.graphics.lineStyle(1,0x0,0);
			featureShp.graphics.beginFill(0xffffff,0);
			featureShp.graphics.drawRect(x-tipBuffer,y1,tipBuffer*2,lineLen);
			featureShp.graphics.endFill();
			
			cntyLnSprite.addChild(featureShp);
			//write county name on the left side
			cntyLnSprite.addChild(writeCntyNames(x,y1+labelYOffset,"L",coLabel));
			//write county name on the right side
			cntyLnSprite.addChild(writeCntyNames(x,y1+labelYOffset,"R",coLabel));
			cntyLnSprite.buttonMode = true;
			cntyLnSprite.useHandCursor = true;
			cntyLnSprite.addEventListener(MouseEvent.CLICK,onCntyLnClick);
			addChild(cntyLnSprite);
		}
		
		private function onCntyLnClick(event:MouseEvent):void{
			
		}
		private function writeCntyNames(xPt:Number, yPt:Number, cntySide:String, coLabel:String):TextField{
			var text:TextField = new TextField();
			var txtColor:uint = 0xffffff;
			var cntyNames:Array = coLabel.split("-");
			var xPtOfPrev:Number = txtPtArray[txtPtArray.length-1];
			var cXPt:Number;
			var cYPt:Number;
			if (cntySide == "L")
			{
				// align left county text to right with buffer
				var leftText:String = cntyNames[0] != null ? cntyNames[0] : "";
				text.text = leftText.replace(" ","");
				text.autoSize = TextFieldAutoSize.RIGHT;
				cXPt = xPt - (text.width + 10);
				cYPt= yPt;
				if(cXPt < xPtOfPrev) text.text = "";
				text.x = cXPt;
				text.y = cYPt ;
				
			}
			else
			{
				// align right county text to left with buffer
				var rightText:String = cntyNames[1] != null ? cntyNames[1] : "";
				text.text = rightText.replace(" COUNTY LINE", "");
				text.autoSize = TextFieldAutoSize.LEFT;
				cXPt = xPt + 10;
				cYPt = yPt;
				if(cXPt < xPtOfPrev) text.text = "";
				text.x = cXPt;
				text.y = cYPt;
				//store the furthest x value of text string
				txtPtArray.push(text.x+text.textWidth);  
			}
			text.backgroundColor = 	0x92D38F;
			text.background = true;
//			text.filters = [new GlowFilter(0xdfdfdf,0.6)];
			text.autoSize = TextFieldAutoSize.CENTER;       
			var txtFormat:TextFormat = new TextFormat(); 
			txtFormat.color = txtColor; 
			txtFormat.font = txtFont; 
			txtFormat.size = txtSize;
			txtFormat.letterSpacing = 2;
			text.setTextFormat(txtFormat); 
			return text;     
		}		
		
		public function clearContainer():void{
			// clear all children of container
			while (this.numChildren > 0)
			{
				this.removeChildAt(0);
			}
		}
	}

}