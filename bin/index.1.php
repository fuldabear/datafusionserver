<?php
	ini_set(display_errors, true);

	//echo "in teh file";
	
	require_once("database.php");
	
	$db=new Database($db_hostname="localhost",$db_username="root",$db_password="doc",$db_database="mydb");
	//var_dump($db);
	//test to see if the variable already exists in the database
		
	$mode=$_GET['mode'];
	
	if ($mode=="read"){
		$name=$_GET['name'];
		read($name,$db);
	} 
   	if($mode=="write"){
		$name=$_GET['name'];
		$value=$_GET['value'];
		write($name,$value,$db);
	} 
	if($mode=="lsvar"){
		lsvar($db);
	}
	
	
	function write($name,$value,$db){
		$unique = $db->sqlQuery("select name from variable where name='$name'");
		//var_dump($unique);
		if ($unique->numOfRows!=0){ //update existing variable
			$q="update variable set value='$value' where name='$name'";
		//	var_dump($q);
			$temp=$db->sqlQuery($q);
		}else { //make new variable
			$temp=$db->sqlQuery("insert variable set name='$name', value='$value'");
		}
		$jtemp=json_encode($temp);
	
		echo $jtemp;
	}
	
	
	function read($name,$db){
		//echo "test";
		$unique = $db->sqlQuery("select name, value, lastUpdated, description, units from variable where name='$name'");
		//var_dump($unique);
		//if ($unique->numOfRows!=0){ //variable exists
		$jtemp=json_encode($unique);
		//	var_dump($q);
		//	$temp=$db->sqlQuery($q);
		//}else { //make new variable
		//	$temp=$db->sqlQuery("insert variable set name='$name', value='$value'");
		//}
		//$jtemp=json_encode($temp);
	
		$out = $unique->result;
		$outt = json_encode($out);
		echo $outt;
	}
	
	function lsvar($db){
		$unique = $db->sqlQuery("select name, value, lastUpdated, description, units from variable");		
		$jtemp=json_encode($unique);
		echo $jtemp;
	}
	
	
	
	
	
	
	
	
	
	
?>
