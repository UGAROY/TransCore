package com.transcendss.transcore.util
{
	import flash.display.GraphicsPath;
	import flash.display.Shape;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.filters.GradientGlowFilter;
	
	import mx.core.UIComponent;

	
	public final class Graphics
	{
		public static function addGradientGlow(shp:Shape,gArray:Array,gStrength:Number=2, dist:Number=0):Shape{
			//add glow to the shp and return
			var gradientGlow:GradientGlowFilter = new GradientGlowFilter(); 
			gradientGlow.distance = dist; 
			gradientGlow.angle = 45; 
			gradientGlow.colors = gArray;
			gradientGlow.alphas = [0, 1]; 
			gradientGlow.ratios = [0, 255]; 
			gradientGlow.blurX = 4; 
			gradientGlow.blurY = 4; 
			gradientGlow.strength = gStrength; 
			gradientGlow.quality = BitmapFilterQuality.HIGH; 
			gradientGlow.type = BitmapFilterType.OUTER; 
			shp.filters = [gradientGlow];
			return shp;
		}
		
		public static function addGlow(shp:Shape,gColor:uint,gAlpha:Number=1):Shape{
			//add glow to the shp and return
			var glow:GlowFilter = new GlowFilter(); 
			glow.color = gColor;
			glow.alpha = gAlpha;
			shp.filters = [glow];
			return shp;
		}		
		
		public static function addShadow(uic:UIComponent):UIComponent{
			//add glow to the shp and return
			var dsf:DropShadowFilter = new DropShadowFilter();
			uic.filters = [dsf];
			return uic;
		}
//		
//		public static function genDashedLine(startX:int,startY:int,lengthPx:Number,dashLengthPx:int,intervalPx:int):Array
//		{
//			var dashArray:Array = [];
//			var vCmds:Vector.<int> = new Vector.<int>();
//			var vData:Vector.<Number> = new Vector.<Number>();
//			// calculate number of dashed lines
//			var dashNumLen:int = Math.ceil(lengthPx/(dashLengthPx+intervalPx));
//			trace(dashNumLen);
//			var xCoord:int = startX; // culumative x coordinate
//			
//			//move pen to start point
//			vCmds.push(1);
//			vData.push(startX);
//			vData.push(startY);
//			
//			for(var i:int = 1; i <= dashNumLen; i++)
//			{
//				//draw to next pt
//				vCmds.push(2);
//				xCoord = xCoord+dashLengthPx;
//				if (xCoord > lengthPx) xCoord = lengthPx;
//				vData.push(xCoord);
//				vData.push(startY);
//				
//				//move pen interval to next draw pt
//				vCmds.push(1);
//				xCoord = xCoord + intervalPx;
//				vData.push(xCoord);
//				vData.push(startY);
//			}
//			// add vectors to array
//			dashArray[0] = vCmds;
//			dashArray[1] = vData;
//			return dashArray;
//		}
//		
		
		public static function pathtoDashedLine(path:GraphicsPath,dashlen:Number, gaplen:Number ):GraphicsPath
		{
			//input:a solid path
			//returns: a dashed path
			var inCmdsV:Vector.<int> = path.commands;
			var inCoordV:Vector.<Number> = path.data;
			var outCmdsV:Vector.<int> = new Vector.<int>();
			var outCoordV:Vector.<Number> = new Vector.<Number>();
			var rPath:GraphicsPath;
			//foreach command in the solid path
			for(var i:int = 0; i < inCmdsV.length; i++)
			{
				//if the command is "move", add to the return dashed path commands 
				if (inCmdsV[i]==1)
				{
					outCmdsV.push(1);
					outCoordV.push(inCoordV[i*2]);
					outCoordV.push(inCoordV[i*2 + 1]);
				}
				//if the command is "lineto", call the drawDashedLine to obtain the corresponding path 
				//and concatenate the return vactors with the  return dashed path vectors
				else if (inCmdsV[i]==2)
				{
					var returnArray:Array;
					if(i==0)
						returnArray= drawDashedLine(0,0,inCoordV[i*2],inCoordV[i*2 + 1],dashlen,gaplen);	
					else
						returnArray= drawDashedLine(inCoordV[i*2-2],inCoordV[i*2-1],inCoordV[i*2],inCoordV[i*2 + 1],dashlen,gaplen);
					outCmdsV = outCmdsV.concat(returnArray[0]);
					outCoordV = outCoordV.concat(returnArray[1]);
				}
				//TODO : If >3 or 0
			}
			//new dashed path
			rPath = new GraphicsPath(outCmdsV, outCoordV);
			return rPath;
		}
		
		
		public static function drawDashedLine(x1:Number, y1:Number, x2:Number,y2:Number,dashlen:Number, gaplen:Number): Array { 
			//Derived from : http://cookbooks.adobe.com/post_Creating_a_dashed_line_custom_border_with_dash_and-13286.html
			//input: point from and point to for the solid path, dash length and gap
			//returns: a array of vectors with commands and coords to draw corresponding dashed path
			var dashArray:Array = [];
			var vCmds:Vector.<int> = new Vector.<int>();
			var vData:Vector.<Number> = new Vector.<Number>();
			
			if((x1 != x2) || (y1 != y2)){
				var incrlen:Number = dashlen + gaplen;
				
				var len:Number = Math.sqrt((x1 - x2) * (x1 - x2) + (y1 -
					y2) * (y1 - y2));
				var angle:Number = Math.atan((y2 - y1) / (x2 - x1));
				var steps:uint = len / (dashlen + gaplen);
				
				var dashstepx:Number = dashlen * Math.cos(angle);
				if (x2 < x1) dashstepx *= -1;
				
				var dashstepy:Number = dashlen * Math.sin(angle);
				
				var gapstepx:Number = gaplen * Math.cos(angle);
				if (x2 < x1) gapstepx *= -1;
				
				var gapstepy:Number = gaplen * Math.sin(angle);
				var stepcount:uint = 0;
				
				while ((stepcount++) <= steps) {       
					var dashstartx:Number;
					var dashstarty:Number;
					var dashendx:Number;
					var dashendy:Number;
					
					if(x1 == x2 && y1 != y2){
						dashstartx = dashendx = x1;
						if(y2 > y1){
							dashstarty = y1 + ((stepcount-1) * (dashlen +
								gaplen));             
							dashendy = dashstarty + dashlen;
						}else{
							dashstarty = y1 - ((stepcount-1) * (dashlen +
								gaplen));             
							dashendy = dashstarty - dashlen;
						}
					}else if(y1 == y2 && x1 != x2){
						dashstarty = dashendy = y1;
						if(x2 > x1){
							dashstartx = x1 + ((stepcount-1) * (dashlen +
								gaplen));
							dashendx = dashstartx + dashlen;
						}else{
							dashstartx = x1 - ((stepcount-1) * (dashlen +
								gaplen));
							dashendx = dashstartx - dashlen;
						}
						if (dashendx > x2) dashendx = x2;
					}
					vCmds.push(1);
					vData.push(dashstartx);
					vData.push(dashstarty);
					vCmds.push(2);
					vData.push(dashendx);
					vData.push(dashendy);
				}
				
				dashArray[0] = vCmds;
				dashArray[1] = vData;
				
			}
			return dashArray;
		}

	}
}