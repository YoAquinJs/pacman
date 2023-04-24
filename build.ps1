$sourceDir = Get-Location
$destinationZip = Join-Path $sourceDir "pacman.love"
$excludeExtensions = @(".love", ".gitignore", ".ps1", ".md", ".sh", ".zip", ".py")
$excludeFolders = @(".vscode", ".git")

if (Test-Path $destinationZip) {
    Remove-Item $destinationZip
}

$filesToArchive = Get-ChildItem $sourceDir -Recurse | Where-Object {
    ($_.Extension -notin $excludeExtensions)
} | Select-Object -ExpandProperty FullName
    
foreach ($file in $filesToArchive) {
    $exlude = $false
    foreach ($excludeFolder in $excludeFolders) {
        if ($file -match $excludeFolder) {
            $exlude = $true
            break
        }
    }

    if ($exlude){
        continue
    }

    $relativePath = $file.Replace($sourceDir, "").TrimStart("\")
    $zipEntry = "files\$relativePath"
    $zipEntryDir = Split-Path $zipEntry -Parent
    if (!(Test-Path $zipEntryDir)) {
        New-Item -ItemType Directory -Force -Path $zipEntryDir
    }
    Copy-Item $file -Destination $zipEntry -Force
}

Compress-Archive -Path "$sourceDir\files\*" -DestinationPath $destinationZip -Force

Remove-Item "$sourceDir\files" -Recurse