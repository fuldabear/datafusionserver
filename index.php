<?php
	/*
		For now this file defaults to the data functions as defined in ./bin/data.php if _GET or _POST exist
		This file determines whether a web-site, wiki-site, or functions within ./bin are presented.
	*/

	if(isset($_GET) || isset($_POST))
	{
		require_once('./bin/data.php');
	}
	else
	{
		header('Location:http://wiki.fullmer.homelinux.org');
	}
?>
