$targetDir = "C:\bomb\bombcrypto-client-v2\Assets\Packages"
if (Test-Path $targetDir) {
    Write-Host "Patching DLL metas in $targetDir to enable Editor platform..."
    $files = Get-ChildItem -Path $targetDir -Filter "*.dll.meta" -Recurse
    foreach ($file in $files) {
        $content = Get-Content $file.FullName -Raw
        if ($content -match "Editor:\s*enabled: 0") {
            $content = $content -replace "(?s)Editor:\s*enabled: 0", "Editor:`r`n      enabled: 1"
            Set-Content -Path $file.FullName -Value $content -NoNewline
            Write-Host "Patched $($file.FullName)"
        }
    }
    Write-Host "Patching complete."
} else {
    Write-Host "Directory $targetDir not found, skipping patch."
}
