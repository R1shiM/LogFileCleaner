# Logging all files we removed
$logFolder = "C:\Users\RishiMukherjee\Documents\logs"
New-Item -ItemType Directory $logFolder -Force
$timeStamp = Get-Date -Format "yyyyMMdd_HHmmss"
$transcriptPath = Join-Path -Path $logFolder -ChildPath "LogCleaner-$timeStamp.txt"
Start-Transcript -Path $transcriptPath

$DirectoryListFilePath='C:\Users\RishiMukherjee\Documents\logCleaner\LogDirectories.csv'
$Directories=Import-Csv -Path $DirectoryListFilePath

foreach($Directory in $Directories) {
    # Find all files in each directory
    $DirectoryPath = $Directory.DirectoryPath 
    $files = Get-ChildItem -Path $DirectoryPath -File -Recurse
    $KeepDays = [int]$Directory.KeepForDays

    # Check for each file if its was last written time was before its max keep for days, and delete if so
    foreach($file in $files) {
        $d = [datetime]$file.LastWriteTime
        if ($file.LastWriteTime -lt (Get-Date).AddDays(-$KeepDays)) {
            Remove-Item -Path $file -Confirm:$false -Force
            Write-Output "Removed: $file"
        }
    }
    
}
$currDateTime = Get-Date
Write-Output "Logfile Cleaning Completed at $currDateTime."
Stop-Transcript
