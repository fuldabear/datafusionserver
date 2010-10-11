package classes
{
	import flash.events.*;
	import flash.filters.GlowFilter;
	
	import mx.controls.Image;
	import mx.core.DragSource;
	import mx.managers.DragManager;
	

	public class simComponent extends Image
	{
		//public static const GLOWCOLOR_CHANGE:String = "glowColorChanged";
		public var global:Object = new Object;
		public var onSelect:Function = new Function;
		public var sources:Array = new Array;
		public var dragable:Boolean = false;
		public var currentSimComponentCanvas:simComponentCanvas;
		public var isSelected:Boolean = false;
		public var percentXofCenter:Number = new Number;
		public var percentYofCenter:Number = new Number;
		public var varablesToPlot:Array = new Array;
		public var varablesToControl:Array = new Array;
		public var varablesToControlType:Array = new Array;
		public var varablesToControlValue:Array = new Array;
		// the following two var are not meant to be a permanet part of the program
		public var tempControlOverRide:Number = 0;
		public var tempControlOverRideActive:Boolean = false;
		public var componentVarable:String = new String;
		public var simComponentType:String = new String;
		
		
		public function simComponent() {
			addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			addEventListener(MouseEvent.CLICK, onMouseClick);
			addEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			this.global.selectionColor = 0xFFEE7D;
		}
		
		public function setSource(number:int = 0):void
		{
			this.source = this.sources[number];
		}
		
		private function onMouseClick(e:Event):void
		{
			this.selectSimComponent();
			stage.focus = this;			
		}
		
		private function startGlow():void
		{
			var glowObject:GlowFilter = new GlowFilter();
			glowObject.alpha = 1;
			glowObject.blurX = 50;
			glowObject.blurY = 50;
			glowObject.color = this.global.selectionColor;
			this.filters = new Array(glowObject);
		}
		
		
		public function setGlowColor(color:Number = 0xFFEE7D):void
		{
			this.global.selectionColor = color;
			this.startGlow();
		}
		
		public function stopGlow():void
		{
			this.filters = new Array;
		}
		
		public function selectSimComponent():void
		{
			if(this.isSelected == true)
			{
				this.stopGlow();
				this.dragable = false;
				this.isSelected = false;
				this.currentSimComponentCanvas.currentlySelectedSimComponent = new simComponent;
				if(this.document.currentState == "configureComponent")
				{
					this.document.mode.selectedIndex = 0;
					this.document.changeState();
				}
			}
			else
			{
				this.currentSimComponentCanvas.deselectAllSimComponents();
				this.startGlow();
				this.isSelected = true;
				stage.focus = this;
				this.currentSimComponentCanvas.currentlySelectedSimComponent = this;
				if(this.document.currentState == null || this.document.currentState == "") 
				{
					this.document.mode.selectedIndex = 1;
					this.document.changeState();
				}
				if(this.document.currentState == "configureDash" && this.document.dragAndDropCheckBox.selected == true)
				{
					this.dragable = true;
				}
				this.document.updatePanel();
			}
			
		}
		
		public function onKeyUp(e:KeyboardEvent):void
		{
			if(this.dragable == true)
			{
				if(e.keyCode == 37) // left
				{
					this.x = this.x - 1;
					this.percentXofCenter = (this.x + this.width / 2) / this.currentSimComponentCanvas.width;
					stage.focus = this;
				}
				if(e.keyCode == 39) //right
				{
					this.x = this.x + 1;
					this.percentXofCenter = (this.x + this.width / 2) / this.currentSimComponentCanvas.width;
					stage.focus = this;
				}
				if(e.keyCode == 38) //up
				{
					this.y = this.y - 1;
					this.percentYofCenter = (this.y + this.height / 2) / this.currentSimComponentCanvas.height;
					stage.focus = this;
				}
				if(e.keyCode == 40) //down
				{
					this.y = this.y + 1;
					this.percentYofCenter = (this.y + this.height / 2) / this.currentSimComponentCanvas.height;
					stage.focus = this;
				}
			}
		}
		
		// The mouseMove event handler for the Image control
		// initiates the drag-and-drop operation.
		private function mouseMoveHandler(event:MouseEvent):void 
		{
			if(this.dragable == true)
			{
				var dragInitiator:Image=Image(event.currentTarget);
			    var ds:DragSource = new DragSource();
			    ds.addData(dragInitiator, "img");               
			    DragManager.doDrag(dragInitiator, ds, event);
			}            
		    
		}
		
	}
}