Set-Location -Path $PSScriptRoot


$years = @()
$years += '2010'
$years += '2013'

foreach($year in $years)
{
    $Year = $year

    Write-Host $Year

    $StartDate = (Get-Date)
    Write-Host "StartDate date: $($StartDate)"

    $datasetDir = "$PSScriptRoot\..\..\Dataset\$($Year)\"
    $datasetOutputDir = $datasetDir + "Output\"

    If(!(test-path $datasetOutputDir))
    {
          New-Item -ItemType Directory -Path $datasetOutputDir
    }


    $DBLPDataset = $datasetDir + "DBLP-classified-$($Year).txt"

    $authorOutputFile = $datasetOutputDir + "id_author.txt"
    $venueOutputFile = $datasetOutputDir + "id_conf.txt"
    $paperOutputFile = $datasetOutputDir + "paper.txt"
    $paperToVenueOutputFile = $datasetOutputDir + "paper_conf.txt"
    $paperToAuthorOutputFile = $datasetOutputDir + "paper_author.txt"
    $venueToAuthorOutputFile = $datasetOutputDir + "venue_author.txt"

    $simplifiedDatasetOutputFile = $datasetOutputDir + "ShortenedDataset-$($Year).txt"
    $simplifiedPaperDatasetOutputFile = $datasetOutputDir + "ShortenedDatasetPaper-$($Year).txt"
    $adjacencyListOutputFile = $datasetOutputDir + "adjacencyList.txt"
    $AAAIOutputFile = $datasetOutputDir + "AAAI-Input.txt"

    $content = [System.IO.File]::ReadLines($DBLPDataset) -split('\r\n')

    #$nl = [System.Environment]::NewLine
    #$entryCounter = 1000000

    $authorsArr =  New-Object System.Collections.ArrayList($null)
    $authorsOutput =  New-Object System.Collections.ArrayList($null)
    $authorCounter = 0
    $authorsHash = @{}

    $venuesArr =  New-Object System.Collections.ArrayList($null)
    $venuesOutput =  New-Object System.Collections.ArrayList($null)
    $venueCounter = 0
    $venuesHash = @{}

    $papersArr =  New-Object System.Collections.ArrayList($null)
    $papersOutput =  New-Object System.Collections.ArrayList($null)
    $paperCounter = 0

    $paperToVenue =  New-Object System.Collections.ArrayList($null)
    $paperToAuthor =  New-Object System.Collections.ArrayList($null)
    $venueToAuthor =  New-Object System.Collections.ArrayList($null)

    $simplifiedDataset =  New-Object System.Collections.ArrayList($null)
    $simplifiedPaperDataset =  New-Object System.Collections.ArrayList($null)

    $item = @{}

    $loopCounter = 0
    $noPaperEntryCounter = 0

    if($Year -eq '2010' -or $Year -eq '2014')
    {
        $conferenceCode = "\#c"
        $conferenceWord = "#c"
    }
    else
    {
        $conferenceCode = "\#conf"
        $conferenceWord = "#conf"
    }


    # Iterate every three lines (one entry) of the cleaned dataset
    for($i = 0; $i -lt $content.Count; $i+=3)
    {
        # Paper
        $paper = $content[$i].Trim()
        $paper = $paper.Replace("#*", "")

        # Authors
        $authors = $content[$i+1].Trim()
        $authors = $authors.Replace("#@", "")
        $authors = $authors.Replace(" ", "")
        [System.Collections.ArrayList]$authorsToArr = $authors -split(',')

        # Venue
        $venue = $content[$i+2].Trim()
        $venue = $venue.Replace($conferenceWord, "")
        $venue = $venue.Replace(" ", "")

        # if there is at least one author, venue and paper in the entry
        if($authors -ne "" -and $venues -ne "" -and $paper -ne "")
        {
            # Add 'v' tag infront of venues
            $venue = "v$venue"

            # Set simplified Dataset initially to the paper and venue
            $simplifiedDatasetString = "$venue "

            # Reset current entry paper ID
            $entryPaperId = 0

            # If current ArrayList of papers do not contain the paper in the current entry
            if(!$papersArr.Contains($paper))
            {
                # Set current entry paper ID and add paper to paper array and paper output array, then increment current paper counter
                $entryPaperId = $paperCounter
                $null = $papersArr.Add($paper)
                $null = $papersOutput.Add("$entryPaperId       $paper")
                $paperCounter++
            }
            else
            {
                # Get existing paper ID of the entry
                $entryPaperId = $papersArr.IndexOf($paper)
            }
        
            # Reset current entry venue ID
            $venueId = 0

            # If current ArrayList of venues do not contain the venue in the current entry
            if(!$venuesArr.Contains($venue))
            {
                # Set current entry paper ID and add venue to venue array and venue output array, then increment current venue counter
                $venueId = $venueCounter
                $null = $venuesArr.Add($venue)
                $null = $venuesOutput.Add("$venueId`t$($venue)")
                $venueCounter++
            }
            else
            {
                # Get existing venue ID of the entry
                $venueId = $venuesArr.IndexOf($venue)
            }    

            # Initialize current venue entry in venuesHash if it does not exist
            if(!$venuesHash.ContainsKey($venue))
            {
                $tempArr = New-Object System.Collections.ArrayList($null)
                $venuesHash[$venue] = $tempArr
            }

            # Add paper to venue mapping entry
            $null = $paperToVenue.Add("$entryPaperId`t$venueId") 

            # For each author in current entry
            foreach($author in $authorsToArr)
            {
                # if author is not empty
                if($author.Trim() -ne "")
                {
                    # Reset current author ID
                    $authorId = 0

                    # Clone the array and remove the current Author (all authors except the current one
                    $allButCurrentAuthor = $authorsToArr.Clone()
                    $null = $allButCurrentAuthor.Remove($author)

                    # Add 'a' tag infront of authors
                    $author = "a$author"

                    # append each author to the simplified dataset string
                    $simplifiedDatasetString += "$author "

                    # If current ArrayList of authors do not contain the current author
                    if(!$authorsArr.Contains($author))
                    {
                        # Set current author ID and add author to author array and author output array, then increment current author counter
                        $authorId = $authorCounter
                        $null = $authorsArr.Add($author)
                        $null = $authorsOutput.Add("$authorId`t$author")
                        $authorCounter++
                    }
                    else
                    {
                        # Get existing author ID of the entry
                        $authorId = $authorsArr.IndexOf($author)
                    }

                    # Add current author to paper and venue mapping
                    $null = $paperToAuthor.Add("$entryPaperId`t$authorId")
                    $null = $venueToAuthor.Add("$venueId`t$authorId")
                }

                # Initialize current authors entry in authorsHash if it does not exist
                if(!$authorsHash.ContainsKey($author))
                {
                    $tempArr = New-Object System.Collections.ArrayList($null)
                    $authorsHash[$author] = $tempArr
                }

                # If current author does not contain the current venue in authorHash
                if(!$authorsHash[$author].Contains($venue))
                {
                    $null = $authorsHash[$author].Add($venue)
                }  

                # If current venue does not contain the current author in venuesHash
                if(!$venuesHash[$venue].Contains($author))
                {
                    $null = $venuesHash[$venue].Add($author)
                }  


                # Add all non-current authors to the current author list if they are not already present
                foreach($notCurrentAuthor in $allButCurrentAuthor)
                {
                    $notCurrentAuthorA = "a$notCurrentAuthor"

                    # If other authors does not exist in the values of the current author of authorHash
                    if(!$authorsHash[$author].Contains($notCurrentAuthorA))
                    {
                        $null = $authorsHash[$author].Add($notCurrentAuthorA)
                    }             
                }
            }

            $null = $simplifiedDataset.Add($simplifiedDatasetString)
            $null = $simplifiedPaperDataset.Add($paper)

            $loopCounter++

            if (0 -eq $i % 100000 -and $i -ne 0)
            {
                Write-Host "100k"
            }
        }
    }

    # Write paper IDs to 'paper.txt'
    $sw = new-object system.IO.StreamWriter($paperOutputFile)
    foreach($line in $papersOutput)
    {
        $sw.WriteLine($line)
    }
    $sw.close()

    # Write author IDs to 'id_author.txt'
    $sw = new-object system.IO.StreamWriter($authorOutputFile)
    foreach($line in $authorsOutput)
    {
        $sw.WriteLine($line)
    }
    $sw.close()

    # Write venue IDs to 'id_conf.txt'
    $sw = new-object system.IO.StreamWriter($venueOutputFile)
    foreach($line in $venuesOutput)
    {
        $sw.WriteLine($line)
    }
    $sw.close()

    # Write paper to venue mappings to 'paper_conf.txt'
    $sw = new-object system.IO.StreamWriter($paperToVenueOutputFile)
    foreach($line in $paperToVenue)
    {
        $sw.WriteLine($line)
    }
    $sw.close()

    # Write paper to author mappings to 'paper_author.txt'
    $sw = new-object system.IO.StreamWriter($paperToAuthorOutputFile)
    foreach($line in $paperToAuthor)
    {
        $sw.WriteLine($line)
    }
    $sw.close()

    # Write venue to author mappings to 'venue_author.txt'
    $sw = new-object system.IO.StreamWriter($venueToAuthorOutputFile)
    foreach($line in $venueToAuthor)
    {
        $sw.WriteLine($line)
    }
    $sw.close()

    # Write Simplified dataset to 'ShortenedDataset-(Year).txt'
    $sw = new-object system.IO.StreamWriter($simplifiedDatasetOutputFile)
    foreach($line in $simplifiedDataset)
    {
        $sw.WriteLine($line)
    }
    $sw.close()

    # Write Simplified paper dataset to 'ShortenedDatasetPaper-(Year).txt'
    $sw = new-object system.IO.StreamWriter($simplifiedPaperDatasetOutputFile)
    foreach($line in $simplifiedPaperDataset)
    {
        $sw.WriteLine($line)
    }
    $sw.close()

    # Output the adjacency list of current dataset for authors and venues
    $sw = new-object system.IO.StreamWriter($adjacencyListOutputFile)
    foreach($key in $venuesHash.Keys)
    {
        $outputString = "$key "
        foreach($value in $venuesHash[$key])
        {
            $outputString += "$value "
        }
        $outputString = $outputString.Trim()
        $sw.WriteLine("$outputString")
    }

    foreach($key in $authorsHash.Keys)
    {
        $outputString = "$key "
        foreach($value in $authorsHash[$key])
        {
            $outputString += "$value "
        }
        $outputString = $outputString.Trim()
        $sw.WriteLine("$outputString")
    }
    $sw.Close()

    # Output the adjacency list of current dataset for authors and venues in AAAI format
    $sw = new-object system.IO.StreamWriter($AAAIOutputFile)
    foreach($key in $venuesHash.Keys)
    {
        $outputString = "$key "
        foreach($value in $venuesHash[$key])
        {
            $outputString += "$value 1.0 "
        }
        $outputString = $outputString.Trim()
        $sw.WriteLine("$outputString")
    }

    foreach($key in $authorsHash.Keys)
    {
        $outputString = "$key "
        foreach($value in $authorsHash[$key])
        {
            $outputString += "$value 1.0 "
        }
        $outputString = $outputString.Trim()
        $sw.WriteLine("$outputString")
    }
    $sw.Close()

    $EndDate = (Get-Date)
    Write-Host "End date: $($EndDate)"
}