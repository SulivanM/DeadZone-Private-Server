<?php
$response = [
    "success" => true,
    "services" => [
        [
            "service" => "pio",
            "mode" => 1,
            "message" => "",
            "onlineETA" => "",
            "htmlMessage" => ""
        ]
    ]
];

echo json_encode($response);
?>