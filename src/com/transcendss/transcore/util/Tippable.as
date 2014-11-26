package com.transcendss.transcore.util
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;

	public class Tippable extends Sprite
	{
		
		public static const SLD:int = 1;
		public static const INVENTORY:int = 2;
		
		private var diagramType:int;
		private var _tipText:String = "Default";
		public var tipTextColor:Number = 0x4444444;
		public var tipBGColor:Number = 0xfaff70;
		public var tipBorderColor:Number = 0xc0c0c0;
		public var tipDir:String = "up";
		public var tipDist:int = 5;
		public var tipUseArrow:Boolean = true;
		public var tipAlpha:int = 1;
		public var tipWidth:int = 50;
		public var tipHeight:int = 18;
		public var tipRadius:int = 4
		public var timer:Timer = new Timer(250, 1);
		public var tooltip:Tooltip;
		public var tipdata:String ="";
		private var container:DisplayObject;
		
		public function Tippable(dType:int, container:DisplayObject = null)
		{
			super();
			diagramType = dType;
			this.addEventListener(MouseEvent.MOUSE_OVER, startTooltipCounter);
			this.addEventListener(MouseEvent.MOUSE_OUT, hideTooltip);
			if (!container)
				this.container = this;
			else
				this.container = container;
		}
		/* Tooltip functions */
		private function startTooltipCounter(e:MouseEvent):void
		{
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, showTooltip);
			timer.start();
		}
		
		private function showTooltip(e:TimerEvent):void
		{
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, showTooltip);
			
			/* Modify the parameters to get new tooltips */
			
			tooltip = new Tooltip(tipWidth, tipHeight, tipRadius, tipText, tipBGColor, tipBorderColor, tipTextColor, tipAlpha, tipUseArrow, tipDir, tipDist); 
			
			/* Start Position */
			
			switch (tipDir)
			{
				case "up" :
					var pnt:Point = localToGlobal(new Point(mouseX, mouseY));
					tooltip.x = container.globalToLocal(pnt).x - tooltip.width / 2;
					tooltip.y = container.globalToLocal(pnt).y - (tooltip.height + tipDist);
					break;
				case "down" :
					tooltip.x = mouseX - tooltip.width / 2;
					tooltip.y = mouseY + (tooltip.height + tipDist);
					break;
				case "left" :
					tooltip.x = mouseX - tooltip.width - tipDist;
					tooltip.y = mouseY - (tooltip.height / 2);
					break;
				case "right" :
					tooltip.x = mouseX + tipDist;
					tooltip.y = mouseY - (tooltip.height / 2);
					break;
			}
			
			/* Add tooltip to stage and move listener */
			switch (diagramType)
			{
				case Tippable.SLD :
					FlexGlobals.topLevelApplication.sldDiagram.addToolTip(tooltip,Tippable.SLD);
					break;
				case Tippable.INVENTORY :
					FlexGlobals.topLevelApplication.sldDiagram.addToolTip(tooltip,Tippable.INVENTORY);
					break;
				default:
					addChild(tooltip);
					break;
			}			

			this.addEventListener(MouseEvent.MOUSE_MOVE, moveTooltip);
		}
		
		public function hideTooltip(e:MouseEvent):void
		{
			if (timer.currentCount == 1)
			{
				switch (diagramType)
				{
					case Tippable.SLD :
						FlexGlobals.topLevelApplication.sldDiagram.removeToolTip(tooltip,Tippable.SLD);
						break;
					case Tippable.INVENTORY :
						FlexGlobals.topLevelApplication.sldDiagram.removeToolTip(tooltip,Tippable.INVENTORY);
						break;
					default:
						removeChild(tooltip);
						break;
				}					
			}
			
			timer.reset();
		}
		
		private function moveTooltip(e:MouseEvent):void
		{
			switch (tipDir)
			{	
				case "up" :
					var pnt:Point = localToGlobal(new Point(mouseX, mouseY));
					tooltip.x = container.globalToLocal(pnt).x - tooltip.width / 2;
					tooltip.y = container.globalToLocal(pnt).y - (tooltip.height + tipDist);
					break;
				case "down" :
					tooltip.x = mouseX - tooltip.width / 2;
					tooltip.y = mouseY + (tooltip.height + tipDist);
					break;
				case "left" :
					tooltip.x = mouseX - tooltip.width - tipDist;
					tooltip.y = mouseY - (tooltip.height / 2);
					break;
				case "right" :
					tooltip.x = mouseX + tipDist;
					tooltip.y = mouseY - (tooltip.height / 2);
					break;
			}
		}
	
	    public function set tipText(txt:String):void{
			_tipText = txt;
			var txtField:TextField = new TextField();
			txtField.text = txt;
			tipWidth = txtField.textWidth + 40;
		}
		
		public function get tipText():String{
			return _tipText;
		}
		
	}
}