import classes.*;

import flash.events.Event;

import flexmdi.containers.*;

import mx.collections.*;
import mx.containers.Panel;
import mx.controls.Alert;
import mx.events.MenuEvent;
import mx.managers.HistoryManager;
import mx.managers.PopUpManager;
import mx.modules.*;

import org.as3yaml.YAML;

import popups.Loading;

public var wm:winManager = new winManager;
public var hm:HistoryManager = new HistoryManager;
private var dash:dashML = new dashML;
private var xml:XML;
private var menu:xml2xml = new xml2xml;
private var lock_user:String = new String;
private var loading:Panel = new Loading;

// Handle a query success.
private function loginOnEnter():void
{
	var params:Object = new Object;
	params.user = this.user_name.text;
	params.password = this.user_password.text;
	this.showLoading();
	this.dash.send(params, loginResult, loginFault);
}
private function loginResult(result:Object, token:Object):void
{
	this.hideLoading();
	if(result.result != 'Authorization Failed')this.currentState="App";
	else Alert.show(result.result);
}
private function loginFault(error:Object, token:Object):void
{
	this.hideLoading();
	Alert.show(error.fault.faultString);
}

private function menuHandler2(event:MenuEvent):void
{
	this.currentState = event.item.@data;
}

public function showLoading():void {
    PopUpManager.addPopUp(loading, this, false);
    PopUpManager.centerPopUp(loading);
}

public function hideLoading():void {
    PopUpManager.removePopUp(loading);
}

private function debugSentSend():void{
	this.showLoading();
	this.statusBar.text = 'Sending data to server... awaiting response';
	this.dash.send(YAML.decode(this.debug_sent.text), debugSentResult, debugSentFault);
}

private function debugSentResult(result:Object, token:Object):void
{
	this.hideLoading();
	this.statusBar.text = 'Server response received succuessfully';
	this.debug_received.text = result.result;
}
private function debugSentFault(error:Object, token:Object):void
{
	this.hideLoading();
	this.statusBar.text = 'Client server communitcation error';
	Alert.show(error.fault.faultString);
}

private function updateDebugSessionList(e:Event):void{
	var params:Object = new Object;
	params.command = 'session';
	params.mode = 'list';
	params.user = this.session_name_list.text;
	params.password = this.session_password_list.text;
	this.debug_sent.text = YAML.encode(params).split("!actionscript/object:Object").join("");
	this.debug_sent.data = params;
	this.statusBar.text = 'Sending field refreshed for listing sessions';
}

private function updateDebugSessionCreate(e:Event):void{
	var params:Object = new Object;
	params.command = 'session';
	params.mode = 'create';
	params.user = this.session_name_create.text;
	params.password = this.session_password_create.text;
	params.newname = this.session_newname_create.text;
	params.newpassword = this.session_newpassword_create.text;
	params.expiration = this.session_expiration_create.text;
	params.description = this.session_description_create.text;
	this.debug_sent.text = YAML.encode(params).split("!actionscript/object:Object").join("");
	this.debug_sent.data = params;
	this.statusBar.text = 'Sending field refreshed for creating sessions';
}

private function updateDebugSessionRemove(e:Event):void{
	var params:Object = new Object;
	params.command = 'session';
	params.mode = 'remove';
	params.user = this.session_name_remove.text;
	params.password = this.session_password_remove.text;
	this.debug_sent.text = YAML.encode(params).split("!actionscript/object:Object").join("");
	this.debug_sent.data = params;
	this.statusBar.text = 'Sending field refreshed for removing sessions';
}

private function updateDebugSessionPassword(e:Event):void{
	var params:Object = new Object;
	params.command = 'session';
	params.mode = 'password';
	params.user = this.session_name_password.text;
	params.password = this.session_password_password.text;
	params.newpassword = this.session_newpassword_password.text;
	this.debug_sent.text = YAML.encode(params).split("!actionscript/object:Object").join("");
	this.debug_sent.data = params;
	this.statusBar.text = 'Sending field refreshed for changing a password to a session';
}

private function updateDebugSessionName(e:Event):void{
	var params:Object = new Object;
	params.command = 'session';
	params.mode = 'name';
	params.user = this.session_name_name.text;
	params.password = this.session_password_name.text;
	params.newname = this.session_newname_name.text;
	this.debug_sent.text = YAML.encode(params).split("!actionscript/object:Object").join("");
	this.debug_sent.data = params;
	this.statusBar.text = 'Sending field refreshed for renaming a session';
}

private function updateDebugSessionExpiration(e:Event):void{
	var params:Object = new Object;
	params.command = 'session';
	params.mode = 'expiration';
	params.expiration = this.session_expiration_expiration.text;
	params.user = this.session_name_expiration.text;
	params.password = this.session_password_expiration.text;
	this.debug_sent.text = YAML.encode(params).split("!actionscript/object:Object").join("");
	this.debug_sent.data = params;
	this.statusBar.text = 'Sending field refreshed for changing the expiration of a session';
}

private function updateDebugSessionDescription(e:Event):void{
	var params:Object = new Object;
	params.command = 'session';
	params.mode = 'description';
	params.user = this.session_name_description.text;
	params.password = this.session_password_description.text;
	params.description = this.session_description_description.text;
	this.debug_sent.text = YAML.encode(params).split("!actionscript/object:Object").join("");
	this.debug_sent.data = params;
	this.statusBar.text = 'Sending field refreshed for changing the description of a session';
}

private function updateDebugVariableRead(e:Event):void{
	var params:Object = new Object;
	params.command = 'datastore';
	params.mode = 'read';
	params.user = this.variable_read_name.text;
	params.password = this.variable_read_password.text;
	if(this.variable_read_names.text == '') params.name = '';
	else params.name = "['"+this.variable_read_names.text.split(",").join("','")+"']";
	if(this.variable_read_values.text == '') params.value = '';
	else params.value = "['"+this.variable_read_values.text.split(",").join("','")+"']";
	if( params.value != '')  params.longPoll = true;
	this.debug_sent.text = YAML.encode(params).split("!actionscript/object:Object").join("");
	this.debug_sent.data = params;
	this.statusBar.text = 'Sending field refreshed for reading variables';
}

private function updateDebugVariableWrite(e:Event):void{
	var params:Object = new Object;
	params.command = 'datastore';
	params.mode = 'write';
	params.user = this.variable_write_name.text;
	params.password = this.variable_write_password.text;
	if(this.variable_write_names.text == '') params.name = '';
	else params.name = "['"+this.variable_write_names.text.split(",").join("','")+"']";
	if(this.variable_write_values.text == '') params.value = '';
	else params.value = "['"+this.variable_write_values.text.split(",").join("','")+"']";
	this.debug_sent.text = YAML.encode(params).split("!actionscript/object:Object").join("");
	this.debug_sent.data = params;
	this.statusBar.text = 'Sending field refreshed for writing variables';
}

private function updateDebugVariableRW(e:Event):void{
	var params:Object = new Object;
	params.command = 'datastore';
	params.user = this.variable_rw_name.text;
	params.password = this.variable_rw_password.text;
	if(this.variable_rw_modes.text == '') params.mode = '';
	else params.mode = "['"+this.variable_rw_modes.text.split(",").join("','")+"']";
	if(this.variable_rw_names.text == '') params.name = '';
	else params.name = "['"+this.variable_rw_names.text.split(",").join("','")+"']";
	if(this.variable_rw_values.text == '') params.value = '';
	else params.value = "['"+this.variable_rw_values.text.split(",").join("','")+"']";
	this.debug_sent.text = YAML.encode(params).split("!actionscript/object:Object").join("");
	this.debug_sent.data = params;
	this.statusBar.text = 'Sending field refreshed for reading and writing variables';
}

private function updateDebugVariableRemove(e:Event):void{
	var params:Object = new Object;
	params.command = 'datastore';
	params.mode = 'remove';
	params.user = this.variable_remove_name.text;
	params.password = this.variable_remove_password.text;
	params.name = this.variable_remove_names.text;
	this.debug_sent.text = YAML.encode(params).split("!actionscript/object:Object").join("");
	this.debug_sent.data = params;
	this.statusBar.text = 'Sending field refreshed for removing variables';
}

private function updateDebugVariableRename(e:Event):void{
	var params:Object = new Object;
	params.command = 'datastore';
	params.mode = 'rename';
	params.user = this.variable_rename_name.text;
	params.password = this.variable_rename_password.text;
	params.name = this.variable_rename_names.text;
	params.newname = this.variable_rename_newname.text;
	this.debug_sent.text = YAML.encode(params).split("!actionscript/object:Object").join("");
	this.debug_sent.data = params;
	this.statusBar.text = 'Sending field refreshed for renaming variables';
}

private function updateDebugVariableLink(e:Event):void{
	var params:Object = new Object;
	params.command = 'datastore';
	params.mode = 'link';
	params.user = this.variable_link_name.text;
	params.password = this.variable_link_password.text;
	params.name = this.variable_link_names.text;
	params.session = this.variable_link_session.text;
	this.debug_sent.text = YAML.encode(params).split("!actionscript/object:Object").join("");
	this.debug_sent.data = params;
	this.statusBar.text = 'Sending field refreshed for linking variables to sessions';
}

private function updateDebugVariableList(e:Event):void{
	var params:Object = new Object;
	params.command = 'datastore';
	params.mode = 'list';
	params.user = this.variable_list_name.text;
	params.password = this.variable_list_password.text;
	this.debug_sent.text = YAML.encode(params).split("!actionscript/object:Object").join("");
	this.debug_sent.data = params;
	this.statusBar.text = 'Sending field refreshed for listing variables';
}

[Embed(source="echo.png")]
[Bindable]
public var iris:Class;