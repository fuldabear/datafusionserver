<?php
//call with: [rho,a,temp,press,kvisc,ZorH]=stdatmo(H_in,Toffset,Units,GeomFlag)
$hip = exec("octave -q --eval 'stdatmo(".@$_GET['h'].")'");


$hip = str_replace("ans = ","",$hip);

echo $hip;

?>
