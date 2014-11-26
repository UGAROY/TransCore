package com.transcendss.transcore.sld.models.managers
{
//	import com.transcendss.sld.models.SLDDiagramModel;
	import com.transcendss.transcore.sld.models.InventoryDiagram;
	import com.transcendss.transcore.sld.models.StickDiagram;
	import com.transcendss.transcore.sld.models.components.Route;
	import com.transcendss.transcore.util.ConfigurationManager;
	
	import flash.events.IEventDispatcher;

	public class GlobalCompManager
	{
		private var _sldRoute:Route;
		private var _stickDiagram:StickDiagram;
		private var _invDiagram:InventoryDiagram;
		private var _ConfigManager:ConfigurationManager;
		
		
		public var dispatcher:IEventDispatcher;
		
		public function GlobalCompManager()
		{
		}
		
		public function set ConfigManager(configManagerObj:ConfigurationManager):void
		{
			_ConfigManager = configManagerObj;
		}
		
		public function get ConfigManager():ConfigurationManager
		{
			return _ConfigManager;
		}
		
		public function set sldRoute(routeObj:Route):void
		{
			_sldRoute = routeObj;
		}
		
		public function get sldRoute():Route
		{
			return _sldRoute;
		}
		
		public function set stkDiagram(diagramObj:StickDiagram):void
		{
			_stickDiagram = diagramObj;
		}
		
		
		public function get stkDiagram():StickDiagram
		{
			return _stickDiagram;
		}
		
		
		public function set invDiagram(diagramObj:InventoryDiagram):void
		{
			_invDiagram = diagramObj;
		}
		
		public function get invDiagram():InventoryDiagram
		{
			return _invDiagram;
		}
	}
}