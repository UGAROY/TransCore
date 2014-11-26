package com.transcendss.transcore.sld.models.components
{
	
	import com.transcendss.transcore.sld.models.components.BaseAsset;
	public class NearestBaseAsset
	{
		public var milepoint:Number;
		public var baseAsset:BaseAsset = null;
		public var offsetMiles:Number;
		public var milepost:Number;
		
		public function NearestBaseAsset()
		{
		}
		
		public function getOffsetMeters():Number
		{
			return offsetMiles * 1609.34;	
		}
		
		public function getOffsetFeet():Number
		{
			return offsetMiles * 5280;	
		}
	}
}