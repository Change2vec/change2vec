Set-Location -Path $PSScriptRoot

$Type = 'venue'

$Year= '2010-2011'

$groundTruthRoot0 = "C:\Users\Hung\Desktop\Metapath-Momo\Datasets\All\DBLP-2010-Classified\Output\"
$groundTruthRoot1 = "C:\Users\Hung\Desktop\Metapath-Momo\Datasets\All\DBLP-2011-Classified\Output\"
$groundTruthRootc = "C:\Users\Hung\Desktop\Metapath-Momo\Datasets\All\change2vecMerge\Output\"

$gtr = "C:\Users\Hung\Desktop\SIGIR-code\Dataset\$Year\"

if($Type -match "venue")
{
    $groundTruthPath = "C:\Users\Hung\Desktop\SIGIR-code\Dataset\GroundTruth.txt"
}
elseif ($Type -match "author")
{
    $groundTruthPath = $gtr + "AuthorGroundTruth.txt"
}
else
{
    Write-Error "Invalid Type"
}

#$clusterResultPath = "C:\Users\Hung\Desktop\Metapath-Momo\Datasets\All\DBLP-2010-Classified\out_dblp2010-classified\dblp2010-classified.w1000.l100.8c"
#$clusterResultPath = "C:\Users\Hung\Desktop\Metapath-Momo\Datasets\All\DBLP-2011-Classified\out_dblp2011-classified\dblp2011-classified.w1000.l100.8c"
#$clusterResultPath = "C:\Users\Hung\Desktop\Metapath-Momo\Datasets\All\change2vecMerge\change2vec_merge.w1000.l100.c8"
$clusterResultPath = $gtr + "vectors.dblp$Year.w1000.l100.c8"


#$NMIOutputPath = "C:\Users\Hung\Desktop\Metapath-Momo\Datasets\All\change2vecMerge\Output\NMI-Input.py"
$NMIOutputPath = $gtr + "DBLP$Year-$($Type)-NMI.py"

$groundTruthContent = [System.IO.File]::ReadLines($groundTruthPath)
$groundTruthHash = @{}
foreach($node in $groundTruthContent)
{
    $nodeArr = $node -split (" ")
    $groundTruthHash[$nodeArr[0]] = $nodeArr[1]
}

#$groundTruthHash



#$clusterResultPath = "C:\Users\Hung\Desktop\Metapath-Momo\Datasets\All\change2vec\out_change2vec_classified\net_change2vec_classified.w1000.l100.c8"
#$clusterResultPath = "C:\Users\Hung\Desktop\Metapath-Momo\change2vec.cac.w1000.l100.c8"


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

$sw.WriteLine("from sklearn.metrics.cluster import normalized_mutual_info_score")
$sw.WriteLine("labels_true = [$groundTruthArrString]")
$sw.WriteLine("labels_pred = [$clusterResultArrString]")
$sw.WriteLine("x = normalized_mutual_info_score(labels_true, labels_pred, average_method='arithmetic')")
$sw.WriteLine("print(x)")

$sw.close()