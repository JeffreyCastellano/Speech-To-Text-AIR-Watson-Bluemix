<?php

$username_tts_bmix='USERNAME FROM BLUEMIX CREDS';
$password_tts_bmix='PASSWORD FROM BLUEMIX CREDS';
$URL_bmix='https://stream.watsonplatform.net/authorization/api/v1/token?url=https://stream.watsonplatform.net/speech-to-text/api';

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL,$URL_bmix);
curl_setopt($ch, CURLOPT_TIMEOUT, 30);
curl_setopt($ch, CURLOPT_RETURNTRANSFER,1); // BAD!
curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_ANY);
curl_setopt($ch, CURLOPT_USERPWD, "$username_tts_bmix:$password_tts_bmix");
$status_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$result=curl_exec ($ch);
curl_close ($ch);

echo $result;
?>
