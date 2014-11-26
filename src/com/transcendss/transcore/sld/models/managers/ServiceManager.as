package com.transcendss.transcore.sld.models.managers
{
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	public class ServiceManager
	{
		public var dispatcher:IEventDispatcher;
		
		
		
		public function ServiceManager()
		{
		}
		
		public function onServiceResult(Obj:Object, event:Event):ArrayCollection
		{
			event.stopPropagation();
			var rawData:String = String(Obj);
			//trace("Sample Data: " + rawData);
			//if (rawData.indexOf("[{\"X\"") > 0)
				//FlexGlobals.topLevelApplication.rawCoords = rawData;
			var ac:ArrayCollection = new ArrayCollection();
			if (rawData.length >0)
			{
			//decode the data to ActionScript using the JSON API
			//in this case, the JSON data is a serialize Array of Objects.
				var arr:Array = (JSON.parse(rawData)) as Array;
				
				ac = new ArrayCollection(arr);
				
				
			}
			return ac;
		}
		
		
		
		
		
		public function onServiceObjResult(Obj:Object, event:Event):Object
		{
			event.stopPropagation();
			var rawData:String = String(Obj);
			
			
			if (rawData.length >0)
			{
				//decode the data to ActionScript using the JSON API
				//in this case, the JSON data is an Object.
				var obj:Object = JSON.parse(rawData);
				return obj;
				
				
				
			}
			return null;
		}
		
		public function MaterialResult(Obj:Object, event:Event):Object
		{
			event.stopPropagation();
			var rawData:String = String(Obj);
		//	var data:Object = (JSON.parse(rawData));
			
			return rawData;
			
		}
	}
}