package com.transcendss.transcore.sld.models.components
{
	import com.transcendss.transcore.util.AssetSymbol;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.core.FlexGlobals;

	public class BaseAsset
	{
		private var _assetType:String;
		private var _subType:String; // not yet set, need access to database
		private var _primaryKey:String;
		private var _routeIDColName:String;
		private var _fromMeasureColName:String;
		private var _lengthColName:String;
		private var _lengthUnit:String;
		private var _toMeasureColName:String;
		private var _typeKey:String;
		private var _valueKey:String;
		private var _invProperties:Object; // hashmap
		private var _inspProperties:Object;
		private var _description:String;
		private var dtypes : Object = {"AbutmentList":["Concrete", "Wood", "Not Applicable"],"BeamList":["Concrete", "Steel", "Not Applicable"]};
		private var _id:Number; // Some value != -1 if asset is in table
		private var _symbol:AssetSymbol;
		private var _numProperties:int = 0;
		private var _milePost:Number;
		private var _useCustomForm:String;
		private var _geotagsArray:ArrayCollection;
		private var _status:String ='NEW';
		
		public function BaseAsset(template : Object=null)
		{
			_symbol = new AssetSymbol(this);
			if(template != null)
			{
				var templateName:String = template.hasOwnProperty("ASSET_DATA_TEMPLATE") ? "ASSET_DATA_TEMPLATE" : "BAR_ELEMENT_DATA_TEMPLATE";
				if(templateName == "ASSET_DATA_TEMPLATE")
					_assetType = template[templateName].ASSET_TYPE;
				else
					_assetType = template[templateName].ELEMENT_TYPE;
				_description = template[templateName].DESCRIPTION;
				_primaryKey = template[templateName].PRIMARY_KEY;
				_routeIDColName = template[templateName].ROUTE_ID_COLUMN;
			    _fromMeasureColName= template[templateName].FROM_MEASURE_COLUMN;
				_toMeasureColName= template[templateName].TO_MEASURE_COLUMN;
				_lengthColName = template[templateName].LENGTH_COLUMN;
				_lengthUnit = template.LENGTH_UNIT;
				_typeKey = template.TYPE_KEY;
				_valueKey = template[templateName].VALUE_KEY;
				buildProperties(template, "INV");
				if(templateName == "ASSET_DATA_TEMPLATE")
					buildProperties(template, "INSP");
				_id = -1;
				
				if(templateName == "ASSET_DATA_TEMPLATE")
					_useCustomForm = template.FORM_CLASS as String;
				
			}
			else
			{
			}
			
		}
		
		public function toDynamicObject():Object
		{
			var dyna:Object = new Object();
			for (var prop:String in this._invProperties)
				dyna[prop] = _invProperties[prop].value;
			
			for (var prop2:String in this._inspProperties)
				dyna[prop2] = _inspProperties[prop2].value;
			
			return dyna;
		}
		
		private function buildProperties(template : Object, invOrInsp:String):void
		{
			var templateName:String = template.hasOwnProperty("ASSET_DATA_TEMPLATE") ? "ASSET_DATA_TEMPLATE" : "BAR_ELEMENT_DATA_TEMPLATE";
			var invArray : Object;
			var property : Object; // refers to property object in JSON
			var propertyObj : Object; //  refers to property object in ActionScript
			
			if(invOrInsp === "INV")
			{
				invArray = template[templateName].INV_COLUMNS;
				_invProperties = new Object();
				propertyObj = _invProperties;
			}
			else if(invOrInsp === "INSP")
			{
				invArray = template[templateName].INSP_COLUMNS;
				_inspProperties = new Object();
				propertyObj = _inspProperties;
			}
			
			for(var i : int = 0; i < invArray.length; i++)
			{
				property = invArray[i];
				var d_arr : ArrayList = new ArrayList();
				var pd_str : String = property.D_TYPE  as String;
				var pd_arr : Array = dtypes[pd_str];
				
				if(pd_arr != null)
				{
					for(var eli : int = 0; eli < pd_arr.length; eli++)
					{
						d_arr.addItem(pd_arr[eli]);
					}
				}
				
				// ********* TEST CODE: value should be set to appropriate value from database! ************
				propertyObj[property.NAME] = {name:property.NAME,type:property.TYPE, value:null, d_type: property.D_TYPE, nullable:property.Nullable};
				
			}
			
		}
		
		/*public function clone():BaseAsset
		{
			var cloned:BaseAsset = ObjectUtil.clone(this) as BaseAsset;
			return cloned;
		}*/
		
		public function setInspProperty(property : String, value : Object):void
		{
			_inspProperties[property] = value;
		}
		
		public function setInvProperty(property : String, value :Object):void
		{
			_invProperties[property] = value;
		}

		public function get inspProperties():Object
		{
			return _inspProperties;
		}

		public function set inspProperties(value:Object):void
		{
			_inspProperties = value;
		}

		public function get invProperties():Object
		{
			return _invProperties;
		}

		public function set invProperties(value:Object):void
		{
			_invProperties = value;
		}

		public function get primaryKey():String
		{
			return _primaryKey;
		}
		
		public function get routeIDColName():String
		{
			return this._routeIDColName;
		}
		
		public function get fromMeasureColName():String
		{
			return this._fromMeasureColName;
		}
		
		public function get lengthMeasureColName():String
		{
			return this._lengthColName;
		}
		
		public function get lengthUnit():String
		{
			return this._lengthUnit;
		}
		
		public function get toMeasureColName():String
		{
			return this._toMeasureColName;
		}

		public function set primaryKey(value:String):void
		{
			_primaryKey = value;
		}

		public function get subType():String
		{
			if (_invProperties[_typeKey])
			{
				if (_invProperties[_typeKey].type == "INTEGER" || _invProperties[_typeKey].type == "TEXT")
					return new String(_invProperties[_typeKey].value);
				else 
					return "-2";
			}
			else
				return "1";
		}

		public function set subType(value:String):void
		{
			if (_invProperties[_typeKey])
			{
				if (_invProperties[_typeKey].type == "TEXT")
				{
					_invProperties[_typeKey].value = value;
					_subType = value;
				}
				else if (_invProperties[_typeKey].type == "INTEGER")
				{
					_invProperties[_typeKey].value = new int(value);
					_subType = value;
				}
				else
				{
					_subType = "-2";
				}
			}
			else
			{
				_subType = value;
			}
		}

		public function get assetType():String
		{
			return _assetType;
		}

		public function set assetType(value:String):void
		{
			_assetType = value;
		}
		
		public function get description():String
		{
			return _description;
		}
		
		public function set description(value:String):void
		{
			_description = value;
		}
		
		public function toString():String 
		{
			var res : String = "";
			res += "Inventory\n";
			for each (var obj : Object in _invProperties)
			{
				res += obj.name + ": " + obj.value + "\n";
			}
			res += "Inspection\n";
			for each (var obj2 : Object in _inspProperties)
			{
				res += obj2.name + ": " + obj2.value + "\n";
			}
			
			
			return res;
		}
		
		public function get id():int
		{
			return _id;
		}
		
		public function set id(value:int):void
		{
			if(invProperties[_primaryKey])
				invProperties[_primaryKey].value = value.toString();
			_id = value;
		}
		
		public function setupSprite():void
		{
			//_symbol.addEventListener(MouseEvent.CLICK, onSpriteClick);
			//_symbol.name = String(cLength)+ " ft";
			_symbol.buttonMode = true;
			_symbol.useHandCursor = true;	
			
		}
		
		private function onSpriteClick(evt:MouseEvent):void
		{
			FlexGlobals.topLevelApplication.editCulvert(evt.target as Culvert);
			
		}

		public function get symbol():AssetSymbol
		{
			return _symbol;
		}

		public function set symbol(value:AssetSymbol):void
		{
			_symbol = value;
		}

		public function get numProperties():int
		{
			return _numProperties;
		}

		public function set numProperties(value:int):void
		{
			_numProperties = value;
		}

		public function get milePost():Number
		{
			return _milePost;
		}

		public function set milePost(value:Number):void
		{
			_milePost = value;
		}

		public function get useCustomForm():String
		{
			return _useCustomForm;
		}
		
		public function get routeName():String
		{
			if (invProperties[this.routeIDColName])
				return invProperties[this.routeIDColName].value;
			
			else 
				return "";
		}
		
		public function set subtypeDirect(st:String):void
		{
			_subType = st;
		}
		
		public function get subtypeDirect():String
		{
			return _subType;
		}

		public function get typeKey():String
		{
			return _typeKey;
		}
		
		public function get valueKey():String
		{
			return _valueKey;
		}
		
		public function set geotagsArray(st:ArrayCollection):void
		{
			_geotagsArray = st;
		}
		
		public function get geotagsArray():ArrayCollection
		{
			return _geotagsArray;
		}
		
		public function get status():String
		{
			return _status;
		}
		
		public function set status(s:String):void
		{
			_status = s;
		}
		
		//To be Used only in MAVRIC
		public function setAssetLocation(latProp:String, longProp:String, refptVal:Number=NaN,latVal:String="",longVal:String ="", precVal:String=""):void
		{
			if(FlexGlobals.topLevelApplication.sldDiagram.sldDiagram.captureBar)
			{
				this.invProperties[latProp].value = latVal!=""?latVal:FlexGlobals.topLevelApplication.sldDiagram.sldDiagram.captureBar.Lat;
				this.invProperties[longProp].value =longVal!=""?longVal:FlexGlobals.topLevelApplication.sldDiagram.sldDiagram.captureBar.Long;
				if (FlexGlobals.topLevelApplication.useInternalGPS)
				{
					this.invProperties["PRECISION"].value =precVal!=""?precVal:FlexGlobals.topLevelApplication.sldDiagram.sldDiagram.captureBar.Precision;
					this.invProperties["PDOP"].value ="";
				}
				else if (FlexGlobals.topLevelApplication.useInternalGPS )
				{
					this.invProperties["PRECISION"].value ="";
					this.invProperties["PDOP"].value =precVal!=""?precVal:FlexGlobals.topLevelApplication.sldDiagram.sldDiagram.captureBar.Precision;
				}
				this.invProperties[this._fromMeasureColName].value = !isNaN(refptVal)?refptVal: FlexGlobals.topLevelApplication.sldDiagram.sldDiagram.getCurrentMP();
			}
		}

	}
}