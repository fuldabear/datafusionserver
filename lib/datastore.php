<?php
	class Datastore
	{
	
		var $name;
		var $value;
		var $db;
			
		function Datastore($d='',$n='',$v='')
		{
			$this->name = $n;
			$this->value = $v;
			if($d == '') $this->db = new Datastore;
			else $this->db = $d;
		}
		
		public function write(){
			$unique = $this->db->sqlQuery("select name from variable where name='$this->name'");
			if ($unique->numOfRows!=0){ //update existing variable
				$query="update variable set value='$this->value' where name='$this->name'";
				$result=$this->db->sqlQuery($query);
			}else { //make new variable
				$result=$this->db->sqlQuery("insert variable set name='$this->name', value='$this->value'");
			}
			return $result;
		}
	
	
		public function read(){		
			$unique = $this->db->sqlQuery("select name, value, lastUpdated, description, units from variable where name='$this->name'");
			return $unique;
		}
	
		public function lsvar(){
			$unique = $this->db->sqlQuery("select name, value, lastUpdated, description, units from variable");		
			return $unique;
		}
	}
?>
