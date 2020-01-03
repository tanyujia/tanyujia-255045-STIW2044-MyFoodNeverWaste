<?php
error_reporting(0);
include_once("dbconnect.php");
$foodid = $_POST['foodid'];
$email = $_POST['email'];
$credit = $_POST['credit'];
$sql = "UPDATE FOOD SET FOODWORKER = '$email'  WHERE FOODID = '$foodid'";
if ($conn->query($sql) === TRUE) {
    $newcredit = $credit - 1;
    $sqlcredit = "UPDATE USER SET CREDIT = '$newcredit' WHERE EMAIL = '$email'";
    $conn->query($sqlcredit);
    echo "success";
} else {
    echo "error";
}
$conn->close();
?>