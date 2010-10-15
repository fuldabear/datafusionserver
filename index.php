<?php
	/*
		For now this file defaults to the data functions as defined in ./bin/data.php

		In the future this file will determine whether a web-site, wiki-site, or functions within ./bin are presented.
	*/
	
	if(!isset($_GET)) header("Location: http://".$_SERVER['HTTP_HOST']."/dashboard/bin-release/");
	else require_once('./bin/secureData.php');
?>
