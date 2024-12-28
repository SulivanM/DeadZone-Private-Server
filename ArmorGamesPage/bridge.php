<?php

// Set the content type to JSON
header('Content-Type: application/json');

// Define the response data as a JSON string with formatting
$response = '{
    "success": true,
    "services": [
        {
            "service": "fb",
            "mode": 1,
            "message": "",
            "onlineETA": "",
            "htmlMessage": ""
        }
    ]
}';

// Print the JSON response
echo $response;
