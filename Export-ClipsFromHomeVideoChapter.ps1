using module "C:\Users\dreww\src\Git\HomeVideoProject_Scripts\PSClasses\PSHomeVideoProject\1.0.0.0\Classes\PDFForm.psm1"
using module "C:\Users\dreww\src\Git\HomeVideoProject_Scripts\PSClasses\PSHomeVideoProject\1.0.0.0\Classes\HomeVideo.psm1"

param(
    [string]$XMLPath,
    [int]$ChapterNumber,
    [string]$OutputFolder,
    [string]$VideoFile
)

$VerbosePreference = 2
Import-Module "C:\Users\dreww\src\Git\HomeVideoProject_Scripts\PSClasses\PSHomeVideoProject\1.0.0.0\PSHomeVideoProject.psd1" -Force

$HomeVideo_DVD = [HomeVideo_DVD]::new([xml](Get-Content $XMLPath))
$HomeVideo_Chapter = $HomeVideo_DVD.DVDChapters | Where-Object -Property ChapterNumber -EQ $ChapterNumber

Export-ClipsFromHomeVideoChapter -HomeVideo_DVD $HomeVideo_DVD -HomeVideo_Chapter $HomeVideo_Chapter -OutputFolder $OutputFolder -VideoFile $VideoFile