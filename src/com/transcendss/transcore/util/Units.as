package com.transcendss.transcore.util
{
	public final class Units
	{
		
		public static const MILE:int = 1;
		public static const KILOMETER:int = 2;
		public static const COUNTYMILE:int = 3;
		public static const FEET:int = 4;
		public static const METER:int = 5;
		
		
		public static const MILE_LABEL:String = "MI";
		public static const KILOMETER_LABEL:String = "KM";
		public static const COUNTYMILE_LABEL:String = "CM";
		public static const FEET_LABEL:String = "FT";
		public static const METER_LABEL:String = "M";
		
		public static function getLabelByUnit(unit:int):String{
			switch(unit)
			{
				case MILE:
					return MILE_LABEL;
				case KILOMETER:
					return KILOMETER_LABEL;
				case COUNTYMILE:
					return COUNTYMILE_LABEL;
				case FEET:
					return FEET_LABEL;
				case METER:
					return METER_LABEL;
			}
			return "";
		}
	}
}