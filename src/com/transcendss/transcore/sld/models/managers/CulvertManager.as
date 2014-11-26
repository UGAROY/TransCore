package com.transcendss.transcore.sld.models.managers
{
	import com.transcendss.transcore.events.*;
	
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	public class CulvertManager
	{
		public var dispatcher:IEventDispatcher;
		
		public function CulvertManager()
		{
		}
		
		public function setCulvertMaterial(arrayColl:ArrayCollection):void
		{
			var rcEvent:InventoryMenuEvent = new InventoryMenuEvent(InventoryMenuEvent.CULVERT_MATERIAL_READY);
			rcEvent.dataProviderAC =  arrayColl;
			dispatcher.dispatchEvent(rcEvent);
		}	
		
		public function setCulvertShape(arrayColl:ArrayCollection):void
		{
			var rcEvent:InventoryMenuEvent = new InventoryMenuEvent(InventoryMenuEvent.CULVERT_SHAPE_READY);
			rcEvent.dataProviderAC =  arrayColl;
			dispatcher.dispatchEvent(rcEvent);
		}	
		
		public function setCulvertPlacement(arrayColl:ArrayCollection):void
		{
			var rcEvent:InventoryMenuEvent = new InventoryMenuEvent(InventoryMenuEvent.CULVERT_PLACEMENT_READY);
			rcEvent.dataProviderAC =  arrayColl;
			dispatcher.dispatchEvent(rcEvent);
		}	
		
		public function setCulvertJointloc(arrayColl:ArrayCollection):void
		{
			var rcEvent:InventoryMenuEvent = new InventoryMenuEvent(InventoryMenuEvent.CULVERT_JOINTLOC_READY);
			rcEvent.dataProviderAC =  arrayColl;
			dispatcher.dispatchEvent(rcEvent);
		}	
		
		public function setCulvertAbutment(arrayColl:ArrayCollection):void
		{
			var rcEvent:InventoryMenuEvent = new InventoryMenuEvent(InventoryMenuEvent.CULVERT_ABUTMENT_READY);
			rcEvent.dataProviderAC =  arrayColl;
			dispatcher.dispatchEvent(rcEvent);
		}	
		
		public function setCulvertBeam(arrayColl:ArrayCollection):void
		{
			var rcEvent:InventoryMenuEvent = new InventoryMenuEvent(InventoryMenuEvent.CULVERT_BEAM_READY);
			rcEvent.dataProviderAC =  arrayColl;
			dispatcher.dispatchEvent(rcEvent);
		}	
		
		public function setCulvertGeneral(arrayColl:ArrayCollection):void
		{
			var rcEvent:InventoryMenuEvent = new InventoryMenuEvent(InventoryMenuEvent.CULVERT_GENERAL_READY);
			rcEvent.dataProviderAC =  arrayColl;
			dispatcher.dispatchEvent(rcEvent);
		}	
		
		public function setCulvertFlow(arrayColl:ArrayCollection):void
		{
			var rcEvent:InventoryMenuEvent = new InventoryMenuEvent(InventoryMenuEvent.CULVERT_FLOW_READY);
			rcEvent.dataProviderAC =  arrayColl;
			dispatcher.dispatchEvent(rcEvent);
		}
		
		public function setCulvertJoint(arrayColl:ArrayCollection):void
		{
			var rcEvent:InventoryMenuEvent = new InventoryMenuEvent(InventoryMenuEvent.CULVERT_JOINT_READY);
			rcEvent.dataProviderAC =  arrayColl;
			dispatcher.dispatchEvent(rcEvent);
		}	
		
		public function setCulvertBarrel(arrayColl:ArrayCollection):void
		{
			var rcEvent:InventoryMenuEvent = new InventoryMenuEvent(InventoryMenuEvent.CULVERT_BARREL_READY);
			rcEvent.dataProviderAC =  arrayColl;
			dispatcher.dispatchEvent(rcEvent);
		}	
		
		public function setCulvertEnds(arrayColl:ArrayCollection):void
		{
			var rcEvent:InventoryMenuEvent = new InventoryMenuEvent(InventoryMenuEvent.CULVERT_CULVERTENDS_READY);
			rcEvent.dataProviderAC =  arrayColl;
			dispatcher.dispatchEvent(rcEvent);
		}	
		
		public function setCulvertChannel(arrayColl:ArrayCollection):void
		{
			var rcEvent:InventoryMenuEvent = new InventoryMenuEvent(InventoryMenuEvent.CULVERT_CHANNEL_READY);
			rcEvent.dataProviderAC =  arrayColl; 
			dispatcher.dispatchEvent(rcEvent);
		}	
		
		public function setCulvertMaint(arrayColl:ArrayCollection):void
		{
			var rcEvent:InventoryMenuEvent = new InventoryMenuEvent(InventoryMenuEvent.CULVERT_MAINT_READY);
			rcEvent.dataProviderAC =  arrayColl;
			dispatcher.dispatchEvent(rcEvent);
		}	
		
		public function setCulvertMaintEquip(arrayColl:ArrayCollection):void
		{
			var rcEvent:InventoryMenuEvent = new InventoryMenuEvent(InventoryMenuEvent.CULVERT_MAINT_EQUIP_READY);
			rcEvent.dataProviderAC =  arrayColl;
			dispatcher.dispatchEvent(rcEvent);
		}	
		
		public function setCulvertGeotags(arrayColl:ArrayCollection):void
		{
			var rcEvent:InventoryMenuEvent = new InventoryMenuEvent(InventoryMenuEvent.CULVERT_GEOTAG_READY);
			rcEvent.dataProviderAC =  arrayColl;
			dispatcher.dispatchEvent(rcEvent);
		}	
	}
}