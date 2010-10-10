<?php	
	class Session
	{
	
		var $name;
		var $password;
		var $database;
		var $ldap;
	
		function Session($db='',$n='',$p='',$l='')
		{
			$this->name = $n;
			$this->password = $p;
			if($db == '') $db = new Database;
			else $this->database = $db;
			if($l == '') $l = new Ldap;
			else $this->ldap = $l;
			
			$this->checkExpiration();		
		}
		
		public function check()
		{
			// Check to see if session already exist for user and pass
			$results = $this->database->sqlQuery("select * from session where name='$this->name' and password='$this->password'");
			//var_dump($results);
			if($results->numOfRows != 0) return $results;
			
			// So the session does not exist let's check the ldap
			if($this->ldap->check())
			{
				// So ldap is good let's create a session
				$this->createSession();
				$results = $this->database->sqlQuery("select * from session where name='$this->name'");
				return $results;
			}
			else return false;
		}
		
		public function createSession($name='', $password='', $expiration='4320', $description='')
		{	
			if($name == '') $n = $this->name;
			else $n = $name;
			if($password == '') $p = $this->password;
			else $p = $password;
			$e = time() + ($expiration * 60);
			$d = $description;
					
			// check to see if the session name exist
			$results = $this->database->sqlQuery("select * from session where name='$n'");
			if($results->numOfRows > 0) return 'session already exist';			
			$results = $this->database->sqlQuery("insert session set name='$n', password='$p', description='$d', expiration='$e'");
			return $results;
		}
		
		public function removeSession()
		{
			// need to add code for the removal of items exclusivly assoicated with this session
			$results = $this->database->sqlQuery("delete from session where name='$this->name' and password='$this->password'");
			return $results;
		}
		
		public function changeName($name='')
		{
			$results = $this->database->sqlQuery("update session set name='$name' where name='$this->name' and password='$this->password'");
			return $results;
		}
		
		public function changePassword($password='')
		{
			$results = $this->database->sqlQuery("update session set password='$password' where name='$this->name' and password='$this->password'");
			return $results;
		}
		
		public function changeDescription($description='')
		{
			$results = $this->database->sqlQuery("update session set description='$description' where name='$this->name' and password='$this->password'");
			return $results;
		}
		
		public function changeExpiration($expiration='4320')
		{
			if($expiration != 0) $expiration = time() + ($expiration * 60);
			$results = $this->database->sqlQuery("update session set expiration='$expiration' where name='$this->name' and password='$this->password'");
			return $results;
		}
		
		public function listSessions()
		{
			$results = $this->database->sqlQuery("select name, description, expiration from session");
			return $results;
		}
		
		private function checkExpiration()
		{
			$t = time();
			$results = $this->database->sqlQuery("delete from session where expiration < '$t' AND expiration != 0");
			return $results;
		}
		
		
	}
?>
