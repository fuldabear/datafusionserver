<?php	
	class DbConfig
	{
		var $host;
		var $user;
		var $pass;
		var $database;
		
		function DbConfig($h="",$u="",$p="",$d="")
		{
			$this->host = $h;
			$this->user = $u;
			$this->pass = $p;
			$this->database = $d;	
		}
	}
	
	class DbQuery
	{
		var $query;
		var $numOfRows;
		var $numOfRowsAffected;
		var $numOfColumns;
		var $columnNames;
		var $status;
		var $error;
		var $result;
		
		function DbQuery($q="",$nor="",$nora="",$noc="",$cn="",$s="",$e="",$r="")
		{
			$this->query = $q;
			$this->numOfRows = $nor;
			$this->numOfRowsAffected = $nora;
			$this->numOfColumns = $noc;
			$this->columnNames = $cn;
			$this->status = $s;
			$this->error = $e;
			$this->result = $r;
				
		}
	}
	
	class DbQueryMultipleInserts
	{
		var $result;
		var $errors;
		
		function DbQueryMultipleInserts()
		{
			$this->result = true;
			$this->errors = null;
		}
		
		public function update($r=null){
		if($r != null){
			if($r->status == 'error'){
					$this->result = 'error';
					$this->errors[] = clone $r;
				}
			}
		}
		
		public function logError($l=''){
			$this->result = 'error';
			$this->errors[] = $l;
		}
	}
	
	class Database
	{
		var $result;
		var $dbConfig;
		var $logOp;
		
		function database($db_hostname="",$db_username="",$db_password="",$db_database="")
		{
			$this->result = new DbQuery();
			$this->dbConfig = new DbConfig($db_hostname,$db_username,$db_password,$db_database);
			//$this->logger = new Logger();
			$this->logOp = false;
			
		}
			
		private function connect()
		{	
			$status = 'ok';
			$connection = mysql_connect($this->dbConfig->host, $this->dbConfig->user, $this->dbConfig->pass) or $status = 'Error connecting to mysql';
			mysql_select_db($this->dbConfig->database);
			return $status;
		}
		
		private function disconnect()
		{
			@mysql_close();
		}
		
		public function sqlQuery($query='',$autoDisconnect=true)
		{
			$query = str_replace("dev",$this->dbConfig->database,$query); /// convert keyword 'dev' in sql to current database name on server
			$query = split(";",$query);
			$numOfQueries = count($query);
			if($numOfQueries > 1){
				var_dump($query);
				//return 'cool';
			}
			$this->result->status = 'error';
			$this->result->error = 'none';
			
			if ($this->connect() != 'ok')
			{
				$this->result->error = mysql_error();
				return $this->result;
			}
			for($i = 0; $i < $numOfQueries; $i++){	
				$this->result->query = $query[$i];
				$resource = mysql_query($query[$i]);
				
				if (!$resource) {
					$this->result->error = 'Query failed: ' . mysql_error();
					//if($this->logOp == false) $this->logger->log('',$query,$this->result->error);
				}
				/////////////////////////////////////////else unset($this->result->query);
			
				$this->result->numOfRows = @mysql_num_rows($resource);
				if ($this->result->numOfRows == false) $this->result->numOfRows = 0;
				$this->result->numOfRowsAffected = @mysql_affected_rows();
				if ($this->result->numOfRowsAffected == false || $this->result->numOfRowsAffected == -1) $this->result->numOfRowsAffected = 0;
				
				$i = 0;
				while ($i < @mysql_num_fields($resource))
					{
					$meta = mysql_fetch_field($resource, $i);
					$columnNames[] = $meta->name;//place col name into array
					$i++;
				}
				@$this->result->columnNames = $columnNames;
				$this->result->numOfColumns = $i;
				if ($resource == false)
				{
					$this->result->status = 'error';
					$this->result->result = false;
				}
				else
				{
					$row = null;
					while ($line = @mysql_fetch_array($resource, MYSQL_ASSOC))
					{
						$row[] = $line;
					}
					if($row != null)
					{
						$this->result->status = 'ok';
						$this->result->result = $row;
					}
					else
					{
						$this->result->status = 'ok';
						$this->result->result = true;
					}
				}
				$o[] = $this->result;
			}
			if($autoDisconnect == true) $this->disconnect();
			if($numOfQueries == 1) return $this->result;
			else return $o;
		}
		
		public function deleteOrphanedRecords($dt='',$jt='',$id=''){
			// dt: table recordes are being delected from
			// jt: table dt is joined with
			// id: where column id is null
			$r = $this->sqlQuery("delete ".$dt." from ".$dt." left join ".$jt." on ".$dt.".".$id."=".$jt.".".$id." where ".$jt.".".$id." is null");
			return $r;
		}
	}
?>
