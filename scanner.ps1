Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.Security.Cryptography;

public class HashUtils {
    public static string GetSHA256Hash(string filePath) {
        using (FileStream fs = File.OpenRead(filePath)) {
            using (SHA256 sha256 = SHA256.Create()) {
                byte[] hashBytes = sha256.ComputeHash(fs);
                return BitConverter.ToString(hashBytes).Replace("-", "").ToLowerInvariant();
            }
        }
    }
}
"@

$targetSHA256 = "1aa3d70ba34f808a67391eb21a73c3a5bc725368ae96d49d267559dd83065170"

$allFoundFiles = @()

function Scan-Drive {
    param (
        [string]$drive
    )
    
    $driveResults = @()

    Get-ChildItem -Path $drive -Recurse -Force -File -Filter *.asi -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            Write-Host "Skeniranje fajla: $($_.FullName)"
            $fileSHA256 = [HashUtils]::GetSHA256Hash($_.FullName)

            if ($fileSHA256 -eq $targetSHA256) {
                $driveResults += "Keylogger je pronadjen! File: $($_.FullName)"
            }
        } catch {
            Write-Host "Greska u skeniraju fajla: $($_.FullName)" -ForegroundColor Red
        }
    }

    return $driveResults
}

$drives = Get-PSDrive -PSProvider FileSystem
foreach ($drive in $drives) {
    Write-Host "Skeniranje drive-a: $($drive.Root)"
    $results = Scan-Drive -drive $drive.Root
    $allFoundFiles += $results
}

if ($allFoundFiles.Count -gt 0) {
    Write-Host "`nRezultati:" -ForegroundColor Red
    $allFoundFiles | ForEach-Object {
        Write-Host $_ -ForegroundColor Red
    }
} else {
    Write-Host "`nKeylogger nije pronadjen." -ForegroundColor Red
}

Write-Host "Skeniranje je zavrseno. Scanner napravljen od strane ---> cerovina$"
while ($true) { Start-Sleep -Seconds 1 }
