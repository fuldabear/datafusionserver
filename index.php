<?php
	/*
		For now this file defaults to the data functions as defined in ./bin/data.php

		In the future this file will determine whether a web-site, wiki-site, or functions within ./bin are presented.
	*/


	if()
	{
		require_once('./bin/data.php');
	}
	else
	{
		header('Location:http://wiki.fullmer.homelinux.org');
	}
?>
