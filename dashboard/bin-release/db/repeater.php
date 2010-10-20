<?php
//!!!temp for debuging!!!
if(count($_GET)>0){
	$_POST = $_GET;
}

$tidy = tidy_parse_string($_POST['dashML'], array("output-xml" => true,"input-xml" => true));
$tidy->cleanRepair();
$dashML = new SimpleXMLElement($tidy);
//echo $tidy;
//echo $dashML->movie->plot;

echo $dashML->asXML();
// <movies><movie><title>dave</title><plot>it's all about me</plot></movie></movies>
?>