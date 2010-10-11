package classes
{
	import mx.containers.Panel;
	import mx.controls.Alert;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;
	import mx.managers.PopUpManager;
	import mx.rpc.AsyncResponder;
	import mx.rpc.AsyncToken;
	import mx.rpc.http.HTTPService;
	import mx.utils.URLUtil;
	
	public class dashML
	{
		/// http stuff ///
		public var result:AsyncToken;
		public var method:String = "GET";
		public var resultFormat:String = "text";
		public var debugServerName:String = "david-laptop";
		public var url:String = "/";
		public var useProxy:Boolean = false;
		public var requestTimeout:int = 10;
		//public var showBusyCursor = "true";
		//public var concurrency = "last";
		private var http:HTTPService = new HTTPService;
		
		private function initHttp():void
		{
					var browser:IBrowserManager = BrowserManager.getInstance();
					browser.init("","Tomcat");
					
					var serverName:String = mx.utils.URLUtil.getServerName(browser.url);
			
					if (serverName != "")
					{
						this.http.url = "http://"+serverName+this.url;
					}
					else
					{
						this.http.url = "http://"+debugServerName+this.url;
					}
			
					this.http.method = this.method;
					this.http.resultFormat = this.resultFormat;
					this.http.useProxy = this.useProxy;
					this.http.requestTimeout = this.requestTimeout;
		}
		
		public function showFault(error:Object, token:Object):void
		{
			Alert.show(error.fault.faultString);
		}
		public function defaultResultFunction(result:Object, token:Object):void
		{
			
		}
		public function sendDashML(dashML:String, resultFunction:Function = null):void
		{
			var params:Object = new Object();
			params.dashML = dashML;
			initHttp();
			this.result = this.http.send(params);
			if(resultFunction == null) resultFunction = this.defaultResultFunction;
			var asyncRespond:AsyncResponder = new AsyncResponder(resultFunction, showFault);
			this.result.addResponder(asyncRespond);
		}
		public function sendSql(sql:String, resultFunction:Function = null):void
		{
			var dashML:String = new String;
			dashML = "<dashML><sql><query>"+sql+"</query></sql></dashML>";
			sendDashML(dashML, resultFunction);
		}
		
		public function encode(s:String):String
		{
			s = s.split("<").join("~lt;");
			s = s.split(">").join("~gt;");
			s = s.split('"').join("~quot;");
			return s;
		}
		
		public function decode(s:String):String
		{
			s = s.split("~lt;").join("<");
			s = s.split("~gt;").join(">");
			s = s.split("~quot;").join('"');
			return s;
		}
		
		public function send(params:Object = null, resultFunction:Function = null, faultFunction:Function = null):void
		{
			initHttp();
			this.result = this.http.send(params);
			if(resultFunction == null) resultFunction = this.defaultResultFunction;
			if(faultFunction == null) faultFunction = this.showFault;
			var asyncRespond:AsyncResponder = new AsyncResponder(resultFunction, faultFunction);
			this.result.addResponder(asyncRespond);
		}
	}
}

/*private function resultFunction(result:Object, token:Object):void {
    if (!result) {
        this.outSQL.text ="No results from query.";
        return;
    }

    this.outSQL.text = result.result as String;
}*/