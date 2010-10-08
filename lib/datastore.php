<?php
	class Datastore
	{
	
		var $name;
		var $value;
		var $db;
			
		function Datastore($d=null,$n=null,$v=null)
		{
			$this->name = $n;
			$this->value = $v;
			if($d == null) $this->db = new Datastore;
			else $this->db = $d;
		}
		
		public function writeValue($n=null,$v=null){
			if($n == null) $n = $this->name;
			if($v == null) $v = $this->value;
			
			$unique = $this->db->sqlQuery("select name from variable where name='$n'");
			if ($unique->numOfRows!=0){ //update existing variable
				$query="update variable set value='$v' where name='$n'";
				$result=$this->db->sqlQuery($query);
			}else { //make new variable
				$result=$this->db->sqlQuery("insert variable set name='$n', value='$v'");
			}
			return $result;
		}
	
	
		public function read($n=null, $v=null, $longPoll=true){
			if($n == null) $n = $this->name;
			if($v == null) $v = $this->value;
			
			//create string
			
			//longpoll
			
			if($v != null && $longPoll == true)
			{
			
			}
			
			//shortpoll
			else
			{
			
			}
				
			$unique = $this->db->sqlQuery("select name, value, lastUpdated, description, units from variable where name='$this->name'");
			return $unique;
		}
	
		public function listVaraibles(){
			$unique = $this->db->sqlQuery("select name, value, lastUpdated, description, units from variable");		
			return $unique;
		}
		
		public function write()
		{
			$n = json_decode($this->name);
			$v = json_decode($this->value);
			if($n == null)
			{
				$results = $this->writeValue($this->name,$this->value);
			}
			else
			{
				$len_n = count($n);
				$len_v = count($v);
			
				if($len_n != $len_v) return 'mismatched name and value pairs';
				if($len_n <= 0) return 'no name value pairs';
				
				for($i = 0; $i < $len_n; $i++)
				{
					$results[$i] = clone $this->writeValue($n[$i],$v[$i]);
				}
			}
			return $results;
		}
		
		
	}
?>
