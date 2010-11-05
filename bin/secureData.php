<?php
	header("Cache-Control: no-cache, must-revalidate");
	header("Content-Type: text/plain");

	ini_set('display_errors', true);

	require_once("./lib/database.php");
	require_once("./lib/session.php");
	require_once("./lib/ldap.php");
	require_once("./lib/json2obj.php");
	require_once("./lib/datastore.php");
	require_once("./lib/spyc.php");
	
	/*$myFile = "input.txt";
	$fh = fopen($myFile, 'w') or die("can't open file");
	fwrite($fh, var_dump($_GET));
	fclose($fh);*/
	
	$db = new Database($db_hostname="localhost",$db_username="root",$db_password="doc",$db_database="dev");
	
	if(!isset($_GET['user']) && !isset($_GET['password'])) echo 'Authorization Failed';
	else
	{
		$ldap = new Ldap($_GET['user'],$_GET['password']);
		$session = new Session($db, $_GET['user'],$_GET['password'], $ldap);
		if(isset($_GET['session'])) $session->session = $_GET['session'];
	
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
						if(isset($_GET['session'])) $ds->session = $_GET['session'];
						else $o->error = 'Session undefinded';
			
						if($mode == "read"){
							if(isset($_GET['name'])) $ds->name = $_GET['name'];
							if(isset($_GET['key'])) $ds->key = $_GET['key'];
							if(isset($_GET['value'])) $ds->value = $_GET['value'];
							if(isset($_GET['time'])) $ds->time = $_GET['time'];
							if(isset($_GET['rollback'])) $ds->rollback = $_GET['rollback'];
							if(isset($_GET['longPoll'])) $ds->longPoll = $_GET['longPoll'];
							if(isset($_GET['limit'])) $ds->limit = $_GET['limit'];
							if(isset($_GET['orderBy'])) $ds->orderBy = $_GET['orderBy'];
							$o = $ds->read();
						} 
						elseif($mode == "write"){
							if(isset($_GET['name'])) $ds->name = $_GET['name'];
							if(isset($_GET['value'])) $ds->value = $_GET['value'];
							if(isset($_GET['key'])) $ds->key = $_GET['key'];
							$o = $ds->write();
						} 
						elseif($mode == "move"){
							if(isset($_GET['name'])) $ds->name = $_GET['name'];
							if(isset($_GET['newName'])) $ds->newName = $_GET['newName'];
							$o = $ds->move();
						}
						elseif($mode == "remove"){
							if(isset($_GET['name'])) $ds->name = $_GET['name'];
							if(isset($_GET['fromAllSessions'])) $ds->fromAllSessions = $_GET['fromAllSessions'];
							$o = $ds->remove();
						}
						elseif($mode == "copy"){
							if(isset($_GET['name'])) $ds->name = $_GET['name'];
							if(isset($_GET['newName'])) $ds->newName = $_GET['newName'];
							if(isset($_GET['newSession'])) $ds->newSession = $_GET['newSession'];
							if(isset($_GET['link'])) $ds->link = $_GET['link'];
							if(isset($_GET['rw'])) $ds->rw = $_GET['rw'];
							if(isset($_GET['overWrite'])) $ds->overWrite = $_GET['overWrite'];
							$o = $ds->rename();
						}
						else{
						$o->error = 'Mode undefinded';
						}
					}else{
						$o->error = 'Mode undefinded';
					}
				}
				elseif($c == 'session'){
					if(isset($_GET['mode']))
					{
						$mode = $_GET['mode'];
					
						if($mode == "create"){
							if(isset($_GET['newSession'])) $session->newSession = $_GET['newSession'];
							if(isset($_GET['newSessionPassword'])) $session->newSessionPassword = $_GET['newSessionPassword'];
							if(isset($_GET['expiration'])) $session->expiration = $_GET['expiration'];
							if(isset($_GET['description'])) $session->description = $_GET['description'];							
							$o = $session->createSession();
						} 
						elseif($mode == "remove"){
							if(isset($_GET['name'])) $session->name = $_GET['name'];
							$o = $session->removeUserFromSession();
						} 
						elseif($mode == "setProperty"){
							if(isset($_GET['newSession'])) $session->newSession = $_GET['newSession'];
							if(isset($_GET['newSessionPassword'])) $session->newSessionPassword = $_GET['newSessionPassword'];
							if(isset($_GET['expiration'])) $session->expiration = $_GET['expiration'];
							if(isset($_GET['description'])) $session->description = $_GET['description'];
							$o = $session->setProperty();
						}
						elseif($mode == "list"){
							if(isset($_GET['list'])) $session->listof = $_GET['list'];
							if(isset($_GET['name'])) $session->name = $_GET['name'];
							$o = $session->listSessions();
						}
						else{
							$o->error = 'Mode undefinded';
						}
					}
					else{
						$o->error = 'Mode undefinded';
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
					$o->error = 'Command undefinded';
				}
			}
			else{
				$o->login = $userSession;
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
							echo $y->YAMLDump($o[$i],4,900);
						}
					}
					else
					{
						if(is_array($o)) echo $y->YAMLDump($o[0],4,900);
						else echo $y->YAMLDump($o,4,1000);
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
						echo $y->YAMLDump($o[$i],4,900);
					}
				}
				else
				{
					if(is_array($o)) echo $y->YAMLDump($o[0],4,900);
					else echo $y->YAMLDump($o,4,900);
				}
			}
		
		}else{
			echo 'Authorization Failed';
		}
	}
?>
