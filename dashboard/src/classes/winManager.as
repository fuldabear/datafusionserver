package classes
{
	import flash.events.Event;
	
	public class winManager
	{
		import flexmdi.containers.*;
		import flexmdi.effects.effectsLib.MDIVistaEffects;
		import mx.modules.*;
		import mx.events.FlexEvent;
		import mx.events.ModuleEvent;
		public var lastWindow:MDIWindow;
		public var onComplete:Function = new Function;
		public var onPrograss:Function = new Function;
		
		public function addWin(title:String,module:String,canvas:MDICanvas,width:Number=100,height:Number=100):void
		{
			var win:MDIWindow = new MDIWindow();
			win.percentWidth = width;
			win.percentHeight = height;
			win.title = title;
			this.lastWindow = win;
			var mod:ModuleLoader = new ModuleLoader();
			mod.percentWidth = 100;
			mod.percentHeight = 100;
			mod.url = module;
			mod.addEventListener(ModuleEvent.PROGRESS,this.prograss);
			win.addChild(mod);
			canvas.windowManager.add(win);
			canvas.windowManager.center(win);
			if(width == 100 && height==100) win.maximize();
		}
		
		private function prograss(event:ModuleEvent):void
		{
			this.onPrograss(event.bytesLoaded,event.bytesTotal);
			if(event.bytesLoaded == event.bytesTotal) this.onComplete();
		}

	}
}