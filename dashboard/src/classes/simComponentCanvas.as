package classes
{
	import flash.events.*;
	import flash.geom.Rectangle;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	
	public class simComponentCanvas extends Canvas
	{
		public var lastSimComponent:simComponent = new simComponent();
		public var simComponents:Array = new Array;
		public var currentlySelectedSimComponent:simComponent = new simComponent();
		public var listOfDataVarables:Array = new Array;
		public var simulationData:Array = new Array;
		public var global:Object = new Object;
		
		public function simComponentCanvas()
		{
			addEventListener(DragEvent.DRAG_ENTER,dragEnterHandler);
			addEventListener(DragEvent.DRAG_DROP,dragDropHandler);
			//addEventListener(ResizeEvent.RESIZE,onResizeUpdateComponents);
			addEventListener(FlexEvent.UPDATE_COMPLETE,onResizeUpdateComponents);
			percentHeight = 100;
			percentWidth = 100;
			this.global.selectionColor = 0xFFEE7D;
		}
		
		/*public function setBackground2(xml:String):void
		{
			var svg:SVGViewer = new SVGViewer;
			svg.xml = new XML(xml);
			svg.x = 0;
			svg.y = 0;
			svg.percentHeight = 100;
			svg.percentWidth = 100;
			this.addChild(svg);			
		}*/
		
		public function setBackground(image:Class):void
		{
			var img:Image = new Image;
			img.source = image;
			img.percentHeight = 100;
			img.percentWidth = 100;
			img.x = 0;
			img.y = 0;
			img.scaleContent = true;
			img.autoLoad = true;
			img.maintainAspectRatio = false;
			this.addChild(img);			
		}
		
		// t:Array is an Array of possible images:Class
		public function addSimComponent(t:Array,percentXofCenter:Number,percentYofCenter:Number,percentH:Number,percentW:Number,rotation:Number):void
		{
			var rectangle:Rectangle = this.getRect(this);
			var c:simComponent = new simComponent;
			c.sources = t;
			c.source = t[0];
			c.percentHeight = percentH;
			c.percentWidth = percentW;
			c.percentXofCenter = percentXofCenter;
			c.percentYofCenter = percentYofCenter;
			c.x = (percentXofCenter * rectangle.width) - (c.width / 2);
			c.y = (percentYofCenter * rectangle.height) - (c.height / 2);
			c.rotation = rotation;
			c.currentSimComponentCanvas = this;
			c.global = this.global;
			this.lastSimComponent = c;
			this.simComponents.push(c);
			this.addChild(c);
		}
		
		public function delSelectedSimComponent():void
		{
			this.removeChild(this.currentlySelectedSimComponent);
			this.simComponents.splice(this.simComponents.indexOf(this.currentlySelectedSimComponent),1);
		}
		
		public function delAllSimComponents():void
		{
			for each (var i:simComponent in this.simComponents)
			{
				this.removeChild(i);
			}
			this.simComponents = new Array;
		}
		
		public function deselectAllSimComponents():void
		{
			for each (var item:simComponent in this.simComponents)
			{
				item.dragable = false;
				item.isSelected = false;
				item.stopGlow();
				
			} 
		}
		
		public function onResizeUpdateComponents(e:Event):void
		{
			var rectangle:Rectangle = this.getRect(this);
			for each (var item:simComponent in this.simComponents)
			{
					item.x = (item.percentXofCenter * rectangle.width) - (item.width / 2);
					item.y = (item.percentYofCenter * rectangle.height) - (item.height / 2);			
			} 
		}
		
			
		// The dragEnter event handler for the Canvas container
		// enables dropping.
		private function dragEnterHandler(event:DragEvent):void {
		    if (event.dragSource.hasFormat("img"))
		    {
		        DragManager.acceptDragDrop(Canvas(event.currentTarget));
		    }
		}
		
		// The dragDrop event handler for the Canvas container
		// sets the Image control's position by 
		// "dropping" it in its new location.
		private function dragDropHandler(event:DragEvent):void {
		    simComponent(event.dragInitiator).x = Canvas(event.currentTarget).mouseX;
		    simComponent(event.dragInitiator).y = Canvas(event.currentTarget).mouseY;
		    simComponent(event.dragInitiator).percentXofCenter = Canvas(event.currentTarget).mouseX / Canvas(event.currentTarget).width;
		    simComponent(event.dragInitiator).percentYofCenter = Canvas(event.currentTarget).mouseY / Canvas(event.currentTarget).height;
		    stage.focus = this.currentlySelectedSimComponent;
		}
		
		public function createConfigurationXml():String
		{
			var s:String = new String;
			for each (var i:simComponent in this.simComponents)
			{
				s += "<"+i.simComponentType+">";
				s += "<size>"+i.percentWidth+"</size>";
				s += "<rotation>"+i.rotation+"</rotation>";
				s += "<percentXofCenter>"+i.percentXofCenter+"</percentXofCenter>";
				s += "<percentYofCenter>"+i.percentYofCenter+"</percentYofCenter>";
				s += "<componentVarable>"+i.componentVarable+"</componentVarable>";
				s += "<plot>";
				for each (var j:String in i.varablesToPlot)
				{
					s += "<varable>"+j+"</varable>";
				}
				s += "</plot>";
				s += "<control>";
				for (var k:int = 0; k < i.varablesToControl.length; k++)
				{
					s += "<varable>";
						s += "<name>"+i.varablesToControl[k]+"</name>";
						s += "<type>"+i.varablesToControlType[k]+"</type>";
						s += "<value>"+i.varablesToControlValue[k]+"</value>";
					s += "</varable>";
				}
				s += "</control>";
				s += "</"+i.simComponentType+">";
			} 
			return s;
		}
		
		public function update(d:XML, c:XML, a:Array):XML
		{
			this.simulationData = a;
			/*this.listOfDataVarables.splice(0,this.listOfDataVarables.length);
			for (var n:int = 0; n < d.children().length(); n++)
			{
				this.listOfDataVarables.push(d.children()[n].name().localName);
			}
			// this next line of code needs to be done via some registration process
			this.document.listOfDataVarablesDataProvider = new ArrayCollection(this.listOfDataVarables);*/
			for each (var o:simComponent in this.simComponents)
			{
				o.setSource(d[o.componentVarable]);
			}
			// need to do something with cdata!!!
			var s:String = new String;
			for each (var i:simComponent in this.simComponents)
			{
				for (var k:int = 0; k < i.varablesToControl.length; k++)
				{
					s += "<"+i.varablesToControl[k]+">";
						s += i.varablesToControlValue[k];
					s += "</"+i.varablesToControl[k]+">";
				}
			} 
			return new XML(s);		
		}
		
		public function setSelectionColor(color:Number = 0xFFEE7D):void
		{
			this.global.selectionColor = color;
			this.currentlySelectedSimComponent.setGlowColor(this.global.selectionColor);
		}
		
	}
}