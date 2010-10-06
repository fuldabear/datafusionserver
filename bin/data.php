<?php
	ini_set(display_errors, true);
	
	header("Cache-Control: no-cache, must-revalidate");

	//echo "in the file";
	
	require_once("lib/database.php");
	
	$db=new Database($db_hostname="localhost",$db_username="root",$db_password="doc",$db_database="mydb");
	//var_dump($db);
	//test to see if the variable already exists in the database
		
	$mode=$_GET['mode'];
	
	if ($mode=="read"){
		$name=$_GET['name'];
		$o = read($name,$db);
	} 
   	if($mode=="write"){
		$name=$_GET['name'];
		$value=$_GET['value'];
		$o = write($name,$value,$db);
	} 
	if($mode=="lsvar"){
		$o = lsvar($db);
	}
	
	//format output
	if(isset($_GET['output'])){
		if($_GET['output']=="simple"){
			$j = json_encode($o->result);
			echo $j;
		}
		if($_GET['output']=="number"){
			$j = json_encode($o->result[0]['value']);
			echo ltrim(rtrim($j,'"'),'"');
		}
		if($_GET['output']=="php"){
			var_dump($o);
		}
		if($_GET['output']=="normal"){
			$j = json_encode($o);
			echo $j;
		}
	}
	else{
		$j = json_encode($o);
		echo $j;
	}
	
	
	function write($name,$value,$db){
		$unique = $db->sqlQuery("select name from variable where name='$name'");
		if ($unique->numOfRows!=0){ //update existing variable
			$q="update variable set value='$value' where name='$name'";
			$temp=$db->sqlQuery($q);
		}else { //make new variable
			$temp=$db->sqlQuery("insert variable set name='$name', value='$value'");
		}
		return $temp;
	}
	
	
	function read($name,$db){		
		$unique = $db->sqlQuery("select name, value, lastUpdated, description, units from variable where name='$name'");
		return $unique;
	}
	
	function lsvar($db){
		$unique = $db->sqlQuery("select name, value, lastUpdated, description, units from variable");		
		return $unique;
	}
	
	
	
	
	
	
	
	
	
	
?>
