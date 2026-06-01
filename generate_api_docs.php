<?php
$json = file_get_contents('C:\wamp64\www\Cosmic-tech\backend\postman\Therapy-Booking-MVP-API.postman_collection.json');
$data = json_decode($json, true);

function processItems($items, $level = 3) {
    $out = "";
    foreach ($items as $item) {
        if (isset($item['item'])) {
            $out .= str_repeat('#', $level) . " " . $item['name'] . "\n\n";
            $out .= processItems($item['item'], $level + 1);
        } else {
            $req = $item['request'];
            if (!$req) continue;
            
            $method = $req['method'] ?? 'GET';
            $url = '';
            if (isset($req['url']['raw'])) {
                $url = str_replace('{{baseUrl}}', '', $req['url']['raw']);
            }
            
            $out .= str_repeat('#', $level) . " " . $item['name'] . "\n";
            $out .= "**Method:** `$method`  \n";
            $out .= "**Endpoint:** `$url`  \n\n";
            
            if (isset($req['header']) && count($req['header']) > 0) {
                $out .= "**Headers:**\n";
                foreach ($req['header'] as $h) {
                    $out .= "- `{$h['key']}`: {$h['value']}\n";
                }
                $out .= "\n";
            }
            
            if (isset($req['body'])) {
                $mode = $req['body']['mode'] ?? '';
                if ($mode === 'raw') {
                    $raw = $req['body']['raw'] ?? '';
                    $out .= "**Body (JSON):**\n```json\n$raw\n```\n\n";
                } elseif ($mode === 'formdata') {
                    $out .= "**Body (FormData):**\n";
                    foreach ($req['body']['formdata'] as $fd) {
                        $type = $fd['type'] ?? 'text';
                        $out .= "- `{$fd['key']}` ($type)\n";
                    }
                    $out .= "\n";
                }
            }
            $out .= "---\n\n";
        }
    }
    return $out;
}

$markdown = "### Detailed API Endpoints (Parsed from Postman Collection)\n\n";
$markdown .= processItems($data['item']);

file_put_contents('C:\wamp64\www\Cosmic-tech\api_docs.md', $markdown);
echo "Done";
