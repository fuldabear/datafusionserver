<?php
$user_id_tag_req = 0;

include 'utilities.php';
include 'mysqlManagement.php';
include 'dataManagement.php';
include 'userManagement.php';
connect();
ini_set(display_errors,false);

//!!!for debuging!!!
if($_GET['dashML']){
	$_POST = $_GET;
}

//////Program Process//////
if($_POST['dashML']){
	
	$dashML =& parseXml($_POST['dashML']);

	if($dashML->debug){
		ini_set(display_errors,true);
	}
	if($dashML->login){
		$user_name = $dashML->login->user_name;
	 	$user_password = $dashML->login->user_password;
		echo parseXml(loginUser($user_name, $user_password))->asXML();
	}
	elseif(!$dashML->user_id && $user_id_tag_req == 1){
		echo parseXml(dashEnvelope("Error: User not logged in OR User does not exist"))->asXML();
	}
	elseif($dashML->logout){
		$user_name = $dashML->logout->user_name;
		echo parseXml(logoutUser($user_name))->asXML();
	}
	elseif($dashML->register){
		$user_name = $dashML->register->user_name;
		$user_password = $dashML->register->user_password;
		$first_name = $dashML->register->first_name;
		$last_name = $dashML->register->last_name;
		$email = $dashML->register->email;
		echo parseXml(register($user_name,$user_password,$first_name,$last_name,$email))->asXML();
	}
	elseif($dashML->data){
		if($dashML->data_id){
			echo parseXml(processData(substr($_POST['dashML'],strpos($_POST['dashML'],'<data>')+6,strpos($_POST['dashML'],'</data>')-strpos($_POST['dashML'],'<data>')-6),$dashML->data_id))->asXML();
		}
		else echo parseXml(processData(substr($_POST['dashML'],strpos($_POST['dashML'],'<data>')+6,strpos($_POST['dashML'],'</data>')-strpos($_POST['dashML'],'<data>')-6)))->asXML();
	}
	elseif($dashML->cdata && $dashML->user_id && $dashML->simulation_id){
		if($dashML->data_id){
			echo parseXml(processCData(substr($_POST['dashML'],strpos($_POST['dashML'],'<cdata>')+7,strpos($_POST['dashML'],'</cdata>')-strpos($_POST['dashML'],'<cdata>')-7),$dashML->user_id,$dashML->simulation_id,$dashML->data_id))->asXML();
		}
		else echo parseXml(processCData(substr($_POST['dashML'],strpos($_POST['dashML'],'<cdata>')+7,strpos($_POST['dashML'],'</cdata>')-strpos($_POST['dashML'],'<cdata>')-7),$dashML->user_id,$dashML->simulation_id))->asXML();
	}
	elseif($dashML->config_data && $dashML->dash_id && $dashML->simulation_id){
		echo parseXml(processConfigData(substr($_POST['dashML'],strpos($_POST['dashML'],'<config_data>')+13,strpos($_POST['dashML'],'</config_data>')-strpos($_POST['dashML'],'<config_data>')-13),$dashML->simulation_id,$dashML->dash_id))->asXML();
	}
	elseif($dashML->sql){
		echo parseXml(sqlQuery($dashML->sql->query))->asXML();
	}
	elseif($dashML->repeater){
		echo $dashML->repeater->string;
	}
	elseif($dashML->ip){
		echo parseXml(dashEnvelope(getIpAddress()))->asXML();
	}
	else{
		echo parseXml(dashEnvelope("Error: Nothing to do"))->asXML();
	}
}

else{
	echo parseXml(dashEnvelope("Error: No Input"))->asXML();
}


disconnect();

/* SELECT logins.ip_address, users.user_name, users.password, users.is_administrator
FROM users INNER JOIN logins ON users.user_id=logins.user_id
WHERE ip_address="127.0.0.1";*/

//<login><user_name>david</user_name><user_password>fullmer</user_password></login>

?>