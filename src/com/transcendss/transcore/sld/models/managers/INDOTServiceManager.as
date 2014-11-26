package com.transcendss.transcore.sld.models.managers
{
	import com.transcendss.transcore.events.*;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	public class INDOTServiceManager
	{
		public var dispatcher:IEventDispatcher;
		
		
		public function INDOTServiceManager()
		{
		}
		
		public function onRouteListResult(obj:Object,event:Event):ArrayCollection
		{
			var arrayColl:ArrayCollection = new ArrayCollection();
			event.stopPropagation();
			var arr:Array = parseJsonObj(obj);
			for each(var arrItem:Object in arr)
			{
				arrayColl.addItem({ "ROUTE_NAME" : arrItem.attributes.ROUTEID, "ROUTE_FULL_NAME":arrItem.attributes.ROUTENAME});
			}
			return arrayColl;
		}
		

		public function onMinMaxResult(obj:Object,event:Event):ArrayCollection
		{
			//[{"MIN":"0","MAX":"151.80"}]
			event.stopPropagation();
			
			var arrayColl:ArrayCollection = new ArrayCollection();
			var min:String="";
			var max:String="";
			
			var arr:Array = parseJsonObj(obj);
			
			arrayColl.addItem({ "MIN" : arr[0].attributes.MEASURE, "MAX" : arr[1].attributes.MEASURE});
			
			return arrayColl;
		}
		
		public function onAttrResult(obj:Object,event:AttributeEvent):ArrayCollection
		{
			//[{"MIN":"0","MAX":"151.80"}]
			event.stopPropagation();
			
			var arrayColl:ArrayCollection = new ArrayCollection();
			
			var atName:String="";
			var arr:Array = parseJsonObj(obj);
			var dataArr:Array = new Array();
			for each(var arrItem:Object in arr)
			{
				switch(event.attrType)
				{
					case "1":
						dataArr.push({ "ROUTE_NAME" : arrItem.attributes.ROUTEID, "ROUTE" : arrItem.attributes.ROUTEID,"REFPT":arrItem.attributes.FROMMEASURE ,"ENDREFPT": arrItem.attributes.TOMEASURE,"ELEM_VALUE":arrItem.attributes.SPEED_LIMIT,"ID":arrItem.attributes.OBJECTID});
						atName = "Speed Limit";
						break;
					case "2":
						dataArr.push({ "ROUTE_NAME" : arrItem.attributes.ROUTEID, "ROUTE" : arrItem.attributes.ROUTEID,"REFPT":arrItem.attributes.FROMMEASURE ,"ENDREFPT": arrItem.attributes.TOMEASURE,"ELEM_VALUE":arrItem.attributes.HNO_PEAK_LANES,"ID":arrItem.attributes.OBJECTID});
						atName = "Peak Lanes";
						break;
					case "3":
						dataArr.push({ "ROUTE_NAME" : arrItem.attributes.ROUTEID, "ROUTE" : arrItem.attributes.ROUTEID,"REFPT":arrItem.attributes.FROMMEASURE ,"ENDREFPT": arrItem.attributes.TOMEASURE,"ELEM_VALUE":arrItem.attributes.FUNC_CLASS_2010,"ID":arrItem.attributes.OBJECTID});
						atName = "Functional Class";
						break;
					case "4":
						dataArr.push({ "ROUTE_NAME" : arrItem.attributes.ROUTEID, "ROUTE" : arrItem.attributes.ROUTEID,"REFPT":arrItem.attributes.FROMMEASURE ,"ENDREFPT": arrItem.attributes.TOMEASURE,"ELEM_VALUE":arrItem.attributes.HPREVAIL_TYPE_SIGNAL,"ID":arrItem.attributes.OBJECTID});
						atName = "Signal Type";
						break;
					
					case "5":
						dataArr.push({ "ROUTE_NAME" : arrItem.attributes.ROUTEID, "ROUTE" : arrItem.attributes.ROUTEID,"REFPT":arrItem.attributes.FROMMEASURE ,"ENDREFPT": arrItem.attributes.TOMEASURE,"ELEM_VALUE":arrItem.attributes.HTYPE_TERRAIN,"ID":arrItem.attributes.OBJECTID});
						atName = "Terrain Type";
						break;
					
				}
			}
			dataArr.sortOn("REFPT", Array.NUMERIC);
			arrayColl.addItem({"ID":event.attrType, "ATT_NAME": atName, "DATA" : dataArr});
			return arrayColl;
		}
		
		public function onLatLongResult(obj:Object,event:Event):ArrayCollection
		{
			var arrayColl:ArrayCollection = new ArrayCollection();
			event.stopPropagation();
			var arr:Array = parseJsonObj(obj);
			for each(var arrItem:Object in arr)
			{
				var coords:Array = arrItem.geometry.paths[0] as Array;
				for each(var coord:Array in coords)
				{
					arrayColl.addItem({ "X" : String(coord[0]) , "Y" : String(coord[1])});
				}
			}
			return arrayColl;
		}
		
		public function onElementResult(obj:Object,event:ElementEvent):ArrayCollection
		{
			//[{"MIN":"0","MAX":"151.80"}]
			event.stopPropagation();
			
			var arrayColl:ArrayCollection = new ArrayCollection();
			
			var atName:String="";
			var arr:Array = parseJsonObj(obj);
			var dataArr:Array = new Array();
			for each(var arrItem:Object in arr)
			{
				switch(event.elementType)
				{
					case "1":
						dataArr.push({ "ROUTE_NAME" : arrItem.attributes.ROUTEID, "ROUTE" : arrItem.attributes.ROUTEID,"REFPT":arrItem.attributes.FROMMEASURE ,"ENDREFPT": arrItem.attributes.TOMEASURE,"ELEM_VALUE":arrItem.attributes.SPEED_LIMIT,"ID":arrItem.attributes.OBJECTID});
						atName = "Speed Limit";
						break;
					case "2":
						dataArr.push({ "ROUTE_NAME" : arrItem.attributes.ROUTEID, "ROUTE" : arrItem.attributes.ROUTEID,"REFPT":arrItem.attributes.FROMMEASURE ,"ENDREFPT": arrItem.attributes.TOMEASURE,"ELEM_VALUE":arrItem.attributes.HNO_PEAK_LANES,"ID":arrItem.attributes.OBJECTID});
						atName = "Peak Lanes";
						break;
					case "3":
						dataArr.push({ "ROUTE_NAME" : arrItem.attributes.ROUTEID, "ROUTE" : arrItem.attributes.ROUTEID,"REFPT":arrItem.attributes.FROMMEASURE ,"ENDREFPT": arrItem.attributes.TOMEASURE,"ELEM_VALUE":arrItem.attributes.FUNC_CLASS_2010,"ID":arrItem.attributes.OBJECTID});
						atName = "Functional Class";
						break;
					case "4":
						dataArr.push({ "ROUTE_NAME" : arrItem.attributes.ROUTEID, "ROUTE" : arrItem.attributes.ROUTEID,"REFPT":arrItem.attributes.FROMMEASURE ,"ENDREFPT": arrItem.attributes.TOMEASURE,"ELEM_VALUE":arrItem.attributes.HPREVAIL_TYPE_SIGNAL,"ID":arrItem.attributes.OBJECTID});
						atName = "Signal Type";
						break;

					case "5":
						dataArr.push({ "ROUTE_NAME" : arrItem.attributes.ROUTEID, "ROUTE" : arrItem.attributes.ROUTEID,"REFPT":arrItem.attributes.FROMMEASURE ,"ENDREFPT": arrItem.attributes.TOMEASURE,"ELEM_VALUE":arrItem.attributes.HTYPE_TERRAIN,"ID":arrItem.attributes.OBJECTID});
						atName = "Terrain Type";
						break;
					
				}
			}
			dataArr.sortOn("REFPT", Array.NUMERIC);
	        arrayColl.addItem({"ID":event.elementType, "ATT_NAME": atName, "DATA" : dataArr});
			return arrayColl;
		}
		
		//{"ID":"190894","REFPT":"1.40688995","FEATURE_NAME":"I 29 N TO IA 333 E"}
		//{"ROUTE":"130244","ROUTE_NAME":"I 29 N","REFPT":"0.00093996","ENDREFPT":"0.03817641","ELEM_VALUE":"554808","ID":"24990"} element sample
		
		public function onFeatureResult(obj:Object, event:FeatureEvent):ArrayCollection
		{
			//[{"MIN":"0","MAX":"151.80"}]
			event.stopPropagation();
			
			var arrayColl:ArrayCollection = new ArrayCollection();
			
			var atName:String="";
			var arr:Array = parseJsonObj(obj);
			var dataArr:Array = new Array();
			for each(var arrItem:Object in arr)
			{
				switch(event.featureName)
				{
					case "BRDG":
						dataArr.push({ "REFPT":arrItem.attributes.Measure, "FEATURE_NAME":arrItem.attributes.IIT_DESCR,"ID":arrItem.attributes.OBJECTID, "FEATURE_LENGTH":arrItem.attributes.Distance});
						break;
					//{"id":"236364","refpt":"0","feature_name":"0","mutcd":"D10","route_name":"I 35 N"}
					case "SIGN":
						dataArr.push({"ROUTE_NAME":arrItem.attributes.ROUTEID, "REFPT":arrItem.attributes.MEASURE, "FEATURE_NAME":arrItem.attributes.Description,"ID":arrItem.attributes.OBJECTID, "MUTCD":arrItem.attributes.MUTCD?arrItem.attributes.MUTCD:"R6-2"});
						break;
				}
			}
			if(dataArr.length<1)
				arrayColl= new ArrayCollection(arr);
			else
				arrayColl  = new ArrayCollection(dataArr);
			return arrayColl;
		}
		
		public function parseJsonObj(obj:Object):Array
		{
			
			var rawData:String = String(obj);
			
			var arr:Array = new Array();
			if (rawData.length >0)
			{
				//decode the data to ActionScript using the JSON API
				//in this case, the JSON data is a serialize Array of Objects.
				arr = (JSON.parse(rawData).features) as Array;
			}
			return arr;
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

