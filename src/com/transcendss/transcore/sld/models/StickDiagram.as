package com.transcendss.transcore.sld.models
{
	
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.transcore.events.RouteGeotagEvent;
	import com.transcendss.transcore.sld.models.components.BaseAsset;
	import com.transcendss.transcore.sld.models.components.Bridge;
	import com.transcendss.transcore.sld.models.components.CountyLine;
	import com.transcendss.transcore.sld.models.components.GeoTag;
	import com.transcendss.transcore.sld.models.components.GuideBar;
	import com.transcendss.transcore.sld.models.components.Intersection;
	import com.transcendss.transcore.sld.models.components.MeasureBar;
	import com.transcendss.transcore.sld.models.components.MileMarker;
	import com.transcendss.transcore.sld.models.components.Railroad;
	import com.transcendss.transcore.sld.models.components.Route;
	import com.transcendss.transcore.sld.models.components.RouteInfoHUD;
	import com.transcendss.transcore.sld.models.components.RouteMarkers;
	import com.transcendss.transcore.sld.models.components.Ruler;
	import com.transcendss.transcore.sld.models.components.Stream;
	import com.transcendss.transcore.sld.models.components.LeftViewMileMarker;
	import com.transcendss.transcore.sld.models.components.RightViewMileMarker;
	import com.transcendss.transcore.sld.models.managers.CoreAssetManager;
	import com.transcendss.transcore.sld.models.managers.GeotagsManager;
	import com.transcendss.transcore.util.AssetSymbol;
	import com.transcendss.transcore.util.Converter;
	import com.transcendss.transcore.util.PDFUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.rpc.Responder;
	
	[Bindable]
	public class StickDiagram extends UIComponent
	{
		public static const COUNTY_LINE:String = "COLN";
		public static const INTERCHANGE:String = "INT";
		public static const RRXING:String = "RRXNG";
		public static const BRIDGE:String = "BRDG";
		public static const STREAM:String = "STRM"
		public static const SIGNC:String = "SIGN";
		public static const CULV:String = "CULV";
		
		private var leftLabelLength:Number = 0;	
		private var diagramRoute:Route;
		private var diagramScale:Number;
		private var ruler:Ruler;
		private var fruler:MeasureBar;
		private var routeMkrs:RouteMarkers;
		public var leftViewMileMarkers:LeftViewMileMarker;
		public var rightViewMileMarkers:RightViewMileMarker;
		public var routeHUD:RouteInfoHUD;
		private var countyLine:CountyLine;
		private var stream:Stream;
		private var bridge:Bridge;
		private var intersec:Intersection;
		private var sign: MileMarker;
		private var railroad:Railroad;
		private var leftMP:Number;
		private var rightMP:Number;
		private var cachedAssets:Dictionary = new Dictionary();
		
		private var offsetValue:Number ;
		
		public var guideBar:GuideBar;
		private var HUDText:DisplayObject;
		
		private var layerArray:Array;
		//private var featureStore:Array = new Array();
		private var _gBarX:Number;
		private var gbBbuttonMode:Boolean=false;
		private var gbUseHandCursor:Boolean = false;
		private var pdfBeginMi:Number =0;
		private var pdfEndMi:Number = 0;
		
		private var assetTypes:Vector.<String>;
		private var _assets:Vector.<BaseAsset>;
		private var _culvert:BaseAsset;
		private var _spriteLayers:Object = new Object();
		private var _typeCounts:Object = new Object();
		private var ftSprite:Sprite = new Sprite();
		private var _spriteLists:Object = new Object();
		private var _milepostArray:ArrayCollection = new ArrayCollection();
		private var _signArray:ArrayCollection = new ArrayCollection();
		private var dispatcher:Dispatcher = new Dispatcher();
		private var testArray:Array = new Array();
		private var gtManager:GeotagsManager = new GeotagsManager();
		private var _routeGeotags:Array = new Array();
		
		public function StickDiagram(route:Route=null,scale:Number=50000)
		{
			super();

			name = "sld_graphic";
			// set scale
			diagramScale = scale;	
			// init ruler
			ruler = new Ruler();
			
			fruler = new MeasureBar();
			
			// init rte mkrs
			routeMkrs = new RouteMarkers();
			//init view mile markers
			leftViewMileMarkers = new LeftViewMileMarker();
			rightViewMileMarkers = new RightViewMileMarker();
			// init HUD
			routeHUD = new RouteInfoHUD();
			
			// Speed Optimization ... or not
			//this.cacheAsBitmap = true;
			
			//init guidebar
			guideBar = new GuideBar("STICK");
			
			_culvert = new BaseAsset();
			
			sign = new MileMarker();
			
			
			// init draw route
			if(route == null){
				diagramRoute = new Route("no_rte",0,100);
			} 
			else{
				//init countyLine
				diagramRoute = route;
				draw();
				
			}
			FlexGlobals.topLevelApplication.GlobalComponents.stkDiagram = this;
			
		}

		// Draw the roadway in the panel based on the number of lanes, if known.  Default is to draw 2 lane roadway
		public function drawRoadwayLanes(featureAC:ArrayCollection, scale:Number):void
		{
			diagramRoute.clearContainer();
			if(scale <= 0 || isNaN(scale))
				scale = diagramScale;
			
			width = Math.round(Converter.scaleMileToPixel(diagramRoute.distance,diagramScale));

			if(featureAC != null && featureAC.length>0 && featureAC[0].hasOwnProperty("DATA") && featureAC[0].DATA.length > 0)
				diagramRoute.drawMultiLanes(width,height, scale, 0, 0x000000,0xFFF544, this.offsetValue, featureAC);
			else
			{
				diagramRoute.drawMultiLanes(width,height, scale, 1, 0x000000,0xFFF544, this.offsetValue);
			}
			
			addFeature(diagramRoute, 0)
		}

		
		//guideBarX needs to be screenwidth/2 for MAVRIC and for RA 0 for the guidebar to be at pos 0
		public function draw(scale:Number=0.5,route:Route=null,fromStorage:Boolean=false,screenWidth:Number = 1500,guideBarX:Number = 1500/2, buttonMd:Boolean=false, useHandCrsr:Boolean = false, rescaling:Boolean = false):void{
			this.offsetValue = (screenWidth-50)/2;
			
			clearContainer(); // clear stick diagram - UIComponent is mx and doesn't have removeElements method
			_routeGeotags = [];
			if(!fromStorage)
				this.cachedAssets = new Dictionary();
			if(route != null) 
				diagramRoute = route; // update route if not null
			diagramScale = scale;
			_gBarX = guideBarX;
			
			gbBbuttonMode = buttonMd;
			gbUseHandCursor = useHandCrsr;  
			layerArray = []; //init [clear] layers array
			
			width = Math.round(Converter.scaleMileToPixel(diagramRoute.distance,diagramScale));


			
			// draw ruler
			//ruler.draw(diagramRoute.beginMi,diagramRoute.endMi,diagramScale,Units.MILE);
			if(FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.feetMarkerSwitch )
				layerArray.push({layer:ruler, order:100, layerIndex:0});
			
			fruler.draw(height,_gBarX*2,_gBarX,diagramScale,FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.dataUnits, FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.measureBarUnit);
			if(FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.feetMarkerSwitch )
				layerArray.push({layer:fruler, order:100, layerIndex:0});
			
			
			//draw route Heads Up Display
			routeHUD.draw(diagramRoute.routeName,diagramRoute.beginMilepost,diagramRoute.endMilepost,screenWidth,height,diagramRoute.beginMi+Converter.scalePixelToMile(_gBarX - offsetValue,diagramScale));
			layerArray.push({layer:routeHUD, order:999, layerIndex:0});
			
			
			var leftLabel:String = "VMP Left: ";
			leftLabelLength = leftLabel.length +45;
			
			//check if the route length is less than the screen width. Place the ViewMile markers at the end of the route not the right edge of the screen
			var rightMrkrPtX:Number = screenWidth-50;
			var endMileMrkrX:Number = Converter.scaleMileToPixel(diagramRoute.beginMi+diagramRoute.endMi,diagramScale);
			
			
//			if (rightMrkrPtX> endMileMrkrX)
//			{
//				rightMrkrPtX = endMileMrkrX;
//				rightValue = diagramRoute.endMi.toFixed(2);
//			}
			
			
			leftViewMileMarkers.clear();
			leftViewMileMarkers.addCallOut(width,height,leftLabel,-10,0x000000,0x000000,2,"leftLabelCallOut");
			leftViewMileMarkers.addCallOut(width,height,diagramRoute.beginMilepost.toString(),leftLabelLength,0x000000,0x000000,0,"leftValueCallOut");
			leftViewMileMarkers.x = 10;
			//viewMileLabelMarkers.addCallOut(width,height,"VMP Right: ",rightMrkrPtX,0x000000,0x000000,0, "rightLabelCallOut");
			layerArray.push({layer:leftViewMileMarkers, order:99, layerIndex:0});
			
			rightViewMileMarkers.clear();
			rightViewMileMarkers.addCallOut(width,height,"VMP Right: ",25 ,0x000000,0x000000,0,"rightLabelCallOut");
			//viewMileValueMarkers.addCallOut(width,height,diagramRoute.beginMilepost.toString(),leftLabelLength + 10,0x008000,0x800000,0,"leftValueCallOut");
			var rightValue:String = (diagramRoute.beginMi + Converter.scalePixelToMile(rightMrkrPtX/2,diagramScale)).toFixed(2);
			rightViewMileMarkers.addCallOut(width,height,rightValue,50,0x000000,0x000000,2,"rightValueCallOut");
			rightViewMileMarkers.x = rightMrkrPtX-50;
			layerArray.push({layer:rightViewMileMarkers, order:99, layerIndex:0});
			
			// draw begin/end labels
			routeMkrs.clear();
			routeMkrs.addCallOut(width,height,"BMP: "+diagramRoute.beginMilepost.toString(),0,0x008000,0x008000,this.offsetValue );
			routeMkrs.addCallOut(width,height,"EMP: "+diagramRoute.endMilepost.toString(),width,0x800000,0x800000,this.offsetValue);
			layerArray.push({layer:routeMkrs, order:101, layerIndex:0});
			
			
			
			
			
			// sort layers
			layerArray.sortOn("order", Array.NUMERIC);
			// draw graphics
			drawLayers();
			// query for crossing features
			getFeatures(fromStorage, rescaling);
			
			drawGuideBar();
			//this.width -= 100;
			
			getUnattachedGeotags(fromStorage);
		
		}
		
		
		/**
		 *Function to get both local and server unattached geotags. 
		 * Same event collects unattached geotags from local and remote DB --see ListenerInjector & EventHandler in MainEventMap.mxml
		 */
		private function getUnattachedGeotags(fromStorage:Boolean):void
		{
			var ftEvent:RouteGeotagEvent;
			dispatcher = new Dispatcher();
			//if connected call service and obtain array of geotags on the route (unattached to culvert)
			if(!fromStorage)
			{
				ftEvent = new RouteGeotagEvent( RouteGeotagEvent.ROUTE_GEOTAG_REQUESTED,true);
				ftEvent.serviceURL = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.serviceURL +"RouteGeotags/"+this.route.routeName+"/"+this.route.beginMi+"/"+this.route.endMi;
				dispatcher.dispatchEvent(ftEvent);
			}
			//get the geotags which we have on the local DB. 
			//For RoadA this event is ignored, since we do not have anything specified in the event map
			ftEvent = new RouteGeotagEvent( RouteGeotagEvent.ROUTE_LOCAL_GEOTAG_REQUESTED, true);
			dispatcher.dispatchEvent(ftEvent);
		}
		
		
		/**
		 *Function to add unattached geotags to the diagram. 
		 * Called from MainEventMap inlineInvoker for geotags obtained from server.
		 * Called from MAVRICDiagram for local geotags for MAVRIC
		 * @param ac - geotag arraycollection
		 * 
		 */
		public function geotagRequestCallBack(ac:ArrayCollection,source:String ="server"):void
		{
			var tmpGT:GeoTag;
			var insp:Number;
			var viE:*;
			var gtArray:Array = ac.source;
			for (var gti:int=0;gti<gtArray.length;gti++)
			{
				//if coming from local it is already converted to geotag, else convert
				if(gtArray[gti] is GeoTag)
					tmpGT = gtArray[gti];
				else
					tmpGT= new GeoTag(Number(gtArray[gti].ATTACH_ID),"0",String(gtArray[gti].ROUTE_NAME),String(gtArray[gti].ASSET_BASE_ID),""
					,-1,Number(gtArray[gti].BEGIN_MILE),Number(gtArray[gti].END_MILE),String(gtArray[gti].IMAGE_FILENAME),String(gtArray[gti].VIDEO_FILENAME),String(gtArray[gti].VOICE_FILENAME),String(gtArray[gti].TEXT_MEMO));
				
				
				var typ:String ="";
				
				//If already in routeGeotags arr skip
				if(!isPresentInRouteGeotags(tmpGT))
				{
				
					//if coming from local, it does not have a URL property. Only geotags obtained from server has URL property.
					//Convert to TSSPicture, TSSVideo, TSSAudio or TSSMemo depepnding on the filename/text field
					if(!gtArray[gti].hasOwnProperty("URL") || source == "local")
						viE= gtManager.ConvertGeotags(tmpGT, "", "local");
					else
						viE= gtManager.ConvertGeotags(tmpGT, String(gtArray[gti].URL));
					
					if(viE)
					{
						
						/* This conditional is not working when try to load cached route with unattached geotag. Wired...
						if(viE is TSSPicture)
						typ = "image";
						else if (viE is TSSVideo)
						typ = "video";
						else if (viE is TSSMemo)
						typ = "text";
						else(viE is TSSAudio)
						typ = "voice";
						*/
						switch(viE['className'])
						{
							case "TSSPicture":
							{
								typ = "image"
								break;
							}
							case "TSSVideo":
							{
								typ = "video"
								break;
							}
							case "TSSMemo":
							{
								typ = "text"
								break;
							}	
							case "TSSAudio":
							{
								typ = "audio"
								break;
							}	
							default:
							{
								trace("out of range");
								break;
							}
						}
						viE.x = Converter.scaleMileToPixel(tmpGT.begin_mile_point-diagramRoute.beginMi,diagramScale) + offsetValue; //offsetValue
						viE.y = getIconY(typ);
						if(this.getChildByName("GUIDE_BAR_SPRITE"))
							this.addChildAt(viE, getChildIndex(guideBar));
						else
							this.addChild(viE);	
						_routeGeotags.push({geotag:tmpGT,tssobj:viE});
					}
				}
				
			}
		}
		
		public function isPresentInRouteGeotags(gt:GeoTag):Boolean
		{
			for each(var rgtObj:Object in _routeGeotags)
				if(rgtObj.geotag ===gt)
					return true;
			return false;
		}
		
		public function getIconY(typ:String):Number{
			var y:Number = 10;
			
			switch(typ)
			{
				case "sign":
					y=25;
					break;
				case "text":
					y=55;
					break;
				case "voice":
					y= 85;
					break;
				case "video":
					y= 165;
					break;
				case "image":
					y=195;
					break;
				
			}
			return y;
		}
		
	
	
		
		/*private function refreshFeatures(fromStorage:Boolean):void
		{
			if(diagramRoute != null)
			{	
				intersec = new Intersection(INTERCHANGE,diagramRoute.routeName, diagramRoute.beginMi, diagramRoute.endMi);
				//culvert = new BaseAsset();
				
				if(!fromStorage)
				{
					featureStore = [];
					
					intersec.getIntLines();
					
					var resp :Responder = new Responder(success, fail);
					FlexGlobals.topLevelApplication.GlobalComponents.assetManager.requestAssets(CULV, resp);		
					var assetDefs:Object = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.assetDefs;
					for each(var assetDef : Object in assetDefs)
					{
						_spriteLayers[assetDef.DESCRIPTION] = new Sprite();
						_spriteLayers[assetDef.DESCRIPTION].name = assetDef.DESCRIPTION;
					}
					FlexGlobals.topLevelApplication.GlobalComponents.stkDiagram = this;
				}
				else{
					for (var i:int=0; i< featureStore.length;i++)
					{
						drawFeatures(featureStore[i].ArrayColl,featureStore[i].Name, fromStorage);
					}
				}
			}
		}		*/
		
		/**
		 * Induces each object to get all associate sprites from storage
		 */ 
		private function getFeatures(fromStorage:Boolean=false, rescaling:Boolean = false):void
		{
			var assetDefs:Object = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.assetDefs;
			
			//featureStore = []; // equivalent to below lines
			for each(var assetDef : Object in assetDefs)
			{
				if(_spriteLayers[assetDef.DESCRIPTION] == null)
				{
					_spriteLayers[assetDef.DESCRIPTION] = new Sprite();
					_spriteLayers[assetDef.DESCRIPTION].name = assetDef.DESCRIPTION;
				}
				
			}
			
			if (diagramRoute != null)
			{	
				//intersec = new Intersection(INTERCHANGE,diagramRoute.routeName, diagramRoute.beginMi, diagramRoute.endMi);
				
				if (!fromStorage)
				{
					
					var assetMan:Object = FlexGlobals.topLevelApplication.GlobalComponents.assetManager;
					var resp:Responder = new Responder(liveAssetRetrievalSuccess, liveAssetRetrievalFailure);
					
					for (var prop:String in assetMan.assetDescriptions) 
					{
						assetMan.requestAssets(prop, resp);
						FlexGlobals.topLevelApplication.incrementEventStack();
					}
					
					
					
				}
				else
				{
					var array : ArrayCollection; 
					var ftSprite: Sprite;
					for (var ftName : String in _spriteLayers)
					{
						trace(ftName);
						FlexGlobals.topLevelApplication.incrementEventStack();
						ftSprite = _spriteLayers[ftName];	
						array = new ArrayCollection();
						if (this.cachedAssets[ftName] == null)
						{
							for (var i:int = 0; i < ftSprite.numChildren; i++)
							{
								array.addItem((ftSprite.getChildAt(i) as AssetSymbol).baseAsset);
							}
							
							drawFeatures(array, ftName, fromStorage, rescaling);
						}
						else
						{
							drawFeatures(this.cachedAssets[ftName] as ArrayCollection, ftName, fromStorage, rescaling);
						}
							
					}
						
						
				}
			}
		}
		
		public function liveAssetRetrievalSuccess(obj2:Object):void
		{
			var obj:Object = obj2.assets;
			var type:String = obj2.type as String;
			var vec : Vector.<BaseAsset> = obj as Vector.<BaseAsset>;
			var ac : ArrayCollection = new ArrayCollection();
			for (var vecIndex=0;vecIndex<vec.length; vecIndex++)
			{
				var a:BaseAsset = vec[vecIndex];
				a.status="SERVER";
				ac.addItem(a);
				
			}
			
			
			var ac2:ArrayCollection = new ArrayCollection();
			

			ac2 = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.getAssetsByRoute(type, this.route);
			//ac.addAll(ac2);
			

			for each (var liveAsset:BaseAsset in ac)
			{
				var good:Boolean = true;
				for each (var cachedAsset:BaseAsset in ac2)
				{
					if (liveAsset.id == cachedAsset.id)
					{
						good = false;
						break;
					}
				}
				
				if (good)
					ac2.addItem(liveAsset);
			}
			
			var arr:ArrayCollection = new ArrayCollection();
			arr.addAll(ac2);
			_spriteLists[type] = arr;
			drawFeatures(ac2, type);
			
		}
		
		public function liveAssetRetrievalFailure():void
		{
			trace("----------------------------------------------------------");
			trace("(ERROR)        Live Asset Retrieval Failed!               ");
			trace("----------------------------------------------------------");
			FlexGlobals.topLevelApplication.decrementEventStack();
		}
		
		
		public function drawFeatures(ac:ArrayCollection, ftName:String, fromStorage:Boolean=false, rescaling:Boolean = false):void
		{
			if (!fromStorage)
			{
				var assetDefs:Object = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.assetDefs;
				var inAssetDefs:Boolean = false;
				_spriteLayers[ftName] = new Sprite();
				_spriteLayers[ftName].name = ftName;
	
			}
				
			 ftSprite = new Sprite();
			 ftSprite.name = ftName;
			 _spriteLayers[ftName] = ftSprite;
			 
			
			var ftSprite:Sprite = _spriteLayers[ftName];
			if (ftSprite == null)
				return;
			
			if (rescaling && ftSprite.numChildren > 0)
			{
				ftSprite.removeChildren(0, ftSprite.numChildren-1);
			}
			
			var assetMan:CoreAssetManager = FlexGlobals.topLevelApplication.GlobalComponents.assetManager as CoreAssetManager;
			if (assetMan.assetDescriptions.hasOwnProperty(ftName) && ftName != MileMarker.TYPE)
			{
				this._typeCounts[ftName] = ac.length;
				//FlexGlobals.topLevelApplication.runningEvents = 0;
				try
				{
					if(ac.length==0)
					{
						trace(ftName + " DONE");
						FlexGlobals.topLevelApplication.decrementEventStack();
					}
					for each (var asset:Object in ac)
					{
						if (asset == null)
							continue;
						
						var resp:Responder = new Responder(mapAssetSuccess, liveAssetRetrievalFailure);
						FlexGlobals.topLevelApplication.GlobalComponents.assetManager.mapAndAssignAssetSymbols(asset, ftName, resp);
					
					}
				}
				catch(e:Error)
				{
					trace(ftName + " DONE");
					FlexGlobals.topLevelApplication.decrementEventStack();
					FlexGlobals.topLevelApplication.TSSAlert('Error drawing asset: '+ ftName + '. ' + e.message);	
				}
				if(ftName === "SIGN")
				{
					_signArray = ac;
					var childArray:Array = new Array();
					for(var i:int = 0; i< ftSprite.numChildren; i++)
					{
						childArray.push(ftSprite.getChildAt(i));	
					}
					
				}

			}

			else if (ftName === "BRDG") // Feature is not an Asset, and it must be drawn using manual classes.
			{
				bridge.draw(ac, diagramScale, height, diagramRoute.beginMi);
				drawAsset("BRDG");
				FlexGlobals.topLevelApplication.decrementEventStack();
			}
			
			else if (ftName === MileMarker.TYPE)
			{
				
				
				if(ac !=null && ac.length >0)
				{
					_milepostArray.removeAll();
					_milepostArray.addAll(ac);
				}
				else if(_milepostArray != null && _milepostArray.length>0)
					ac= _milepostArray;
				sign.draw(ac, diagramScale, height, diagramRoute.beginMi, this.offsetValue);
				sign.name = ftName;
				(_spriteLayers[ftName]).addChild(sign);
				
				addFeature(sign, 96); // Milemarker will be added no matter it is turned on or not
				if (FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.assetSwitch[ftName])
					sign.visible = true;
				else
					sign.visible = false;
				
				FlexGlobals.topLevelApplication.decrementEventStack();
				trace(ftName + " DONE");
			}
			//trace(_spriteLayers);
		}
		
		/**
		 * Positions an asset on the diagram and adds the asset symbol. Similar to applyAssetToDiagram.
		 */
		public function mapAssetSuccess(resultObj:Object):void
		{	
			var basset:BaseAsset = resultObj.bAsset as BaseAsset;
			
			_typeCounts[basset.description] = (_typeCounts[basset.description] as int) - 1;
			
			if (basset.description == null || basset.description == "" || !basset.description)
				_typeCounts[basset.description] = (_typeCounts[basset.description] as int) - 1;
			
			
			var ftType:String = resultObj.ftName as String;
			
			//if(basset.description ==="CULV")
				//trace("Adding CULVERT asset to diagram");
			
			placeAssetOnMap(basset);
			
			 //will need an array of switches based on asset type
			
			if (this.getChildByName(ftType) != null)
				(this.getChildByName(ftType) as Sprite).addChild(basset.symbol);
			else 
			{
				(_spriteLayers[ftType]).addChild(basset.symbol);
				
				(_spriteLayers[ftType]).visible = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.assetSwitch[basset.description];
						
				addFeature((_spriteLayers[ftType]), 101);
			}
			
			
			if ((_typeCounts[basset.description] as int) < 1)
			{	
				trace(basset.description + " DONE");
				FlexGlobals.topLevelApplication.decrementEventStack();
			}
					
		}
		
		public function placeAssetOnMap(asset:BaseAsset):void
		{
		//	var placement : Number = new Number(asset.subType);
			var milePoint : Number = asset.invProperties[asset.fromMeasureColName].value; // TODO: this should be asset.milepost, once ready.
				
			var assetSprite : AssetSymbol = asset.symbol;	
			assetSprite.x = Converter.scaleMileToPixel(milePoint-diagramRoute.beginMi,diagramScale) + offsetValue ;
			trace(asset.description +":" + milePoint + ":"+ assetSprite.x);
			assetSprite.y = height * assetSprite.placement_y / 100;
			if(asset.description === "INT")
			{
				//trace("Placing an Intersection on StickDiagram");
				testArray.push(asset.symbol);
				
			}
			
			if (assetSprite.centerH)
			{	
				if (assetSprite.rotation > 0)
					assetSprite.x += assetSprite.stdWidth/2;
				else
				{
					if(asset.description === "INCIDENT")
					{
						assetSprite.x -= assetSprite.stdWidth/2;
					}
					else
						assetSprite.x -= assetSprite.stdWidth/2;
				}
			}
			
			if(assetSprite.centerV)
			{
				if(assetSprite.rotation > 0)
					assetSprite.y -= assetSprite.stdHeight/2;
				else
					assetSprite.y += assetSprite.stdHeight/2;
			}
			
			// For placing culverts only
//			if (placement == 1)
//			{
//				assetSprite.y = height/2-assetSprite.height/2;
//				assetSprite.x += assetSprite.width/2 - 12; // -12 to help center when placing new sprite.
//			}	
//			else if (placement == 3 || placement == 4 || placement == 5)
//				assetSprite.y = height/6;
//			else
//				assetSprite.y = height/6 * 4;
			//assetSprite.width = diagramScale / 5000 * assetSprite.stdWidth;
			//assetSprite.height = diagramScale / 5000 * assetSprite.stdHeight;
		}
		
		/**
		 * Used to add elements to the StickDiagram sprite. 
		 */
		private function addFeature(feature:*, featureOrder:Number):void
		{
			if(!layerArray)
				return;
			if (feature != null)
			{
				layerArray.push({layer:feature, order:featureOrder, layerIndex:0});
				layerArray.sortOn("order", Array.NUMERIC);
				var newIndex:int = getNewLayerIndex(feature, featureOrder, 0);
				
				try
				{
					addChildAt(feature,newIndex);
				}
				catch (ex:Error) // Index out of bounds error. Kind of a hack fix. Change this. Actually, this whole process may be wrong.
				{
					addChild(feature);
				}
				correctLayerIndex(feature, featureOrder, newIndex);
				
			}
		}
		

		// TODO: Update for new Asset Framework.
		public function drawXingFeatToPDF(pdfU:PDFUtil,begMile:Number, endMile:Number, startX:Number, startY:Number, maxPixelsWide:Number ):void
		{	
			for each( var spr:Sprite in _spriteLayers)
			{
				var ac:ArrayCollection = new ArrayCollection();
				for each(var child:AssetSymbol in spr)
				{
					ac.addItem(child);
				}
				
				pdfBeginMi = begMile;
				pdfEndMi = endMile;
				ac.filterFunction = filterByBegEndmile;
				ac.refresh();
				drawFeaturesToPDF(pdfU,ac,spr.name, begMile, endMile, startX, startY, maxPixelsWide );
			}
			
				//elemt.drawElementToPDF(pdfU,elementColl[i].AC, new Route(this.diagramRoute.routeName,begMile,endMile) , startX, startY,maxPixelsWide, diagramScale);
		}
		
		private function filterByBegEndmile(obj:Object):Boolean{
			var mp:Number=-1;
			if(obj.hasOwnProperty("REFPT"))
				mp = new Number(String(obj.REFPT));
			else if(obj.hasOwnProperty("MILEPOST"))
				mp = new Number(String(obj.MILEPOST));
			
			return (mp>= pdfBeginMi && mp<=pdfEndMi) ;
		}
		
		
		// TODO: This is definitely broken, and it doesn't support the new Asset Framework. Fix it.
		public function drawFeaturesToPDF(pdfU:PDFUtil,ac:ArrayCollection, ftName:String,begMile:Number, endMile:Number, startX:Number, startY:Number, maxPixelsWide:Number):void
		{
					
			switch(ftName)
			{
				case COUNTY_LINE:
					countyLine.draw(ac,diagramScale, height, diagramRoute.beginMi);
					if(FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.countyLineSwitch)
						addFeature(countyLine, 40);
					break;
				case STREAM:
					stream.draw(ac,diagramScale, height, diagramRoute.beginMi);
					if(FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.streamSwitch)
						addFeature(stream, 30);
					break;
				case BRIDGE:
					bridge.draw(ac,diagramScale, height,diagramRoute.beginMi, 1, 1, true);
					if(FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.bridgeSwitch)
						addFeature(bridge, 70);
					break;
				case RRXING:
					railroad.draw(ac,diagramScale, height,diagramRoute.beginMi, 1, true);
					if(FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.rrxingSwitch)
						addFeature(railroad, 45);
					break;
				case INTERCHANGE:
					intersec.drawToPDF(pdfU,ac, begMile, endMile, startX, startY, diagramScale, maxPixelsWide);
					break;
				case SIGNC:
					sign.drawToPDF(pdfU,ac, begMile, endMile, startX, startY, diagramScale, maxPixelsWide);
					break;
				case CULV:
					//_culvert.drawToPDF(pdfU,ac, begMile, endMile, startX, startY, diagramScale, maxPixelsWide);
					break;
			}
			
		}
		
		//Meant to replace addLocalCulverts
		public function addLocalAssets(ac:ArrayCollection, description:String):void
		{
			var ftSprite:Sprite = _spriteLayers[description];
			
			for each(var asset:Object in ac)
			{
				if (asset == null)
					continue;
				
				var basset:BaseAsset;
				
				if (!(asset is BaseAsset))
				{
					basset = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.mapDataToBaseAsset(asset, description);
				}
				else
					basset = asset as BaseAsset;
				
				FlexGlobals.topLevelApplication.GlobalComponents.assetManager.assignAssetSymbol(basset, basset.assetType,null);
				placeAssetOnMap(basset);
				ftSprite.addChild(basset.symbol);	
			}
		}
		
		
		
		public function getAllMilePosts():Array
		{
			var array:Array = new Array();
			if(sign != null)
			{
				for(var i:int = 0; i < sign.numChildren; i++)
				{
					array.push(sign.getChildAt(i));
				}
			}
			return array;
		}
		
		public function getAllSignsByPostID(postAssemblyID:String):Array
		{
			var array:Array = new Array();
			if(_signArray != null && postAssemblyID!="")
			{
				for(var i:int = 0; i < _signArray.length; i++)
				{
					if(postAssemblyID ==String(( _signArray[i] as BaseAsset).invProperties["ASSEMBLY_ID"].value))
						array.push(_signArray[i]);
				}
			}
			return array;
		}
		public function getAllMilePostsAsBaseAssets():Array
		{
			var array:Array = new Array();
			if(sign != null)
			{
				for(var i:int = 0; i < sign.numChildren; i++)
				{
					array.push(AssetSymbol(sign.getChildAt(i)).baseAsset);
				}
			}
			return array;
		}	
		
		public function getSubsectionAtCurrentMP():BaseAsset
		{
			var subArray:ArrayCollection  = this._spriteLists["SUBSECTION"] as ArrayCollection;
			var subsection:BaseAsset= null;
		
			if(subArray)
			{
				for(var i:int = 0; i < subArray.length; i++)
				{
					if(this.currentMPoint() >= Number(( subArray[i] as BaseAsset).invProperties[( subArray[i] as BaseAsset).fromMeasureColName].value) && this.currentMPoint() <= (Number(( subArray[i] as BaseAsset).invProperties[( subArray[i] as BaseAsset).fromMeasureColName].value) + Converter.feetToMiles ( Number(( subArray[i] as BaseAsset).invProperties["LENGTH_FT"].value)) ))
						subsection = subArray[i] as BaseAsset;
				}
			}
			return subsection;
		}
		
		public function drawAsset(type:String):void
		{
			if(this.getChildByName(type)!=null)
				this.getChildByName(type).visible = true;
		}
		public function hideAsset(type:String):void
		{
			if(this.getChildByName(type))
			{
//				layerArray.splice(getLayerIndex(_spriteLayers[type]),1);
//				this.removeChild(this.getChildByName(type));
				this.getChildByName(type).visible = false;
			}
				
		}
		
		public function removeAsset(type:String):void
		{
			if(this.getChildByName(type))
			{
				layerArray.splice(getLayerIndex(_spriteLayers[type]),1);
				this.removeChild(this.getChildByName(type));
				
			}
			
		}
		public function drawMeasureBar():void
		{
			
			addFeature(fruler, 100);
		}
		public function removeMeasureBar():void
		{
			layerArray.splice(getLayerIndex(fruler),1);
			this.removeChild(this.getChildByName("MeasureBar"));
		}
		
		public function changeMeasureBarUnit(newUnit:Number):void
		{
			if(layerArray!=null && layerArray.length>0)
				layerArray.splice(getLayerIndex(fruler),1);
			if (this.getChildByName("MeasureBar") != null)
			{
				this.removeChild(this.getChildByName("MeasureBar"));
				fruler.draw(height,_gBarX*2,_gBarX,diagramScale,FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.dataUnits, newUnit);
				addFeature(fruler, 100);
			}
		}
		
		/**
		 * Draws assets and other graphics
		 */
		private function drawLayers():void{
			// add stored layer to stick diagram
			for(var i:int=0;i< layerArray.length;i++){
				addChild(layerArray[i].layer);
				layerArray[i].layerIndex =i;
			}
			
			// obtain HUD text
			HUDText = routeHUD.getChildByName("HUD_SPRITE");
		}
		
		
		public function moveHUD(posX:Number):void{
			if (HUDText != null)
				HUDText.x = posX-HUDText.width/2;
		}
			
		
		/**
		 * Returns an index according to which a sprite layer will be added to the diagram.
		 * Index based on index in layer array, 0 if layer isn't in layer array.
		 */
		private function getNewLayerIndex(layer:*, order:Number, layerIndex:Number):int
		{
			for (var i:int=0; i< layerArray.length ; i++)
			{
				if ( layerArray[i].layer == layer && layerArray[i].order == order && layerArray[i].layerIndex == layerIndex) 
					return i;
			}
			return 0;
		}
		
		private function getLayerIndex(layer:*):int
		{
			if(layerArray!=null)
			{
				for (var i:int=0; i< layerArray.length ; i++)
				{
					if ( layerArray[i].layer == layer) 
						return i;
				}
			}
			return -1;
		}
		
		private function correctLayerIndex(layer:*, order:Number, layerIndex:Number):void
		{
			for (var i:int=0; i< layerArray.length ; i++)
			{
				if ( layerArray[i].layer == layer && layerArray[i].order == order) 
				layerArray[i].layerIndex = layerIndex;
			}
			incrementLayerIndex(layerIndex);
		}
		
		private function incrementLayerIndex(startIndex:int):void
		{
			for (var i:int=startIndex; i< layerArray.length ; i++)
			{
				layerArray[i].layerIndex = i;
			}
		}
		
		public function clearContainer():void{
		
			while(this.numChildren > 0)
			{
				var dispObj:DisplayObject = this.getChildAt(0) as DisplayObject;
				this.removeChild(dispObj as DisplayObject);
			}
		}
		
		private function hasAllRouteChildren():Boolean
		{
			var allRoutes:Boolean = true;
			for(var i:int=0; i<=this.numChildren; i++)
			{
				var dispObj:DisplayObject = this.getChildAt(i) as DisplayObject;
				if(!(dispObj is Route))
				{
					allRoutes = false;
					break;
				}
			}
			return allRoutes;
		}
		
		public function updateCallOutXs(leftX:Number):void
		{
			leftViewMileMarkers.x = leftX;
			rightViewMileMarkers.x =  leftX+ (offsetValue*2)-50;
			//viewMileValueMarkers.x = leftX;
		}
				
		public function updateCallOutVals(leftMPu:Number, rightMPu:Number):void
		{
			leftViewMileMarkers.updateCallOutVal(leftMPu.toFixed(2),"leftValueCallOut");
			rightViewMileMarkers.updateCallOutVal(rightMPu.toFixed(2),"rightValueCallOut");

		}
		public function updateMileRange(leftMPu:Number, rightMPu:Number):void
		{
			leftMP =leftMPu;
			rightMP =rightMPu;
		}
		public function hideUpdateCallOutVals():void
		{
			leftViewMileMarkers.hideCallOutVal("leftValueCallOut");
			rightViewMileMarkers.hideCallOutVal("rightValueCallOut");
		}
		
		public function updateMeasureBarX(leftX:Number):void
		{
			fruler.moveMeasureBar(leftX);
		}
		
		public function get route():Route{
			return diagramRoute;
		} 
		
		public function set route(rte:Route):void{
			diagramRoute = rte;
		}
		
		public function get culvert():BaseAsset{
			return _culvert;
		}
		
		public function removeGuideBar():void{
			this.getChildByName("GUIDE_BAR_SPRITE").visible = false;
		}
		
		
		
		public function refreshCulvert():void{
			this.removeChild(this.getChildByName("CULVERT"));
			addFeature(_culvert, 95);
		}
		
		public function refreshAsset(type:String):void
		{
			var disp:DisplayObject = this.removeChild(this.getChildByName(type));
			addFeature(disp, 95); // May need new ordering
		}
		
		public function reapplySymbol(symbol:AssetSymbol):void
		{
			if(symbol.baseAsset.description !== "MILEMARKER")
				(_spriteLayers[symbol.baseAsset.description] as Sprite).addChild(symbol);
			else
			{
				symbol.x -= symbol.stdWidth/2;
				sign.addChild(symbol);
			}
				
			
		}
		
		public function applyAssetToDiagram(type:String, asset:BaseAsset, refresh:Boolean = true, multiples:Boolean= false):void
		{
			
			var dispSprite:Sprite;
			var alreadyAdded:Boolean = false; 
			if (_spriteLayers[type] != null && this.contains(_spriteLayers[type]))
			{
				dispSprite = this.getChildByName(type) as Sprite;
				alreadyAdded = true;
			}
			else
			{
				dispSprite = _spriteLayers[type];
				dispSprite.name = type;
			}
			
			
			var nodule:DisplayObject = dispSprite.getChildByName(asset.symbol.name);
			if (nodule)
				dispSprite.removeChild(asset.symbol);
			
			FlexGlobals.topLevelApplication.GlobalComponents.assetManager.assignAssetSymbol(asset, asset.assetType,null,multiples);
			
			/*
			 * Old symbol thrown away, so need to select this symbol in order to deselect.
			 */
			asset.symbol.selectAsset();
			asset.symbol.deselectAsset();
			
			placeAssetOnMap(asset);
			dispSprite.addChild(asset.symbol);
			dispSprite.visible = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.assetSwitch[asset.description];
			if(type =="SIGN")
				this._signArray.addItem(asset);
			
			
			
			if(this.cachedAssets.hasOwnProperty(type))
			{
				if (this.cachedAssets[type] == null)
					this.cachedAssets[type] = new ArrayCollection();
				
				(this.cachedAssets[type] as ArrayCollection).addItem(asset);
			}
			if(!alreadyAdded)
			{
				addFeature(dispSprite, 100);
			}
			
		} 
		
		public function drawGuideBar():void
		{
			
			if (this.getChildByName("GUIDE_BAR_SPRITE") == null)
			{
				guideBar.draw(_gBarX,this.height,width,90, gbBbuttonMode,gbUseHandCursor);
				guideBar.name = "GUIDE_BAR_SPRITE";
				this.addChildAt(guideBar, this.numChildren - 1);
				if (!FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.guideBarSwitch)
					guideBar.visible = false;
				if(layerArray)
					layerArray.push({layer:guideBar, order:110, layerIndex:0});
			}
			else
			{
				//this.setChildIndex(this.getChildByName("GUIDE_BAR_SPRITE"),this.numChildren-1);
				//removeGuideBar();
				//guideBar.draw(gBarX,this.height,width,90, gbBbuttonMode,gbUseHandCursor);
				//guideBar.name = "GUIDE_BAR_SPRITE";
				//if (FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.guideBarSwitch)
					//this.addChildAt(guideBar, 0);
				//layerArray.push({layer:guideBar, order:90, layerIndex:0});
				if (FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.guideBarSwitch)
					guideBar.visible = true;
			}
		}
		
		
		
		public function xingFeaturesToJSON():String
		{
			// iterates through featureStore to remove inherited complexities involved with ArrayCollections
			// net result is 50%+ reduction in JSON string size
			var featArr:Array = [];
			
			for (var layerProp:String in _spriteLayers)
			{
				var typeObject:Object = new Object();
				var typeArray:Array = new Array();
				typeObject.Name = layerProp;
				var layer:Sprite = _spriteLayers[layerProp] as Sprite;
				
				if (!layer)
					continue;
				for (var i:int = 0; i < layer.numChildren; i++)
				{
					var sprasset:AssetSymbol = layer.getChildAt(i) as AssetSymbol;
					var jsonObj:Object = sprasset.baseAsset.toDynamicObject();
					typeArray.push(jsonObj);
				}
				
				if(layerProp=="MILEMARKER" && typeArray.length==0)
				{
					var milmrkrs:Array = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.filteredMileMarkers.source;
					for (var j:int = 0; j < milmrkrs.length; j++)
					{
						
						var jsonObj:Object = milmrkrs[j].toDynamicObject();
						typeArray.push(jsonObj);
					}
					
				}
				
				typeObject.ArrayColl = typeArray;
				featArr.push(typeObject);
			}
			
			return JSON.stringify(featArr);
		}
		
		public function JSONToMileMarkers(jsonText:String, begin:Number, end:Number):ArrayCollection
		{
			var mmCollection:ArrayCollection = new ArrayCollection();
			// decodes JSON and replaces existing array collections
			var fStore:Array = JSON.parse(jsonText) as Array;
			
			var assetMan:CoreAssetManager = FlexGlobals.topLevelApplication.GlobalComponents.assetManager as CoreAssetManager;
			
			for each (var obj:Object in fStore)
			{
				//extract milemarkers
				if(obj.Name == "MILEMARKER" && obj.hasOwnProperty("ArrayColl"))
				{
					var mileMarkerObjColl:ArrayCollection = getMileMarkersFromCollection(begin,end,new ArrayCollection(obj.ArrayColl));
					var mileMarkerArr:Array = new Array();
					//var mileMarkerArr:Array= assetMan.mapAssetColl(mileMarkerObjColl,"MILEMARKER");
					for each (var rawAsset:Object in mileMarkerObjColl)
					{
						var rawAsset2:Object = new Object();
						for (var prop:String in rawAsset)
						{
							rawAsset2[prop.toUpperCase()] = rawAsset[prop];
							//delete rawAsset[prop];
						}
						var asset:BaseAsset = assetMan.mapDataToBaseAsset(rawAsset2, obj.Name);
						mileMarkerArr.push(asset);
					}
					mmCollection= new ArrayCollection(mileMarkerArr); 
				}
				
			}
			return mmCollection;
		}
		public function JSONToXingFeatures(jsonText:String, begin:Number, end:Number):void
		{
			this.cachedAssets  = new Dictionary();
			var mmCollection:ArrayCollection = new ArrayCollection();
			// decodes JSON and replaces existing array collections
			var fStore:Array = JSON.parse(jsonText) as Array;
			//trace(jsonText);
			for(var i:int=0; i<fStore.length;i++)
			{
				var ac:ArrayCollection = new ArrayCollection();
				var tmpObj:Object = fStore[i].ArrayColl;
				
				if (tmpObj == null)
					continue;
				
				for(var j:int=0; j<tmpObj.length;j++)
				{
					var sObj:Object = tmpObj[j];
					ac.addItem(sObj);
				}

				fStore[i].ArrayColl = ac;
			}
			// replace current featureStore
			//this.cachedAssets = new ArrayCollection(fStore);
			var assetMan:CoreAssetManager = FlexGlobals.topLevelApplication.GlobalComponents.assetManager as CoreAssetManager;
			
			for each (var obj:Object in fStore)
			{
				if (!assetMan.hasType(obj.Name))
					continue;
				if (!this.cachedAssets.hasOwnProperty(obj.Name))
					this.cachedAssets[obj.Name] = new ArrayCollection();
				if (!obj.hasOwnProperty("ArrayColl"))
					continue;
				
				
					
				
				for each (var rawAsset:Object in obj.ArrayColl)
				{
					var rawAsset2:Object = new Object();
					for (var prop:String in rawAsset)
					{
						rawAsset2[prop.toUpperCase()] = rawAsset[prop];
						//delete rawAsset[prop];
					}
					var asset:BaseAsset = assetMan.mapDataToBaseAsset(rawAsset2, obj.Name);
					var name:String = obj.Name;
					var milepoint:Number = asset.invProperties[asset.fromMeasureColName].value;
					
					if(asset.invProperties[asset.typeKey] && asset.invProperties[asset.typeKey].value === "D10-1")
					{
						//trace("TYPE IS: " + asset.description);
						name = "MILEMARKER";
						
						asset = assetMan.mapDataToBaseAsset(rawAsset2, name);
						if (!this.cachedAssets.hasOwnProperty("MILEMARKER"))
							this.cachedAssets[name] = new ArrayCollection();
						//trace("TYPE2 IS: " + asset.description);
						
						if(milepoint >= begin && milepoint <= end)
							this.cachedAssets[name].addItem(asset);
						

					} else
					{
						
						if(milepoint >= begin && milepoint <= end)
							this.cachedAssets[name].addItem(asset);
					}
					
				}
			}
			
			
			//sign.draw(mmCollection, this.scale(),this.height,this.route.beginMi);
			//if (FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.milepostSwitch)
			//addFeature(sign, 96);
			//trace("Hello");
		}
		
		private function getMileMarkersFromCollection(begin:Number,end:Number, arr:ArrayCollection):ArrayCollection {
			var cmenuFiltered:ArrayCollection = new ArrayCollection(arr.toArray());
			
			cmenuFiltered.filterFunction =
				function(item:Object):Boolean {
					return (Number(item.feature_name) >=begin && Number(item.feature_name) <=end) ;
				}
			
			cmenuFiltered.refresh();
			
		
			return cmenuFiltered;
		}
		
		public function getCachedAssetByType(typ:String):ArrayCollection
		{
			return this.cachedAssets[typ];
		}
		
		public function includeLocalAssets(evtRoute:Route):void
		{
			var arr:ArrayCollection;
			var toAddArr:ArrayCollection;
			for (var type:String in this.cachedAssets)
			{
				arr = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.getAssetsByRoute(type,evtRoute);
				
				var tempAsset:BaseAsset;
				toAddArr = new ArrayCollection();
				
				//Nested loops used for resolving collisions.
				for(var j:int=0; j < arr.length;j++)
				{
					for(var i:int=0; i < cachedAssets[type].length; i++)	
					{
						tempAsset = arr.getItemAt(j) as BaseAsset;
						if(tempAsset.id == cachedAssets[type].getItemAt(i).id)
						{
							cachedAssets[type].removeItemAt(i);
							//cachedAssets[type].addItem(tempAsset);
						}/*else
						{
							toAddArr.addItem(tempAsset);	
						}*/
					}	
				}
				cachedAssets[type].addAll(arr);
			}
			
			for(var type2:String in cachedAssets)
			{
				_spriteLists[type2] = new ArrayCollection();
				_spriteLists[type2].addAll(cachedAssets[type2]);
			}
			
		}
		
		public function scale():Number
		{
		 return diagramScale;
		}	
		
		public function currentMPoint():Number
		{
			var mp:Number = Converter.scalePixelToMile(guideBar.getXPosition() + _gBarX - offsetValue, diagramScale) + route.beginMi; 
			return mp;
		}
		public function currentMPost():Number
		{
			return this.routeHUD.currentMilePost();
		}
		
		/**
		 * Purpose is to limit the number of visible/present assets in order to improve performance.
		 */
		public function displayAssetsInRange():void
		{
			FlexGlobals.topLevelApplication.setBusyStatus(true);
			var diff:Number = Converter.scaleMileToPixel(rightMP,diagramScale) -  Converter.scaleMileToPixel(leftMP,diagramScale);
			var min:Number = Converter.scaleMileToPixel(leftMP,diagramScale) - diff - Converter.scaleMileToPixel(route.beginMi, diagramScale);
			var max:Number = Converter.scaleMileToPixel(rightMP,diagramScale) + diff - Converter.scaleMileToPixel(route.beginMi, diagramScale);
			var ax:Number;
			for each(var spriteLayer:Sprite in _spriteLayers)
			{
				var spriteArray:ArrayCollection = _spriteLists[spriteLayer.name];
				for(var i : int = 0; spriteArray != null && i < spriteArray.length; i++)
				{
					var assetSymbol:AssetSymbol = spriteArray.getItemAt(i).symbol;//spriteLayer.getChildAt(i) as AssetSymbol;
					//if((assetSymbol.baseAsset.invProperties["MILEPOST"].value  > min) && (assetSymbol.baseAsset.invProperties["MILEPOST"].value < max))
					
					if((assetSymbol.x > min || assetSymbol.x + assetSymbol.width > min) && assetSymbol.x < max &&  (FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.assetSwitch[assetSymbol.baseAsset.description]))
					{
						assetSymbol.visible = true;
						//spriteLayer.addChild(assetSymbol);
					}		
					else if(spriteLayer.contains(assetSymbol)&&  (FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.assetSwitch[assetSymbol.baseAsset.description]))
						assetSymbol.visible = false;
					else
						assetSymbol.visible = false;
				
						//spriteLayer.removeChild(assetSymbol);
				}
				spriteLayer.visible = false;
				spriteLayer.visible = true;
			}
			FlexGlobals.topLevelApplication.setBusyStatus(false);
		}

		public function get milepostArray():ArrayCollection
		{
			return _milepostArray;
		}

		public function set milepostArray(value:ArrayCollection):void
		{
			_milepostArray = value;
		}
		
		public function set gBarX(value:Number):void
		{
			_gBarX = value;
		}
		
		public function get gBarX():Number
		{
			return _gBarX;
		}
		
		public function getSpriteAssets(description:String):ArrayCollection
		{
			return _spriteLists[description];
		}
		
		public function removeGeoTag(tssmedia:Object):void
		{
			this.removeChild(tssmedia as DisplayObject);
		}
		
		public function get routeGeotags():Array
		{
			return _routeGeotags;
		}
		public function set routeGeotags(a:Array):void
		{
			_routeGeotags=a;
		}
		
		public function get spriteLists():Object
		{
			return _spriteLists;
		}
	}
}