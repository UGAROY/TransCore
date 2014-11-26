package com.transcendss.transcore.sld.models.components
{
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.transcore.events.FeatureEvent;
	import com.transcendss.transcore.events.MenuBarEvent;
	import com.transcendss.transcore.events.RouteSelectorEvent;
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
	import mx.core.FlexGlobals;
	
	public class Intersection extends Sprite
	{
		private var txtPtArray:Array;
		private var txtSize:int = 12;
		private var txtFont:String = "Arial";
		private var intLineID:Number;
		private var intLineColl:ArrayCollection = new ArrayCollection();
		private var routeName:String;
		private var beginMile:Number;
		private var endMile:Number;
		private var milePoint:Number;
		private var featureName:String;
		private var dispatcher:Dispatcher = new Dispatcher();
		private var featureConst:String;
		private var dScale:Number;
		private var rtLength:String;
		
		public function Intersection(ftConst:String,rteName:String, rteBeg:Number, rteEnd:Number)
		{
			super();
			clearContainer();
			txtPtArray = []; //init array
			name = "INTERSEC";
			beginMile=rteBeg;
			endMile=rteEnd;
			routeName = rteName;
			featureConst = ftConst;
		}
		
		/**
		 * call service and obtain array of countylines 
		 */
		public function getIntLines():void
		{
			var ftEvent:FeatureEvent = new FeatureEvent( FeatureEvent.FEATURE_REQUEST,featureConst);
			ftEvent.serviceURL = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.serviceURL +"XingFeatures/"+featureConst+"/"+routeName+"/"+beginMile+"/"+endMile;
			dispatcher.dispatchEvent(ftEvent);
		}
		
		public function draw(ac:ArrayCollection, diagramScale:Number, diagramHeight:Number,rteBeginMi:Number):void
		{
			clearContainer();  // must clear to draw/redraw
			intLineColl = ac;
			dScale = diagramScale;
			//draw each county line
				for(var i:int =0; i<intLineColl.length; i++)
				{
					intLineID = new Number(String(intLineColl.getItemAt(i).ID));
					milePoint = new Number(String(intLineColl.getItemAt(i).REFPT));
					featureName = String(intLineColl.getItemAt(i).FEATURE_NAME);
					rtLength = (new Number(String(intLineColl.getItemAt(i).RT_LENGTH))).toFixed(2);
					drawintLine(Converter.scaleMileToPixel(milePoint-rteBeginMi,diagramScale), diagramHeight, featureName, intLineID,rtLength);
				}
		}
		
		private function drawintLine(atPixel:Number, lineLen:Number, coLabel:String,intLineID:Number, rtLength:String ,xAngle:Number=90):void
		{
			
			var offsetValue:Number = 508;
			
			var featureShp:Shape = new Shape();
			var drawing:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
			var intLnSprite:Tippable = new Tippable(Tippable.SLD);
			var path:GraphicsPath;
			var tipBuffer:int = 7;
			var x:int = atPixel;
			var y1:Number = lineLen/2-50;
			var y2:Number = lineLen/2+50;
			var labelYOffset:Number = 30;
			intLnSprite.name = coLabel;
			intLnSprite.tipText = coLabel;
			intLnSprite.tipdata = rtLength;
			
			featureShp.graphics.lineStyle(1.5,0x0,0);
			featureShp.graphics.beginFill(0x000000,1);
			featureShp.graphics.drawRect(x-tipBuffer,y1,tipBuffer*2,100);
			featureShp.graphics.endFill();
			featureShp.graphics.lineStyle(1,0xFFF544,1);
//			featureShp.graphics.moveTo(x,y1);
//			featureShp.graphics.lineTo(x,y2);
			
			path = new GraphicsPath(Vector.<int>([1,2]),
				Vector.<Number>([x,y1, x,y2]));
			//convert the solid path to dashed path and add to sprite
			drawing.push(Graphics.pathtoDashedLine(path,15,12));
			featureShp.graphics.drawGraphicsData(drawing);
			
			
			intLnSprite.addChild(featureShp);			
			intLnSprite.buttonMode = true;
			intLnSprite.useHandCursor = true;
			intLnSprite.addEventListener(MouseEvent.CLICK,onintLnClick);
			intLnSprite.addEventListener(MouseEvent.DOUBLE_CLICK,onDoubleClick);
			addChild(intLnSprite);
		}
		
		public function drawToPDF(pdfU:PDFUtil,ac:ArrayCollection, begMile:Number, endMile:Number, startX:Number, startY:Number, diagramScale:Number, maxPixelsWide:Number):void
		{
			for(var i:int =0; i<ac.length; i++)
			{
				intLineID = new Number(String(intLineColl.getItemAt(i).ID));
				milePoint = new Number(String(intLineColl.getItemAt(i).REFPT));
				featureName = String(intLineColl.getItemAt(i).FEATURE_NAME);
				
				startX = Converter.scaleMileToPixel(milePoint-begMile,diagramScale);
				
				pdfU.drawRectToPDF(startX-5,startY-30,10,60,.02,"0x000000","0x000000");
				//draw road divider dashed line
				pdfU.drawLineToPDF(startX,startY+30,startX,startY-30,.005,"0xFFFA0C",true);

			}
			
		}
		
		private function onDoubleClick(event:MouseEvent):void{
			//dispatcher.dispatchEvent(new RouteSelectorEvent(RouteSelectorEvent.ROUTE_CHANGE_REQUESTED,new Route(featureName,0,rtLength),dScale, true, true));
			
		}
		
		private function onintLnClick(event:MouseEvent):void{
			dispatcher.dispatchEvent(new RouteSelectorEvent(RouteSelectorEvent.ROUTE_CHANGE_REQUESTED,new Route(event.currentTarget.tipText,0,Number(event.currentTarget.tipdata)),dScale, true, true));
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