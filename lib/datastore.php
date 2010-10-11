<?php
	class Datastore
	{
	
		var $name;
		var $value;
		var $db;
		var $longPoll;
		var $session;
		var $newname;
			
		function Datastore($d=null,$n=null,$v=null,$s=null,$nn=null,$l=false){
		
			$this->name = $n;
			$this->value = $v;
			if($d == null) $this->db = new Datastore;
			else $this->db = $d;
			$this->longPoll = $l;
			$this->session = $s;
			$this->session = $nn;
		}	
	
		public function read($n=null, $v=null, $longPoll=null){
			
			//check links to sessions
			if($n == null) $n = $this->name;
			if($v == null) $v = $this->value;
			if($longPoll == null) $longPoll = $this->longPoll;
			
			//test for multiple variables
			$n_is_array = false;
			
			if(json_decode(str_replace("'",'"',$n)) != null){
			
				$n_is_array = true;
			
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
			if($longPoll == "true" && $v != null && $v != ''){
			
			$v_is_array = false;
			
				if(json_decode(str_replace("'",'"',$v)) != null && $n_is_array){
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
		
		public function write($n=null,$v=null){
		
			if($n == null) $n = $this->name;
			if($v == null) $v = $this->value;
			
			if(json_decode(str_replace("'",'"',$n)) == null)
			{
				$results = $this->writeValue($this->name,$this->value);
			}
			else
			{
				$n = json_decode(str_replace("'",'"',$n));
				$v = json_decode(str_replace("'",'"',$v));
				
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
		
		public function rw(){
		
		}
		
		public function rename($vn=null,$nn=null,$sn=null){
			
			if($vn == null) $vn = $this->name;
			if($nn == null) $nn = $this->newname;
			if($sn == null) $sn = $this->session;
			
			// get variable id
			$results = $this->db->sqlQuery("select detailVariableSession.idvariable from detailVariableSession inner join variable on variable.idvariable = detailVariableSession.idvariable inner join session on session.idsession = detailVariableSession.idsession where session.name='$sn' and variable.name='$vn' and detailVariableSession.rw='1'");
			if($results->numOfRows > 0){
				$id = $results->result[0]['idvariable'];
				$results = $this->db->sqlQuery("update variable set name='$nn' where idvariable='$id'");
				return $results;
			}
			return $error = 'variable not found';
		}
		
		public function link2session(){
		
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
				
				//$vid = $this->db->sqlQuery("select idvariable from variable where name='$n'");
				//$result[] = clone $this->db->sqlQuery("insert detailVariableSession set idvariable='$vid', idsession='$sid', rw='1'");
			}
			return $result;
		}
	}
?>
