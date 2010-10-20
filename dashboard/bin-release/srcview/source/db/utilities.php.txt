<?php
//////service functions//////
function dashEnvelope($content){
	return "<?xml version=\"1.0\"?><dashML><serverResponse>$content</serverReponse></dashML>";
}


function parseXml($inXml){
	// tidy things up (ensure data is well formed xml)
	$tidy = tidy_parse_string($inXml, array("output-xml" => true,"input-xml" => true));
	$tidy->cleanRepair();
	
	//create simpleXML object from data
	$result = new SimpleXMLElement($tidy);
	return $result;
}


function getIpAddress(){
	  if (!empty($_SERVER['HTTP_CLIENT_IP']))
	  //check ip from share internet
	  {
	    $ip=$_SERVER['HTTP_CLIENT_IP'];
	  }
	  elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR']))
	  //to check ip is pass from proxy
	  {
	    $ip=$_SERVER['HTTP_X_FORWARDED_FOR'];
	  }
	  else
	  {
	    $ip=$_SERVER['REMOTE_ADDR'];
	  }
	  return $ip;
};
?>