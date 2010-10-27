<?php
	class json2obj
	{
		var $json = null;
		var $length = null;
		var $result = null;
		
		function json2obj($j=null){
			if($j != null){
				$this->json = $j;
				$this->decode($this->json);
			}
		}
		
		// This function test the json code to ensure it is an array and returns the array
		// And updates the length
		public function decode($in=null){
			if($in == null) $in = $this->json;
			if(!json_decode(str_replace("'",'"',$in)) || is_numeric(json_decode(str_replace("'",'"',$in))) || $in == null) return false;
			$this->result = json_decode(str_replace("'",'"',$in));
			if(!is_array($this->result)) return false;
			$this->length = count($this->result);
			return $this->result;
		}
		
		public function andString($in=null){
			if($in == null) return false;
			if($this->result == null) $this->decode();
			if($this->result == false) return false;
			$r = $this->result;
			$s = "$in='$r[0]' ";
			for($i = 1; $i < $this->length; $i++){
				$s .= "AND $in='$r[$i]' ";
			}
			return $s;
		}
		
		public function orString($in=null){
			if($in == null) return false;
			if($this->result == null) $this->decode();
			if($this->result == false) return false;
			$r = $this->result;
			$s = "$in='$r[0]' ";
			for($i = 1; $i < $this->length; $i++){
				$s .= "OR $in='$r[$i]' ";
			}
			return $s;
		}
	}	
?>