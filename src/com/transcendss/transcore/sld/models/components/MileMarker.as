package com.transcendss.transcore.sld.models.components
{
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.transcore.events.FeatureEvent;
	import com.transcendss.transcore.util.AssetSymbol;
	import com.transcendss.transcore.util.Converter;
	import com.transcendss.transcore.util.PDFUtil;
	import com.transcendss.transcore.vlog.TSSImage;
	
	import flash.display.IGraphicsData;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.text.TextField;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	
	public class MileMarker extends Sprite
	{
		public static var TYPE:String = "MILEMARKER";
		private var txtPtArray:Array;
		private var txtSize:int = 12;
		private var txtFont:String = "Arial";
		private var signID:Number;
		private var signColl:ArrayCollection = new ArrayCollection();
		private var routeName:String;
		private var beginMile:Number;
		private var scale:Number;
		private var endMile:Number;
		private var milePoint:Number;
		private var featureName:String;
		private var dispatcher:Dispatcher = new Dispatcher();
		private var featureConst:String;
		private var mutcd:String;
		private var loader:Loader;
		private var drawing:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
		private var Shp:Shape = new Shape();
		public function MileMarker()
		{
			super();
			clearContainer();
			txtPtArray = []; //init array
			name = "SIGN";
			
		}
		
		public function getSigns(ftConst:String,rteName:String, rteBeg:Number, rteEnd:Number):void
		{
			beginMile=rteBeg;
			endMile=rteEnd;
			routeName = rteName;
			featureConst = ftConst;
			var ftEvent:FeatureEvent = new FeatureEvent( FeatureEvent.FEATURE_REQUEST,featureConst);
			ftEvent.serviceURL = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.serviceURL +"XingFeatures/"+featureConst+"/"+routeName+"/"+beginMile+"/"+endMile;
			dispatcher.dispatchEvent(ftEvent);
		}
		
		public function draw(ac:ArrayCollection, diagramScale:Number, diagramHeight:Number,rteBeginMi:Number, offsetValue:Number = 508):void
		{
			clearContainer();  // must clear to draw/redraw
			
			signColl = ac;
			var tsspic:TSSImage = new TSSImage();
			var signSprite:AssetSymbol;
			scale = diagramScale;
			var signLabel1:flash.text.TextField = new flash.text.TextField();
			var signLabel2:flash.text.TextField = new flash.text.TextField();
			var signLabel3:flash.text.TextField = new flash.text.TextField();
			var signLabelAll:String = new String();
			//draw each county line
			for(var i:int =0; i<signColl.length; i++)
			{
				if(signColl.getItemAt(i) == null)
					continue;
				var baseA:BaseAsset = signColl.getItemAt(i) as BaseAsset;
				signSprite = new AssetSymbol(baseA);
				signID = new Number(String(baseA.invProperties[baseA.primaryKey].value));
				milePoint = new Number(String(baseA.invProperties[baseA.fromMeasureColName].value));
				featureName = String(baseA.invProperties[baseA.valueKey].value);
				mutcd = String(baseA.invProperties[baseA.typeKey].value);
				signLabelAll = featureName;
				
				Shp= new Shape();
				drawing= new Vector.<IGraphicsData>();
				Shp.graphics.lineStyle(1,0,1);
				
				Shp.graphics.drawGraphicsData(drawing);
				// Draw a rect that allows easier mouse click capture
				Shp.graphics.beginFill(0x009966,1);
				Shp.graphics.drawRect(0,0,15,32);
				Shp.graphics.endFill();
				signSprite.addChild(Shp);
				signSprite.stdHeight = 32;
				signSprite.stdWidth = 15;
				
				signLabel1 = new flash.text.TextField();
				signLabel1.textColor = 0xFFFFFF;
				signLabel1.selectable = false;
				signLabel2 = new flash.text.TextField();
				signLabel2.textColor = 0xFFFFFF;
				signLabel2.selectable = false;
				signLabel3 = new flash.text.TextField();
				signLabel3.textColor = 0xFFFFFF;
				signLabel3.selectable = false;
				if (signLabelAll.length == 1)
				{
					signLabel1.text = signLabelAll;
					signLabel1.x=2;
					signLabel1.y=6;
					signLabel1.visible=true;
					signSprite.addChild(signLabel1);
				} else if (signLabelAll.length == 2)
				{
					signLabel1.text = signLabelAll.substr(0,1);
					signLabel1.x=2;
					signLabel1.y=2;
					signLabel1.visible=true;
					signSprite.addChild(signLabel1);
					
					signLabel2.text = signLabelAll.substr(1,1);
					signLabel2.x=2;
					signLabel2.y=12;
					signLabel2.visible=true;
					signSprite.addChild(signLabel2);
					
				} else if (signLabelAll.length == 3)
				{
					signLabel1.text = signLabelAll.substr(0,1);
					signLabel1.x=2;
					signLabel1.y=-2;
					signLabel1.visible=true;
					signSprite.addChild(signLabel1);
					
					signLabel2.text = signLabelAll.substr(1,1);
					signLabel2.x=2;
					signLabel2.y=8;
					signLabel2.visible=true;
					signSprite.addChild(signLabel2);
					
					signLabel3.text = signLabelAll.substr(2,1);
					signLabel3.x=2;
					signLabel3.y=18;
					signLabel3.visible=true;
					signSprite.addChild(signLabel3);
				}
				
				signSprite.x =  Converter.scaleMileToPixel(milePoint-rteBeginMi,diagramScale)-signSprite.stdWidth/2 + offsetValue; // offsetvalues
				signSprite.y = 30;	
				addChild(signSprite);
				/*loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, resizeImage);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imageFailed);  
				var request:URLRequest = new URLRequest( "/images/signs/"+ mutcd + ".gif");  
				loader.load(request);  
				addChild(loader);
				
				loader.x =  Converter.scaleMileToPixel(milePoint-rteBeginMi,diagramScale);
				loader.y = 40;*/
				baseA.symbol = signSprite;
			}  
		}
		
		public function drawToPDF(pdfU:PDFUtil,ac:ArrayCollection, begMile:Number, endMile:Number, startX:Number, startY:Number, diagramScale:Number, maxPixelsWide:Number):void
		{
			var signLabelAll:String = new String();
			for(var i:int =0; i<ac.length; i++)
			{
				signID = new Number(String(signColl.getItemAt(i).ID));
				milePoint = new Number(String(signColl.getItemAt(i).REFPT));
				featureName = String(signColl.getItemAt(i).FEATURE_NAME);
				mutcd = String(signColl.getItemAt(i).MUTCD);
				signLabelAll = featureName;
				

				startX = Converter.scaleMileToPixel(milePoint-begMile,diagramScale);
				
				pdfU.drawRectToPDF(startX-10,startY-60,20,25,.02,"0x000000","0x009966");
				//draw road divider dashed line
				pdfU.drawTextToPDF("Arial",8, String(milePoint.toFixed(0)),startX-5,startY-70,0,"0xFFFFFF");
				
			}
			
		}
		
		private function resizeImage(e:Event):void {
			loader = e.target.loader as Loader;
			loader.width = 40;
			loader.height = 40;
		} 
			private function imageFailed(event:IOErrorEvent):void  
			{  
				//Alert.show("Image loading failed");  
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