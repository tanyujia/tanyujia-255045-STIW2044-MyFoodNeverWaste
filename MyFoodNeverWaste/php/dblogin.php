<?php
error_reporting(0);
include_once("dbconnect.php");
$email = $_POST['email'];
$password = $_POST['password'];
$passwordsha = sha1($password);
$sql = "SELECT * FROM USER WHERE EMAIL = '$email' AND PASSWORD = '$passwordsha' AND VERIFY ='1'";
$result = $conn->query($sql);
if ($result->num_rows > 0) {
    while ($row = $result ->fetch_assoc()){
        echo "success,".$row["NAME"].",".$row["EMAIL"].",".$row["PHONE"].",".$row["RADIUS"].",".$row["CREDIT"].",".$row["RATING"];
    }
}else{
    echo "failed,null,null,null,null,null,null";
}