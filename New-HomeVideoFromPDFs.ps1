﻿using module "C:\Users\dreww\src\Git\HomeVideoProject_Scripts\PSClasses\PSHomeVideoProject\1.0.0.0\Classes\PDFForm.psm1"
using module "C:\Users\dreww\src\Git\HomeVideoProject_Scripts\PSClasses\PSHomeVideoProject\1.0.0.0\Classes\HomeVideo.psm1"

param(
    [string]$DVDLabel = "1994-02_1996-12",
    [int[]]$Chapters = (1..6),
    [string]$XMLFolder = "E:\OneDrive\HomeVideosProject\XML",
    [string]$ChaptersFolder = "E:\OneDrive\HomeVideosProject\Chapters_7_ClipSplittingMetadataEmbedding"
)

$VerbosePreference = 2
Import-Module "C:\Users\dreww\src\Git\HomeVideoProject_Scripts\PSClasses\PSHomeVideoProject\1.0.0.0\PSHomeVideoProject.psd1" -Force

$XMLFile = Join-Path $XMLFolder "$DVDLabel.xml"
$HomeVideo = [HomeVideo_DVD]::new([xml](Get-Content $XMLFile))

$Chapters | ForEach-Object {
    $Chapter = $_
    $CurrentChapter = $HomeVideo.DVDChapters | Where-Object -Property ChapterNumber -eq $Chapter
    $CurrentChapter.ChapterClips = $null
    $PDFFiles = Get-ChildItem (Join-Path $ChaptersFolder "$($DVDLabel)_$($Chapter)\PDF Forms") | Select -ExpandProperty FullName
    $PDFFiles | %{ $CurrentChapter.AddClipsFromPDF($_) }
    $CurrentChapter.ChapterClips = $CurrentChapter.ChapterClips | Sort-Object {[int]($_.ClipNumber)}
}

$HomeVideo.ToXML().Save($XMLFile)

return $HomeVideo
#Export-ClipsFromHomeVideoChapter -HomeVideo_DVD $HomeVideo -HomeVideo_Chapter $HomeVideo.DVDChapters[0] -OutputFolder "M:\Home Movies" -VideoFile "E:\OneDrive\HomeVideosProject\Chapters_7_ClipSplittingMetadataEmbedding\$($DVDLabel)_$($Chapter)\$($DVDLabel)_$($Chapter).mp4"
#$HomeVideo.AddDVDChapter([HomeVideo_Chapter]::new("$Chapter","00:00:06:21.398"))
#$CSV = Import-Csv "E:\OneDrive\HomeVideosProject\Chapters_5_GeneratePDFs\$($DVDLabel)_$($Chapter)\$($DVDLabel)_$($Chapter).csv"
#$CSV | %{ $HomeVideo.DVDChapters[1].AddChapterClip([HomeVideo_Clip]::new($_.Index,$_.Start,$_.End))}

#$HomeVideo.DVDChapters[1].CreatePDFs("E:\OneDrive\HomeVideosProject\Chapters_5_GeneratePDFs\$($DVDLabel)_$($Chapter)\PDF Forms",$DVDLabel,$Chapter)
#$HomeVideo.DVDChapters[$Chapter - 1].AddClipsFromPDF($PDFFile)
#$HomeVideo.ToXML().Save($XMLFile)
#>