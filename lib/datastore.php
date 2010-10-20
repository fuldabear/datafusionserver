<?php
	class Datastore
	{
	
		var $name;
		var $value;
		var $db;
		var $longPoll;
		var $session;
		var $newname;
		var $key;
			
		function Datastore($d=null,$n=null,$k=null,$v=null,$s=null,$nn=null,$l=true){
		
			$this->name = $n;
			$this->value = $v;
			if($d == null) $this->db = new Datastore;
			else $this->db = $d;
			$this->longPoll = $l;
			$this->session = $s;
			$this->session = $nn;
			$this->key = $k;
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
					// get all the id's
					
					// get all the variables by id
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
		
		public function write($n=null,$k=null,$v=null){
		
			if($n == null) $n = $this->name;
			if($k == null) $k = $this->key;
			if($v == null) $v = $this->value;
			
			$nj = new json2obj($n);
			$kj = new json2obj($k);
			$vj = new json2obj($v);
			
			if(($k == null || $k == '') && isset($_GET['user'])){
				$k = $_GET['user'];
				if($vj->length != null && $kj->length == null){
					$kj->length = $vj->length;
					for($i = 0; $i < $vj->length; $i++){
						$kj->result[] = $_GET['user'];
					}
				}
			}
			if($nj->result == false && $kj->result == false && $vj->result == false)
			{
				$results = $this->writeValue($n,$k,$v);
			}
			else
			{
				if($nj->length != $kj->length || $nj->length != $vj->length) return 'mismatched name, key, and value pairs';
				if($nj->length <= 0) return 'no name, key, and value pairs';
				for($i = 0; $i < $nj->length; $i++)
				{
					$results[$i] = $this->writeValue($nj->result[$i],$kj->result[$i],$vj->result[$i]);
				}
			}
			return $results;
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
			$j = new json2obj();
			$j->result = $this->getVariableId(true);
			$id = $j->orString('idvariable');
			if($id == false) return 'Session has no variables';
			$results = $this->db->sqlQuery("select name, value, lastUpdated, description, units from variable where $id");
			if($results->numOfRows != 0){
				for($i = 0; $i < $results->numOfRows; $i++){
					$results->result[$i]['lastUpdated'] = date('m/d/Y h:i:s a',$results->result[$i]['lastUpdated']);
				}
			}		
			return $results;
		}
		
		private function writeValue($n=null,$k=null,$v=null){
			if($n == null) $n = $this->name;
			if($v == null) $v = $this->value;
			if($k == null) $k = $this->key;
			$o = new DbQueryMultipleInserts();
			$variableId = $this->getWritableVariableId($n,$this->session); // there will only be one id or false
			$sessionId = $this->getSessionId($this->session); // there will only be one id or false
			$t = time();
			if ($variableId[0] != false){ //update existing variable
				$valueId = $this->getValueId($variableId[0],$k); // there will only be one or false
				if($valueId != false){ //update existing key value
					$result=$this->db->sqlQuery("insert history set value='$v', time='$t', idvalue='$valueId'",false);
					$o->update($result);
					$result=$this->db->sqlQuery("update variable set lastUpdated='$t' where idvariable='$variableId[0]'");
					$o->update($result);
				}
				else{ //make new key value
					$result=$this->db->sqlQuery("insert value set idvariable='$variableId[0]', name='$k', defaultValue='0'",false);
					$o->update($result);
					$result=$this->db->sqlQuery("insert history set value='$v', time='$t', idvalue=last_insert_id()",false);
					$o->update($result);
					$result=$this->db->sqlQuery("update variable set lastUpdated='$t' where idvariable='$variableId[0]'");
					$o->update($result);
				}
			}else { //make new variable
				$result=$this->db->sqlQuery("insert variable set name='$n', lastUpdated='$t'",false);
				$o->update($result);
				$result=$this->db->sqlQuery("insert detailVariableSession set idvariable=last_insert_id(), idsession='$sessionId', rw='1'",false);
				$o->update($result);
				$variableId = $this->getWritableVariableId($n,$this->session); // there will only be one id or false
				$result=$this->db->sqlQuery("insert value set idvariable='$variableId[0]', name='$k', defaultValue='0'",false);
				$o->update($result);
				$result=$this->db->sqlQuery("insert history set idvalue=last_insert_id(), value='$v', time='$t'");
				$o->update($result);
			}
			return $o;
		}
		private function getVariableId($n=null,$sn=null){
				if($n == null) $n = $this->name;
				if($sn == null) $sn = $this->session;
				$j = new json2obj($n);
				if($n == true){
					$results = $this->db->sqlQuery("select detailVariableSession.idvariable from detailVariableSession inner join variable on variable.idvariable = detailVariableSession.idvariable inner join session on session.idsession = detailVariableSession.idsession where session.name='$sn'");
				}
				elseif($j->result != false){
					$n = $j->andString('variable.name');
					$results = $this->db->sqlQuery("select detailVariableSession.idvariable from detailVariableSession inner join variable on variable.idvariable = detailVariableSession.idvariable inner join session on session.idsession = detailVariableSession.idsession where session.name='$sn' and $n");
				}
				else{
					$results = $this->db->sqlQuery("select detailVariableSession.idvariable from detailVariableSession inner join variable on variable.idvariable = detailVariableSession.idvariable inner join session on session.idsession = detailVariableSession.idsession where session.name='$sn' and variable.name='$n'");
				}
				if($results->numOfRows > 0){
					for($i = 0; $i < $results->numOfRows; $i++){
							$id[$i] = $results->result[$i]['idvariable'];
					}
					return $id;
				}
				return false;
		}
		
		private function getWritableVariableId($n=null,$sn=null){
				if($n == null) $n = $this->name;
				if($sn == null) $sn = $this->session;
				$j = new json2obj($n);
				if($j->result != false){
					$n = $j->andString('variable.name');
					$results = $this->db->sqlQuery("select detailVariableSession.idvariable from detailVariableSession inner join variable on variable.idvariable = detailVariableSession.idvariable inner join session on session.idsession = detailVariableSession.idsession where session.name='$sn' and detailVariableSession.rw='1' and $n");
				}
				else{
					$results = $this->db->sqlQuery("select detailVariableSession.idvariable from detailVariableSession inner join variable on variable.idvariable = detailVariableSession.idvariable inner join session on session.idsession = detailVariableSession.idsession where session.name='$sn' and detailVariableSession.rw='1' and variable.name='$n'");
				}
				if($results->numOfRows > 0){
					for($i = 0; $i < $results->numOfRows; $i++){
							$id[$i] = $results->result[$i]['idvariable'];
					}
					return $id;
				}
				return false;
		}
		
		private function getSessionId($sn=null){
			if($sn == null) $sn = $this->session;
			$result = $this->db->sqlQuery("select idsession from session where name='$sn' limit 1");
			if($result->numOfRows != 0) return $result->result[0]['idsession'];
			else return false;
		}
		
		private function getValueId($vid=null,$k=null){
			if($vid == null) return false;
			if($k == null) $k = $this->key;
			if($k != null){
				$result = $this->db->sqlQuery("select idvalue from value where name='$k' and idvariable='$vid' limit 1");
				if($result->numOfRows != 0) return $result->result[0]['idvalue'];
				else return false;
			}
			else{
				$result = $this->db->sqlQuery("select idvalue from value where idvariable='$vid' and defaultValue='1' limit 1");
				if($result->numOfRows != 0) return $result->result[0]['idvalue'];
				$result = $this->db->sqlQuery("select idvalue from value where idvariable='$vid' limit 1");
				if($result->numOfRows != 0) return $result->result[0]['idvalue'];
				else return false;
			}
		}
		
		private function getFunctionId(){
		
		}
	}
?>
