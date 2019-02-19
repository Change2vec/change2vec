function Get-ArrayListFromFile
{
    [cmdletbinding()] 
    Param
    (
        [string]
        $DatasetPath,

        [string]
        $Delimiter
    )

    $arrayList = New-Object System.Collections.ArrayList($null)
    $data = [System.IO.File]::ReadLines($DatasetPath)
    
    foreach($line in $data)
    {
        $lineArray = $line -split ($Delimiter)
        $null = $arrayList.Add($lineArray[1])
    }

    return $arrayList
}

function Get-HashTableFromFile
{
    [cmdletbinding()] 
    Param
    (
        [string]
        $DatasetPath,

        [string]
        $Delimiter = " "
    )

    $hashTable = @{}

    $data = [System.IO.File]::ReadLines($DatasetPath)
    


    foreach($line in $data)
    {
        $isKey = $true
        $key = ""
        $lineArray = $line -split ($Delimiter)
        foreach($value in $lineArray)
        {
            if($isKey)
            {
                $tempArr = New-Object System.Collections.ArrayList($null)
                $hashTable[$value] = $tempArr
                $key = $value
                $isKey = $false
            }
            else
            {
                $null = $hashTable[$key].Add($value)
            }
        }
    }

    return $hashTable
}

function Write-ToStreamWriter
{
    [cmdletbinding()] 
    Param
    (
        [System.Collections.ArrayList]
        $ArrayList,

        [string]
        $OutputFile
    )

    $sw = new-object system.IO.StreamWriter($OutputFile)
    foreach($entry in $ArrayList)
    {
        $sw.WriteLine($entry)
    }
    $sw.close()
}


function Get-AdjacencyList
{
    [cmdletbinding()] 
    Param
    (
        [string]
        $DatasetPath
    )

    $content = [System.IO.File]::ReadLines($DatasetPath) -split('\r\n')
    $nodeHash = @{}

    foreach($line in $content)
    {
        [System.Collections.ArrayList]$arr = $line -split(" ")
        $key = $arr[0]
        $arr.RemoveAt(0)
        $nodeHash[$key] = $arr
    }

    Write-Host "Done!`n"
    return $nodeHash
}


Set-Location -Path $PSScriptRoot

$StartDate = (Get-Date)
Write-Host "Start Date: $($StartDate)"

$dataRootDir = "$PSScriptRoot\..\..\Dataset\"

$YearOne = '2011'
$YearTwo = '2013'

# Dataset One Directories
$datasetDirOnePath = $dataRootDir + "$($YearOne)\"
$datasetOutputDirOnePath = $datasetDirOnePath + "Output\"

# Dataset One Files
$adjacencyListOnePath = $datasetOutputDirOnePath + "adjacencyList.txt"
$datasetDirOneAuthorInputFile = $datasetOutputDirOnePath + "id_author.txt"
$datasetDirOneVenueInputFile = $datasetOutputDirOnePath + "id_conf.txt"
$datasetDirOnePaperInputFile = $datasetOutputDirOnePath + "paper.txt"
$datasetDirOnePaperToVenueInputFile = $datasetOutputDirOnePath + "paper_conf.txt"
$datasetDirOnePaperToAuthorInputFile = $datasetOutputDirOnePath + "paper_author.txt"
$datasetDirOneVenueToAuthorInputFile = $datasetOutputDirOnePath + "venue_author.txt"
$ShortenedDatasetOnePath = $datasetOutputDirOnePath + "ShortenedDataset-$($YearOne).txt" 
$ShortenedDatasetPaperOnePath = $datasetOutputDirOnePath + "ShortenedDatasetPaper-$($YearOne).txt" 

[System.Collections.ArrayList]$authorsArr = Get-ArrayListFromFile -DatasetPath $datasetDirOneAuthorInputFile -Delimiter "\t"
[System.Collections.ArrayList]$authorsOutput = [System.IO.File]::ReadLines($datasetDirOneAuthorInputFile) -split('\r\n')

# Venue ArrayLists
[System.Collections.ArrayList]$venuesArr =  Get-ArrayListFromFile -DatasetPath $datasetDirOneVenueInputFile -Delimiter "\t"
[System.Collections.ArrayList]$venuesOutput = [System.IO.File]::ReadLines($datasetDirOneVenueInputFile) -split('\r\n')

# Paper ArrayLists
[System.Collections.ArrayList]$papersArr = Get-ArrayListFromFile -DatasetPath $datasetDirOnePaperInputFile -Delimiter "       "
[System.Collections.ArrayList]$papersOutput = [System.IO.File]::ReadLines($datasetDirOnePaperInputFile) -split('\r\n')

# Relational ArrayLists
[System.Collections.ArrayList]$paperToVenue = [System.IO.File]::ReadLines($datasetDirOnePaperToVenueInputFile) -split('\r\n')
[System.Collections.ArrayList]$paperToAuthor = [System.IO.File]::ReadLines($datasetDirOnePaperToAuthorInputFile) -split('\r\n')
[System.Collections.ArrayList]$venueToAuthor = [System.IO.File]::ReadLines($datasetDirOneVenueToAuthorInputFile) -split('\r\n')
[System.Collections.ArrayList]$shortenedDataset = [System.IO.File]::ReadLines($ShortenedDatasetOnePath) -split('\r\n')
[System.Collections.ArrayList]$shortenedDatasetPaper = [System.IO.File]::ReadLines($ShortenedDatasetPaperOnePath) -split('\r\n')

$authorCounter = ($authorsArr.Count)
$venueCounter = ($venuesArr.Count)
$paperCounter = ($papersArr.Count)

Write-Host "Existing number of Authors: $authorCounter"
Write-Host "Existing number of Venues: $venueCounter"
Write-Host "Existing number of Papers: $paperCounter"

# Dataset Two Directories
$datasetDirTwoPath = $dataRootDir + "$($YearTwo)\"
$datasetOutputDirTwoPath = $datasetDirTwoPath + "Output\"

# Dataset Two Files
$adjacencyListTwoPath = $datasetOutputDirTwoPath + "adjacencyList.txt"
$ShortenedDatasetTwoPath = $datasetOutputDirTwoPath + "ShortenedDataset-$($YearTwo).txt" 
$ShortenedDatasetPaperTwoPath = $datasetOutputDirTwoPath + "ShortenedDatasetPaper-$($YearTwo).txt" 

# Output Directories
$mergedYears = "$($YearOne)-$($YearTwo)"
$mergedRootPath = $dataRootDir + "$mergedYears\"

# Create Merged Root Path if it does not already exist
If(!(test-path $mergedRootPath))
{
      New-Item -ItemType Directory -Path $mergedRootPath
}

$outputDir = $mergedRootPath + "Output\"
$commonKeysPath = $mergedRootPath + "$mergedYears-commonKeys.txt"

# Output Files
$outputDirAdjacencyListFile = $outputDir + "adjacencyList.txt"
$outputDirAAAIOutputFile = $outputDir + "AAAI-Input.txt"
$outputDirAuthorInputFile = $outputDir + "id_author.txt"
$outputDirVenueInputFile = $outputDir + "id_conf.txt"
$outputDirPaperInputFile = $outputDir + "paper.txt"
$outputDirPaperToVenueInputFile = $outputDir + "paper_conf.txt"
$outputDirPaperToAuthorInputFile = $outputDir + "paper_author.txt"
$outputDirVenueToAuthorInputFile = $outputDir + "venue_author.txt"
$outputDirShortenedDatasetPath = $outputDir + "ShortenedDataset-$mergedYears.txt" 
$outputDirShortenedDatasetPaperPath = $outputDir + "ShortenedDatasetPaper-$mergedYears.txt" 

# Obtain adjacency lists
$adjacencyListOne = Get-AdjacencyList -DatasetPath $adjacencyListOnePath
$adjacencyListTwo = Get-AdjacencyList -DatasetPath $adjacencyListTwoPath

$keysInOneButNotTwo = New-Object System.Collections.ArrayList($null)
$keysInTwoButNotOne = New-Object System.Collections.ArrayList($null)
$commonKeys = New-Object System.Collections.ArrayList($null)


$adjacencyListOne.keys | %{
	if (!$adjacencyListTwo.ContainsKey($_))
    {
		$null = $keysInOneButNotTwo.Add($_)
	}
    else
    {
        $null = $commonKeys.Add($_)
    }
}
Write-Host "Done 2010"

$adjacencyListTwo.keys | %{
	if (!$adjacencyListOne.ContainsKey($_))
    {
		$null = $keysInTwoButNotOne.Add($_)
	}
}
Write-Host "Done 2011"

Write-Host "2010 total keys: $($adjacencyListOne.Keys.Count)"
Write-Host "Keys in 2010 but not in 2011: $($keysInOneButNotTwo.Count)"

Write-Host "2011 total keys: $($adjacencyListTwo.Keys.Count)"
Write-Host "Keys in 2011 but not in 2010: $($keysInTwoButNotOne.Count)"

Write-Host "Common keys: $($commonKeys.Count)"


$sw = new-object system.IO.StreamWriter($commonKeysPath)
foreach($key in $commonKeys)
{
    $sw.WriteLine($key)
}
$sw.Close()

$nonNeighboursOfNewNodesInCommonKeys = $commonKeys.Clone()
$neighboursOfNewNodesInCommonKeys = New-Object System.Collections.ArrayList($null)
$counter = 0

foreach($key in $keysInTwoButNotOne)
{
    foreach($newNodeNeighbour in $adjacencyListTwo[$key])
    {
        if($commonKeys.Contains($newNodeNeighbour) -and !$neighboursOfNewNodesInCommonKeys.Contains($newNodeNeighbour))
        {
            $null = $neighboursOfNewNodesInCommonKeys.Add($newNodeNeighbour)
            $null = $nonNeighboursOfNewNodesInCommonKeys.Remove($newNodeNeighbour)
        }
    }

    $counter++
}

$commonKeysChanged = New-Object System.Collections.ArrayList($null)

$commonKeyChangedCounter = 0
foreach($node in $nonNeighboursOfNewNodesInCommonKeys)
{
    $compare = Compare-Object -ReferenceObject $adjacencyListTwo[$node] -DifferenceObject $adjacencyListOne[$node]

    if($compare -ne $null)
    {   
        foreach($neighbourNode in $compare)
        {
            if($neighbourNode.SideIndicator -eq '<=')
            {
                if($neighbourNode.InputObject -match '^[v]')
                {     
                    $null = $commonKeysChanged.Add($node)
                }
                
                if($neighbourNode.InputObject -match '^[a]')
                {     
                    $Green = $adjacencyListOne[$node]  | Where {$adjacencyListTwo[$neighbourNode.InputObject] -Contains $_}
                    if($Green.Count -ge 1)
                    {
                        $null = $commonKeysChanged.Add($node)
                    }
                }
            }
        }
    }   
    $commonKeyChangedCounter++
}


$changeNodes = New-Object System.Collections.ArrayList($null)
# New nodes
$changeNodes.AddRange($keysInTwoButNotOne)
# Neighbours of new nodes
$changeNodes.AddRange($neighboursOfNewNodesInCommonKeys)
# existing nodes that formed triads
$changeNodes.AddRange($commonKeysChanged)

Write-Host "Changed Nodes: $($changeNodes.Count)"

Write-Host "Appending Dataset Two"
$AppendingDate = (Get-Date)
Write-Host "Appending date: $($AppendingDate)"


[System.Collections.ArrayList]$shortenedDatasetTwo = [System.IO.File]::ReadLines($ShortenedDatasetTwoPath) -split('\r\n')
[System.Collections.ArrayList]$shortenedDatasetPaperTwo = [System.IO.File]::ReadLines($ShortenedDatasetPaperTwoPath) -split('\r\n')

$currentIndex = 0

foreach($entry in $shortenedDatasetTwo)
{
    $entry = $entry.Trim()
    $mergeCurrentEntry = $true
    [System.Collections.ArrayList]$arr = $entry -split(' ') 

    foreach($node in $arr)
    {
        if(!$changeNodes.Contains($node))
        {
            $mergeCurrentEntry = $false
        }
    }

    # If we are merging current entry
    if($mergeCurrentEntry)
    {

        # add paper and author here
        $paper = $shortenedDatasetPaperTwo[$currentIndex]

        $firstSpaceIndex = $entry.IndexOf(' ')
        $venue = $entry.Substring(0, $firstSpaceIndex).Trim()
        $authors = $entry.Substring($firstSpaceIndex, $entry.Length - $firstSpaceIndex).Trim()
        [System.Collections.ArrayList]$authorsToArr = $authors -split(' ')
        
        # Paper Arr output
        $entryPaperId = 0

        if(!$papersArr.Contains($paper))
        {
            $null = $papersArr.Add($paper)
            $entryPaperId = $paperCounter
            $null = $papersOutput.Add("$entryPaperId       $paper")
            $paperCounter++
        }
        else
        {
            $entryPaperId = $papersArr.IndexOf($paper)
        }
        
        $venueId = 0
        if(!$venuesArr.Contains($venue))
        {
            $null = $venuesArr.Add($venue)
            $venueId = $venueCounter
            $venueCounter++

            $null = $venuesOutput.Add("$venueId`t$($venue)")
        }
        else
        {
            $venueId = $venuesArr.IndexOf($venue)
        }    
        $null = $paperToVenue.Add("$entryPaperId`t$venueId") 

        # Initialize current venue entry in venuesHash if it does not exist
        if(!$adjacencyListOne.ContainsKey($venue))
        {
            $tempArr = New-Object System.Collections.ArrayList($null)
            $adjacencyListOne[$venue] = $tempArr
        }

        foreach($author in $authorsToArr)
        {
            # Clone the array and remove the current Author (all authors except the current one)
            $allButCurrentAuthor = $authorsToArr.Clone()
            $null = $allButCurrentAuthor.Remove($author)
                
            $authorId = 0
            $author = "a$author"
            if(!$authorsArr.Contains($author))
            {
                #Write-Host "Added author to array"
                $null = $authorsArr.Add($author)
                $authorId = $authorCounter
                $authorCounter++

                $null = $authorsOutput.Add("$authorId`t$author")
            }
            else
            {
                $authorId = $authorsArr.IndexOf($author)
            }

            $null = $paperToAuthor.Add("$entryPaperId`t$authorId")

            $null = $venueToAuthor.Add("$venueId`t$authorId")
            

          
            # Initialize current authors entry in authorsHash if it does not exist
            if(!$adjacencyListOne.ContainsKey($author))
            {
                #Write-Host "Added new author"
                $tempArr = New-Object System.Collections.ArrayList($null)
                $adjacencyListOne[$author] = $tempArr
            }

            # If current author does not contain the current venue in authorHash
            if(!$adjacencyListOne[$author].Contains($venue))
            {
                #Write-Host "Added venue to author key"
                $null = $adjacencyListOne[$author].Add($venue)
            }  

            # If current venue does not contain the current author in venuesHash
            if(!$adjacencyListOne[$venue].Contains($author))
            {
                #Write-Host "Added author to venue key"
                $null = $adjacencyListOne[$venue].Add($author)
            }  


            # Add all non-current authors to the current author list if they are not already present
            foreach($notCurrentAuthor in $allButCurrentAuthor)
            {
                $notCurrentAuthorA = "a$notCurrentAuthor"

                # If other authors does not exist in the values of the current author of authorHash
                if(!$adjacencyListOne[$author].Contains($notCurrentAuthorA))
                {
                    #Write-Host "Added non-current author to current author"
                    $null = $adjacencyListOne[$author].Add($notCurrentAuthorA)
                }             
            }
        }

        $null = $shortenedDataset.Add($entry)
        $null = $shortenedDatasetPaper.Add($paper)
    }

    $currentIndex++
}




$outputDirAdjacencyListPath = $outputDir + "adjacencyList.txt"
$outputDirAuthorInputFile = $outputDir + "id_author.txt"
$outputDirVenueInputFile = $outputDir + "id_conf.txt"
$outputDirPaperInputFile = $outputDir + "paper.txt"
$outputDirPaperToVenueInputFile = $outputDir + "paper_conf.txt"
$outputDirPaperToAuthorInputFile = $outputDir + "paper_author.txt"
$outputDirVenueToAuthorInputFile = $outputDir + "venue_author.txt"
$outputDirShortenedDatasetPath = $outputDir + "ShortenedDataset-$mergedYears.txt" 

Write-Host "Writing files to output directory"
$OuputDate = (Get-Date)
Write-Host "Output date: $($OuputDate)"

Write-ToStreamWriter -ArrayList $papersOutput -OutputFile $outputDirPaperInputFile
Write-ToStreamWriter -ArrayList $authorsOutput -OutputFile $outputDirAuthorInputFile
Write-ToStreamWriter -ArrayList $venuesOutput -OutputFile $outputDirVenueInputFile
Write-ToStreamWriter -ArrayList $paperToVenue -OutputFile $outputDirPaperToVenueInputFile
Write-ToStreamWriter -ArrayList $paperToAuthor -OutputFile $outputDirPaperToAuthorInputFile
Write-ToStreamWriter -ArrayList $venueToAuthor -OutputFile $outputDirVenueToAuthorInputFile
Write-ToStreamWriter -ArrayList $shortenedDataset -OutputFile $outputDirShortenedDatasetPath
Write-ToStreamWriter -ArrayList $shortenedDatasetPaper -OutputFile $outputDirShortenedDatasetPaperPath



# Output the adjacency list of current dataset for authors and venues
$sw = new-object system.IO.StreamWriter($outputDirAdjacencyListFile)
foreach($key in $adjacencyListOne.Keys)
{
    $outputString = "$key "
    foreach($value in $adjacencyListOne[$key])
    {
        $outputString += "$value "
    }
    $outputString = $outputString.Trim()
    $sw.WriteLine("$outputString")
}
$sw.Close()

# Output the adjacency list of current dataset for authors and venues
$sw = new-object system.IO.StreamWriter($outputDirAdjacencyListFile)
foreach($key in $adjacencyListOne.Keys)
{
    $outputString = "$key "
    foreach($value in $adjacencyListOne[$key])
    {
        $outputString += "$value "
    }
    $outputString = $outputString.Trim()
    $sw.WriteLine("$outputString")
}
$sw.Close()

# Output the adjacency list of current dataset for authors and venues in AAAI format
$sw = new-object system.IO.StreamWriter($outputDirAAAIOutputFile)
foreach($key in $adjacencyListOne.Keys)
{
    $outputString = "$key "
    foreach($value in $adjacencyListOne[$key])
    {
        $outputString += "$value 1.0 "
    }
    $outputString = $outputString.Trim()
    $sw.WriteLine("$outputString")
}
$sw.Close()


$EndDate = (Get-Date)
Write-Host "End date: $($EndDate)"
