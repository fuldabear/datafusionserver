<?php
function processData($data,$id=""){
	// step 1 :: determine senders ip address
	$ip = getIpAddress();
	// step 2 :: lookup ip address in database to find simulation data handler
	$simulation_id = sqlQueryXml("SELECT simulations.simulation_id FROM simulations WHERE simulations.simulation_source_ip=\"$ip\"","serverResponse->row->simulation_id");
	// step 3 :: if match was found continue else return error status
	// step 4 :: store data using the correct data handler
	// step 5 :: return status of operation
	$time = time();
	if($simulation_id >= 1 && $data != ""){
		$result = sqlQueryXml("INSERT simData SET simData.simulation_id=\"$simulation_id\", simData.data=\"$data\", simData.time=\"$time\"","serverResponse");
		if($result != 1) return dashEnvelope("Error: Could not store data");
	}
	else{
		//return dashEnvelope("Error: Could not accept data");		
	}
	
	// step 6 :: check if a data_id was provided
	
	if($id != ""){
		echo parseXml(sqlQuery("SELECT * FROM simData WHERE simData.simulation_id=\"$simulation_id\" && simData.data_id>\"$id\" && simData.cdata != \"\""))->asXML();
	}
	else{
		//return dashEnvelope("Data::OK");
		echo parseXml(sqlQuery("SELECT * FROM simData WHERE simData.simulation_id=\"$simulation_id\" && simData.time=(SELECT MAX(simData.time) FROM simData WHERE simData.cdata != \"\")"))->asXML();
	}
	
}

function processCData($data,$user,$sim,$id=""){
	// step 1 :: determine senders ip address
	$ip = getIpAddress();
	// step 2 :: Check that the user id and the ip address match
	$num_logins = sqlQueryXml("SELECT * FROM logins WHERE logins.user_id=\"$user\" && logins.ip_address=\"$ip\"","serverResponse->num");
	// step 3 :: if match was found continue else return error status
	if($num_logins == 0) return dashEnvelope("Error: User not logged in OR User does not exist");
	
	// step 4 :: store data using the given data handler (simulation_id)
	$num_simulations = sqlQueryXml("SELECT * FROM simulations WHERE simulations.simulation_id=\"$sim\"","serverResponse->num");
	if($num_simulations == 0) return dashEnvelope("Error: Not a valid simulation id");
	
	// step 5 :: return status of operation
	$time = time();
	if($data != ""){
		$result = sqlQueryXml("INSERT simData SET simData.simulation_id=\"$sim\", simData.cdata=\"$data\", simData.user_id=\"$user\", simData.time=\"$time\"","serverResponse");
		if($result != 1) return dashEnvelope("Error: Could not store data");
	}
	else{
		//return dashEnvelope("Error: Could not accept data");		
	}
	
	// step 6 :: check if a data_id was provided

	if($id != ""){
		echo parseXml(sqlQuery("SELECT * FROM simData WHERE simData.simulation_id=\"$sim\" && simData.data_id>\"$id\""))->asXML();
	}
	else{
		//return dashEnvelope("Data::OK");
		//echo parseXml(sqlQuery("SELECT * FROM simData WHERE simData.simulation_id=\"$sim\" && simData.time=(SELECT MAX(simData.time) FROM simData WHERE simData.data != \"\")"))->asXML();
		$last_data = sqlQueryXml("SELECT * FROM simData WHERE simData.simulation_id=\"$sim\" && simData.time=(SELECT MAX(simData.time) FROM simData WHERE simData.data != \"\")","serverResponse->row->data",0);
		$last_cdata = sqlQueryXml("SELECT * FROM simData WHERE simData.simulation_id=\"$sim\" && simData.time=(SELECT MAX(simData.time) FROM simData WHERE simData.cdata != \"\")","serverResponse->row->cdata",0);
		$last_time = sqlQueryXml("SELECT * FROM simData WHERE simData.simulation_id=\"$sim\" && simData.time=(SELECT MAX(simData.time) FROM simData)","serverResponse->row->time",0);
		$str = "<data>"."$last_data"."</data><cdata>"."$last_cdata"."</cdata><time>"."$last_time"."</time>";
		return dashEnvelope($str);
	}
	
}

function processConfigData($data,$sim,$dash){
	// step 1 :: determine if config_data is empty
	//			 If it is empty query config_data from database
	//			 If it is not empty store config_data in database
	if($sim >= 1 && $dash >= 1 && $data != ""){
		// step 2 :: check if configuration already exist in database
		//			 if it does perform an update
		//			 if it does not perform an insert
		$result = sqlQueryXml("SELECT dashConfiguration.config_id FROM dashConfiguration WHERE dashConfiguration.simulation_id=\"$sim\" && dashConfiguration.dash_id=\"$dash\"","serverResponse->row->config_id");
		if($result == ""){
			$result = sqlQueryXml("INSERT dashConfiguration SET dashConfiguration.simulation_id=\"$sim\", dashConfiguration.config_data=\"$data\", dashConfiguration.dash_id=\"$dash\"","serverResponse");
		}
		else{
			$result = sqlQueryXml("UPDATE dashConfiguration SET dashConfiguration.config_data=\"$data\" WHERE dashConfiguration.config_id=\"$result\"","serverResponse");
		} 
		if($result != 1) return dashEnvelope("Error: Could not store data");
	}
	elseif($sim >= 1 && $dash >= 1 && $data == ""){
		return parseXml(sqlQuery("SELECT dashConfiguration.config_data FROM dashConfiguration WHERE dashConfiguration.simulation_id=\"$sim\" && dashConfiguration.dash_id=\"$dash\""))->asXML();
	}
	
	else{
		return dashEnvelope("Error: missing simulation_id and/or dash_id in request");
	}
	return dashEnvelope("Data:OK");
}
?>