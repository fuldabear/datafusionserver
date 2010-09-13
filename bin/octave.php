<?php

$hip = exec("octave -q --eval 'sst(".@$_GET['x'].")'");
$hip = str_replace("ans = ","",$hip);
echo $hip;

?>
