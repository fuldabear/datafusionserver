// ActionScript file
import classes.*;

import mx.rpc.AsyncToken;


public var result:AsyncToken;
private var dash:dashML = new dashML;


 // Handle a query fault.
private function dashFault(error:Object, token:Object):void {
    this.outDashML.text = error.fault.faultString;
}
private function xmlFault(error:Object, token:Object):void {
    this.outXML.text = error.fault.faultString;
}
private function sqlFault(error:Object, token:Object):void {
    this.outSQL.text = error.fault.faultString;
}

// Handle a query success.
private function dashResult(result:Object, token:Object):void {
    if (!result) {
        this.outDashML.text ="No results from query.";
        return;
    }

    this.outDashML.text = result.result as String;
}
private function xmlResult(result:Object, token:Object):void {
    if (!result) {
        this.outXML.text ="No results from query.";
        return;
    }

    this.outXML.text = result.result as String;
}
private function sqlResult(result:Object, token:Object):void {
    if (!result) {
        this.outSQL.text ="No results from query.";
        return;
    }

    this.outSQL.text = result.result as String;
}

public function applyButton():void{
    var params:Object = new Object();
    if(this.tabBar.selectedIndex == 0){
        //params.dashML = this.inDashML.text;
        //this.result = this.parentApplication.http.send(params);
        //this.result.addResponder(new AsyncResponder(dashResult, dashFault));
        this.dash.sendDashML(this.inDashML.text, dashResult);
    }
    if(this.tabBar.selectedIndex == 1){
        //params.dashML = "<dashML><sql><query>"+this.inSQL.text+"</query></sql></dashML>";
        //this.result = this.parentApplication.http.send(params);
        //this.result.addResponder(new AsyncResponder(sqlResult, sqlFault));
        this.dash.sendSql(this.inSQL.text, sqlResult);
    }
    if(this.tabBar.selectedIndex == 2){
        var returnXML:XMLList = E4XParser.evaluate(new XML(this.inXML.text), this.inE4x.text);
        this.outXML.text = returnXML.toString();
    }
    if(this.tabBar.selectedIndex == 3){
        svgViewer.xml = new XML(this.inSVG.text);
        //svgViewer.loadSVG(this.inSVG.text);
    }
}

