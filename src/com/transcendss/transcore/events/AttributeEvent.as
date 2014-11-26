package com.transcendss.transcore.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class AttributeEvent extends Event
	{
		public static const ATTRIBUTE_REQUEST:String = "attributeEvent_atrRequest";
		public static const ATTRIBUTE_READY:String = "attributeEvent_attrReady";
		public static const ATTRIBUTE_SAVE:String = "attributeEvent_attrSave";
		
		private var _serviceURL:String ;
		private var _data:ArrayCollection = new ArrayCollection();
		private var _milePoint:Number = new Number();
		private var _emilePoint:Number = new Number();
		private var _bmilePoint:Number = new Number();
		private var _id:Number = new Number();
		private var _rowid:Number = new Number();
		private var _value:*;
		private var _desc:String ;
		private var _clicky:int;
		private var _clickx:int;
		private var _attrType:String;
		private var _routeName:String;
		private var _routeFullName:String;
		
		
		
		public function AttributeEvent(type:String, milepoint:Number = 0, data:ArrayCollection = null, clickY:int=0, clickX:int=0,bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
			_data = data;
			_milePoint = milepoint;
			_clicky=clickY;
			_clickx = clickX;
		}
		
		public function set ClickY(Y:int):void{
			_clicky = Y;
		}
		public function get ClickY():int{
			return _clicky;
		}
		
		public function set ClickX(X:int):void{
			_clickx = X;
		}
		public function get ClickX():int{
			return _clickx;
		}
		
		public function set serviceURL(url:String):void{
			_serviceURL =  url;
		}
		public function get serviceURL():String{
			return _serviceURL;
		}
		
		public function get data():ArrayCollection { return _data; } 
		
		public function set data(dt:ArrayCollection):void{
			_data =  dt;
		}
		
		public function get milePoint():Number {return _milePoint;}
		
		public function set milePoint(mp:Number):void {_milePoint =mp;}
		
		public function get bmilePoint():Number {return _bmilePoint;}
		
		public function set bmilePoint(mp:Number):void {_bmilePoint =mp;}
		
		public function get emilePoint():Number {return _emilePoint;}
		
		public function set emilePoint(mp:Number):void {_emilePoint =mp;}
		
		public function get attrid():Number {return _id;}
		
		public function set attrid(i:Number):void {_id =i;}
		
		public function get rowid():Number {return _rowid;}
		
		public function set rowid(rid:Number):void {_rowid =rid;}
				
		public function get value():* {return _value;}
		
		public function set value(val:*):void {_value =val;}
		
		public function get desc():String {return _desc;}
		
		public function set desc(d:String):void {_desc =d;}
		
		public function get attrType():String {return _attrType;}
		
		public function set attrType(d:String):void {_attrType =d;}
		
		public function get routeName():String {return _routeName;}
		
		public function set routeName(d:String):void {_routeName =d;}
		
		public function get routeFullName():String {return _routeFullName;}
		
		public function set routeFullName(d:String):void {_routeFullName =d;}
	}
}