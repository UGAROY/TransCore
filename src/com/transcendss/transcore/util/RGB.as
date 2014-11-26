package com.transcendss.transcore.util
{
	import flash.geom.ColorTransform;
	
	public class RGB
	{
			//r the red channel
			public var r:uint;
			//the green channel
			public var g:uint;
			//the blue channel
			public var b:uint;
			
			/**
			 * RGB class stores a color as rgb values and allows one to output that value in various formats
			 * @param r the red channel
			 * @param g the green channel
			 * @param b the blue channel
			 * 
			 */
			public function RGB(r:uint = 0, g:uint = 0, b:uint = 0)
			{
				this.r = r;
				this.g = g;
				this.b = b;
			}
			/**
			 * sets the RGB value based on a hex/oct value hex as uint 
			 * @param hex the hex/oct value of the RGB object.
			 * 
			 */
			public function setByHex(hex:uint):void{ 
				var colorTransform:ColorTransform = new ColorTransform();
				colorTransform.color = hex;
				r = colorTransform.redOffset;
				g = colorTransform.greenOffset;
				b = colorTransform.blueOffset;
			}
			
			/**
			 * gets the octal value of the RGB object as a string 
			 * @return the octal value of the RGB object as a string
			 * 
			 */
			public function getOctalString():String{
				
				
				return "0x"+getRGBHex();
			}
			/**
			 * gets the hex/oct value of the RGB object as uint 
			 * @return the hex/oct value of the RGB object as uint 
			 * 
			 */
			public function getUint():uint{
				var colorTransform:ColorTransform = new ColorTransform();
				
				colorTransform.redOffset = r;
				colorTransform.greenOffset = g;
				colorTransform.blueOffset = b;
				
				return colorTransform.color;
			}
			/**
			 * gets the 6 character string representing the RGB
			 * @return a 6 character string representing the RGB
			 * 
			 */
			public function getRGBHex():String{
				var hexStr:String = RGB._convertChannelToHexStr(r)+RGB._convertChannelToHexStr(g)+RGB._convertChannelToHexStr(b);
				var strLength:uint;
				
				strLength = hexStr.length;
				if (strLength < 6){
					for (var j:uint; j < (6-strLength); j++){
						hexStr += "0";
					}
					
				}
				
				return hexStr;
			}
			
			/**
			 * gets a 6 character string representing the RGB
			 * @param hex RGB hex/oct value as uint
			 * @return a 6 character string representing the RGB hex/oct value in inputed in uint for as hex
			 * 
			 */
			public static function uintToRGBHex(hex:uint):String{
				var colorTransform:ColorTransform = new ColorTransform();
				colorTransform.color = hex;
				var rgb:RGB = new RGB(colorTransform.redOffset, colorTransform.greenOffset, colorTransform.blueOffset);
				return rgb.getRGBHex();
			}
			
			/**
			 * converts the uint chanel representation of a color to a hex string 
			 * @param hex
			 * @return the string representation of the hex, this does not return the RGB format of a hex 
			 *              like 00ff00 use uintToRGBHex getting a string that is always 6  characters long
			 */
			private static function _convertChannelToHexStr(hex:uint):String {
				if (hex > 255){
					hex = 255;
					//trace("hex val overloaded");
				}
				
				var hexStr:String = hex.toString(16);
				
				if (hexStr.length < 2){
					hexStr = "0"+hexStr;
				}
				return hexStr;
			}

	}
}