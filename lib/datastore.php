<?php
	class Datastore
	{
	
		var $name;
		var $value;
		var $db;
		var $longPoll;
			
		function Datastore($d=null,$n=null,$v=null,$l=false)
		{
			$this->name = $n;
			$this->value = $v;
			if($d == null) $this->db = new Datastore;
			else $this->db = $d;
			$this->longPoll = $l;
		}	
	
		public function read($n=null, $v=null, $longPoll=null){
			
			//check links to sessions
			if($n == null) $n = $this->name;
			if($v == null) $v = $this->value;
			if($longPoll == null) $longPoll = $this->longPoll;
			
			//test for multiple variables
			if(json_decode(str_replace("'",'"',$n)) != null){
			
				$n = json_decode(str_replace("'",'"',$n));
			
				$len_n = count($n);
				
				if($len_n <= 0) return 'no name value pairs';
			
				//create string for the multiple case
				$s = "name='$n[0]' ";
				for($i = 1; $i < $len_n; $i++){
					$s .= "OR name='$n[$i]' ";
				}
			}
			else{
				//create string for the single case
				$s = "name='$n';";
			}
			
			//longpoll
			if($longPoll == true && $v != null && $v != '')
			{
				if(json_decode(str_replace("'",'"',$v)) != null){
				
					$v_is_array = true;
					$v = json_decode(str_replace("'",'"',$v));
					$len_v = count($v);
					if($len_n != $len_v) return 'mismatched name and value pairs';
					if($len_v <= 0) return 'no name value pairs';
				}
				
				// check for change
				$c = false;
				while($c != true){
					$results = $this->db->sqlQuery("select name, value, lastUpdated, description, units from variable where $s");
					if($results->numOfRows != 0){
						for($i = 0; $i < $results->numOfRows; $i++){
							$results->result[$i]['lastUpdated'] = date('m/d/Y h:i:s a',$results->result[$i]['lastUpdated']);
							if($v_is_array == true){
								if($v[array_search($results->result[$i]['name'], $n)] != $results->result[$i]['value']) $c = true;
							}
							else{
								if($v != $results->result[$i]['value']) $c = true;
							}
						}
					}
					if($c == false) usleep(250000);
				}
				return $results;
			}
			
			//shortpoll
			else
			{
				$results = $this->db->sqlQuery("select name, value, lastUpdated, description, units from variable where $s");
				if($results->numOfRows != 0){
					for($i = 0; $i < $results->numOfRows; $i++){
						$results->result[$i]['lastUpdated'] = date('m/d/Y h:i:s a',$results->result[$i]['lastUpdated']);
					}
				}		
				return $results;
			}
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
		
		public function rw()
		{
		
		}
		
		public function link2session()
		{
		
		}
	
		public function listVaraibles(){
			// enforce links to sessions
			$results = $this->db->sqlQuery("select name, value, lastUpdated, description, units from variable");
			if($results->numOfRows != 0){
				for($i = 0; $i < $results->numOfRows; $i++){
					$results->result[$i]['lastUpdated'] = date('m/d/Y h:i:s a',$results->result[$i]['lastUpdated']);
				}
			}		
			return $results;
		}
		
		public function writeValue($n=null,$v=null){
			//create links to sessions
			
			if($n == null) $n = $this->name;
			if($v == null) $v = $this->value;
			
			$t = time();
			
			$unique = $this->db->sqlQuery("select name from variable where name='$n'");
			if ($unique->numOfRows!=0){ //update existing variable
				$query="update variable set value='$v', lastUpdated='$t' where name='$n'";
				$result=$this->db->sqlQuery($query);
			}else { //make new variable
				$result=$this->db->sqlQuery("insert variable set name='$n', value='$v', lastUpdated='$t'");
			}
			return $result;
		}
	}
?>
