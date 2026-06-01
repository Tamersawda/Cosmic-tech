<?php
$archFile = 'C:\wamp64\www\Cosmic-tech\BACKEND_ARCHITECTURE.md';
$apiDocsFile = 'C:\wamp64\www\Cosmic-tech\api_docs.md';

$archContent = file_get_contents($archFile);
$apiDocsContent = file_get_contents($apiDocsFile);

$startMarker = "### API Flows and Inputs";
$endMarker = "## 7. Authentication & Authorization";

$startPos = strpos($archContent, $startMarker);
$endPos = strpos($archContent, $endMarker);

if ($startPos !== false && $endPos !== false) {
    $before = substr($archContent, 0, $startPos + strlen($startMarker) . "\n\n");
    $after = substr($archContent, $endPos);
    
    // the apiDocsContent already starts with ### Detailed API Endpoints
    // let's just insert it here
    $newContent = $before . $apiDocsContent . "\n\n" . $after;
    
    file_put_contents($archFile, $newContent);
    echo "Successfully updated BACKEND_ARCHITECTURE.md\n";
} else {
    echo "Could not find markers\n";
}
