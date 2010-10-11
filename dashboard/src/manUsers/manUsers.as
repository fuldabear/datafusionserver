import classes.E4XParser;
import classes.dashML;
import classes.xml2xml;

import flash.events.Event;

import mx.controls.Alert;
import mx.rpc.AsyncToken;

//private var userNames:XML = new XMLList;
[Bindable] private var usersTable:XML = new XML;
[Bindable] private var userNames:XML = new XML;
[Bindable] private var userLogInTable:XML = new XML;
[Bindable] private var userLogInLocations:XML = new XML;
private var result:AsyncToken;
private var http:dashML = new dashML;

private function addNewUser():void
{
	
}
private function removeUser():void
{
	
}
private function changeUserPassword():void
{
	
}
private function logOutUser():void
{
	
}
private function applyChanges():void
{
	
}
public function getUsersTable(result:Object, token:Object):void
{
	this.usersTable = new XML(result.result as String);
	var n:xml2xml = new xml2xml;
	n.xml = new XML(E4XParser.evaluate(this.usersTable,"serverResponse").toString());
	n.rTag = "row";
	n.rProperty = "user_name";
	this.users.columns = n.toDatagridColumns();
	this.userNames = n.toDatagridDataProvider();
	
}
public function showFault(error:Object, token:Object):void {
    Alert.show(error.fault.faultString);
}
private function getUserLoginTable(result:Object, token:Object):void
{
	this.userLogInTable = new XML(result.result as String);
	var n:xml2xml = new xml2xml;
	n.xml = new XML(E4XParser.evaluate(this.userLogInTable,"serverResponse").toString());
	n.rLabel = "ip address";
	n.rTag = "row";
	n.rProperty = "ip_address";
	this.logInIps.columns = n.toDatagridColumns();
	this.userLogInLocations = n.toDatagridDataProvider();
	
}
private function getUserInformation(event:Event):void
{
	var index:int = users.selectedIndex as int;
	if (xml2xml.eval2String(this.usersTable, "serverResponse.row.is_administrator["+index+"]") == "-1")
	{
		this.userAdministrator.selected = true;
	}
	if (xml2xml.eval2String(this.usersTable, "serverResponse.row.activated["+index+"]") == "-1")
	{
		this.userDisabled.selected = false;
	}
	this.userEmailAddress.text = xml2xml.eval2String(this.usersTable, "serverResponse.row.email["+index+"]");
	this.userFirstName.text = xml2xml.eval2String(this.usersTable, "serverResponse.row.first_name["+index+"]");
	this.userLastName.text = xml2xml.eval2String(this.usersTable, "serverResponse.row.last_name["+index+"]");
	this.userUserName.text = xml2xml.eval2String(this.usersTable, "serverResponse.row.user_name["+index+"]");
	//this.userContactNumber.text = xml2xml.eval2String(this.usersTable, "serverResponse.row.contact_number["+index+"]");
	var sql:String = "SELECT users.user_name, logins.ip_address FROM users INNER JOIN logins ON users.user_id=logins.user_id WHERE user_name=\""+this.userUserName.text+"\";";
	this.http.sendSql(sql,getUserLoginTable);
	
}
private function init():void
{
	var sql:String = "SELECT * FROM users";
	this.http.sendSql(sql,getUsersTable);
}