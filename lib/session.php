<?php	
	class Session{
	
		// level 1 (required for login)
		var $user;
		var $password;
		var $database;
		var $ldap;
		
		// level 2 (required for all commands)
		var $session;		
		
		// level 3 (dependent on command)
		var $name;
		var $newSession;
		var $sessionPassword;
		var $newSessionPassword;
		var $expiration;
		var $description;
		var $listof;
		var $userName;
		var $sessionName;
		
		// level 4 (misc)
		var $userId;
		var $sessionId;
	
		function Session($db=null,$n=null,$p=null,$l=null,$s=null){
			
			// level 1 (required for login)
			$this->user = $n;
			$this->password = $p;
			
			if($db == null) $db = new Database;
			else $this->database = $db;
			
			if($l == null) $l = new Ldap;
			else $this->ldap = $l;
			
			// level 2 (required for all commands)
			if($s != null) $session = $s;
			
			// run on init
			$this->checkExpiration();		
		}
		
		public function check(){
			
			// Check to see if the user already exist for the given user name
			$userCheckResults = $this->database->sqlQuery("select * from user where name='$this->user'");
			if($userCheckResults->numOfRows != 0){
				// check password
				if($userCheckResults->result[0]['password'] == $this->password) return true;
				// So the user exist, but the password is incorrect. let check ldap
				elseif($this->ldap->check()){
					$createUserResults = $this->database->sqlQuery("update user set password='$this->password' where name='$this->user'");
					return 'ldap';
				}
			}
			// So user does not exist. let check ldap
			elseif($this->ldap->check()){
					$createUserResults = $this->database->sqlQuery("insert user set name='$this->user', password='$this->password'");
					$num = '';
					while($this->createSession($this->user.$num, $this->password, 'User session') == 'session already exist'){
						if($num == '') $num = 1;
						else $num++;
					}
					return 'ldap';
			}
			else return false;
		}
			
		public function createSession($n=null, $p=null, $d=null, $e=null){	
			
			if($n == null) $n = $this->newSession;
			if($p == null) $p = $this->newSessionPassword;
			if($e == null) $e = $this->calculateExpiration($e);
			if($d == null) $d = $this->description;
			$o = new DbQueryMultipleInserts();
					
			// check to see if the session user exist
			$q = $this->database->sqlQuery("select * from session where name='$n'");
			if($q->numOfRows > 0) return 'Session already exist';			
			$q = $this->database->sqlQuery("insert session set name='$n', password='$p', description='$d', expiration='$e'");
			$o->update($q);
			$uid = $this->database->sqlQuery("select userId from user where name='$this->user'");
			$this->userId = $uid->result[0]['userId'];
			$sid = $this->database->sqlQuery("select sessionId from session where name='$n'");
			$this->sessionId = $sid->result[0]['sessionId'];
			$q = $this->database->sqlQuery("insert detailUserSession set userId='$this->userId', sessionId='$this->sessionId', admin='1'");			
			$o->update($q);
			return $o;
		}
		
			public function removeUserFromSession($n=null){
			if($n == null) $n = $this->name;
			if($n == null) $n = $this->user;
			
			if($this->session == null) return $error = 'Session undefined';
			
			$o = new DbQueryMultipleInserts();
			if($this->isAdmin() || $n == $this->user){
				$q = $this->database->sqlQuery("delete detailUserSession from detailUserSession inner join user on user.userId=detailUserSession.userId inner join session on session.sessionId=detailUserSession.sessionId where session.name='$this->session' and user.name='$n'");
				$o->update($q);
			}
			else $o->logError('Insufficient rights');
			return $o;
		}
		
		public function setProperty(){
			$n = $this->newSession;
			$p = $this->newSessionPassword;
			$e = $this->calculateExpiration($this->expiration);
			$d = $this->description;
			
			if($this->session == null) return $error = 'Session undefined';
			
			$o = new DbQueryMultipleInserts();
			
			if($this->isAdmin()){
				if($n != null){
					$q2 = $this->database->sqlQuery("select * from session where name='$n'");
					if($q2->numOfRows == 0){
						$q3 = $this->database->sqlQuery("update session set name='$n' where name='$this->session'");
						$o->update($q3);
					}
					else $o->logError("Session '$n' already exist");
				}
				if($p != null){
					$q4 = $this->database->sqlQuery("update session set password='$p' where name='$this->session'");
					$o->update($q4);
				}
				if($e != null){
					$q5 = $this->database->sqlQuery("update session set expiration='$e' where name='$this->session'");
					$o->update($q5);
				}
				if($d != null){
					$q6 = $this->database->sqlQuery("update session set description='$d' where name='$this->session'");
					$o->update($q6);
				}
			}
			else $o->logError('Insufficient rights');
			return $o;
		}
		
		public function listSessions(){
			$l  = $this->listof;
			$n = $this->name;
			
			if($l  == null) $l = 'allSessions';
			
			if($l  == 'sessionWithUser'){
				if($n == null) $n = $this->user;
				$q = $this->database->sqlQuery("select session.name, session.description, session.expiration, detailUserSession.admin from session inner join detailUserSession on detailUserSession.sessionId=session.sessionId inner join user on user.userId=detailUserSession.userId where user.name='$n'");	
			}
			elseif($l  == 'allSessions'){
				$q = $this->database->sqlQuery("select session.name, session.description, session.expiration from session");	
			}
			elseif($l  == 'allUsers'){
				$q = $this->database->sqlQuery("select user.name, user.title, user.email from user");	
			}
			elseif($l  == 'adminsInSession'){
				if($this->session == null) return $error = 'Session undefined';
				if($n == null) $n = $this->session;
				$q = $this->database->sqlQuery("select user.name, user.title, user.email from session inner join detailUserSession on detailUserSession.sessionId=session.sessionId inner join user on user.userId=detailUserSession.userId where session.name='$n'");	
			}
			else{
				// check if it is a variable
				if($this->session == null) return $error = 'Session undefined';
				$q1 = $this->database->sqlQuery("select variable.variableId from session inner join detailVariableSession on detailVariableSession.sessionId=session.sessionId inner join variable on variable.variableId=detailVariableSession.variableId where variable.name='$l' and session.name='$this->session'");	
				if($q1->numOfRows > 0){
					$q = $this->database->sqlQuery("select session.name, session.description, session.expiration from session inner join detailVariableSession on detailVariableSession.sessionId=session.sessionId inner join variable on variable.variableId=detailVariableSession.variableId where variable.variableId='".$q1->result[0]['variableId']."'");
				}
				else return $error = 'Variable not found';
			}
			if($q->numOfRows > 0 && isset($q->result[0]['expiration'])){
				for($i = 0; $i < $q->numOfRows; $i++){
					if($q->result[$i]['expiration'] == 0) $q->result[$i]['expiration'] = 'never';
					else $q->result[$i]['expiration'] = date('m/d/Y h:i:s a',$q->result[$i]['expiration']);
				}
			}
			return $q;
		}
		
		private function checkExpiration(){
			$t = time();
			// delete expired sessions
			$r = $this->database->sqlQuery("delete from ".$this->database->dbConfig->database.".session where (".$this->database->dbConfig->database.".session.expiration < ".$t." and ".$this->database->dbConfig->database.".session.expiration != 0) OR ".$this->database->dbConfig->database.".session.expiration is null");
			// delete orphined variable variables
			$r = $this->database->deleteOrphanedRecords('variable','detailVariableSession','variableId');
			// delete orphined value values
			$r = $this->database->deleteOrphanedRecords('value','variable','variableId');
			//delete orphaned histories
			$r = $this->database->deleteOrphanedRecords('history','value','valueId');
			//delete orpahned users
			$r = $this->database->deleteOrphanedRecords('user','detailUserSession','userId');
			//delete orphaned functions
			$r = $this->database->deleteOrphanedRecords('function','detailFunctionSession','idfunction');
			
			return $r;
		}
		
		private function calculateExpiration($e=null){
			if($e == null) $e = time() + 1209600;
			elseif($e == 0) $e = 0;
			else $e = strtotime($e);
			return $e;
		}
		
		private function isAdmin(){
			$u = $this->user;
			$s = $this->session;
			$q = $this->database->sqlQuery("select * from session inner join detailUserSession on detailUserSession.sessionId=session.sessionId inner join user on user.userId=detailUserSession.userId where session.name='$s' and user.name='$u' and admin='1'");
			if($q->numOfRows > 0) return true;
			else return false;
		}
		
	}
?>
