package com.transcendss.transcore.sld.models.interfaces
{
	import com.transcendss.transcore.sld.models.components.*;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import mx.core.IVisualElement;
	
	public interface IAssetDiagram
	{
		
		// Constructor
		function IAssetDiagram(route:Route=null,scale:Number=50000):void;
		//--------------------------------------
		//  Diagram Initialization
		//--------------------------------------										
		function updateRoute(route:Route,scale:Number, fromStorage:Boolean=false, view:Number=0):void;
		
		//--------------------------------------
		//  Diagram Initialization
		//--------------------------------------
		function initStick(route:Route=null):void;
		//function initInventory(route:Route=null, scale:Number = 50000):void;
		function initInventory(content:IVisualElement):void;
		
		//--------------------------------------
		//  Tooltip Methods
		//--------------------------------------
		function addToolTip(tooltip:Sprite,dType:int):void;
		function removeToolTip(tooltip:Sprite,dType:int):void;
		
		//--------------------------------------
		//  Guide Bar Methods 
		//--------------------------------------
		function turnGuideBarOff():void;
		function turnGuideBarOn():void; 
		
		//--------------------------------------
		//  Member Methods
		//--------------------------------------	
		function set sldBorderWidth(val:Number):void;
		function set invBorderWidth(val:Number):void;
		
		function get scale():Number;
		
		function get viewMile():Number;
		function set viewMile(vMile:Number):void;
		
		function get getRoute():Route;
	}
}