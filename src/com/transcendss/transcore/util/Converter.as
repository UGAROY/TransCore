package com.transcendss.transcore.util
{
	
	public final class Converter
	{
		public static var PPI:int = 150;
		public static function scaleMileToPixel(distMi:Number,scale:Number):Number
		{
			
			if (distMi == 0) 
				return 0;
			
			var distIn:Number = (5280 * Math.abs(distMi)) * 12;
			var scalePerIn:Number =  Math.abs(scale) * 63360;
			var scaledPixels:Number = (distIn/scalePerIn) * PPI;
			
			if(distMi < 0) 
				scaledPixels = scaledPixels * -1;
			
			return scaledPixels;
		}
		
		public static function scalePixelToMile(pixels:Number,scale:Number):Number
		{	
			var scalePerIn:Number = (5280 * Math.abs(scale)) * 12;
			var distIn:Number = (pixels / PPI) * scalePerIn;
			var scaledMile:Number =  distIn / (5280 * 12);
			return scaledMile;
		}
		
		public static function scaleMeterToPixel(meters:Number,scale:Number):Number
		{
			if (meters == 0) 
				return 0;
			
			var distIn:Number = 39.3700787 * meters;
			var scaledPixels:Number = (distIn / scale) * PPI;
			
			if (meters < 0) 
				scaledPixels = scaledPixels * -1;
			
			return scaledPixels;
		}
		
		public static function meterToMiles(meters:Number):Number
		{
			if (meters == 0) 
				return 0;
			
			var distMi:Number = meters/1609.344;  
			
			return distMi;
		}
		
		public static function kmeterToMiles(kmeters:Number):Number
		{
			if (kmeters == 0) 
				return 0;
			
			// 1 meter = 0.000621371192 miles
			var distMi:Number = kmeters/1.609344 ;  
			
			return distMi;
		}
		
		public static function mileToKMeter(mile:Number):Number
		{
			if (mile == 0) 
				return 0;
			// 1 meter = 0.000621371192 miles
			
			var distMi:Number = mile * 1.609344;  
			return distMi;
		}
		
		public static function feetToMiles(feet:Number):Number
		{
			if (feet == 0) 
				return 0;
			
			var distMi:Number = feet / 5280;  
			return distMi;
		}
		
		public static function mileToFeet(mile:Number):Number
		{
			if (mile == 0) 
				return 0;
			
			var distMi:Number = mile * 5280;
			return distMi;
		}
		
		public static function milesToMeters(miles:Number):Number
		{
			if (miles == 0) 
				return 0;
			
			// 1 meter = 0.000621371192 miles
			var distMeters:Number = miles * 1609.344;  
			return distMeters;
		}		
		
		public static function inchesToPixels(screenDPI:Number, inches:Number):uint
		{
			return Math.round(screenDPI * inches);
		}
		
		public static function roundDec(numIn:Number, decimalPlaces:int):Number 
		{
			var nExp:int = Math.pow(10,decimalPlaces) ; 
			var nRetVal:Number = Math.round(numIn * nExp) / nExp
			return nRetVal;
		}
		
		public static function convertToMile(measure:Number, unit:Number):Number
		{
			switch (unit)
			{
				case Units.FEET:
					return feetToMiles(measure);
				case Units.METER:
					return meterToMiles(measure);
				case Units.KILOMETER:
					return kmeterToMiles(measure);
				case Units.MILE:
					return measure;
				case Units.COUNTYMILE:
					return measure;
			}
			return -1;	
		}
		
		public static function convertFromMile(measure:Number, unit:Number):Number
		{
			switch (unit)
			{
				case Units.FEET:
					return mileToFeet(measure);
				case Units.METER:
					return milesToMeters(measure);
				case Units.KILOMETER:
					return mileToKMeter(measure);
				case Units.MILE:
					return measure;
				case Units.COUNTYMILE:
					return measure;
			}
			return -1;	
		}
		
	}
}