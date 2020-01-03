<?php
$servername = "localhost";
$username = "mobileho_MyFoodNoWasteAdmin";
$password = "p6?sfqer@B-#";
$dbname = "mobileho_MyFoodNoWaste";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>