package com.transcendss.transcore.util
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import spark.components.Scroller;
	import spark.components.supportClasses.SkinnableComponent;
	
	public class LinkedScrollers extends EventDispatcher
	{
		private var _enabled:Boolean;
		
		private var _component1:SkinnableComponent;
		
		private var _component2:SkinnableComponent;
		
		private var _scroller1:Scroller;
		
		private var _scroller2:Scroller;
		
		
		public function LinkedScrollers() {
			_enabled = true;
		}
		
		[Bindable("enabledChanged")]
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void {
			if (value != _enabled) {
				_enabled = value;
				if (value) {
					// synchronize the horizontal scroll positions
					updateHorizontalScrollPosition(scroller1, scroller2);
				}
				dispatchEvent(new Event("enabledChanged"));
			}
		}
		
		[Bindable("component1Changed")]
		public function get component1():SkinnableComponent {
			return _component1;
		}
		
		public function set component1(value:SkinnableComponent):void {
			if (value != _component1) {
				if (_component1) {
					removePartListener(_component1);
				}
				_component1 = value;
				if (_component1) {
					addPartListener(_component1);
				}
				dispatchEvent(new Event("component1Changed"));
			}
		}
		
		[Bindable("component2Changed")]
		public function get component2():SkinnableComponent {
			return _component2;
		}
		
		public function set component2(value:SkinnableComponent):void {
			if (value != _component2) {
				if (_component2) {
					removePartListener(_component2);
				}
				_component2 = value;
				if (_component2) {
					addPartListener(_component2);
				}
				dispatchEvent(new Event("component2Changed"));
			}
		}
		
		[Bindable("scroller1Changed")]
		public function get scroller1():Scroller {
			return _scroller1;
		}
		
		public function set scroller1(value:Scroller):void {
			if (value != _scroller1) {
				if (_scroller1) {
					removeScrollListener(_scroller1, scroller1Scrolled);
				}
				_scroller1 = value;
				if (_scroller1) {
					addScrollListener(_scroller1, scroller1Scrolled);
				}
				dispatchEvent(new Event("scroller1Changed"));
			}
		}
		
		[Bindable("scroller2Changed")]
		public function get scroller2():Scroller {
			return _scroller2;
		}
		
		public function set scroller2(value:Scroller):void {
			if (value != _scroller2) {
				if (_scroller2) {
					removeScrollListener(_scroller2, scroller2Scrolled);
				}
				_scroller2 = value;
				if (_scroller2) {
					addScrollListener(_scroller2, scroller2Scrolled);
				}
				dispatchEvent(new Event("scroller2Changed"));
			}
		}
		
		
		// Listen for when the skin parts are added so that we can add listeners to the scrollbar
		private function addPartListener(skinComponent:SkinnableComponent):void {
			skinComponent.addEventListener("partAdded", partAdded);
			skinComponent.addEventListener("partRemoved", partRemoved);
			setScroller(skinComponent);
		}
		
		private function removePartListener(skinComponent:SkinnableComponent):void {
			skinComponent.removeEventListener("partAdded", partAdded);
			skinComponent.removeEventListener("partRemoved", partRemoved);
		}
		
		private function partAdded(event:Event /*spark.events.SkinPartEvent*/):void {
			if (event.hasOwnProperty("partName") && (event["partName"] == "scroller")) {
				var component:SkinnableComponent = (event.currentTarget as SkinnableComponent);
				setScroller(component);
			}
		}
		
		private function partRemoved(event:Event /*spark.events.SkinPartEvent*/):void {
			if (event.hasOwnProperty("partName") && (event["partName"] == "scroller")) {
				var component:SkinnableComponent = (event.currentTarget as SkinnableComponent);
				unsetScroller(component);
			}
		}
		
		private function setScroller(skinComponent:SkinnableComponent):void {
			if (skinComponent.hasOwnProperty("scroller") && (skinComponent["scroller"] != null)) {
				var scroller:Scroller = (skinComponent["scroller"] as Scroller);
				if (skinComponent == component1) {
					//trace("set scroller 1 " + (scroller != null));
					scroller1 = scroller;
				} else if (skinComponent == component2) {
					//trace("set scroller 2 " + (scroller != null));
					scroller2 = scroller;
				}
			}
		}
		
		private function unsetScroller(skinComponent:SkinnableComponent):void {
			if (skinComponent == component1) {
				//trace("unset scroller 1");
				scroller1 = null;
			} else if (skinComponent == component2) {
				//trace("unset scroller 2");
				scroller2 = null;
			}
		}
		
		// listen for scroll events
		private function addScrollListener(scroller:Scroller, handler:Function):void {
			scroller.addEventListener(MouseEvent.MOUSE_WHEEL, handler, false, 0, true);
			if (scroller.horizontalScrollBar) {
				// the change handle handles all the user interaction events
				scroller.horizontalScrollBar.addEventListener(Event.CHANGE, handler, false, 0, true);
				// the value commit is needed to handle the programmatic changes of the scroll position
				scroller.horizontalScrollBar.addEventListener(FlexEvent.VALUE_COMMIT, handler, false, 0, true);
			} else {
				// add later when the scrollbar has been created
				var created:Function = function(event:FlexEvent):void {
					scroller.removeEventListener(FlexEvent.CREATION_COMPLETE, created);
					if (scroller.horizontalScrollBar) {
						scroller.horizontalScrollBar.addEventListener(Event.CHANGE, handler, false, 0, true);
						scroller.horizontalScrollBar.addEventListener(FlexEvent.VALUE_COMMIT, handler, false, 0, true);
					}
				};
				scroller.addEventListener(FlexEvent.CREATION_COMPLETE, created, false, 0, true);
			}
		}
		
		private function removeScrollListener(scroller:Scroller, handler:Function):void {
			scroller.removeEventListener(MouseEvent.MOUSE_WHEEL, handler);
			if (scroller.horizontalScrollBar) {
				scroller.horizontalScrollBar.removeEventListener(Event.CHANGE, handler);
				scroller.horizontalScrollBar.removeEventListener(FlexEvent.VALUE_COMMIT, handler);
			}
		}
		
		private function scroller1Scrolled(event:Event):void {
			updateHorizontalScrollPosition(scroller1, scroller2);
		}
		
		private function scroller2Scrolled(event:Event):void {
			updateHorizontalScrollPosition(scroller2, scroller1);
		}
		
		/**
		 * Copies the horizontal scroll position from the source scroller to the target scroller.
		 */
		public function updateHorizontalScrollPosition(source:Scroller, target:Scroller):void {
			if (enabled && source && source.viewport && target && target.viewport) {
				var newPos:Number = source.viewport.horizontalScrollPosition;
				var oldPos:Number = target.viewport.horizontalScrollPosition;
				if (newPos != oldPos) {
					target.viewport.horizontalScrollPosition = newPos;
				}
			}
		}
		
		
	}
}