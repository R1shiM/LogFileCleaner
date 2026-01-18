#logging
$logFolder = 'C:\Users\RishiMukherjee\Documents\logs'
New-Item -ItemType Directory $logFolder -Force
$timeStamp = Get-Date -Format "yyyyMMdd_HHmmss"
$transcriptPath = Join-Path -Path $logFolder -ChildPath "FindDuplicates-$timeStamp.txt"
Start-Transcript -Path $transcriptPath

$DirectoryToSearch = "C:\Users\RishiMukherjee\Downloads"
$ListOfFiles = Get-ChildItem $DirectoryToSearch -Recurse -File | Sort-Object Length
Write-Output "Files Found: $ListOfFiles"


$DuplicatesFound = @()
$i = 0
$aheadCount = 1
$HASHING_ALGO = "MD5"

# Iterate through all files
while($i -lt ($ListOfFiles.Length - 1)) {
    
    $aheadCount = 1
    $file = $ListOfFiles[$i]
  
    $currDuplicates = @()

    # Skip if alr in duplicates or the next item has diff length (don't wasteg computing hashes)
    if (($DuplicatesFound -Contains $file) -OR ($ListOfFiles[$i+1].Length -ne $file.Length)) { 
         $i++
         continue 
    }

    $currHash = Get-FileHash -Path $file.FullName -Algorithm MD5
    
    # Compare this file to all files in the array with the same size
    while(($i + $aheadCount) -lt $ListOfFiles.Length -and $ListOfFiles[($i+$aheadCount)].Length -eq $file.Length) {
        
        $nextHash = Get-FileHash -Path $ListOfFiles[($i+$aheadCount)].FullName -Algorithm $HASHING_ALGO
        
        # Record if duplicates are found
        if($currHash.Hash -eq $nextHash.Hash) { 
            if($currDuplicates.Length -eq 0) {
                $currDuplicates += $File
                $currDuplicates += $ListOfFiles[($i+$aheadCount)]
            }
            else{
                $currDuplicates += $ListOfFiles[($i+$aheadCount)]
            }
        }
        $aheadCount++
    }

    # If duplicates found for a section of the array, add them all to the list
    if($currDuplicates.Count -ne 0) {
        foreach($item in $currDuplicates) {$DuplicatesFound += $item}
    }

    # Then increment i until it skips all items with same length
    $i = $i + $aheadCount

}
$csvFolder = "C:\Users\RishiMukherjee\Documents\duplicatesFound"
$currTimeStamp = $timeStamp
$csvPath = Join-Path -Path $csvFolder -ChildPath "DuplicatesFound- $currTimeStamp.csv"
$DuplicatesFound | Export-CSV -Path $csvPath -NoTypeInformation

Write-Output "All duplicates found are: $DuplicatesFound"

Stop-Transcript
