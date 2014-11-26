package com.transcendss.transcore.sld.models.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.*;
	
	import mx.core.FlexGlobals;
	
	public class RouteInfoHUD extends Sprite
	{
		private var mtrxPos:int = 2;
		private var headColor:uint;
		private var valueColor:uint;
		private var mainBmdWidth:Number=0;
		private var txtFormat:TextFormat = new TextFormat();
		private var textfield:TextField = new TextField();
		private var HUDSprite:Sprite = new Sprite();
		private var begMile:Number = 0;
		private var guideMilePo:Number =0;
		public function RouteInfoHUD()
		{
			super();
			clearContainer();
			name = "ROUTE_HUD";
		}
		
		public function draw(rteName:String, begMi:Number, endMi:Number, initScreenWidthPx:int, diagramHeight:Number, guideBarMP:Number=0,textHeadColor:uint=0x000000, textValueColor:uint=0x800000, textSize:int=13, textFont:String = "Arial"):void
		{
			clearContainer();  // must clear to draw/redraw
			mainBmdWidth=0;
			guideMilePo=0;
			
			HUDSprite.name = "HUD_SPRITE";

			textfield.autoSize = TextFieldAutoSize.LEFT;
			textfield.backgroundColor = 0xffffcc;
			textfield.filters = [new GlowFilter(0xdfdfdf,0.6)];
			textfield.selectable = false;
			textfield.border = false;
			textfield.embedFonts=false;
			textfield.mouseEnabled=false;
			txtFormat.font = textFont; 
			txtFormat.size = textSize;
			txtFormat.bold = true;
			txtFormat.letterSpacing = 1.2;
			
			
			headColor=textHeadColor;
			valueColor=textValueColor;
			begMile = begMi;

			
			
			HUDSprite.addChild( getBitMap("ROUTE: ", rteName, "RouteBitMap"));  
			HUDSprite.addChild( getBitMap(" BEGIN MP: ", begMi.toString(), "BeginMiBitMap"));  
			HUDSprite.addChild( getBitMap(" END MP: ", endMi.toString(), "EndMiBitMap"));  

			HUDSprite.addChild( getBitMap(" GUIDE MP: ", "", "GuideMiLblBitMap"));  
			HUDSprite.addChild( getBitMap("", (guideBarMP).toFixed(2), "GuideMiBitMap"));  
			guideMilePo = new Number((guideBarMP).toFixed(2));
			HUDSprite.x = initScreenWidthPx/2 - HUDSprite.width/2;
			//HUDSprite.x = 0;//(initScreenWidthPx - 50) / 2 - (mainBmdWidth / 2);
			HUDSprite.y = diagramHeight - 50;
			
			addChild(HUDSprite);
		}
		
		private function getBitMap(label:String, val:String, bitMapName:String):Bitmap
		{
			var spacer:Number = 0;
			var txtLabel:TextField = new TextField();
			var txtValue:TextField = new TextField();
			var mtrxPos:int= 2;
			var bitMapWidth:int = 0;

			
			txtLabel.text = label;
			txtFormat.color = headColor;	
			txtLabel.setTextFormat(txtFormat); 
			txtLabel.backgroundColor = 0xffffcc;
			
			txtValue.text = val;
			txtValue.width = 300;
			txtFormat.color = valueColor;
			txtValue.setTextFormat(txtFormat); 
			
			if(label =="")
				bitMapWidth =  txtValue.textWidth+10;
			else if (val =="")
				bitMapWidth = txtLabel.textWidth;
			else
				bitMapWidth = txtLabel.textWidth + txtValue.textWidth+50;
			
			var bmd:BitmapData = new BitmapData( bitMapWidth,20);

			spacer = 2;
			bmd.floodFill(0,0,0xffffcc);
			bmd.draw(txtLabel,new Matrix(1,0,0,1,mtrxPos,0));
			mtrxPos = mtrxPos +(txtLabel.textWidth + spacer);
			spacer =0;
			bmd.floodFill(0,0,0xffffcc);
			bmd.draw(txtValue,new Matrix(1,0,0,1,mtrxPos,0));
			mtrxPos = mtrxPos +(txtValue.textWidth + spacer);

			var bm:Bitmap = new Bitmap(bmd,"auto",true);
			
			bm.name = bitMapName;
			bm.x = mainBmdWidth;
			mainBmdWidth = mainBmdWidth + bmd.width;
			return bm;
		}
		
		
		public function updateGuideMile(val:Number):void
		{
			var bitmp:DisplayObject = HUDSprite.getChildByName("GuideMiBitMap");
			
			
			var txtValue:TextField = new TextField();
			txtValue.text =  val.toFixed(2);
			guideMilePo = new Number(val.toFixed(2));
			txtValue.backgroundColor = 0xffffcc;
			txtFormat.color = valueColor;
			
			txtValue.setTextFormat(txtFormat); 
			var bitMapWidth:int =  txtValue.textWidth+10;
			var bmd:BitmapData = new BitmapData( bitMapWidth,20);
			var spacer:int =0;
			
			var mtrxPos:int= 2;
			bmd.floodFill(0,0,0xffffcc);
			bmd.draw(txtValue,new Matrix(1,0,0,1,mtrxPos,0));
			bmd.floodFill(0,0,0xffffcc);
			var bm:Bitmap = new Bitmap(bmd,"auto",true);
			bm.name = "GuideMiBitMap";
			bm.x = bitmp.x;
			bm.visible = true;
			
			HUDSprite.removeChild(bitmp);
			HUDSprite.addChild(bm);
			HUDSprite.setChildIndex(bm,HUDSprite.numChildren-1);
		}

		public function hideGuideMile():void
		{
			var bitmp:DisplayObject = HUDSprite.getChildByName("GuideMiBitMap");
			bitmp.visible = false;
		} 
		public function currentMilePost():Number
		{
			return this.guideMilePo;
		}
			
			
			
		
		public function clearContainer():void{
			// clear all children of container
			while (HUDSprite.numChildren > 0)
			{
				HUDSprite.removeChildAt(0);
			}
			while (this.numChildren > 0)
			{
				this.removeChildAt(0);
			}
		}
	}
}

