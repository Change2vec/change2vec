Set-Location -Path $PSScriptRoot

$Year = '2011-2013'

$datasetDir = "$PSScriptRoot\..\Dataset\"
$venueGroundTruthPath = $datasetDir + "GroundTruth.txt"
$venueGroundTruthContent = [System.IO.File]::ReadLines($venueGroundTruthPath)
$venueGroundTruthHash = @{}

$venueMapping = New-Object System.Collections.ArrayList($null)
$authorMapping = New-Object System.Collections.ArrayList($null)

$authorGroundTruthHash = @{}

foreach($node in $venueGroundTruthContent)
{
    $nodeArr = $node -split (" ")
    $venueGroundTruthHash[$nodeArr[0]] = $nodeArr[1]
}

$idRoot = $datasetDir + "$Year\Output\"

$VtAPath = $idRoot + "venue_author.txt"
$venueIdPath = $idRoot + "id_conf.txt"
$authorIdPath = $idRoot + "id_author.txt"


$authorGroundTruthOutput = $datasetDir + "$Year\AuthorGroundTruth.txt"

$VtAs = [System.IO.File]::ReadLines($VtAPath)
$venueId = [System.IO.File]::ReadLines($venueIdPath)
$authorId = [System.IO.File]::ReadLines($authorIdPath)


foreach($entry in $venueId)
{
    $venue = $entry -split ("\t")

    if($venueGroundTruthHash.ContainsKey($venue[1]))
    {
        $null = $venueMapping.Add($venueGroundTruthHash[$venue[1]])
    }
    else
    {
        Write-Host "Uh oh"       
        $venue[0]
        $venue[1]
    }
}

foreach($entry in $authorId)
{
    $author = $entry -split ("\t")
    $null = $authorMapping.Add($author[1])
}

foreach($VtAentry in $VtAs)
{
    $VtA = $VtAentry -split ("\t")

    # Get the Raw ids of the entry
    $venueId = $VtA[0]
    $authorId = $VtA[1]

    # Get the authorName and ground truth cluster Id of the entry
    $authorName = $authorMapping[$authorId]
    $groundTruthClusterIdOfVenue = $venueMapping[$venueId]

    if($authorGroundTruthHash.ContainsKey($authorName))
    {
        $arr = $authorGroundTruthHash[$authorName]
        $currentValue = $arr.Get($groundTruthClusterIdOfVenue)
        $arr.Set($groundTruthClusterIdOfVenue, ($currentValue + 1))
        $authorGroundTruthHash[$authorName] = $arr
    }
    else
    {
        $arr = @(0) * 9
        $currentValue = $arr.Get($groundTruthClusterIdOfVenue)
        $arr.Set($groundTruthClusterIdOfVenue, ($currentValue + 1))
        $authorGroundTruthHash[$authorName] = $arr
    }
}

#$authorGroundTruthHash
$sw = new-object system.IO.StreamWriter($authorGroundTruthOutput)


$authorsWithTiedClusters = 0

foreach($author in $authorGroundTruthHash.Keys)
{
    $array = $authorGroundTruthHash[$author]
    $maximum = ($array | Measure -Max).Maximum
    
    $indexCounter = 0
    $numberOfMaxInstances = 0
    $maxInstanceIndexes = @()


    foreach($index in $array)
    {
        if($index -eq $maximum)
        {
            $maxInstanceIndexes += $indexCounter
            $numberOfMaxInstances++
        }

        $indexCounter++
    }


    if($numberOfMaxInstances -ge 2)
    {
        $authorsWithTiedClusters++
        $randIndex = Get-Random -InputObject $maxInstanceIndexes
        <#
        Write-Host $array
        Write-Host $maxInstanceIndexes
        Write-Host $randIndex
        Write-Host ""
        #>

        $sw.WriteLine("$author $randIndex")
        <#
        Write-Host $array
        Write-Host $maxInstanceIndexes
        #>
        <#
        $index = [Array]::IndexOf($array, [int]$maximum)
        $author

        $maximum
        $index
        #>     
    
    }
    else
    {
        $index = [Array]::IndexOf($array, [int]$maximum)
        $sw.WriteLine("$author $index")
    }
}


$sw.close()

Write-Host "Total authors: $($authorGroundTruthHash.Count)"
Write-Host "Authors with tied clusters: $($authorsWithTiedClusters)"
