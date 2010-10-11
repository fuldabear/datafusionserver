<?php
	class Ldap
	{
	
		var $user;
		var $password;
		var $host;
		var $dn;
		var $bindUser;
		var $bindPassword;
	
		function ldap($u='',$p='',$h='fender.asdl.ae.gatech.edu',$d='CN=users,DC=asdl,DC=ae,DC=gatech,DC=edu',$bu='webauth@asdl.ae.gatech.edu',$bp='dprz%562')
		{
			$this->user = $u;
			$this->password = $p;
			$this->host = $h;
			$this->dn = $d;
			$this->bindUser = $bu;
			$this->bindPassword = $bp;
		}
		
		public function check()
		{
			//return false; //temperary for debugging
			$ds=@ldap_connect("ldap://$this->host");
			if ($ds) {
				if (@ldap_bind($ds,$this->bindUser,$this->bindPassword)) {
					$r = @ldap_search( $ds, $this->dn, 'sAMAccountName=' . $this->user);
					if ($r) {
						$result = @ldap_get_entries( $ds, $r);
						if (isset($result[0])) {
							if (@ldap_bind( $ds, $result[0]['dn'], $this->password) ) {
								//echo "You're authorized as ".$this->user;
								//return $result[0];
								ldap_close($ds);
								return true;
							}else{
								//echo "Wrong Password.";
							}
						}else{
							//echo "User not found.";
							ldap_close($ds);
							return false;
						}
					}

				} else {
					//echo "Unable to bind to LDAP server.";
					ldap_close($ds);
					return false;
				}

				ldap_close($ds);

			} else {
				//echo "Unable to connect to LDAP server.";
				return false;
			}
		}
	}
?>
