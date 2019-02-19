Set-Location -Path $PSScriptRoot

$Type = 'venue'

$Year= '2011'

$gtr = "C:\Users\Hung\Desktop\SIGIR-code\Dataset\DynamicTriad\"

if($Type -match "venue")
{
    $groundTruthPath = "C:\Users\Hung\Desktop\SIGIR-code\Dataset\GroundTruth.txt"
}
elseif ($Type -match "author")
{
    $groundTruthPath = "C:\Users\Hung\Desktop\SIGIR-code\Dataset\$Year\AuthorGroundTruth.txt"
}
else
{
    Write-Error "Invalid Type"
}

$clusterResultPath = $gtr + "vectors.$Year.txt"


#$NMIOutputPath = "C:\Users\Hung\Desktop\Metapath-Momo\Datasets\All\change2vecMerge\Output\NMI-Input.py"
$NMIOutputPath = $gtr + "AAAI-$Year-$($Type)-RandIndex.py"

$groundTruthContent = [System.IO.File]::ReadLines($groundTruthPath)
$groundTruthHash = @{}
foreach($node in $groundTruthContent)
{
    $nodeArr = $node -split (" ")
    $groundTruthHash[$nodeArr[0]] = $nodeArr[1]
}



$clusterResultContent = [System.IO.File]::ReadLines($clusterResultPath)
$clusterResultHash = @{}

foreach($node in $clusterResultContent)
{
    $nodeArr = $node -split (" ")
    $clusterResultHash[$nodeArr[0]] = $nodeArr[1]
}


$groundTruthArr = New-Object System.Collections.ArrayList($null)
$clusterResultArr = New-Object System.Collections.ArrayList($null)
$counterArr = New-Object System.Collections.ArrayList($null)

$matchingKeyCounter= 0;
foreach($key in $groundTruthHash.Keys)
{
    if($clusterResultHash.ContainsKey($key))
    {
        $null = $counterArr.Add($matchingKeyCounter)
        $null = $groundTruthArr.Add($groundTruthHash[$key])
        $null = $clusterResultArr.Add($clusterResultHash[$key])
        #Write-Host "$($groundTruthHash[$key]) $($clusterResultHash[$key])"
        $matchingKeyCounter++
    }
}

$counterArrString = $($counterArr -join ",")
$groundTruthArrString = $($groundTruthArr -join ",")
$clusterResultArrString = $($clusterResultArr -join ",")

Write-Host $groundTruthHash.Keys.Count
Write-Host $matchingKeyCounter
Write-Host $counterArr.Count
Write-Host $groundTruthArr.Count
Write-Host $clusterResultArr.Count

$sw = new-object system.IO.StreamWriter($NMIOutputPath)

$sw.WriteLine("from sklearn.metrics.cluster import adjusted_rand_score")
$sw.WriteLine("labels_true = [$groundTruthArrString]")
$sw.WriteLine("labels_pred = [$clusterResultArrString]")
$sw.WriteLine("x = adjusted_rand_score(labels_true, labels_pred)")
$sw.WriteLine("print(x)")

$sw.close()