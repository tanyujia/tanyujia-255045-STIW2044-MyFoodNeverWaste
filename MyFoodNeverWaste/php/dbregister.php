<?php
error_reporting(0);
include_once ("dbconnect.php");
$email = $_POST['email'];
$password = sha1($_POST['password']);
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
$sqlinsert = "INSERT INTO USER (NAME,EMAIL,PASSWORD,PHONE,VERIFY,RADIUS,CREDIT,RATING) VALUES ('$name','$email','$password','$phone','0','$radius','100','5')";
if ($conn->query($sqlinsert) == TRUE) {
    $path = '../profile/'.$email.'.jpg';
    file_put_contents($path, $decoded_string);
    sendEmail($email);
    echo "Success. Please check your email to verify your account";
}
}

function sendEmail($useremail) {
    $to      = $useremail; 
    $subject = 'Verification for MyExpress'; 
    $message = 'Please click the link to activate your account http://alifmirzaandriyanto.com/mydriver/php/verify.php?email='.$useremail; 
    $headers = 'From: noreply@myFoodNoWaste.com.my' . "\r\n" . 
    'Reply-To: '.$useremail . "\r\n" . 
    'X-Mailer: PHP/' . phpversion(); 
    mail($to, $subject, $message, $headers); 
}
?>