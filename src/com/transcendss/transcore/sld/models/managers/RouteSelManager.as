package com.transcendss.transcore.sld.models.managers
{
	import com.transcendss.transcore.events.RouteSelectorEvent;
	
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	public class RouteSelManager
	{
		public var dispatcher:IEventDispatcher;
		
		public function RouteSelManager()
		{
		}
		
		public function setRouteList(arrayColl:ArrayCollection, event:RouteSelectorEvent):void
		{
			
			var rcEvent:RouteSelectorEvent = new RouteSelectorEvent(RouteSelectorEvent.ROUTE_LIST_READY, event.route, event.scale);
			if(BaseConfigUtility.getBool("route_sort_on"))
			{
				//Create the sort field			
				var dataSortField2:SortField = new SortField();
				
				//name of the field of the object on which you wish to sort the Collection			
				dataSortField2.name = "num";
				dataSortField2.numeric = true;		
				
				//create the sort object
				var dataSort:Sort = new Sort();
				dataSort.fields = [dataSortField2];
				var tempArrayColl1:ArrayCollection = new ArrayCollection();
				var tempArrayColl2:ArrayCollection = new ArrayCollection();
				var tempArrayColl3:ArrayCollection = new ArrayCollection();
				var finalArrayColl:ArrayCollection = new ArrayCollection();
				
				for(var i:int=0;i<arrayColl.length;i++)
				{
					var temprt:Array;
					temprt = arrayColl[i].ROUTE_NAME.toString().split(" ");
					
					arrayColl[i].num = parseInt(temprt[1]);
					
					switch(temprt[0])
					{
						case "I":
							tempArrayColl1.addItem(arrayColl[i]);
							break;
						case "US":
							tempArrayColl2.addItem(arrayColl[i]);
							break;
						case "IA":
						case "SR":
							tempArrayColl3.addItem(arrayColl[i]);
							break;
					}
				}
				
				tempArrayColl1.sort = dataSort;
				tempArrayColl2.sort = dataSort;
				tempArrayColl3.sort = dataSort;
				tempArrayColl1.refresh();
				tempArrayColl2.refresh();
				tempArrayColl3.refresh(); 
				
				for each (var object:Object in tempArrayColl1){
					finalArrayColl.addItem(object);
				}						
				for each (var object2:Object in tempArrayColl2)
				finalArrayColl.addItem(object2);
				for each (var object3:Object in tempArrayColl3)
				finalArrayColl.addItem(object3);
				//arrayColl.sort = dataSort;
				//arrayColl.refresh();
				rcEvent.dataProviderAC =  finalArrayColl;
			}
			else
				rcEvent.dataProviderAC = arrayColl;
			
			event.stopPropagation();
			dispatcher.dispatchEvent(rcEvent);
		}
		public function setMinMax(arrayColl:ArrayCollection):void
		{
			var rcEvent:RouteSelectorEvent = new RouteSelectorEvent(RouteSelectorEvent.MIN_MAX_READY);
			rcEvent.dataProviderAC =  arrayColl;
			dispatcher.dispatchEvent(rcEvent);
		}
		
	}
}