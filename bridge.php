<?php
header('Content-Type: application/json');

$service = isset($_GET['service']) ? $_GET['service'] : '';
$response = [];

if ($service === 'fb') {
    $response = [
        'services' => [
            [
                'mode' => 1,
                'onlineETA' => '00:00',
                'htmlMessage' => '',
            ]
        ]
    ];
} else {
    $response = [
        'error' => 'Invalid service requested.'
    ];
}

echo json_encode($response);