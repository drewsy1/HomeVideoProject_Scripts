$xml = [xml](Get-Content "M:\ISO\DVDs\1996-12_1997-05.xml")
$ChapterNodes = $xml.HomeVideoLibrary.HomeVideoDVD.DVDChapters.DVDChapter
$ClipDescriptions = ($ChapterNodes | ForEach-Object{
    $CurrentChapterNumber = $_.DVDChapterNumber
    $_.VideoClips.VideoClip | ForEach-Object{
        $CurrentVideoClip = $_.ClipNumber
        [PSCustomObject]@{
            "Chapter" = $CurrentChapterNumber;
            "Video Clip" = $CurrentVideoClip;
            "Timestamp" = $_.ClipStart -replace '\.\d{3}','';
            "Time/Date" = ([dateTime]($_.DateRecorded)).ToString('MM/dd/yy');
            "Description" = $_.Description
        }
    }
})
$Chapter1 = $ClipDescriptions | Where -Property "Chapter" -EQ "1"
$Chapter2 = $ClipDescriptions | Where -Property "Chapter" -EQ "2"
$Chapter3 = $ClipDescriptions | Where -Property "Chapter" -EQ "3"

Document '1996-12_1997-05' {
        Section -Style Heading1 'Chapter 1' {
            $Chapter1 | Table -Columns "Video Clip","Timestamp","Time/Date","Description"
        }
        Section -Style Heading1 'Chapter 2' {
            $Chapter2 | Table -Columns "Video Clip","Timestamp","Time/Date","Description"
        }
        Section -Style Heading1 'Chapter 3' {
            $Chapter3 | Table -Columns "Video Clip","Timestamp","Time/Date","Description"
        }
} | Export-Document -Path M:\ISO\DVDs -Format Word

$ClipDescriptions