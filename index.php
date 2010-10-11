<?php
	/*
		For now this file defaults to the data functions as defined in ./bin/data.php

		In the future this file will determine whether a web-site, wiki-site, or functions within ./bin are presented.
	*/
	
	if(!isset($_GET['command'])) header("Location: http://".$_SERVER['HTTP_HOST']."/dev/david/www/datafusionserver/dashboard/bin-release/");
	else require_once('./bin/secureData.php');
?>
