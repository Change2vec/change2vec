Set-Location -Path $PSScriptRoot

$DBLPDataset = "C:\Users\Hung\Downloads\DBLP_citation_2014_May\DBLP_Citation_2014_May\publications.txt"
$outputPath = "C:\Users\Hung\Downloads\DBLP_citation_2014_May\DBLP_Citation_2014_May\DBLP-cleanedVenues-nospace-2014.txt"

$conferencecode = "\#c"


$dataset = [System.IO.File]::ReadLines($DBLPDataset) -split('\r\n')


$sw = new-object system.IO.StreamWriter($outputPath)

foreach($line in $dataset)
{
    $writeLine = $true
    if($line.StartsWith("#!"))
    {
        $writeLine = $false
    }

    if($line -match "\#\@" -and $writeLine)
    {
		$line = $line -replace(",,",",")
        $sw.WriteLine($line)
        $writeLine = $false
    }

    if($line -match "\#\*" -and $writeLine)
    {
        $sw.WriteLine($line)
        $writeLine = $false
    }

    if($line -match $conferencecode -and $writeLine)
    {
        $line = $line -replace('\([0-9]\)','')
        $sw.WriteLine($line)
        $writeLine = $false
    }
}

$sw.Close()