<?php
error_reporting(0);
include_once("dbconnect.php");
$email = $_POST['email'];

$sql = "SELECT * FROM FOOD WHERE FOODWORKER = '$email' ORDER BY FOODID DESC";

$result = $conn->query($sql);
if ($result->num_rows > 0) {
    $response["food"] = array();
    while ($row = $result ->fetch_assoc()){
        $foodlist = array();
        $foodlist[foodid] = $row["FOODID"];
        $foodlist[foodtitle] = $row["FOODTITLE"];
        $foodlist[foodowner] = $row["FOODOWNER"];
        $foodlist[foodprice] = $row["FOODPRICE"];
        $foodlist[fooddesc] = $row["FOODDESC"];
        $foodlist[foodtime] = date_format(date_create($row["FOODTIME"]), 'd/m/Y h:i:s');
        $foodlist[foodimage] = $row["FOODIMAGE"];
        $foodlist[foodlatitude] = $row["LATITUDE"];
        $foodlist[foodlongitude] = $row["LONGITUDE"];
        $foodlist[foodrating] = $row["RATING"];
        array_push($response["food"], $foodlist);    
    }
    echo json_encode($response);
}else{
    echo "nodata";
}

?>