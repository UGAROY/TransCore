package com.transcendss.transcore.util
{
		
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	
	import mx.core.FlexGlobals;
	import mx.utils.ObjectUtil;
	
	
	public class BaseSymbol extends Sprite implements IDraggableSymbol
	{
		private var _id:Number;
		private var _symbolType:String;
		private var _selectRect:Shape = new Shape();
		private var _symbolSprite:Sprite = new Sprite();
	//	public var symMoveGroup:Array = FlexGlobals.topLevelApplication.spriteMoveGroup;
		private var _manualRotation:Number = 0;
		private var _memberID:String = "";
		private var _tableName:String ="";
		private var groupMembers:String;
		//private var draggableSprites:Vector.<BaseSymbol> = FlexGlobals.topLevelApplication.draggableSprites;
		private var selFtn:String;
		
		
		public function BaseSymbol()
		{
			super();
		}
		
		public function get manualRotation():Number
		{
			return _manualRotation;
		}

		public function set manualRotation(value:Number):void
		{
			_manualRotation = value;
		}

		public function get symbolSprite():Sprite
		{
			return _symbolSprite;
		}

		public function set symbolSprite(value:Sprite):void
		{
			_symbolSprite = value;
		}

		public function get symbolType():String
		{
			return _symbolType;
		}
		
		public function set symbolType(value:String):void
		{
			_symbolType = value;
		}
		
		public function get id():Number
		{
			return _id;
		}
		
		public function set id(value:Number):void
		{
			_id = value;
		}
		
		public function get memberID():String
		{
			return _memberID;
		}
		
		public function set memberID(value:String):void
		{
			_memberID = value;
		}
		
		public function get tableName():String
		{
			return _tableName;
		}
		
		public function set tableName(value:String):void
		{
			_tableName = value;
		}
			
		
		/*public function selectRectVis():void{
			var rect:DisplayObject = symbolSprite.getChildAt(0);
			rect.visible = true;
		}
		*/
		// Latest clone attempt
		public function clone() : BaseSymbol
		{
			registerClassAlias("com.transcendss.railanalyzer.symbols.BaseSymbol", BaseSymbol);
			var obj:Object = ObjectUtil.clone(this);
			var bs1:BaseSymbol   = obj as BaseSymbol;
			return bs1;
		}
		
//		public function EnableSelection():void
//		{
//			symbolSprite.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
//		}
//		
//		private function getGroupMembers():void
//		{
//			var urlReq:URLRequest = new URLRequest("http://ec2-23-22-137-217.compute-1.amazonaws.com/NFSRailService/RAService.svc/GroupMembers/" + this.memberID);
//			var urlLdr:URLLoader = new URLLoader();
//			urlLdr.addEventListener(Event.COMPLETE, handleGroupEvent);
//			urlLdr.load(urlReq);
//		}
//		
//		private function handleGroupEvent(e:Event):void
//		{
//			switch (e.type) {
//				case Event.COMPLETE:
//					var ldr:URLLoader = e.currentTarget as URLLoader;
//					var groupMemJSON:String = ldr.data;
//					
//					if (selFtn == "select")
//					{
//						selectSymbols(groupMemJSON);
//					} else
//					{
//						deselectSymbols(groupMemJSON);
//					}
//						
//					
//					break;
//			}
//		}
		
//		private function selectSymbols(groupMemJSON:String):void{
//			var groupMemData:Object = (JSON.parse(groupMemJSON));
//			var groupMemArray:Array = groupMemData.GroupMembers;
//			
//			if (groupMemArray != null)
//			{
//				for (var i:int=0; i<groupMemArray.length; i++)
//				{
//					var tmpMemID:String = groupMemArray[i].MEMBER_ID;
//					for (var j:int=0; j<draggableSprites.length; j++)
//					{
//						if (draggableSprites[j].memberID == tmpMemID)
//						{
//							symMoveGroup.push(draggableSprites[j]);
//							draggableSprites[j]._selectRect.visible = true;
//						}
//					}
//				}
//			}
//			
//		}
//		
//		private function deselectSymbols(groupMemJSON:String):void
//		{
//			var groupMemData:Object = (JSON.parse(groupMemJSON));
//			var groupMemArray:Array = groupMemData.GroupMembers;
//			
//			if (groupMemArray != null)
//			{
//				for (var i:int=0; i<groupMemArray.length; i++)
//				{
//					var tmpMemID:String = groupMemArray[i].MEMBER_ID;
//					for (var j:int=0; j<draggableSprites.length; j++)
//					{
//						if (draggableSprites[j].memberID == tmpMemID)
//						{
//							var symPos:int = symMoveGroup.indexOf(draggableSprites[j]);
//							symMoveGroup.splice(symPos, 1);
//							draggableSprites[j]._selectRect.visible = false;
//							//symMoveGroup.push(draggableSprites[j]);
//							//draggableSprites[j].selectRect.visible = true;
//						}
//					}
//				}
//			}
//		}
//		
//		protected function onMouseUp(event:MouseEvent):void
//		{
//			var tool:String = FlexGlobals.topLevelApplication.currentTool;
//			if (tool == "select")
//			{
//				var symPos:int = symMoveGroup.indexOf(this);				
//				
//				if (!event.ctrlKey)
//				{
//					clearSelectArray(symMoveGroup);
//				}
//				
//				if (symPos >= 0)
//				{
//					if (this.memberID != "")
//					{
//						selFtn = "deselect";
//						getGroupMembers();
//					} else
//					{
//						symMoveGroup.splice(symPos, 1);
//						_selectRect.visible = false;
//					}
//					
//				} else
//				{
//					if (this.memberID != "")
//					{
//						selFtn = "select";
//						getGroupMembers();
//					} else
//					{
//						symMoveGroup.push(this);
//						_selectRect.visible = true;
//					}
//				}
//			}
//		}
		
		public function clearSelectArray(array:Array):void{
			for (var i:int=array.length - 1; i >= 0; i--)
			{
				//var rect:Shape = array[i].getChildAt(0);
				var tmpSym:BaseSymbol = array[i] as BaseSymbol;
				tmpSym._selectRect.visible = false;
				array.pop();
			}
		}

		public function get selectRect():Shape
		{
			return _selectRect;
		}

		public function set selectRect(value:Shape):void
		{
			_selectRect = value;
		}

		
	}
}

