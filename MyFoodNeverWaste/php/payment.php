<?php
error_reporting(0);
include_once("dbconnect.php");

$email = $_GET['email']; //email
$mobile = $_GET['mobile']; 
$name = $_GET['name']; 
$amount = $_GET['amount']; 
$orderid = $_GET['orderid'];

$api_key = '67633135-29c3-40ba-a7f1-c739d0b38c50';
$host = 'https://billplz-sandbox.com/api/v3/bills';
$collection_id = 'pwxlfa6x';

$data = array(
          'collection_id' => $collection_id,
          'email' => $email,
          'mobile' => $mobile,
          'name' => $name,
          'amount' => $amount * 100, // RM20
		  'description' => 'Payment for order id '.$orderid,
          'callback_url' => "http://mobilehost2019.com/MyFoodNeverWaste/return_url.php",
          'redirect_url' => "http://mobilehost2019.com/MyFoodNeverWaste/php/paymentUpdate.php?userid=$email&mobile=$mobile&amount=$amount&orderid=$orderid" 
);


$process = curl_init($host );
curl_setopt($process, CURLOPT_HEADER, 0);
curl_setopt($process, CURLOPT_USERPWD, $api_key . ":");
curl_setopt($process, CURLOPT_TIMEOUT, 30);
curl_setopt($process, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($process, CURLOPT_SSL_VERIFYHOST, 0);
curl_setopt($process, CURLOPT_SSL_VERIFYPEER, 0);
curl_setopt($process, CURLOPT_POSTFIELDS, http_build_query($data) );  

$return = curl_exec($process);
curl_close($process);

$bill = json_decode($return, true);

//echo "<pre>".print_r($bill, true)."</pre>";
header("Location: {$bill['url']}");
?>