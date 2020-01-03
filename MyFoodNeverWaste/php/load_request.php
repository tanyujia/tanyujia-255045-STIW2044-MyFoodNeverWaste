<?php
error_reporting(0);
include_once("dbconnect.php");
$foodowner = $_POST['email'];
$sql = "SELECT * FROM FOOD WHERE FOODOWNER = '$foodowner'";
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
        $foodlist[foodtime] = $row["FOODTIME"];
        array_push($response["food"], $foodlist);
    }
    echo json_encode($response);
}else{
    echo "nodata";
}
?>