<?php
	/*
		For now this file defaults to the data functions as defined in ./bin/data.php

		In the future this file will determine whether a web-site, wiki-site, or functions within ./bin are presented.
	*/
	ini_set('display_errors', true);
	
	
	if(isset($_GET)){
		if(count($_GET) > 0) require_once('./bin/secureData.php');
		else{
			header("Location: http://".$_SERVER['HTTP_HOST']."/dev/dashboard/bin-release/");
		}
	}
	else{
		header("Location: http://".$_SERVER['HTTP_HOST']."/dev/dashboard/bin-release/");
	}
?>