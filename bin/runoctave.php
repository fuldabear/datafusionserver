<?php
//call with: runoctave?function=stdatmo&inputs=[x1,x2,...]  
$hip = "octave -q --eval '" . @$_GET['function'] . "(" . @$_GET['h'] . ")'";


//$hip = str_replace("ans = ","",$hip);

echo $hip;

?>