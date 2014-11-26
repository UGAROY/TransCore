package com.transcendss.transcore.sld.models.managers
{
	
	import com.transcendss.transcore.sld.models.components.NearestBaseAsset;
	
	import mx.collections.ArrayCollection;
	
	
	public class LRMManager
	{
		
		public function LRMManager()
		{
		}
		
		//returns the nearest milepost to a milepoint with its offset
		public function milepostToMilepointPlusOffset(milepost:Number, assetType:String , assetColl:ArrayCollection):NearestBaseAsset
		{
			
			var baseAssetArray:ArrayCollection = assetColl ;
			var left:int = 0;
			var right:int ;
//			var left:int;
//			var right:int;
			var middle:int;
			var nearestBaseAsset:NearestBaseAsset = new NearestBaseAsset();
			var order:String ="";
			nearestBaseAsset.milepost = milepost;
			right = baseAssetArray.length - 1
			
			
			if(milepost <=  new Number(baseAssetArray[left].invProperties[baseAssetArray[left].valueKey].value))
			{
				var leftValue:Number = new Number(baseAssetArray[left].invProperties[baseAssetArray[left].valueKey].value);
				nearestBaseAsset.baseAsset = baseAssetArray[left];
				nearestBaseAsset.milepoint = new Number(nearestBaseAsset.baseAsset.invProperties[nearestBaseAsset.baseAsset.fromMeasureColName].value);
				
				nearestBaseAsset.offsetMiles =  milepost - leftValue;
				nearestBaseAsset.milepost = new Number(baseAssetArray[left].invProperties[baseAssetArray[left].valueKey].value) + nearestBaseAsset.offsetMiles;

			}	
			else if(milepost >=  new Number(baseAssetArray[right].invProperties[baseAssetArray[right].valueKey].value))
			{
				var rightValue:Number = new Number(baseAssetArray[right].invProperties[baseAssetArray[right].valueKey].value);
				nearestBaseAsset.baseAsset = baseAssetArray[right];
				nearestBaseAsset.milepoint = new Number(nearestBaseAsset.baseAsset.invProperties[nearestBaseAsset.baseAsset.fromMeasureColName].value);
				
//				nearestBaseAsset.milepost =rightValue;
				
				nearestBaseAsset.offsetMiles =   milepost- rightValue  ;
				nearestBaseAsset.milepost =new Number(baseAssetArray[right].invProperties[baseAssetArray[right].valueKey].value) + nearestBaseAsset.offsetMiles;
				
			}
			else
			{
				left = 0;
				right = baseAssetArray.length - 1;
				while(left < right - 1)
				{
					middle = (left + right)/2;
					if(milepost == new Number(baseAssetArray[middle].invProperties[baseAssetArray[middle].valueKey].value))
					{
						nearestBaseAsset.baseAsset = baseAssetArray[middle];
						nearestBaseAsset.milepoint = new Number(nearestBaseAsset.baseAsset.invProperties[nearestBaseAsset.baseAsset.fromMeasureColName].value);
						nearestBaseAsset.offsetMiles =  milepost -new Number(baseAssetArray[middle].invProperties[baseAssetArray[middle].valueKey].value);
						nearestBaseAsset.milepost =new Number(baseAssetArray[middle].invProperties[baseAssetArray[middle].valueKey].value);
						break;
					}
					else if(milepost < new Number(baseAssetArray[middle].invProperties[baseAssetArray[middle].valueKey].value))
						right  = middle;
					else
						left = middle;
				}
				if(nearestBaseAsset.baseAsset == null)
				{
					
					
					nearestBaseAsset.baseAsset =baseAssetArray[right];
					
					nearestBaseAsset.milepoint = new Number(nearestBaseAsset.baseAsset.invProperties[nearestBaseAsset.baseAsset.fromMeasureColName].value);
					nearestBaseAsset.offsetMiles =  milepost - nearestBaseAsset.milepoint;
					nearestBaseAsset.milepost = nearestBaseAsset.milepoint+  nearestBaseAsset.offsetMiles;
				}
			}
			return nearestBaseAsset;
		}
		
		
		public function milepointToMilepostPlusOffset(milepoint:Number, assetType:String , baseAssetArray:ArrayCollection):Number
		{
			
			//var baseAssetArray:ArrayCollection = new ArrayCollection();
			var order:String = "";
							
			var left:int = 0;
			var right:int = baseAssetArray.length - 1;
			var middle:int;
			
			
			
			
			if(baseAssetArray == null || baseAssetArray.length == 0 )
			{
				return 0;
				
			}
			else if(milepoint ==  new Number(baseAssetArray[left].invProperties[baseAssetArray[left].fromMeasureColName].value))
			{
				return new Number(baseAssetArray[left].invProperties[baseAssetArray[left].valueKey].value);
			}	
			else if(milepoint ==  new Number(baseAssetArray[right].invProperties[baseAssetArray[right].fromMeasureColName].value))
			{
				return new Number(baseAssetArray[right].invProperties[baseAssetArray[right].valueKey].value);
			}
			else if(milepoint < new Number(baseAssetArray[left].invProperties[baseAssetArray[left].fromMeasureColName].value))
			{
				var offset1:Number = new Number(baseAssetArray[left].invProperties[baseAssetArray[left].fromMeasureColName].value) - milepoint;
				var returnVal:Number =  new Number(baseAssetArray[left].invProperties[baseAssetArray[left].valueKey].value)- offset1;
				if(returnVal>0)
					return returnVal;
				else
					return 0;
				
			}	
			else if(milepoint >  new Number(baseAssetArray[right].invProperties[baseAssetArray[right].fromMeasureColName].value))
			{
				var offset2:Number = new Number(baseAssetArray[right].invProperties[baseAssetArray[right].fromMeasureColName].value)-milepoint;
				var returnVal2:Number =  new Number(baseAssetArray[right].invProperties[baseAssetArray[right].valueKey].value)- offset2;
				if(returnVal2>0)
					return returnVal2;
				else
					return 0;				
			}
			
			else
			{
				
				
				while(left < right - 1)
				{
					
					middle = (left + right)/2;
										
					if(milepoint ==new Number(baseAssetArray[middle].invProperties[baseAssetArray[middle].fromMeasureColName].value))
					{
						return new Number(baseAssetArray[middle].invProperties[baseAssetArray[middle].valueKey].value);
					}
					else if(milepoint < new Number(baseAssetArray[middle].invProperties[baseAssetArray[middle].valueKey].value))
						right  = middle;
					else
						left = middle;
				}
				
				var leftrefpt:Number = new Number(baseAssetArray[left].invProperties[baseAssetArray[left].fromMeasureColName].value);
				var rightrefpt:Number = new Number(baseAssetArray[right].invProperties[baseAssetArray[right].fromMeasureColName].value);
				var leftmilepost:Number = new Number(baseAssetArray[left].invProperties[baseAssetArray[left].valueKey].value);
				var rightmilepost:Number = new Number(baseAssetArray[right].invProperties[baseAssetArray[right].valueKey].value);
				
					
				var val:Number = ((milepoint - leftrefpt) * (rightmilepost - leftmilepost) )/ (rightrefpt- leftrefpt);
				return leftmilepost + val ;
				
			}
			
		}
		
		
		public function nearestBaseAssetToMilePoint(location:NearestBaseAsset):Number
		{
			return location.baseAsset.invProperties[location.baseAsset.fromMeasureColName].value;
		}
		
		
		
	}
}