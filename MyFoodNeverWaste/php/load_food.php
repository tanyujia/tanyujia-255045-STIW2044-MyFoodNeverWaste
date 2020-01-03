<?php
error_reporting(0);
include_once("dbconnect.php");
$email = $_POST['email'];
$latitude = $_POST['latitude'];
$longitude = $_POST['longitude'];
$radius = $_POST['radius'];
$sql = "SELECT * FROM FOOD WHERE FOODWORKER IS NULL ORDER BY FOODID";
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
        $foodlist[km] = distance($latitude,$longitude,$row["LATITUDE"],$row["LONGITUDE"]);
        $foodlist[foodrating] = $row["RATING"];
        //$foodlist[radius] = $row["LATITUDE"];
        if (distance($latitude,$longitude,$row["LATITUDE"],$row["LONGITUDE"])<$radius){
            array_push($response["food"], $foodlist);    
        }
    }
    echo json_encode($response);
}else{
    echo "nodata";
}
function distance($lat1, $lon1, $lat2, $lon2) {
   $pi80 = M_PI / 180;
    $lat1 *= $pi80;
    $lon1 *= $pi80;
    $lat2 *= $pi80;
    $lon2 *= $pi80;
    $r = 6372.797; // mean radius of Earth in km
    $dlat = $lat2 - $lat1;
    $dlon = $lon2 - $lon1;
    $a = sin($dlat / 2) * sin($dlat / 2) + cos($lat1) * cos($lat2) * sin($dlon / 2) * sin($dlon / 2);
    $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
    $km = $r * $c;
    //echo '<br/>'.$km;
    return $km;
}
?>