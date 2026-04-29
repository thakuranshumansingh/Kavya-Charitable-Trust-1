$port = 8080
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Prefixes.Add("http://10.106.0.156:$port/")
$listener.Start()
Write-Host "Server started at http://localhost:$port/"
try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $path = $request.Url.LocalPath
        if ($path -eq "/") { $path = "/index.html" }
        
        $filepath = Join-Path (Get-Location) $path.Replace('/', '\').TrimStart('\')
        
        if (Test-Path $filepath -PathType Leaf) {
            $content = [System.IO.File]::ReadAllBytes($filepath)
            $response.ContentLength64 = $content.Length
            
            if ($filepath.EndsWith(".html")) { $response.ContentType = "text/html" }
            elseif ($filepath.EndsWith(".css")) { $response.ContentType = "text/css" }
            elseif ($filepath.EndsWith(".js")) { $response.ContentType = "application/javascript" }
            elseif ($filepath.EndsWith(".jpg") -or $filepath.EndsWith(".jpeg")) { $response.ContentType = "image/jpeg" }
            elseif ($filepath.EndsWith(".png")) { $response.ContentType = "image/png" }
            
            $response.OutputStream.Write($content, 0, $content.Length)
        } else {
            $response.StatusCode = 404
        }
        $response.Close()
    }
} finally {
    $listener.Stop()
}
