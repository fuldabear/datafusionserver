import classes.E4XParser;
import classes.dashML;
import classes.xml2xml;

import mx.controls.Alert;

private var http:dashML = new dashML;
private var xml:XML;
private var currently_selected_dash_id:String = new String;
[Bindable]
private var xmlListOfDashboards:XML = new XML;

private function getDashInformation(event:Event):void
{
	var index:int = listOfDashboards.selectedIndex as int;
	this.currently_selected_dash_id = xml2xml.eval2String(this.xml, "serverResponse.row.dash_id["+index+"]");
	this.dash_name.text = xml2xml.eval2String(this.xml, "serverResponse.row.dash_name["+index+"]");
	this.dash_title.text = xml2xml.eval2String(this.xml, "serverResponse.row.dash_title["+index+"]");
	this.dash_discription.text = xml2xml.eval2String(this.xml, "serverResponse.row.dash_discription["+index+"]");
	this.dash_path.text = xml2xml.eval2String(this.xml, "serverResponse.row.dash_path["+index+"]");
	if (xml2xml.eval2String(this.xml, "serverResponse.row.on_menu["+index+"]") == "-1")
	{
		this.on_menu.selected = true;
	}
	try {
	  this.preview.url = xml2xml.eval2String(this.xml, "serverResponse.row.dash_path["+index+"]");
	}
	catch(errObject:Error) {
	  trace(errObject.message);
	}
}
private function init2(result:Object, token:Object):void
{
	this.xml = new XML(result.result as String);
	var n:xml2xml = new xml2xml;
	n.xml = new XML(E4XParser.evaluate(this.xml,"serverResponse").toString());
	n.rTag = "row";
	n.rProperty = "dash_name";
	this.listOfDashboards.columns = n.toDatagridColumns();
	this.xmlListOfDashboards = n.toDatagridDataProvider();
	 
}
private function applyResult(result:Object, token:Object):void
{
	var xml:XML = new XML(result.result as String);
	if(xml.serverResponse == 1){
		this.init();
		this.parentApplication.init();
	} 
	else Alert.show("Error: Unable to store changes");
}
private function init():void
{
	this.http.sendSql("SELECT dashBoards.dash_name, dashBoards.dash_title, dashBoards.dash_discription, dashBoards.dash_path, dashBoards.on_menu, dashBoards.dash_id FROM dashBoards", init2);
} 
private function applyButton():void{
	var on_menu:String = "0";
	if(this.on_menu.selected == true) on_menu = "-1";
	this.http.sendSql("UPDATE dashBoards SET dash_name=\""+this.dash_name.text+"\", dash_title=\""+this.dash_title.text+"\", dash_discription=\""+this.dash_discription.text+"\", dash_path=\""+this.dash_path.text+"\", on_menu=\""+on_menu+"\" WHERE dash_id=\""+this.currently_selected_dash_id+"\"",applyResult);
}