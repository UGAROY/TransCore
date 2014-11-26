package com.transcendss.transcore.sld.models.components
{
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.transcore.events.FeatureEvent;
	import com.transcendss.transcore.util.Converter;
	import com.transcendss.transcore.util.Graphics;
	import com.transcendss.transcore.util.PDFUtil;
	import com.transcendss.transcore.util.Tippable;
	
	import flash.display.GraphicsPath;
	import flash.display.IGraphicsData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.*;
	
	import flashx.textLayout.formats.Float;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.core.*;
	
	public class Culvert extends Sprite
	{
		public static const TYPE:String = "CULV";
		
		public var ID:Number; 
		public var ROUTE_NAME:String; 
		public var ASSET_BASE_ID:String;
		public var CROSS_ST_NM:String; 
		public var CROSS_ST_NUM:String; 
		public var CULV_LENGTH_FLG:Number; 
		public var CULV_LENGTH_FT:String; 
		public var D_ORIG_DATA_SOURCE_ID:String; 
		public var D_BEAM_MAT_ID:String; 
		public var D_ABUTMENT_MAT_ID:String; 
		public var D_CULV_MAT_ID:String; 
		public var D_CULV_MAT_ID_2:String; 
		public var D_CULV_SHAPE_ID:String; 
		public var D_JOINT_SEP_LOC_ID:String; 
		public var D_CULV_PLACEMENT_TY_ID:String; 
		public var MILEPOST:Number;
		public var LOCATION_CMT:String; 
		public var NUM_BARRELS:Number; 
		public var STATION:String; 
		public var D_GARAGE_ID:String; 
		public var CULV_SIZE_VERT_INCH:String; 
		public var CULV_SIZE_HORIZ_INCH:String;
		public var CULV_SIZE3:String; 
		public var SKEW_FLG:Number; 
		public var INV_CMT:String; 
		public var PROJECT_ID:Number; 
		public var INSP_CMT:String;
		public var D_JOINT_COND_ID:String;
		public var D_CHNL_COND_ID:String;
		public var D_BARL_COND_ID:String;
		public var D_ENDS_COND_ID:String;
		public var D_FLOW_COND_ID:String;
		public var D_JOINT_RMK_ID:String;
		public var D_CHNL_RMK_ID:String;
		public var D_BARL_RMK_ID:String;
		public var D_ENDS_RMK_ID:String;
		public var D_FLOW_RMK_ID:String;
		public var D_REFER_TO_ID:String;
		public var CREATE_DT:Date;
		public var MODIFY_DT:Date;
		public var MODIFIED_BY:String;
		public var RETIRE_DT:Date;
		
		private var _retired:Boolean = false;
		
		
//		private var dataType:Number;
//		private var leftCulvertStart:Number = 0;
//		private var rightCulvertStart:Number = 0;
		private var culSprite:Culvert;
		private var drawing:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
		private var Shp:Shape = new Shape();
		
		private var dispatcher:Dispatcher = new Dispatcher();
		private var culCollection:ArrayCollection = new ArrayCollection();
		
		private var diagramH:Number =0;
		private var cLength:Number=-1;
		private var scale:Number;
		private var culID:Number;
		private var milePoint:Number;
		private var featureName:String;
		private var featureLength:Number;
		private var placement:Number;
		private var path:GraphicsPath;
		private var tmpx:Number = 20;
		private var tempy:Number = 40;
		private var culvertMap:ArrayList;
		private var rteBegMile:Number;
		private var currentCached:Boolean = false;
		
		public function Culvert()
		{
			super();
			culvertMap = new ArrayList();
			name= "CULVERT";
			
			//this.addEventListener(MouseEvent.CLICK, onCulvertClick);
		}
	
	
		public function getCulverts(featureConst:String, routeName:String, beginMile:Number, endMile:Number):void
		{
			culCollection = new ArrayCollection();
			var ftEvent:FeatureEvent = new FeatureEvent( FeatureEvent.FEATURE_REQUEST,featureConst);
			ftEvent.serviceURL = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.serviceURL +"XingFeatures/"+featureConst+"/"+routeName+"/"+beginMile+"/"+endMile;
			dispatcher.dispatchEvent(ftEvent);
		}
		
		//draws culvert
		public function draw(ac:ArrayCollection, diagramScale:Number, diagramHeight:Number,rteBeginMi:Number, fromStorage:Boolean = false):void
		{
			//clearContainer();  // must clear to draw/redraw
			culCollection = new ArrayCollection();
			if(culCollection.length>0 && !fromStorage)
				culCollection.addAll(ac);
			else
				culCollection = ac;
			scale = diagramScale;
			diagramH = diagramHeight;
			rteBegMile = rteBeginMi;
			tmpx =0;
			//draw each culvert
			for(var i:int =0; i<culCollection.length; i++)
			{
				
				Shp= new Shape();
				drawing= new Vector.<IGraphicsData>();
				//culSprite = new Tippable(1);
				culSprite = new Culvert();
				
				culID = new Number(String(culCollection.getItemAt(i).ID));
				milePoint = new Number(String(culCollection.getItemAt(i).MILEPOST));
				//featureName = String(culCollection.getItemAt(i).FEATURE_NAME);
				cLength = new Number(culCollection.getItemAt(i).CULV_LENGTH_FT);
				placement  = new Number(culCollection.getItemAt(i).D_CULV_PLACEMENT_TY_ID);
				
				culSprite.x = Converter.scaleMileToPixel(milePoint-rteBeginMi,diagramScale);
				cLength = Converter.scaleMileToPixel(cLength *0.0001894, diagramScale); //converting feet to mile and then to pixel
				
				if (placement == 1 || placement == 4 || placement ==5)//crossing culvert, Other
				{
					Shp.graphics.lineStyle(2.75, 0,1);
					path = new GraphicsPath(Vector.<int>([1,2]),
						Vector.<Number>([tmpx,10, tmpx - 10,0]));
					drawing.push(path);
					path = new GraphicsPath(Vector.<int>([1,2]),
						Vector.<Number>([tmpx,60, tmpx - 10,70]));
					drawing.push(path);
					path = new GraphicsPath(Vector.<int>([1,2]),
						Vector.<Number>([tmpx,10, tmpx + 10,0]));
					drawing.push(path);
					path = new GraphicsPath(Vector.<int>([1,2]),
						Vector.<Number>([tmpx,60, tmpx + 10,70]));
					drawing.push(path);
					path = new GraphicsPath(Vector.<int>([1,2]),
						Vector.<Number>([tmpx,10, tmpx, 60]));
					drawing.push(path);
					Shp.graphics.drawGraphicsData(drawing);
					// Draw a rect that allows easier mouse click capture
					Shp.graphics.beginFill(0xFF0000,0);
					Shp.graphics.lineStyle(0,0,0);
					Shp.graphics.drawRect(0-(Shp.width / 2),0,Shp.width,Shp.height);
					Shp.graphics.endFill();
					culSprite.addChild(Shp);
					culSprite.height = Shp.height;
					culSprite.width = Shp.width;
					culSprite.y = diagramH/2-35;
					
				} else if (placement == 2 || placement ==3)//2-ditch(right) culvert , 3- median (left) culvert
				{
					 tempy=10;
					cLength = cLength+20;
					Shp.graphics.lineStyle(2.75, 0,1);
					path = new GraphicsPath(Vector.<int>([1,2]),
						Vector.<Number>([tmpx,tempy, tmpx - 10,tempy+10]));
					drawing.push(path);
					path = new GraphicsPath(Vector.<int>([1,2]),
						Vector.<Number>([tmpx,tempy, tmpx - 10,tempy-10]));
					
					drawing.push(path);
					path = new GraphicsPath(Vector.<int>([1,2]),
						Vector.<Number>([tmpx,tempy, cLength,tempy]));
					drawing.push(path);
					path = new GraphicsPath(Vector.<int>([1,2]),
						Vector.<Number>([cLength,tempy, cLength + 10,tempy+10]));
					drawing.push(path);
					path = new GraphicsPath(Vector.<int>([1,2]),
						Vector.<Number>([cLength,tempy, cLength + 10,tempy-10]));
					drawing.push(path);
					Shp.graphics.drawGraphicsData(drawing);
					Shp = Graphics.addGlow(Shp,0xdfdfdf,0.4);
					// Draw a rect that allows easier mouse click capture
					Shp.graphics.beginFill(0xFF0000,0);
					Shp.graphics.lineStyle(0,0,0);
					Shp.graphics.drawRect(0,0,Shp.width,Shp.height);
					Shp.graphics.endFill();
					culSprite.addChild(Shp);
					culSprite.height = Shp.height;
					culSprite.width = Shp.width;
					if (placement==3)
						culSprite.y = diagramH/2-70;
					else
						culSprite.y = diagramH/2+50;
					
				}
				culSprite.addEventListener(MouseEvent.CLICK, onSpriteClick);
				culSprite.name = String(cLength)+ " ft";
				culSprite.buttonMode = true;
				culSprite.useHandCursor = true;
				addChild(culSprite);
				var tmpObj:Object = new Object();
				tmpObj.spriteObj = culSprite;
				tmpObj.culData = culCollection.getItemAt(i);
				culvertMap.addItem(tmpObj);
				this.setCulvertPropertiesFromObject(culSprite, tmpObj);
				
			}
			
		}
		
		public function drawToPDF(pdfU:PDFUtil,ac:ArrayCollection, begMile:Number, endMile:Number, startX:Number, startY:Number, diagramScale:Number, maxPixelsWide:Number):void
		{
			for(var i:int =0; i<ac.length; i++)
			{
				culID = new Number(String(ac.getItemAt(i).ID));
				milePoint = new Number(String(ac.getItemAt(i).MILEPOST));
				//featureName = String(culCollection.getItemAt(i).FEATURE_NAME);
				cLength = new Number(ac.getItemAt(i).CULV_LENGTH_FT);
				placement  = new Number(ac.getItemAt(i).D_CULV_PLACEMENT_TY_ID);
				
				startX = Converter.scaleMileToPixel(milePoint-begMile,diagramScale);
				cLength = Converter.scaleMileToPixel(cLength *0.0001894, diagramScale); //converting feet to mile and then to pixel
				
				if (placement == 1 || placement == 4 || placement ==5)//crossing culvert, Other
				{
					pdfU.drawLineToPDF(startX-5, startY+35,startX,startY+30,.02,"0x000000");
					pdfU.drawLineToPDF(startX+5, startY+35,startX,startY+30,.02,"0x000000");
					pdfU.drawLineToPDF(startX, startY+30,startX,startY-30,.02,"0x000000");				
					pdfU.drawLineToPDF(startX-5, startY-35,startX,startY-30,.02,"0x000000");
					pdfU.drawLineToPDF(startX+5, startY-35,startX,startY-30,.02,"0x000000");
				} else if (placement == 2)//2-ditch(right) culvert 
				{
					pdfU.drawLineToPDF(startX-5, startY+45,startX,startY+40,.02,"0x000000");
					pdfU.drawLineToPDF(startX-5, startY+35,startX,startY+40,.02,"0x000000");
					pdfU.drawLineToPDF(startX, startY+40,startX+cLength,startY+40,.02,"0x000000");
					pdfU.drawLineToPDF(startX+cLength+5, startY+45,startX+cLength,startY+40,.02,"0x000000");
					pdfU.drawLineToPDF(startX+cLength+5, startY+35,startX+cLength,startY+40,.02,"0x000000");
				}
				else if (placement==3)//3- median (left) culvert
				{
					pdfU.drawLineToPDF(startX-5, startY-45,startX,startY-40,.02,"0x000000");
					pdfU.drawLineToPDF(startX-5, startY-35,startX,startY-40,.02,"0x000000");
					pdfU.drawLineToPDF(startX, startY-40,startX+cLength,startY-40,.02,"0x000000");
					pdfU.drawLineToPDF(startX+cLength+5, startY-45,startX+cLength,startY-40,.02,"0x000000");
					pdfU.drawLineToPDF(startX+cLength+5, startY-35,startX+cLength,startY-40,.02,"0x000000");
				}
				
			}
				
		}
		
		//add culvert using form
		public function addCulvert(cul:Culvert):void
		{
			currentCached = true;
			var arr:Array = new Array(cul);
			draw(new ArrayCollection(arr),scale,diagramH,rteBegMile);
			currentCached = false;
		}
		
		public function addCulvertArr(arr:ArrayCollection, theScale:Number, theDH:Number, theBegMile:Number):void
		{			
			currentCached = true;
			draw(arr,theScale, theDH, theBegMile);
			currentCached = false;
		}
		
		
		// Retrieve culvert data by the sprite that was clicked
		public function getCulvertData(cSprite:Sprite):Object
		{
			var retVal:Object = null;
			for (var i:int=0;i<culvertMap.length;i++)
			{
				if (culvertMap.getItemAt(i).spriteObj == cSprite)
				{
					retVal = culvertMap.getItemAt(i).culData;
					break;
				}
			}
			return retVal;
		}
		
		private function onSpriteClick(evt:MouseEvent):void
		{
			FlexGlobals.topLevelApplication.editCulvert(evt.target as Culvert);
			
		}
		
		private function onCulvertClick(evt:MouseEvent):void
		{
			FlexGlobals.topLevelApplication.TSSAlert("Culvert Clicked");
		}
		
		public function clearContainer():void{
			// clear all children of container
			while (this.numChildren > 0)
			{
				this.removeChildAt(0);
			}
		}
	
		public function setCulvertProperties(ROUTE_FULL_NAMEp:String,ASSET_BASE_IDp:String,CROSS_ST_NMp:String,CROSS_ST_NUMp:String,CULV_LENGTH_FLGp:Number,CULV_LENGTH_FTp:String,D_ORIG_DATA_SOURCE_IDp:String,D_BEAM_MAT_IDp:String,D_ABUTMENT_MAT_IDp:String,D_CULV_MAT_IDp:String,D_CULV_MAT_ID_2p:String,D_CULV_SHAPE_IDp:String,D_JOINT_SEP_LOC_IDp:String,	D_CULV_PLACEMENT_TY_IDp:String,MILEPOSTp:Number,LOCATION_CMTp:String,NUM_BARRELSp:Number,STATIONp:String,D_GARAGE_IDp:String,CULV_SIZE_VERT_INCHp:String,CULV_SIZE_HORIZ_INCHp:String,CULV_SIZE3p:String,SKEW_FLGp:Number,INV_CMTp:String,PROJECT_IDp:Number,
				INSP_CMTp:String,D_JOINT_COND_IDp:String,D_CHNL_COND_IDp:String,D_BARL_COND_IDp:String,D_ENDS_COND_IDp:String,D_FLOW_COND_IDp:String,D_JOINT_RMK_IDp:String,D_CHNL_RMK_IDp:String,D_BARL_RMK_IDp:String,D_ENDS_RMK_IDp:String,D_FLOW_RMK_IDp:String,D_REFER_TO_IDp:String,CREATE_DTp:Date,MODIFY_DTp:Date,MODIFIED_BYp:String,RETIRE_DTp:Date):void
		{
			ROUTE_NAME= ROUTE_FULL_NAMEp;
			ASSET_BASE_ID = ASSET_BASE_IDp;
			CROSS_ST_NM = CROSS_ST_NMp;
			CROSS_ST_NUM = CROSS_ST_NUMp;
			CULV_LENGTH_FLG= CULV_LENGTH_FLGp;
			CULV_LENGTH_FT = CULV_LENGTH_FTp;
			D_ORIG_DATA_SOURCE_ID = D_ORIG_DATA_SOURCE_IDp;
			D_BEAM_MAT_ID = D_BEAM_MAT_IDp;
			D_ABUTMENT_MAT_ID = D_ABUTMENT_MAT_IDp;
			D_CULV_MAT_ID= D_CULV_MAT_IDp;
			D_CULV_MAT_ID_2= D_CULV_MAT_ID_2p;
			D_CULV_SHAPE_ID = D_CULV_SHAPE_IDp;
			D_JOINT_SEP_LOC_ID= D_JOINT_SEP_LOC_IDp;
			D_CULV_PLACEMENT_TY_ID = D_CULV_PLACEMENT_TY_IDp;
			MILEPOST= MILEPOSTp;
			LOCATION_CMT= LOCATION_CMTp;
			NUM_BARRELS= NUM_BARRELSp;
			STATION= STATIONp;
			D_GARAGE_ID = D_GARAGE_IDp;
			CULV_SIZE_VERT_INCH = CULV_SIZE_VERT_INCHp;
			CULV_SIZE_HORIZ_INCH =CULV_SIZE_HORIZ_INCHp;
			CULV_SIZE3 =CULV_SIZE3p;
			SKEW_FLG = SKEW_FLGp;
			INV_CMT = INV_CMTp; 
			PROJECT_ID=PROJECT_IDp;
			INSP_CMT=INSP_CMTp;
			D_JOINT_COND_ID=D_JOINT_COND_IDp;
			D_CHNL_COND_ID=D_CHNL_COND_IDp;
			D_BARL_COND_ID=D_BARL_COND_IDp;
			D_ENDS_COND_ID=D_ENDS_COND_IDp;
			D_FLOW_COND_ID=D_FLOW_COND_IDp;
			D_JOINT_RMK_ID=D_JOINT_RMK_IDp;
			D_CHNL_RMK_ID=D_CHNL_RMK_IDp;
			D_BARL_RMK_ID=D_BARL_RMK_IDp;
			D_ENDS_RMK_ID=D_ENDS_RMK_IDp;
			D_FLOW_RMK_ID=D_FLOW_RMK_IDp;
			D_REFER_TO_ID=D_REFER_TO_IDp;
				
			CREATE_DT= CREATE_DTp;
			MODIFY_DT = MODIFY_DTp;
			MODIFIED_BY= MODIFIED_BYp;
			RETIRE_DT= RETIRE_DTp;
		}
		
		public function setCulvertPropertiesFromObject(thisCulvert:Culvert, dataMap:Object):void
		{
			thisCulvert.ROUTE_NAME= dataMap.culData.ROUTE_NAME;
			thisCulvert.ASSET_BASE_ID = dataMap.culData.ASSET_BASE_ID;
			if (dataMap.culData.ID != null && currentCached)
				thisCulvert.ID = dataMap.culData.ID;
			else
				thisCulvert.ID = -1;
			thisCulvert.CROSS_ST_NM = dataMap.culData.CROSS_ST_NM;
			thisCulvert.CROSS_ST_NUM = dataMap.culData.CROSS_ST_NUM;
			thisCulvert.CULV_LENGTH_FLG= dataMap.culData.CULV_LENGTH_FLG;
			thisCulvert.CULV_LENGTH_FT = dataMap.culData.CULV_LENGTH_FT;
			thisCulvert.D_ORIG_DATA_SOURCE_ID = dataMap.culData.D_ORIG_DATA_SOURCE_ID;
			thisCulvert.D_BEAM_MAT_ID = dataMap.culData.D_BEAM_MAT_ID;
			thisCulvert.D_ABUTMENT_MAT_ID = dataMap.culData.D_ABUTMENT_MAT_ID;
			thisCulvert.D_CULV_MAT_ID= dataMap.culData.D_CULV_MAT_ID;
			thisCulvert.D_CULV_MAT_ID_2= dataMap.culData.D_CULV_MAT_ID_2;
			thisCulvert.D_CULV_SHAPE_ID =dataMap.culData. D_CULV_SHAPE_ID;
			thisCulvert.D_JOINT_SEP_LOC_ID= dataMap.culData.D_JOINT_SEP_LOC_ID;
			thisCulvert.D_CULV_PLACEMENT_TY_ID = dataMap.culData.D_CULV_PLACEMENT_TY_ID;
			thisCulvert.MILEPOST= dataMap.culData.MILEPOST;
			thisCulvert.LOCATION_CMT= dataMap.culData.LOCATION_CMT;
			thisCulvert.NUM_BARRELS= dataMap.culData.NUM_BARRELS;
			thisCulvert.STATION= dataMap.culData.STATION;
			thisCulvert.D_GARAGE_ID = dataMap.culData.D_GARAGE_ID;
			thisCulvert.CULV_SIZE_VERT_INCH = dataMap.culData.CULV_SIZE_VERT_INCH;
			thisCulvert.CULV_SIZE_HORIZ_INCH =dataMap.culData.CULV_SIZE_HORIZ_INCH;
			thisCulvert.CULV_SIZE3 =dataMap.culData.CULV_SIZE3;
			thisCulvert.SKEW_FLG = dataMap.culData.SKEW_FLG;
			thisCulvert.INV_CMT = dataMap.culData.INV_CMT; 
			thisCulvert.PROJECT_ID=dataMap.culData.PROJECT_ID;
			thisCulvert.INSP_CMT=dataMap.culData.INSP_CMT;
			thisCulvert.D_JOINT_COND_ID=dataMap.culData.D_JOINT_COND_ID;
			thisCulvert.D_CHNL_COND_ID=dataMap.culData.D_CHNL_COND_ID;
			thisCulvert.D_BARL_COND_ID=dataMap.culData.D_BARL_COND_ID;
			thisCulvert.D_ENDS_COND_ID=dataMap.culData.D_ENDS_COND_ID;
			thisCulvert.D_FLOW_COND_ID=dataMap.culData.D_FLOW_COND_ID;
			thisCulvert.D_JOINT_RMK_ID=dataMap.culData.D_JOINT_RMK_ID;
			thisCulvert.D_CHNL_RMK_ID=dataMap.culData.D_CHNL_RMK_ID;
			thisCulvert.D_BARL_RMK_ID=dataMap.culData.D_BARL_RMK_ID;
			thisCulvert.D_ENDS_RMK_ID=dataMap.culData.D_ENDS_RMK_ID;
			thisCulvert.D_FLOW_RMK_ID=dataMap.culData.D_FLOW_RMK_ID;
			thisCulvert.D_REFER_TO_ID=dataMap.culData.D_REFER_TO_ID;
			
			if (dataMap.culData.CREATE_DT is Date)
			{
				thisCulvert.CREATE_DT= dataMap.culData.CREATE_DT;
			} 
			if (dataMap.culData.CREATE_DT is Date)
			{
				thisCulvert.MODIFY_DT = dataMap.culData.MODIFY_DT;
			}
			if (dataMap.culData.CREATE_DT is Date)
			{
				thisCulvert.MODIFIED_BY= dataMap.culData.MODIFIED_BY;
			}
			if (dataMap.culData.CREATE_DT is Date)
			{
				thisCulvert.RETIRE_DT= dataMap.culData.RETIRE_DT;
			}
		}
		
		public function get retired():Boolean
		{
			return _retired;
		}
		
		public function set retired(_retired:Boolean):void
		{
			this._retired = _retired;
		}
	}

}