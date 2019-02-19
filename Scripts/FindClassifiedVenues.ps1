Set-Location -Path $PSScriptRoot

$Year = '2013'

if($Year -eq '2010' -or $Year -eq '2014')
{
    $conferenceCode = "\#c"
    $conferenceWord = "#c"
}
elseif($Year -eq '2011' -OR $Year -eq '2013')
{
    $conferenceCode = "\#conf"
    $conferenceWord = "#conf"
}
else
{
    Write-Error "Invalid Year"
}

$DBLPDataset = "C:\Users\Hung\Desktop\Metapath-Momo\Datasets\All\DBLP-cleanedVenues-nospace-$($Year).txt"
$DBLPVenues = "C:\Users\Hung\Desktop\Metapath-Momo\GroundTruth-nocluster.txt"
$targetVenues = [System.IO.File]::ReadLines($DBLPVenues) -split('\r\n')
$outputFileName = "C:\Users\Hung\Desktop\Metapath-Momo\Datasets\All\DBLP-classified-$($Year).txt"
$content = [System.IO.File]::ReadLines($DBLPDataset) -split('\r\n')



$sw = new-object system.IO.StreamWriter($outputFileName)

for($i = 0; $i -lt $content.Count; $i+=3)
{
    $venue = $content[$i+2]
    $venue = $venue.Replace($conferenceWord, "")
    $venue = $venue.Replace(" ", "")
    $venue = "v$venue"

    if($targetVenues.Contains($venue))
    {
        $sw.WriteLine($content[$i])
        $sw.WriteLine($content[$i+1])
        $sw.WriteLine($content[$i+2])
    }
}

$sw.close()