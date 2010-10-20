<?php
/* dependancies: utilities.php */

function connect(){
	include 'mysqlConfiguration.php';
	$conn = mysql_connect($dbhost, $dbuser, $dbpass) or die('Error connecting to mysql');
	mysql_select_db($dbname);
}


function disconnect(){
	mysql_close();
}

/// {resource or false} = sqlQuery({sql::string}) for select, show
/// The value of the resource is equal to the number of returns (i think)
/// {true or false} = sqlQuery({sql::string}) for insert, update, delete, drop

function sqlQuery($sqlString,$allow_embeded_xml=1){
	$result = mysql_query(stripslashes($sqlString));

	if(!is_resource($result)) return dashEnvelope($result);
	//Get the number of rows
	$num_row = mysql_num_rows($result);
	
	//Start the output of XML
	$outString = '<num>' .$num_row. '</num>';
	if (!$result) {
	   die('Query failed: ' . mysql_error());
	}   
	/* get column metadata - column name */
	        $i = 0;
	        while ($i < mysql_num_fields($result)) {
	              $meta = mysql_fetch_field($result, $i);
	            $ColumnNames[] = $meta->name;//place col name into array
	            $i++;
	        }
	$specialchar = array("&",">","<");//special characters
	$specialcharReplace = array("&amp;","&gt;","&lt;");//replacement
	/* query & convert table data and column names to xml */
	
	$w = 0;   
	while ($line = mysql_fetch_array($result, MYSQL_ASSOC)) {
	   $outString .= "<row>";
	    foreach ($line as $col_value){
	        $outString .= '<'.$ColumnNames[$w].'>';
	        $col_value_strip = str_replace($specialchar, $specialcharReplace, $col_value);       
	        if($allow_embeded_xml == 0)$outString .= $col_value_strip;
			else $outString .= $col_value;
	        $outString .= '</'.$ColumnNames[$w].'>';
	        if($w == ($i - 1)) { $w = 0; }
	        else { $w++; }
	       }
	    $outString .= "</row>";
	}
	return dashEnvelope($outString);
}

function sqlQueryXml($sqlString,$e4x,$allow_embeded_xml=1){
	$result = parseXml(sqlQuery($sqlString,$allow_embeded_xml));
	$str = "\$result->".$e4x.";";
	return eval("return " . $str);
}
?>