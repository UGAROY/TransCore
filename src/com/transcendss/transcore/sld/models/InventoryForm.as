package com.transcendss.transcore.sld.models
{
	
	import com.transcendss.transcore.events.AttributeEvent;
	import com.transcendss.transcore.sld.models.components.*;
	import com.transcendss.transcore.util.*;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.*;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.*;
	import mx.core.UIComponent;
	import mx.events.FlexMouseEvent;
	
	import spark.components.Button;
	import spark.components.DropDownList;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.RadioButton;
	import spark.components.RadioButtonGroup;
	import spark.components.TextArea;
	import spark.components.TextInput;
	import spark.components.VGroup;
	import spark.components.supportClasses.Skin;
	import spark.events.*;
	import spark.layouts.VerticalLayout;
	

	public class InventoryForm extends UIComponent
	{	
		private var content:DisplayObject ;
		public function InventoryForm(c:DisplayObject)
		{
			super();
			content = c;
			
			setUpContent();
		}
		
		private function setUpContent():void
		{
			if(content !=null)
				this.addChild(content);
		}
		
		
	}
}