<?php
	header("Cache-Control: no-cache, must-revalidate");
	header("Content-Type: text/plain");

	ini_set(display_errors, true);

	require_once("./lib/database.php");
	require_once("./lib/session.php");
	require_once("./lib/ldap.php");
	require_once("./lib/datastore.php");
	require_once("./lib/spyc.php");
	
	$db = new Database($db_hostname="localhost",$db_username="root",$db_password="doc",$db_database="mydb");
	
	if(!isset($_GET['user']) && !isset($_GET['password'])) echo 'Authorization Failed';
	else
	{
		$ldap = new Ldap($_GET['user'],$_GET['password']);
		$session = new Session($db, $_GET['user'],$_GET['password'], $ldap);
	
		$userSession = $session->check();
	
		if($userSession != false)
		{
			if(isset($_GET['command']))
			{
				$c = $_GET['command'];			

				if($c == 'datastore'){
					if(isset($_GET['mode']))
					{
						$mode = $_GET['mode'];
						$ds = new Datastore($db);
			
						if($mode == "read"){
							if(isset($_GET['name'])) $ds->name = $_GET['name'];
							if(isset($_GET['value'])) $ds->value = $_GET['value'];
							if(isset($_GET['longPoll'])) $ds->longPoll = $_GET['longPoll'];					
							$o = $ds->read();
						} 
						elseif($mode == "write"){
							$ds->name = $_GET['name'];
							$ds->value = $_GET['value'];
							$o = $ds->write();
						} 
						elseif($mode == "list"){
							$o = $ds->listVaraibles();
						}
						elseif($mode == "rename"){
							if(isset($_GET['name'])) $ds->name = $_GET['name'];
							if(isset($_GET['newname'])) $ds->newname = $_GET['newname'];
							if(isset($_GET['user'])) $ds->session = $_GET['user'];
							$o = $ds->rename();
						}
						else{
						$o->error = 'mode undefinded';
						}
					}else{
						$o->error = 'mode undefinded';
					}
				}
				elseif($c == 'session'){
					if(isset($_GET['mode']))
					{
						$mode = $_GET['mode'];
					
						if($mode == "create"){
							if(isset($_GET['newname']) && isset($_GET['newpassword']) && isset($_GET['expiration']) && isset($_GET['description'])) $o = $session->createSession($_GET['newname'],$_GET['newpassword'],$_GET['expiration'],$_GET['description']);
							else $o->error = 'newname or newpassword or expiration or description undefined';
						} 
						elseif($mode == "remove"){
							$o = $session->removeSession();
						} 
						elseif($mode == "list"){
							$o = $session->listSessions();
						}
						elseif($mode == "name"){
							if(isset($_GET['newname'])) $o = $session->changeName($_GET['newname']);
							else $o->error = 'newname undefined';
						} 
						elseif($mode == "password"){
							if(isset($_GET['newpassword'])) $o = $session->changePassword($_GET['newpassword']);
							else $o->error = 'newpassword undefined';
						}
						elseif($mode == "description"){
							if(isset($_GET['description'])) $o = $session->changeDescription($_GET['description']);
							else $o->error = 'description undefined';
						} 
						elseif($mode == "expiration"){
							if(isset($_GET['expiration'])) $o = $session->changeExpiration($_GET['expiration']);
							else $o->error = 'expiration undefined';
						}
						else{
							$o->error = 'mode undefinded';
						}
					}
					else{
						$o->error = 'mode undefinded';
					}
				}
				/*elseif($c == 'tag'){
					if(isset($_GET['mode']))
					{
						$mode = $_GET['mode'];
						$t = new Tag($db);
		
						if($mode == "apply"){
							$ds->name = $_GET['name'];						
							$o = $ds->read();
						} 
						elseif($mode == "remove"){
							$ds->name = $_GET['name'];
							$ds->value = $_GET['value'];
							$o = $ds->write();
						} 
						elseif($mode == "list"){
							$o = $ds->lsvar();
						}
						elseif($mode == "create"){
							$o = $ds->lsvar();
						}
						elseif($mode == "delete"){
							$o = $ds->lsvar();
						}
						else{
						$o->error = 'mode undefinded';
						}
					}
					else{
						$o->error = 'mode undefinded';
					}
				}*/
				else{
					$o->error = 'command undefinded';
				}
			}
			else{
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
					//bug fix
					if(count($o) > 1)
					{
						for($i = 0; $i < count($o); $i++)
						{
							echo $y->YAMLDump($o[$i],4,400);
						}
					}
					else
					{
						echo $y->YAMLDump($o,4,400);
					}
				}
			}
			else{
				$y = new Spyc();
				//bug fix
				if(count($o) > 1)
				{
					for($i = 0; $i < count($o); $i++)
					{
						echo $y->YAMLDump($o[$i],4,400);
					}
				}
				else
				{
					echo $y->YAMLDump($o,4,400);
				}
			}
		
		}else{
			echo 'Authorization Failed';
		}
	}
?>
