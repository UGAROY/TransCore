package com.transcendss.transcore.sld.models.managers
{
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.transcore.events.FeatureEvent;
	import com.transcendss.transcore.sld.models.StickDiagram;
	import com.transcendss.transcore.sld.models.components.BaseAsset;
	import com.transcendss.transcore.sld.models.components.Route;
	
	import flash.display.Loader;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.rpc.IResponder;
	
	public class CoreAssetManager
	{
		protected var _assetDefs:Object = new Object();
		protected var _assetDescriptions:Object = new Object();
		protected var _currentAsset:BaseAsset;
		protected var _dispatcher:Dispatcher;

		protected var _barElementDefs:Object = new Object();
		protected var _barElementDescriptions:Object = new Object();

		protected var _event:FeatureEvent;
		protected var _app:Object = FlexGlobals.topLevelApplication;
		protected var _route:Route = null;
		protected var loader:Loader;
		protected var _origMileMarkers:ArrayCollection = new ArrayCollection();
		protected var _filteredMileMarkers:ArrayCollection = new ArrayCollection();
		
		protected var _mileOrder:String = "I";//"I" for increasing "D" for decreasinf
		
		public function CoreAssetManager()
		{
		}
		
		public function hasType(type:String):Boolean
		{
			if (_assetDescriptions[type])
				return true;
			else
				return false;
		}
		
		/**
		 * creates a new asset with the given id and type.
		 * this should be used over creating BaseAsset by itself.
		 * @param id the id of the new asset
		 * @param type the type of asset to create
		 * @param subtype the subtype of the asset to create, if applicable
		 * @return the newly created asset
		 * */
		public function createAsset(type:String, id:int = -1, subtype:String = "0"):BaseAsset
		{	
			var newAsset:BaseAsset = new BaseAsset(_assetDefs[_assetDescriptions[type]]);
			newAsset.id = id;
			newAsset.subType = subtype;
			
			return newAsset;
		}
		
		/**
		 * requestAssets is the method used for calls to the live database (that is, for non-cached assets), and accordingly
		 * uses an asynchronous call, and requires a responder, or callback.
		 * It provides a list of all of a certain type of asset for the current route.
		 * @param type the type of asset to request
		 * @param responder the methods to be fired upon success or failure
		 * @return void
		 */
		public function requestAssets(type:String,  responder:IResponder):void
		{
			FlexGlobals.topLevelApplication.incrementEventStack();
			_event = new FeatureEvent(FeatureEvent.ASSET_REQUEST, type);
			_event.routeName = _route.routeName;
			_event.begMile = _route.beginMi;
			_event.endMile = _route.endMi;
			_event.eventLayerID = _assetDefs[_assetDescriptions[type]].EVENT_LAYER_ID;
			_event.serviceURL = _app.GlobalComponents.ConfigManager.serviceURL + "XingFeatures/" + type
				+ "/" + _route.routeName + "/" + _route.beginMi + "/" + _route.endMi;
			_event.responder = responder;
			_dispatcher.dispatchEvent(_event);
			_event = null;
		}
		
		/**
		 * requestAssets is the method used for calls to the live database (that is, for non-cached assets), and accordingly
		 * uses an asynchronous call, and requires a responder, or callback.
		 * It provides a list of all of a certain type of asset for the current route.
		 * @param type the type of asset to request
		 * @param responder the methods to be fired upon success or failure
		 * @return void
		 */
		public function requestMilePosts( responder:IResponder,diagramObj:Object):void
		{
			var type:String = "MILEMARKER";
			_event = new FeatureEvent(FeatureEvent.GETMILEPOSTDATA, type);
			_event.routeName = _route.routeName;
			_event.begMile = _route.beginMi;
			_event.endMile = _route.endMi;
			_event.eventLayerID = _assetDefs[_assetDescriptions[type]].EVENT_LAYER_ID;
			_event.diagramObj = diagramObj;
			_event.serviceURL = _app.GlobalComponents.ConfigManager.serviceURL + "XingFeatures/" + type
				+ "/" + _route.routeName + "/" + _route.beginMi + "/" + _route.endMi;
			_event.responder = responder;
			_dispatcher.dispatchEvent(_event);
			_event = null;
		}
		
		public function getFakeMilepointsByRoute(nRoute:Object, includeFakeBeg:Boolean=true,includeFakeEnd:Boolean=true):ArrayCollection
		{
			var fakeMilepostArr:Array = new Array();
			
			if(includeFakeBeg)
			{
				//fakeMilepostArr.push({FEATURE_NAME:Math.ceil(Number(nRoute.beginMi)), ID:"1",MUTCD:"D10-1", REFPT:Math.ceil(Number(nRoute.beginMi)), ROUTE_NAME:nRoute.routeName});
				var bsAsset:BaseAsset = createAsset("MILEMARKER",1,"D10-1");
				bsAsset.invProperties[bsAsset.primaryKey].value = 1;
				bsAsset.invProperties[bsAsset.typeKey].value = "D10-1";
				bsAsset.invProperties[bsAsset.fromMeasureColName].value = Math.ceil(Number(nRoute.beginMi));
				bsAsset.invProperties[bsAsset.routeIDColName].value = nRoute.routeName;
				bsAsset.invProperties[bsAsset.valueKey].value = bsAsset.invProperties[bsAsset.fromMeasureColName].value;
				fakeMilepostArr.push(bsAsset);
			}
			
			
				
			if(includeFakeEnd)
			{
//				fakeMilepostArr.push({FEATURE_NAME:Math.floor(Number(nRoute.endMi)), ID:"2",MUTCD:"D10-1", REFPT:Math.floor(Number(nRoute.endMi)), ROUTE_NAME:nRoute.routeName});
				var bsAsset2:BaseAsset = createAsset("MILEMARKER",2,"D10-1");
				bsAsset2.invProperties[bsAsset2.primaryKey].value = 2;
				bsAsset2.invProperties[bsAsset2.typeKey].value = "D10-1";
				bsAsset2.invProperties[bsAsset2.fromMeasureColName].value = Math.floor(Number(nRoute.endMi));
				bsAsset2.invProperties[bsAsset2.routeIDColName].value = nRoute.routeName;
				bsAsset2.invProperties[bsAsset2.valueKey].value = bsAsset2.invProperties[bsAsset2.fromMeasureColName].value;
				fakeMilepostArr.push(bsAsset2);
			}
			return new ArrayCollection(fakeMilepostArr);
		}
		
		/**
		 * 
		 */
		public function onDBRetrievalComplete(arr:ArrayCollection, type:String, resp:IResponder):void
		{
			
			var assetCollection:Vector.<BaseAsset> = new Vector.<BaseAsset>();
			
			if(type=="MILEMARKER")
			{
				origMileMarkers= arr;
				arr = this.filteredMileMarkers;
			}
			
			for each(var asset:Object in arr)
			{
				var temp:BaseAsset = mapDataToBaseAsset(asset, type);
				
				assetCollection.push(temp);
			}
			
			resp.result({assets: assetCollection, type: type});
		}
		
		public function mapAssetColl(arr:ArrayCollection, type:String):Array
		{
			var assetCollection:Array = new Array();
			for each(var asset:Object in arr)
			{
				var temp:BaseAsset = mapDataToBaseAsset(asset, type);
				
				assetCollection.push(temp);
			}
			
			return  assetCollection;
		}
		
		/**
		 * takes in a raw dynamic object with the table properties for a specific BaseAsset, and 
		 * returns a new BaseAsset instance based on those table properties.
		 * @param data the object with data columns as properties
		 * @param type the type to map to
		 * 
		 * @return th enewly created BaseAsset object
		 */
		public function mapDataToBaseAsset(data:Object, type:String, isAsset:Boolean=true):BaseAsset
		{
			if (data == null)
				return null;
			
			if (data is BaseAsset)
				return data as BaseAsset;
			
			if(isAsset)
			{
				if (!_assetDefs[_assetDescriptions[type]] || !_assetDescriptions[type])
				{
					trace("Warning: Invalid Asset Type Given to mapDataToBaseAsset.");
					return null;
				}
			}
			else
			{
				if (!_barElementDefs[_barElementDescriptions[type]] || !_barElementDescriptions[type])
				{
					trace("Warning: Invalid Bar Element Type Given to mapDataToBaseAsset.");
					return null;
				}
			}
			
			var temp:BaseAsset;
			if(isAsset)
				temp = new BaseAsset(_assetDefs[_assetDescriptions[type]]);
			else
				temp = new BaseAsset(_barElementDefs[_barElementDescriptions[type]]);

			var flag:Boolean = false;
			for (var prop:String in data)
			{
				//if(prop === "MODIFY_DT")
				//trace(data[prop]);
				if (data[prop] is Object && data[prop].hasOwnProperty("value"))
					flag = true;
				
				if (prop === temp.primaryKey)
					temp.id = flag ? data[prop].value : data[prop];
					
				else if (prop === "D_CULV_PLACEMENT_TY_ID") 
				{
					temp.subType = flag ? String(data[prop].value) : String(data[prop]);
					temp.invProperties[prop].value = flag ? data[prop].value : data[prop];
				}
				if (temp.invProperties[prop])
					temp.invProperties[prop].value = flag ? data[prop].value : data[prop];
				if (isAsset && temp.inspProperties[prop])
					temp.inspProperties[prop].value = flag ? data[prop].value : data[prop];
				if((isAsset && !temp.invProperties[prop] && !temp.inspProperties[prop]) ||
					(!isAsset && !temp.invProperties[prop]))
					trace("Warning: A property ('" + prop + "') from an Asset JSON result was not found in its Asset Definition file!");
			}
			
			if(isAsset)
			{
				if (data.hasOwnProperty(_assetDefs[_assetDescriptions[type]].TYPE_KEY))
					temp.subType =  (data[_assetDefs[_assetDescriptions[type]].TYPE_KEY] is Object && data[_assetDefs[_assetDescriptions[type]].TYPE_KEY].hasOwnProperty("value")) ? String(data[_assetDefs[_assetDescriptions[type]].TYPE_KEY].value) : 
						String(data[_assetDefs[_assetDescriptions[type]].TYPE_KEY]);
			}
			else
			{
				if (data.hasOwnProperty(_barElementDefs[_barElementDescriptions[type]].TYPE_KEY))
					temp.subType =  (data[_barElementDefs[_barElementDescriptions[type]].TYPE_KEY] is Object && data[_barElementDefs[_barElementDescriptions[type]].TYPE_KEY].hasOwnProperty("value")) ? String(data[_barElementDefs[_barElementDescriptions[type]].TYPE_KEY].value) : 
						String(data[_barElementDefs[_barElementDescriptions[type]].TYPE_KEY]);
			}
			
			if (data.hasOwnProperty(temp.fromMeasureColName)){
				temp.milePost =   (data[temp.fromMeasureColName] is Object && data[temp.fromMeasureColName].hasOwnProperty("value"))? new Number(data[temp.fromMeasureColName].value) : 
					new Number(data[temp.fromMeasureColName]);
				
			
			}
			
				
			
			//assignAssetSymbol(temp);
			
			return temp;
		}
		
		public function getAssetsFromStkDiagram(description:String):ArrayCollection
		{			
			var diagram:StickDiagram = FlexGlobals.topLevelApplication.GlobalComponents.stkDiagram;
			//if(diagram.numChildren !=0 ) // stickdiagram is not empty, this is the default 
			//{
			return diagram.getSpriteAssets(description);
			//}
			//else //In the overview map mode, the stkdiagram will be "empty". This is a temporary solution in order to make the "go to milepost" work. 
			//{
			//	var acc:ArrayCollection = FlexGlobals.topLevelApplication.sldDiagram.sldDiagram.getMilePostData();
			//	return acc;
			//}
		}
		
		public function set origMileMarkers(ac:ArrayCollection):void
		{
			_mileOrder = (_route.beginMilepost < _route.endMilepost)?"I":"D";
			
			var tempAC:ArrayCollection = new ArrayCollection(mapAssetColl(ac,"MILEMARKER"));
			_origMileMarkers =tempAC;
			_filteredMileMarkers = filterValidMileMarkers(_origMileMarkers, _route.beginMilepost, _route.endMilepost);
			
			if(_filteredMileMarkers.length ==0)
			{
				_filteredMileMarkers = getFakeMilepointsByRoute(_route);
				//_filteredMileMarkers = new ArrayCollection(mapAssetColl(tempAC2,"MILEMARKER"));
			}
			if(_filteredMileMarkers.length >0 && _filteredMileMarkers[0].invProperties[_filteredMileMarkers[0].valueKey].value > Math.ceil(_route.beginMilepost))
			{
				
				var tempArr:ArrayCollection = getFakeMilepointsByRoute(_route,true,false);
				
				_filteredMileMarkers.source.unshift(tempArr.getItemAt(0));
			}
			
			if(_filteredMileMarkers.length >0 && _filteredMileMarkers[_filteredMileMarkers.length-1].invProperties[_filteredMileMarkers[_filteredMileMarkers.length-1].valueKey].value < Math.floor(_route.endMilepost))
			{
				
				var tempArr2:ArrayCollection = getFakeMilepointsByRoute(_route,false,true);
				
				_filteredMileMarkers.source.push(tempArr2.getItemAt(0));
			}
			
		}
		
		
		public function get origMileMarkers():ArrayCollection
		{
			return (_origMileMarkers && _origMileMarkers.length>0)?_origMileMarkers:new ArrayCollection();;
		}
		
		
		public function get filteredMileMarkers():ArrayCollection
		{
			return _filteredMileMarkers;
		}
		
		public function get mileOrder():String
		{
			return _mileOrder;
		}
		
		private function filterValidMileMarkers(baseAssetArray:ArrayCollection, routeBeg:Number, routeEnd:Number):ArrayCollection
		{
			
			// filter the mile marker array to remove out of order values
			for (var i:int=0;i<baseAssetArray.length;i++)
			{
				// filter the mile marker array to remove non numeric values
				if (isNaN(baseAssetArray[i].invProperties[baseAssetArray[i].valueKey].value *1))
				{
					baseAssetArray.removeItemAt(i);
					i--;
				}
				else if (i+1<baseAssetArray.length && _mileOrder=="I" && new Number(baseAssetArray[i].invProperties[baseAssetArray[i].valueKey].value) > new Number(baseAssetArray[i+1].invProperties[baseAssetArray[i+1].valueKey].value))
				{
					baseAssetArray.removeItemAt(i+1);
					i--;
				}
				else if (i+1<baseAssetArray.length && _mileOrder=="D" && new Number(baseAssetArray[i].invProperties[baseAssetArray[i].valueKey].value) < new Number(baseAssetArray[i+1].invProperties[baseAssetArray[i+1].valueKey].value))
				{
					baseAssetArray.removeItemAt(i+1);
					i--;
				}
				else if (_mileOrder=="I" && ((new Number(baseAssetArray[i].invProperties[baseAssetArray[i].valueKey].value) < routeBeg) || (new Number(baseAssetArray[i].invProperties[baseAssetArray[i].valueKey].value) > routeEnd)))
				{
					baseAssetArray.removeItemAt(i);
					i--;
				}
				else if (_mileOrder=="D" && ((new Number(baseAssetArray[i].invProperties[baseAssetArray[i].valueKey].value) > routeBeg) || (new Number(baseAssetArray[i].invProperties[baseAssetArray[i].valueKey].value) < routeEnd))) 
				{
					baseAssetArray.removeItemAt(i);
					i--;
				}
				
				
			}
			return baseAssetArray;
		}
		
		public function get currentAsset():BaseAsset
		{
			return _currentAsset;
		}
		
		public function set currentAsset(asset:BaseAsset):void
		{
			_currentAsset = asset;
		}
		
		public function get route():Route
		{
			return _route;
		}
		
		public function set route(value:Route):void
		{
			_route = value;
		}
		
		public function get assetDefs():Object
		{
			return _assetDefs;
		}
		
		public function set assetDefs(value:Object):void
		{
			_assetDefs = value;
		}
		
		public function get barElementDefs():Object
		{
			return _barElementDefs;
		}
		
		public function set barElementDefs(value:Object):void
		{
			_barElementDefs = value;
		}
		
		public function get assetDescriptions():Object
		{
			return _assetDescriptions;
		}
		
		
		public function getAssetUINameByType(typ:String):String
		{
			
			for each ( var asset in assetDefs)
			{
				if(asset.ASSET_TYPE == typ)
					return asset.UI_NAME;
			}
				
				
			return "";
		}
		
		public function set assetDescriptions(value:Object):void
		{
			_assetDescriptions = value;
		}
		
		public function get barElementDescriptions():Object
		{
			return _barElementDescriptions;
		}
		
		public function set barElementDescriptions(value:Object):void
		{
			_barElementDescriptions = value;
		}
	}
}