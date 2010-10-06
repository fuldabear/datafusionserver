<?php
	ini_set(display_errors, true);
	
	header("Cache-Control: no-cache, must-revalidate");
	header("Content-Type: text/plain");


	require_once("./lib/database.php");
	require_once("./lib/ldap.php");
	require_once("./lib/datastore.php");
	require_once("./lib/spyc.php");
	
	$db = new Database($db_hostname="localhost",$db_username="root",$db_password="doc",$db_database="mydb");
	$au = new Ldap($_GET['user'],$_GET['password']);
	
	
	if($au->check())
	{
		if(isset($_GET['command']))
		{
			$c = $_GET['command'];
			$o = ''; //output

			if($c == 'datastore'){
				if(isset($_GET['mode']))
				{
					$mode = $_GET['mode'];
					$ds = new Datastore($db);
			
					if($mode == "read"){
						$ds->name = $_GET['name'];						
						$o = $ds->read();
					} 
					elseif($mode == "write"){
						$ds->name = $_GET['name'];
						$ds->value = $_GET['value'];
						$o = $ds->write();
					} 
					elseif($mode == "lsvar"){
						$o = $ds->lsvar();
					}
					else{
					$o->error = 'mode undefinded';
					}
				}else{
					$o->error = 'mode undefinded';
				}
			}else{
				$o->error = 'command undefinded';
			}
		}else{
			$o->error = 'command undefinded';
		}
		if(isset($_GET['output'])){
			if($_GET['output'] == "simple"){
				$j = json_encode($o->result);
				echo $j;
			}
			elseif($_GET['output'] == "value"){
				$j = json_encode($o->result[0]['value']);
				echo ltrim(rtrim($j,'"'),'"');
			}
			elseif($_GET['output'] == "php"){
				var_dump($o);
			}
			elseif($_GET['output'] == "json"){
				$j = json_encode($o);
				echo $j;
			}
			else{
				$y = new Spyc();
				echo $y->YAMLDump($o,4,100);
			}
		}
		else{
			$y = new Spyc();
			echo $y->YAMLDump($o,4,100);
		}
		
	}else{
		echo 'Authorization Failed';
	}	
?>
