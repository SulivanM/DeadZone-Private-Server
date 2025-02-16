<?php
$response = [
    "success" => true,
    "services" => [
        [
            "service" => "fb",
            "mode" => 1,
            "message" => "",
            "onlineETA" => "",
            "htmlMessage" => ""
        ]
    ]
];

echo json_encode($response);
?>