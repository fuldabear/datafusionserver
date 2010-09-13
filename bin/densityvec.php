<?php
//call with: [rho,a,temp,press,kvisc,ZorH]=stdatmo(H_in,Toffset,Units,GeomFlag)
$hip = exec("octave -q --eval 'warning off;stdatmo([100,200])'",$output);

print_r($output);

?>

