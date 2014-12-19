package com.transcendss.transcore.sld.models.managers
{
	import com.google.maps.LatLng;
	import com.google.maps.MapOptions;
	import com.google.maps.MapType;
	import com.google.maps.View;
	import com.google.maps.geom.Attitude;
	import com.transcendss.transcore.events.MapInitEvent;
	import com.transcendss.transcore.util.PolarToUTM;
	
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	
	
	
	public class MapManager
	{
		
		private var projCoords:ArrayCollection;
		private var llCoords:ArrayCollection;
		private var projCounter:int = 0;
		private var projRuns:int = 0;
		
		public var dispatcher:IEventDispatcher;
		
//		[Bindable]
//		public var routeCoords:ArrayCollection;
		
		
		public function MapManager()
		{
		}
		
		public function onMapPreinitialize(event:MapInitEvent):void{    
			event.stopPropagation();
			var mEvent:MapInitEvent;
			var mapOptions:MapOptions = new MapOptions();           
			mapOptions.zoom = 8;  
			mapOptions.center = new LatLng(39.75, -104.87);  
			if (event.MapType ==3)
			{
				mapOptions.mapType = MapType.NORMAL_MAP_TYPE;
				mapOptions.viewMode = View.VIEWMODE_PERSPECTIVE;
				mapOptions.attitude = new Attitude(0,60,0);
				mEvent = new MapInitEvent(MapInitEvent.MAP3D_OPTIONS_READY);
				mEvent.MapOptions = mapOptions;
				dispatcher.dispatchEvent(mEvent);
			}
			else 
			{
				mapOptions.mapType = MapType.PHYSICAL_MAP_TYPE;
				mEvent = new MapInitEvent(MapInitEvent.MAP_OPTIONS_READY);
				mEvent.MapOptions = mapOptions;
				dispatcher.dispatchEvent(mEvent);
			}
				
			
		}
		
		
		public function setNewRouteCoords(ac:ArrayCollection):void
		{
//			routeCoords = ac;
			FlexGlobals.topLevelApplication.routeCoords = ac;
			/*for (var t:int=0;t<ac.length;t++)
			{
				trace(ac.getItemAt(t)["X"] + "," + ac.getItemAt(t)["Y"]);
			}*/
//			var mapSR:String = BaseConfigUtility.get("basemapSR");
			
			
			var mapSR:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.baseMapSR;
			if (mapSR == "4623")
			{
				// TODO: USE THE NEW ROUTECOORDS structure
				var pUTM:PolarToUTM = new PolarToUTM();
				ac = pUTM.routeCoordsToUTM(ac);
			}
			else
			{
				for each (var coord:Object in ac)
				{
					coord.utmX = coord.X;
					coord.utmY = coord.Y;
				}
			}
			
			/*if (mapSR != "4623")
			{
				projCounter = 0;
				projRuns = Math.ceil(ac.length / 30);
				projCoords = new ArrayCollection(clone(ac.source));
				llCoords = new ArrayCollection(clone(ac.source));
				var projURL:String = BaseConfigUtility.get("projectionService");
				projURL = projURL + "?inSR=4326&outSR=" + mapSR + "&geometries={'geometryType':'esriGeometryPoint','geometries':[";
				//add array
				var acCnt:int = 30;
				if (ac.length< 30)
					acCnt = ac.length;
				for (var i:int=0;i<acCnt;i++)
				{
					projURL = projURL + "{'x':'" + ac.getItemAt(i)["X"] + "','y':'" + ac.getItemAt(i)["Y"] + "'},";
				}
				projURL = projURL.substr(0,projURL.length -1);
				projURL = projURL + "]}&f=pjson";
				//trace(projCounter + " - " + projURL);
				var urlReq:URLRequest = new URLRequest(projURL);
				var urlLdr:URLLoader = new URLLoader();
				urlLdr.addEventListener(Event.COMPLETE, handleProjectedRouteCoords);
				urlLdr.addEventListener(IOErrorEvent.IO_ERROR, handleProjError);
				urlLdr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError);
				urlLdr.addEventListener(HTTPStatusEvent.HTTP_STATUS, statusHandler);
				urlLdr.load(urlReq);
				
			} else
			{*/
				var event:MapInitEvent = new MapInitEvent (MapInitEvent.MAP_ROUTE_INFO_READY);
				event.routeCoords = ac;
				dispatcher.dispatchEvent(event);
			//}
		}
		
		/*private function processAdditionalCoords():void
		{			
			var mapSR:String = BaseConfigUtility.get("basemapSR");
			var projURL:String = BaseConfigUtility.get("projectionService");
			projURL = projURL + "?inSR=4326&outSR=" + mapSR + "&geometries={'geometryType':'esriGeometryPoint','geometries':[";
			//add array
			var acBeg:int;
			var acCnt:int;
			
			acBeg = 0 + (projCounter * 30);
			if ((acBeg + 30) < llCoords.length)
				acCnt = acBeg + 30;
			else 
				acCnt = llCoords.length;
			
			for (var i:int=acBeg;i<acCnt;i++)
			{
				projURL = projURL + "{'x':'" + llCoords.getItemAt(i)["X"] + "','y':'" + llCoords.getItemAt(i)["Y"] + "'},";
			}
			projURL = projURL.substr(0,projURL.length -1);
			projURL = projURL + "]}&f=pjson";
			//trace(projCounter + " - " + projURL);
			var urlReq:URLRequest = new URLRequest(projURL);
			var urlLdr:URLLoader = new URLLoader();
			urlLdr.addEventListener(Event.COMPLETE, handleProjectedRouteCoords);
			urlLdr.addEventListener(IOErrorEvent.IO_ERROR, handleProjError);
			urlLdr.load(urlReq);
		}
		
		private function handleProjectedRouteCoords(evt:Event):void
		{
			//trace(projCounter + " - " + evt.target.data);
			var projReturn:Object = JSON.parse(evt.target.data);	
			var projCArray:Array = projReturn.geometries;
			if (projCArray != null)
			{
				for (var i:int=0;i<projCArray.length;i++)
				{
					if (i + (projCounter * 30) <projCoords.length)
					{
						projCoords.getItemAt(i + (projCounter * 30))["X"] = projCArray[i].x;
						projCoords.getItemAt(i + (projCounter *30))["Y"] = projCArray[i].y;
					}
				}
			}
			projCounter++;
			if (projCounter == projRuns)
			{
				FlexGlobals.topLevelApplication.routeCoords = projCoords;
				var event:MapInitEvent = new MapInitEvent (MapInitEvent.MAP_ROUTE_INFO_READY);
				event.routeCoords = projCoords;
				dispatcher.dispatchEvent(event);
			} else
			{
				processAdditionalCoords();
			}
		}
		
		private function handleProjError(evt:Event):void
		{
			evt.target;
		}
		
		private function handleSecurityError(evt:SecurityErrorEvent):void
		{
			evt.target;
		}
		
		private function statusHandler(evt:HTTPStatusEvent):void
		{
			evt.target;
		}*/
		
		private function clone( source:Object ) :*
		{
			var myBA:ByteArray = new ByteArray();
			myBA.writeObject( source );
			myBA.position = 0;
			return( myBA.readObject() );
		}
		
	}
}