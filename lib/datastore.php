<?php
	class Datastore
	{
		// level 1 (required for all operations)
		var $db;
		
		// level 2 (required for all commands)
		var $session;
		
		// level 3 (dependent on command)
		/// level 3.1
		var $name;
		var $key;
		var $value;
		
		/// level 3.2
		var $time;
		var $rollback;
		var $limit;
		var $orderBy;
		
		/// level 3.3
		var $longPoll;
		
		/// level 3.4
		var $newName;
		var $newSession;
		var $link;
		var $rw;
		var $overWrite;
		var $fromAllSessions;
		
		function Datastore($d=null,$l=true){
		
			if($d == null) $this->db = new Datastore;
			else $this->db = $d;
			$this->longPoll = $l;
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
			
			// Process focused variable requests
			//// the json2obj will convert json into objects
			$nj = new json2obj($n);
			$kj = new json2obj($k);
			$vj = new json2obj($v);
			
			// If $n = $k = $v = null list all variables at their default values
			if($n == null && $k == null){
				$nr = clone $this->db->sqlQuery("select variable.name from variable  inner join dev.detailVariableSession on dev.variable.variableId=dev.detailVariableSession.variableId inner join dev.session on dev.session.sessionId=dev.detailVariableSession.sessionId where dev.session.name='$s'");
				if($nr->numOfRows != 0){
					for($i = 0; $i < $nr->numOfRows; $i++){
						$kr = clone $this->db->sqlQuery("select value.key from value  inner join variable on variable.variableId=value.variableId inner join dev.detailVariableSession on dev.variable.variableId=dev.detailVariableSession.variableId inner join dev.session on dev.session.sessionId=dev.detailVariableSession.sessionId where dev.session.name='$s' and variable.name='".$nr->result[$i]['name']."'");
						for($j = 0; $j < $kr->numOfRows; $j++){
							$nj->result[] = $nr->result[$i]['name'];
							$kj->result[] = $kr->result[$j]['key'];
						}
					}
				}
				$nj->length = count($nj->result);
				$kj->length = count($kj->result);
			}
			
			//// in order to keep the code generic single variable requests are converted into arrays just as multiple variable requests are
			if(($nj->result == false || $nj->result == null) && $n != null){
				$nj->result[] = $n;
				$nj->length = 1;
			}
			if(($kj->result == false || $kj->result == null) && $k != null){
				$kj->result[] = $k;
				$kj->length = 1;
			}
			if(($vj->result == false || $vj->result == null) && $v != null){
				$vj->result[] = $n;
				$vj->length = 1;
			}
			
			//// quick sanity check
			if(($nj->length != $kj->length && $kj->length != null) || ($nj->length != $vj->length && $vj->length != null)) return 'mismatched name, key, and value pairs';
			if(count($nj->result) == 0) return $error = 'Variable(s) not found';
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
							$q = "session.name='$s' and variable.name='".$nj->result[$i]."'";
							if($kj->result[$i] == '') $q .= " and value.default='1'";
							else $q .= " and value.key='".$kj->result[$i]."'";
							$u = $this->db->sqlQuery("select max(history.time) from variable  inner join dev.value on dev.value.variableId=dev.variable.variableId inner join dev.history on dev.value.valueId=dev.history.valueId inner join dev.detailVariableSession on dev.variable.variableId=dev.detailVariableSession.variableId inner join dev.session on dev.session.sessionId=dev.detailVariableSession.sessionId where $q and history.time <= '$rb_time' limit 1");
							$t = $u->result[0]['max(history.time)'];
							$rb_time = $t - 1;
						}
						$time[] = " and history.time='".$t."'";
					}
					else $time[] = "";
				}
				
				//// sql condition string builder
				////// This section builds the custom sql condition statment depending on the information being requested
				$q = "(session.name='$s' and variable.name='".$nj->result[0]."'".$time[0];
				if($kj->result[0] == '') $q .= " and value.default='1')";
				else $q .= " and value.key='".$kj->result[0]."')";
				for($i = 1; $i < $nj->length; $i++){
					$q .= " or (session.name='$s' and variable.name='".$nj->result[$i]."'".$time[$i];
					if($kj->result[$i] == '') $q .= " and value.default='1')";
					else $q .= " and value.key='".$kj->result[$i]."')";
				}
				// order by
				if($this->orderBy != null) $q .= " order by ".str_replace('history','historyId',str_replace('key','value.key',$this->orderBy))."";
				// apply limit to rows returned
				if(is_int($this->limit * 1) && $this->limit != null) $q .= " limit ".$this->limit."";
				
				//// Send sql query and check for changes
				$r = $this->db->sqlQuery("select variable.name, value.key, history.value, history.time, variable.description, variable.units from variable  inner join dev.value on dev.value.variableId=dev.variable.variableId inner join dev.history on dev.value.valueId=dev.history.valueId inner join dev.detailVariableSession on dev.variable.variableId=dev.detailVariableSession.variableId inner join dev.session on dev.session.sessionId=dev.detailVariableSession.sessionId where $q");
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
			if($r->numOfRows < $nj->length && $n != null && $r->error == 'none'){
				$r->error = 'one or more variables do not exist';
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
			
			//get variable id
			
			$id = $this->getWritableVariableId($vn,$sn);
			
			if($id != false){
				$r = $this->db->sqlQuery("update variable set name='$nn' where variableId='".$id[0]."'");
				return $r;
			}
			return $error = 'either variable not found or write access denied';
		}
		
		public function remove($vn=null,$sn=null){
			
			if($vn == null) $vn = $this->name;
			if($sn == null) $sn = $this->session;
			
			//get variable id
			
			$id = $this->getWritableVariableId($vn,$sn);
			
			if($id != false){
				$r = $this->db->sqlQuery("delete from variable where variableId='".$id[0]."'");
				return $r;
			}
			return $error = 'either variable not found or write access denied';
		}
		
		public function link2session(){
			$vn = $this->variable;
			$sn = $this->session;
			$ns = $this->newsession;
			$rw = $this->rw;
			$o = new DbQueryMultipleInserts();
			
			//get variable id
			$id = $this->getWritableVariableId($vn,$sn);
			if($id == false || $rw == 0){
				$id = $this->getVariableId($vn,$sn);
				if($id == false){
					return $error = 'either variable not found or access denied';
				}
				$q = "rw='0' ";
			}
			elseif($id != false) $q = "rw='1' ";
			
			$sid = $this->getSessionId($ns);
			
			if($sid == false) return $error = 'target session does not exist';
			if($id != false && $sid != false){
				$r = $this->db->sqlQuery("select iddetailVariableSession from detailVariableSession where variableId='".$id[0]."' and sessionId='".$sid."' limit 1");
				$o->update($r);
				if($r->numOfRows > 0){
					$r = $this->db->sqlQuery("update detailVariableSession set variableId='".$id[0]."', sessionId='".$sid."', $q where iddetailVariableSession='".$r->result[0]['iddetailVariableSession']."'");
					$o->update($r);
				}
				else{
					$r = $this->db->sqlQuery("insert detailVariableSession set variableId='".$id[0]."', sessionId='".$sid."', $q");
					$o->update($r);
				}
				return $o;
			}
			return $error = 'unable to link variable to session';
		}
	
		public function listVaraibles(){
			// enforce links to sessions
			$j = new json2obj();
			$j->result = $this->getVariableId(true);
			$id = $j->orString('variableId');
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
					$result=$this->db->sqlQuery("insert history set value='$v', time='$t', valueId='$valueId'",false);
					$o->update($result);
					$result=$this->db->sqlQuery("update variable set lastUpdated='$t' where variableId='$variableId[0]'");
					$o->update($result);
				}
				else{ //make new key value
					$result=$this->db->sqlQuery("insert value set variableId='$variableId[0]', value.key='$k', value.default='0'",false);
					$o->update($result);
					$result=$this->db->sqlQuery("insert history set value='$v', time='$t', valueId=last_insert_id()",false);
					$o->update($result);
					$result=$this->db->sqlQuery("update variable set lastUpdated='$t' where variableId='$variableId[0]'");
					$o->update($result);
				}
			}else { //make new variable
				$result=$this->db->sqlQuery("insert variable set name='$n', lastUpdated='$t'",false);
				$o->update($result);
				$result=$this->db->sqlQuery("insert detailVariableSession set variableId=last_insert_id(), sessionId='$sessionId', rw='1'",false);
				$o->update($result);
				$variableId = $this->getWritableVariableId($n,$this->session); // there will only be one id or false
				$result=$this->db->sqlQuery("insert value set variableId='$variableId[0]', value.key='$k', value.default='1'",false);
				$o->update($result);
				$result=$this->db->sqlQuery("insert history set valueId=last_insert_id(), value='$v', time='$t'");
				$o->update($result);
			}
			return $o;
		}
		private function getVariableId($n=null,$sn=null){
				if($n == null) $n = $this->name;
				if($sn == null) $sn = $this->session;
				$j = new json2obj($n);
				if($n == true){
					$results = $this->db->sqlQuery("select detailVariableSession.variableId from detailVariableSession inner join variable on variable.variableId = detailVariableSession.variableId inner join session on session.sessionId = detailVariableSession.sessionId where session.name='$sn'");
				}
				elseif($j->result != false){
					$n = $j->andString('variable.name');
					$results = $this->db->sqlQuery("select detailVariableSession.variableId from detailVariableSession inner join variable on variable.variableId = detailVariableSession.variableId inner join session on session.sessionId = detailVariableSession.sessionId where session.name='$sn' and $n");
				}
				else{
					$results = $this->db->sqlQuery("select detailVariableSession.variableId from detailVariableSession inner join variable on variable.variableId = detailVariableSession.variableId inner join session on session.sessionId = detailVariableSession.sessionId where session.name='$sn' and variable.name='$n'");
				}
				if($results->numOfRows > 0){
					for($i = 0; $i < $results->numOfRows; $i++){
							$id[$i] = $results->result[$i]['variableId'];
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
					$results = $this->db->sqlQuery("select detailVariableSession.variableId from detailVariableSession inner join variable on variable.variableId = detailVariableSession.variableId inner join session on session.sessionId = detailVariableSession.sessionId where session.name='$sn' and detailVariableSession.rw='1' and $n");
				}
				else{
					$results = $this->db->sqlQuery("select detailVariableSession.variableId from detailVariableSession inner join variable on variable.variableId = detailVariableSession.variableId inner join session on session.sessionId = detailVariableSession.sessionId where session.name='$sn' and detailVariableSession.rw='1' and variable.name='$n'");
				}
				if($results->numOfRows > 0){
					for($i = 0; $i < $results->numOfRows; $i++){
							$id[$i] = $results->result[$i]['variableId'];
					}
					return $id;
				}
				return false;
		}
		
		private function getSessionId($sn=null){
			if($sn == null) $sn = $this->session;
			$result = $this->db->sqlQuery("select sessionId from session where name='$sn' limit 1");
			if($result->numOfRows != 0) return $result->result[0]['sessionId'];
			else return false;
		}
		
		private function getValueId($vid=null,$k=null){
			if($vid == null) return false;
			if($k == null) $k = $this->key;
			if($k != null){
				$result = $this->db->sqlQuery("select dev.value.valueId from dev.value where value.key='$k' and value.variableId='$vid' limit 1");
				if($result->numOfRows != 0) return $result->result[0]['valueId'];
				else return false;
			}
			else{
				$result = $this->db->sqlQuery("select valueId from value where variableId='$vid' and defaultValue='1' limit 1");
				if($result->numOfRows != 0) return $result->result[0]['valueId'];
				$result = $this->db->sqlQuery("select valueId from value where variableId='$vid' limit 1");
				if($result->numOfRows != 0) return $result->result[0]['valueId'];
				else return false;
			}
		}
		
		private function getFunctionId(){
		
		}
	}
?>
