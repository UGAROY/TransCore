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
	
	public class Stream extends Sprite
	{
		private var txtPtArray:Array;
		private var txtSize:int = 12;
		private var txtFont:String = "Arial";
		private var streamID:Number;
		private var strmLineColl:ArrayCollection = new ArrayCollection();
		private var routeName:String;
		private var beginMile:Number;
		private var endMile:Number;
		private var milePoint:Number;
		private var featureName:String;
		private var dispatcher:Dispatcher = new Dispatcher();
		private var featureConst:String;
		
		public function Stream(ftConst:String,rteName:String, rteBeg:Number, rteEnd:Number)
		{
			super();
			clearContainer();
			txtPtArray = []; //init array
			name = "STREAM";
			beginMile=rteBeg;
			endMile=rteEnd;
			routeName = rteName;
			featureConst = ftConst;
		}
		
		public function getStreams():void{
			//call service and obtain array of countylines
			var ftEvent:FeatureEvent = new FeatureEvent( FeatureEvent.FEATURE_REQUEST,featureConst);
			ftEvent.serviceURL = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.serviceURL +"XingFeatures/"+featureConst+"/"+routeName+"/"+beginMile+"/"+endMile;
			dispatcher.dispatchEvent(ftEvent);
		}
		
		public function draw(ac:ArrayCollection, diagramScale:Number, diagramHeight:Number,rteBeginMi:Number):void
		{
			clearContainer();  // must clear to draw/redraw
			strmLineColl = ac;
			//draw each county line
				for(var i:int =0; i<strmLineColl.length; i++)
				{
					streamID = new Number(String(strmLineColl.getItemAt(i).ID));
					milePoint = new Number(String(strmLineColl.getItemAt(i).REFPT));
					featureName = String(strmLineColl.getItemAt(i).FEATURE_NAME);
					drawStrmLine(Converter.scaleMileToPixel(milePoint-rteBeginMi,diagramScale), diagramHeight, featureName, streamID);
				}
		}
		
		private function drawStrmLine(atPixel:Number, lineLen:Number, coLabel:String,streamID:Number, xAngle:Number=90, wFreq:Number =3.5, wAmp:int=3.5):void
		{
			var vCmds:Vector.<int> = new Vector.<int>();
			var vCoords:Vector.<Number> = new Vector.<Number>();	
			
			graphics.beginFill(0xffffff,1);
			
			var featureShp:Shape = new Shape();
			var drawing:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
			var strmLnSprite:Tippable = new Tippable(Tippable.SLD); 
			var path:GraphicsPath;
			var tipBuffer:int = 7;
			var x:int = atPixel;
			var y1:Number = 0;
			var y2:Number = lineLen;
			var labelYOffset:Number = 30;

			featureShp = Graphics.addGradientGlow(featureShp,[0x000000, 0xFF0000],1);		
			featureShp.graphics.lineStyle(.5, 0x1CA0FF,.5);

			vCmds.push(1);
			vCoords.push(x);
			vCoords.push(y1);

			for(var i:int=y1; i<y2; i++){
				var ang:Number = 2 * Math.PI * wFreq * i/y2 ;
				vCmds.push(2);
				vCoords.push(x+wAmp * Math.sin(ang));
				vCoords.push(i);
			}
			path = new GraphicsPath(vCmds,vCoords);

			drawing.push(path)
			featureShp.graphics.drawGraphicsData(drawing);
			
			
			featureShp.graphics.lineStyle(1,0x0,0);
			featureShp.graphics.beginFill(0xffffff,0);
			featureShp.graphics.drawRect(x-(wAmp+tipBuffer),y1,2*(wAmp+tipBuffer),lineLen);
			featureShp.graphics.endFill();
			
			strmLnSprite.addChild(featureShp);
			strmLnSprite.tipText = coLabel;
			strmLnSprite.tipBGColor = 0xFAFF70;
			//write county name on the left side
//			strmLnSprite.addChild(writeStrmNames(x,y1+labelYOffset,"R",coLabel));
			strmLnSprite.name = String(streamID);
			strmLnSprite.buttonMode = true;
			strmLnSprite.useHandCursor = true;
			strmLnSprite.addEventListener(MouseEvent.CLICK,onStrmLnClick);
			addChild(strmLnSprite);
		}
		
		private function onStrmLnClick(event:MouseEvent):void{
			
		}
		
		private function writeStrmNames(xPt:Number, yPt:Number, strmSide:String, streamName:String):TextField{
			var text:TextField = new TextField();
			var colorArray:Array = new Array(0x000000, 0x888888, 0xbbbbbb);
			var xPtOfPrev:Number = txtPtArray[txtPtArray.length-1];
			var cXPt:Number;
			var cYPt:Number;
			
			text.text =streamName;
			
			if (strmSide == "L")
			{
				// align left county text to right with buffer
//				var leftText:String = strmNames[0] != null ? strmNames[0] : "";
//				text.text = leftText.replace(" ","");
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
//				var rightText:String = strmNames[1] != null ? strmNames[1] : "";
//				text.text = rightText.replace(" COUNTY LINE", "");
				
				
				text.autoSize = TextFieldAutoSize.LEFT;
				cXPt = xPt + 10;
				cYPt = yPt;
				if(cXPt < xPtOfPrev) text.text = "";
				text.x = cXPt;
				text.y = cYPt;
				//store the furthest x value of text string
				txtPtArray.push(text.x+text.textWidth);  
			}
			text.backgroundColor = 	0xFFFFFF;
			text.filters = [new GlowFilter(0xdfdfdf,0.6)];
			text.autoSize = TextFieldAutoSize.CENTER;       
			var txtFormat:TextFormat = new TextFormat(); 
			txtFormat.color = colorArray[0]; 
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