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
		var $time;
		var $rollback;
			
		function Datastore($d=null,$n=null,$k=null,$v=null,$s=null,$nn=null,$l=true){
		
			$this->name = $n;
			$this->value = $v;
			if($d == null) $this->db = new Datastore;
			else $this->db = $d;
			$this->longPoll = $l;
			$this->session = $s;
			$this->session = $nn;
			$this->key = $k;
			$this->time = null;
			$this->rollback = null;
		}	
	
		public function read($n=null, $k=null, $v=null, $longPoll=null){
			
			// Check to see if arguments have been pased directly to function
			// If yes, then use them
			// If no, then use the object's properties
			if($n == null) $n = $this->name;
			if($k == null) $k = $this->key;
			if($v == null) $v = $this->value;
			if($longPoll == null) $longPoll = $this->longPoll;
			$s = $this->session;
			// if time is 'all' then the function will report the full histories of the requested variables and disable long polling
			// if time is set then the function will report the variables at that time and disable long polling
			if($this->time == null) $this->time = time();
			elseif($this->time == 'all'){
				$longPoll=false;
			}
			else{
				$this->time = strtotime($this->time);
				$longPoll=false;
			}
			
			// If $n = $k = $v = null list all variables at their defualt values
			if($n == null && $k == null){
				if($this->time == 'all') $newest = '';
				else $newest = 'and dev.history.time=dev.variable.lastUpdated';
				$r = $this->db->sqlQuery("select variable.name, value.key, history.value, variable.lastUpdated, variable.description, variable.units from variable  inner join dev.value on dev.value.idvariable=dev.variable.idvariable inner join dev.history on dev.value.idvalue=dev.history.idvalue inner join dev.detailVariableSession on dev.variable.idvariable=dev.detailVariableSession.idvariable inner join dev.session on dev.session.idsession=dev.detailVariableSession.idsession where dev.value.default='1' and dev.session.name='$s' $newest");
				if($r->numOfRows != 0){
					for($i = 0; $i < $r->numOfRows; $i++){
						$r->result[$i]['lastUpdated'] = date('m/d/Y h:i:s a',$r->result[$i]['lastUpdated']);
					}
				}
				return $r;
			}
			
			// Process focused variable requests
			//// the json2obj will convert json into objects
			$nj = new json2obj($n);
			$kj = new json2obj($k);
			$vj = new json2obj($v);
			
			//// in order to keep the code generic single variable requests are converted into arrays just as multiple variable requests are
			if(($nj->result == false || $nj->result == null) && $n != null) $nj->result[] = $n;
			if(($kj->result == false || $kj->result == null) && $k != null) $kj->result[] = $k;
			if(($vj->result == false || $vj->result == null) && $v != null) $vj->result[] = $n;
			
			//// quick sanity check
			if(($nj->length != $kj->length && $kj->length != null) || ($nj->length != $vj->length && $vj->length != null)) return 'mismatched name, key, and value pairs';
			
			//// A long poll delays the server response until a change has taken place (using 10 second connection timeouts)
			////// long polls are disabled when time histories are required, previous values are not given, or disabled by request
			$change = false;
			$tictoc = time();
			while($change == false){
				//// this section determinds the time values for time history related requests
				////// This section convert &t into an array for the sql condition builder
				$time = array();
				for($i = 0; $i < $nj->length; $i++){
					if($this->time != 'all'){
						if($longPoll == true) $rb_time = time();
						else $rb_time = $this->time;
						if($this->rollback != null && is_int($this->rollback * 1)){
							$rb = $this->rollback + 1;
							$rb_time = $this->time - 1;
						}
						else $rb = 1;
						for($j = 0; $j < $rb; $j++){
							$q = "dev.session.name='$s' and dev.variable.name='".$nj->result[$i]."'";
							if($kj->result[$i] == '') $q .= " and dev.value.default='1'";
							else $q .= " and dev.value.key='".$kj->result[$i]."'";
							$u = $this->db->sqlQuery("select max(history.time) from variable  inner join dev.value on dev.value.idvariable=dev.variable.idvariable inner join dev.history on dev.value.idvalue=dev.history.idvalue inner join dev.detailVariableSession on dev.variable.idvariable=dev.detailVariableSession.idvariable inner join dev.session on dev.session.idsession=dev.detailVariableSession.idsession where $q and history.time <= '$rb_time' limit 1");
							$t = $u->result[0]['max(history.time)'];
							$rb_time = $t - 1;
						}
						$time[] = " and dev.history.time='".$t."'";
					}
					else $time[] = "";
				}
				
				//// sql condition string builder
				////// This section builds the custom sql condition statment depending on the information being requested
				$q = "(dev.session.name='$s' and dev.variable.name='".$nj->result[0]."'".$time[0];
				if($kj->result[0] == '') $q .= " and dev.value.default='1')";
				else $q .= " and dev.value.key='".$kj->result[0]."')";
				for($i = 1; $i < $nj->length; $i++){
					$q .= " or (dev.session.name='$s' and dev.variable.name='".$nj->result[$i]."'".$time[$i];
					if($kj->result[$i] == '') $q .= " and dev.value.default='1')";
					else $q .= " and dev.value.key='".$kj->result[$i]."')";
				}
				
				//// Send sql query and check for changes
				$r = $this->db->sqlQuery("select variable.name, value.key, history.value, history.time, variable.description, variable.units from variable  inner join dev.value on dev.value.idvariable=dev.variable.idvariable inner join dev.history on dev.value.idvalue=dev.history.idvalue inner join dev.detailVariableSession on dev.variable.idvariable=dev.detailVariableSession.idvariable inner join dev.session on dev.session.idsession=dev.detailVariableSession.idsession where $q");
				////// if values are present check for changes
				for($i = 0; $i < $vj->length; $i++){
					if($vj->result[array_search($r->result[$i]['name'], $nj->result)] != $r->result[$i]['value']) $change = true;
				}
				////// Break while loop if long poll is disabled
				if($longPoll == false || $vj->length == 0) $change = true;
				////// wait between queries while in long polling mode
				if($change == false){
					//////// if no change within 9 seconds, then return the current value
					if((time() - $tictoc) > 9) $change = true;
					else usleep(250000);
				}
			}
			////// convert time stamps from second from unix time to human time
			if($r->numOfRows != 0){
				for($i = 0; $i < $r->numOfRows; $i++){
					$r->result[$i]['time'] = date('m/d/Y h:i:s a',$r->result[$i]['time']);
				}
			}
			return $r;
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
					$result=$this->db->sqlQuery("insert value set idvariable='$variableId[0]', value.key='$k', value.default='0'",false);
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
				$result=$this->db->sqlQuery("insert value set idvariable='$variableId[0]', value.key='$k', value.default='1'",false);
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
				$result = $this->db->sqlQuery("select dev.value.idvalue from dev.value where value.key='$k' and value.idvariable='$vid' limit 1");
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
