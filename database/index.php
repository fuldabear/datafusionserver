<?php
	/*
		This file is a security precaution to prevent the potential to bypass security measures by redirecting the 
		browser back to the main program
	*/
	header('Location:http://'.$_SERVER["HTTP_HOST"].'?'.$_SERVER["QUERY_STRING"]);
	echo 'Access Denied';
?>
