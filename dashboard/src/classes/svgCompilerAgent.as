package classes
{
	import mx.controls.Image;
	//import mx.controls.SWFLoader;
	import mx.modules.ModuleLoader;
	
	public class svgCompilerAgent extends Image
	{
		public var xml:XML = new XML();
		//public var swf:SWFLoader = new SWFLoader;
		public var l:ModuleLoader = new ModuleLoader;
		
		public function svgCompilerAgent()
		{
			l.url="Images.swf";
			//swf.source="Images.swf";	
			//this.source=swf.tux;
			
		}
		
		public function loadImageLibrary():void
		{
			
		}

	}
}