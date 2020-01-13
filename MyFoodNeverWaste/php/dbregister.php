<?php
error_reporting(0);
include_once("dbconnect.php");
$email = $_POST['email'];
$password = $_POST['password'];
$passwordsha = sha1($password);
$phone = $_POST['phone'];
$name = $_POST['name'];
$radius = $_POST['radius'];
$encoded_string = $_POST["encoded_string"];
$decoded_string = base64_decode($encoded_string);
$sql_e = "SELECT * FROM USER WHERE EMAIL='$email'";

$result = $conn->query($sql_e);
if($result->num_rows > 0) {
    echo "Email already exist. Please try other email.";
} else{
$sqlinsert = "INSERT INTO USER (NAME,EMAIL,PASSWORD,PHONE,VERIFY,RADIUS,CREDIT,RATING) VALUES ('$name','$email','$passwordsha','$phone','0','$radius','0','5')";
if ($conn->query($sqlinsert) == TRUE) {
    $path = '../profile/'.$email.'.jpg';
    file_put_contents($path, $decoded_string);
    sendEmail($email);
    echo "Success. Please check your email to verify your account";
}
}

function sendEmail($useremail) {
    $to      = $useremail; 
    $subject = 'Verification for My Food Never Waste'; 
    $message = 'Please click the link to activate your account http://http://mobilehost2019.com/MyFoodNeverWaste/php/dbverify.php?email='.$useremail;
    $headers = 'From: noreply@myFoodNeverWaste.com.my' . "\r\n" . 
    'Reply-To: '.$useremail . "\r\n" . 
    'X-Mailer: PHP/' . phpversion(); 
    mail($to, $subject, $message, $headers); 
}
?>