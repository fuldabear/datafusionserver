<?php
function register($user_name,$user_password,$first_name,$last_name,$email) {
	// first check to see if proposed user already exist
	$result = sqlQueryXml("SELECT * FROM users WHERE users.user_name=\"$user_name\"","serverResponse->num");
	if($result > 0) return dashEnvelope("Error: $user_name already exists");
	// create new user
	$result = sqlQueryXml("INSERT users SET user_name=\"$user_name\", password=\"$user_password\", first_name=\"$first_name\", last_name=\"$last_name\", email=\"$email\"","serverResponse");
	// check to see if it worked
	if($result == 1){
		return dashEnvelope("Registration::OK");    	
	}
	else {
		return dashEnvelope("Error: Registration failed");
	}
}


function loginUser($user_name, $user_password) {
	// check if user_name and password and correct
    $result = sqlQueryXml("SELECT users.user_name, users.password, users.activated FROM users WHERE (((users.user_name)=\"$user_name\") AND ((users.password)=\"$user_password\") AND ((users.activated)=-1));","serverResponse->num");
	if($result > 1) return dashEnvelope("Error: Duplicate users");
	if($result == 0) return dashEnvelope("Error: Incorrect user name or password or account is not active");
	// check if user is already logged in
	$ip = getIpAddress();
	$user_id = sqlQueryXml("SELECT users.user_id FROM users WHERE users.user_name=\"$user_name\"","serverResponse->row->user_id");
	$result = sqlQueryXml("SELECT * FROM logins WHERE logins.user_id=\"$user_id\" AND logins.ip_address=\"$ip\"","serverResponse->num");
	//$result = sqlQueryXml("SELECT users.user_name, logins.ip_address FROM users INNER JOIN logins ON users.user_id=logins.user_id WHERE users.user_name=\"$user_name\", logins.ip_address=\"$ip\"","serverResponse->num");
	// login user
	if($result == 0){		
		$result2 = sqlQueryXml("INSERT logins SET logins.user_id=\"$user_id\", logins.ip_address=\"$ip\"","serverResponse");
	}
	if($result2 == 1 || $result > 0){
		return dashEnvelope("login::OK");
	}
	else{
		return dashEnvelope("Error: Could not login");
	}
}


function logoutUser($user_name){
	$ip = getIpAddress();
	$user_id = sqlQueryXml("SELECT users.user_id FROM users WHERE users.user_name=\"$user_name\"","serverResponse->row->user_id");
	$result = sqlQueryXml("DELETE FROM logins WHERE logins.user_id=\"$user_id\" AND logins.ip_address=\"$ip\"","serverResponse");
	if($result == 1){
		return dashEnvelope("logout::OK");
	}
	else{
		return dashEnvelope("Error: Could not logout");
	}
}


function changePassword($user_name, $user_password) {
	// check if user_name and password and correct
    $result = sqlQueryXml("SELECT users.user_name, users.password, users.activated FROM users WHERE (((users.user_name)=\"$user_name\") AND ((users.password)=\"$user_password\") AND ((users.activated)=-1));","serverResponse->num");
	if($result > 1) return dashEnvelope("Error: Duplicate users");
	if($result == 0) return dashEnvelope("Error: Incorrect user name or password or account is not active");
	// check if user is already logged in
	$ip = getIpAddress();
	$user_id = sqlQueryXml("SELECT users.user_id FROM users WHERE users.user_name=\"$user_name\"","serverResponse->row->user_id");
	$result = sqlQueryXml("SELECT * FROM logins WHERE logins.user_id=\"$user_id\" AND logins.ip_address=\"$ip\"","serverResponse->num");
	//$result = sqlQueryXml("SELECT users.user_name, logins.ip_address FROM users INNER JOIN logins ON users.user_id=logins.user_id WHERE users.user_name=\"$user_name\", logins.ip_address=\"$ip\"","serverResponse->num");
	// login user
	if($result == 0){		
		$result2 = sqlQueryXml("INSERT logins SET logins.user_id=\"$user_id\", logins.ip_address=\"$ip\"","serverResponse");
	}
	if($result2 == 1 || $result > 0){
		return dashEnvelope("login::OK");
	}
	else{
		return dashEnvelope("Error: Could not login");
	}
}
?>