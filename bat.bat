# === CONFIGURATION ===
$sourceFolder = "$env:APPDATA"         # Local source folder
$serverUser   = "hambx"                         # Username on the VM
$serverIP     = "192.168.1.100"                      # IP address of the VM
$remotePath   = "/Users/backupuser/Desktop/AppDataBackup"  # Remote destination

# === SCRIPT START ===
Write-Host "Starting file transfer from $sourceFolder to $serverUser@$serverIP:$remotePath`n"

# Make sure the remote base directory exists
ssh "$serverUser@$serverIP" "mkdir -p '$remotePath'"

# Loop through each file and transfer
Get-ChildItem -Path $sourceFolder -Recurse -File | ForEach-Object {
    $relativePath = $_.FullName.Substring($sourceFolder.Length).TrimStart('\')
    $remoteFilePath = "$remotePath/$relativePath" -replace '\\', '/'
    $remoteDir = [System.IO.Path]::GetDirectoryName($remoteFilePath)

    Write-Host "Uploading: $relativePath"

    # Create remote subdirectory
    ssh "$serverUser@$serverIP" "mkdir -p '$remoteDir'"

    # Transfer file
    scp -q $_.FullName "$serverUser@$serverIP:`"$remoteFilePath`""
}

Write-Host "`n✅ All files transferred successfully."
