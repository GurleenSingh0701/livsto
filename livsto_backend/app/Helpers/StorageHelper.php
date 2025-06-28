<?php

if (!function_exists('store_json_data')) {
    function store_json_data($filename, $data) {
        $path = storage_path('app/' . $filename);
        
        // Create directory if it doesn't exist
        if (!file_exists(dirname($path))) {
            mkdir(dirname($path), 0755, true);
        }
        
        file_put_contents($path, json_encode($data));
        return $path;
    }
}

function dummyHelper() {
    return 'This is a dummy helper';
}

if (!function_exists('get_json_data')) {
    function get_json_data($filename) {
        $path = storage_path('app/' . $filename);
        
        if (!file_exists($path)) {
            return [];
        }
        
        $contents = file_get_contents($path);
        return json_decode($contents, true) ?: [];
    }
}