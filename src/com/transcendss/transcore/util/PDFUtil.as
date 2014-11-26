package com.transcendss.transcore.util
{
		import flash.geom.Rectangle;
		import flash.net.FileReference;
		import flash.utils.ByteArray;
		
		import org.alivepdf.colors.Color;
		import org.alivepdf.colors.RGBColor;
		import org.alivepdf.drawing.DashedLine;
		import org.alivepdf.pdf.PDF;
		import org.alivepdf.saving.Method;
		
		public class PDFUtil
		{
			private var printPDF:PDF;
			private var cHeight:Number;
			private var cWidth:Number;
			private var pHeight:Number;
			private var pWidth:Number;
			private var hMargin:Number;
			private var vMargin:Number;
			private var inchesPerPixelH:Number;
			private var inchesPerPixelW:Number;
			private var component:Number;
			
			public function PDFUtil(pdf:PDF, cheight:Number, cwidth:Number, pheight:Number, pwidth:Number, hmargin:Number, vmargin:Number)
			{
				cWidth = cwidth;
				printPDF = pdf;
				cHeight = cheight;
				pHeight = pheight;
				pWidth = pwidth;
				hMargin = hmargin;
				vMargin = vmargin;
				
				inchesPerPixelH = pHeight / cHeight;
				inchesPerPixelW = pWidth / cWidth;
			}
			
			//Convert pixel y locations to printed page inches
			public function getYinPageInches(y:Number):Number
			{
				return (y * inchesPerPixelH) + vMargin;
			}
			
			
			//Convert pixel x locations to printed page inches
			public function getXinPageInches(x:Number):Number
			{
				return (x * inchesPerPixelW) + hMargin;
			}
			

			
			public function drawLineToPDF(beginX:Number, beginY:Number, endX:Number, endY:Number, thickness:Number, color:String, dashed:Boolean = false):void
			{
				var arr:Array= new Array("-");
				if(dashed)
					this.printPDF.lineStyle(RGBColor.hexStringToRGBColor(color),thickness,0,1,"NonZeroWinding","Normal", new DashedLine ([0, 1, 2, 9]));
				else
					this.printPDF.lineStyle(RGBColor.hexStringToRGBColor(color),thickness,0,1);
				this.printPDF.moveTo(this.getXinPageInches(beginX), this.getYinPageInches(beginY));
				this.printPDF.lineTo(this.getXinPageInches(endX),this.getYinPageInches(endY));
				this.printPDF.end();	
			}
			
			public function drawCircleToPDF(x:Number, y:Number, radius:Number, thickness:Number, lineColor:String, fillColor:String):void
			{	
				this.printPDF.lineStyle(RGBColor.hexStringToRGBColor(lineColor),thickness,0,1);
				if (fillColor != null) {
					this.printPDF.beginFill(RGBColor.hexStringToRGBColor(fillColor));
				}
				this.printPDF.drawCircle(this.getXinPageInches(x), this.getYinPageInches(y),radius * inchesPerPixelH);
				this.printPDF.endFill();
				this.printPDF.end();	
			}
			
			public function drawRectToPDF(beginX:Number, beginY:Number, width:Number, height:Number, thickness:Number, lineColor:String, fillColor:String):void
			{
				this.printPDF.lineStyle(RGBColor.hexStringToRGBColor(lineColor),thickness,0,1);
				if (fillColor != null) {
					this.printPDF.beginFill(RGBColor.hexStringToRGBColor(fillColor));
				}
				var rect:Rectangle = new Rectangle(this.getXinPageInches(beginX), this.getYinPageInches(beginY), width * inchesPerPixelW, height * inchesPerPixelH);
				this.printPDF.drawRect(rect);
				this.printPDF.endFill();
				this.printPDF.end();
			}
			
			public function drawTextToPDF(font:String, size:Number, txt:String, x:Number, y:Number, rotation:Number, textColor:String):void
			{
				if (rotation == -90)
					x = x + (size * 2.7);
				if (rotation == 0)
					y = y + (size * 2.7);
				
				this.printPDF.startTransform();
				this.printPDF.textStyle(RGBColor.hexStringToRGBColor(textColor));
				this.printPDF.setFont(font, "", size);
				this.printPDF.rotate(rotation, this.getXinPageInches(x), this.getYinPageInches(y));
				this.printPDF.addText(txt, this.getXinPageInches(x), this.getYinPageInches(y));
				this.printPDF.stopTransform();
				this.printPDF.end();
			}
			
			public function drawArrowToPDF(beginX:Number, beginY:Number, endX:Number, endY:Number, headLength:Number, headWidth:Number,
										   direction:String, thickness:Number, lineColor:String, fillColor:String):void
			{
				var x1:Number = this.getXinPageInches(beginX);
				var x2:Number = this.getXinPageInches(endX);
				var y1:Number = this.getYinPageInches(beginY);
				var y2:Number = this.getYinPageInches(endY);
				
				this.printPDF.lineStyle(RGBColor.hexStringToRGBColor("0x000000"),.0001,0,1);
				this.printPDF.moveTo(x1,y1);
				this.printPDF.lineTo(x2,y2);
				
				
				if (fillColor != null)
				{
					this.printPDF.beginFill(RGBColor.hexStringToRGBColor(fillColor));
				}
				var headArray:Array = new Array();
				headArray[0] = this.getXinPageInches(endX);
				headArray[1] = this.getYinPageInches(endY);
				
				if (direction == "L" || direction == "R")
				{
					if (direction == "L")
					{
						headLength = -headLength;
					}
					
					headArray[2] = this.getXinPageInches(endX - headLength);
					headArray[3] = this.getYinPageInches(endY - headWidth/2);
					headArray[4] = this.getXinPageInches(endX - headLength);
					headArray[5] = this.getYinPageInches(endY + headWidth/2);
					this.printPDF.drawPolygone(headArray);
				} else if (direction == "U" || direction == "D")
				{
					if (direction == "U") {
						headLength = -headLength;
					}
					headArray[2] = this.getXinPageInches(endX - headWidth/2);
					headArray[3] = this.getYinPageInches(endY - headLength);
					headArray[4] = this.getXinPageInches(endX + headWidth/2);
					headArray[5] = this.getYinPageInches(endY - headLength);
					this.printPDF.drawPolygone(headArray);
				} else if (direction == "UR" || direction == "LL")
				{
					//only draws 45 degree angle
					if (direction == "LL") {
						headLength = -headLength;
					}
					headArray[2] = this.getXinPageInches((endX - headLength) - headWidth/2);
					headArray[3] = this.getYinPageInches((endY + headLength) - headWidth/2);
					headArray[4] = this.getXinPageInches((endX - headLength) + headWidth/2);
					headArray[5] = this.getYinPageInches((endY + headLength) + headWidth/2);
					this.printPDF.drawPolygone(headArray);
				} else if (direction == "UL" || direction == "LR")
				{
					//only draws 45 degree angle
					if (direction == "LR") {
						headLength = -headLength;
					}
					headArray[2] = this.getXinPageInches((endX + headLength) - headWidth/2);
					headArray[3] = this.getYinPageInches((endY + headLength) + headWidth/2);
					headArray[4] = this.getXinPageInches((endX + headLength) + headWidth/2);
					headArray[5] = this.getYinPageInches((endY + headLength) - headWidth/2);
					this.printPDF.drawPolygone(headArray);
				}
				
				this.printPDF.endFill();
				this.printPDF.end();
			}
			
			public function drawRoundRectToPDF(beginX:Number, beginY:Number, width:Number, height:Number, curveWidth:Number, thickness:Number, lineColor:String, fillColor:String):void
			{
				this.printPDF.lineStyle(RGBColor.hexStringToRGBColor(lineColor),thickness,0,1);
				if (fillColor != null) {
					this.printPDF.beginFill(RGBColor.hexStringToRGBColor(fillColor));
				}
				var rect:Rectangle = new Rectangle(this.getXinPageInches(beginX), this.getYinPageInches(beginY), (width * inchesPerPixelW), (height * inchesPerPixelH));
				this.printPDF.drawRoundRect(rect,curveWidth);
				this.printPDF.endFill();
				this.printPDF.end();
			}
			
			public function drawCurveToPDF(beginX:Number, beginY:Number,contX1:Number, contY1:Number, contX2:Number, contY2:Number, endX:Number, endY:Number, thickness:Number, lineColor:String, fillColor:String):void
			{
				this.printPDF.lineStyle(RGBColor.hexStringToRGBColor(lineColor),thickness,0,1);
				if (fillColor != null) {
					this.printPDF.beginFill(RGBColor.hexStringToRGBColor(fillColor));
				}
				this.printPDF.moveTo(this.getXinPageInches(beginX), this.getYinPageInches(beginY));
				this.printPDF.curveTo(this.getXinPageInches(contX1),this.getYinPageInches(contY1),this.getXinPageInches(contX2),this.getYinPageInches(contY2),this.getXinPageInches(endX),this.getYinPageInches(endY));
				
				this.printPDF.end();
				
				if (fillColor == null) {
					this.printPDF.lineStyle(RGBColor.hexStringToRGBColor("0xFFFFFF"),thickness*100,0,1);
					this.printPDF.moveTo(this.getXinPageInches(beginX), this.getYinPageInches(beginY));
					this.printPDF.lineTo(this.getXinPageInches(endX),this.getYinPageInches(endY));
					this.printPDF.end();
				}
				this.printPDF.endFill();
			}
			
			public function print():void
			{
				var bytes:ByteArray = this.printPDF.save(Method.LOCAL);
				var f:FileReference = new FileReference();
				f.save(bytes,"sld.pdf");
			}
		}
	}