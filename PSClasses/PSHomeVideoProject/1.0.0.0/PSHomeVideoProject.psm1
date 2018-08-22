Using module Classes\HomeVideo.psm1
Using module Classes\PDFForm.psm1
$SetMP4MetadataPy = Join-Path (Get-Item $script:MyInvocation.MyCommand.Path).DirectoryName SetMP4Metadata.py
$ClipMetadataWorksheetPDF = Join-Path (Get-Item $script:MyInvocation.MyCommand.Path).DirectoryName ClipMetadataWorksheet.pdf

function Get-ClipStartTime
{
    <#
        .SYNOPSIS
        Calculates and returns a string representation of the recording start time of a clip.

        .DESCRIPTION
        Subtracts the video timestamp of the start of the clip from the timestamp of the change from the first recorded minute to the next, then adds that difference to the first recorded minute.

        .PARAMETER ClipStart
        String representing the video timestamp of the start of the clip.

        .PARAMETER TimeOfChange
        String representing the video timestamp at which the TimeRecordedStart increments by one minute.

        .PARAMETER TimeRecordedStart
        String representing the date/time at which the video began recording.

        .EXAMPLE
        Get-ClipStartTime -ClipStart "00:10:00" -TimeOfChange "00:10:35.321" -TimeRecordedStart "2018-08-10T16:20:00"
        Returns "2018-08-10T16:20:24", the date/time corresponding to the exact time that recording began.

        .OUTPUTS
        System.String
        String representing the calculated start time of a clip.
    #>
    [CmdletBinding()]
    param(
        [string]$ClipStart,
        [string]$TimeOfChange,
        [string]$TimeRecordedStart
    )
    ([dateTime]$TimeRecordedStart + ([timeSpan]"00:01:00" - [TimeSpan]"00:00:$(([dateTime]$TimeRecordedStart).Second)") - ([dateTime]$TimeOfChange - [dateTime]$ClipStart)).ToString("s")
}

function Get-ClipEndTime
{
    <#
        .SYNOPSIS
        Calculates and returns a string representation of the recording end time of a clip.

        .DESCRIPTION
        Subtracts the timestamp of the change from the second-to-last recorded minute to the last video timestamp from the last video timestamp, then adds that difference to the last recorded minute.

        .PARAMETER ClipEnd
        String representing the video timestamp of the end of the clip.

        .PARAMETER TimeOfChange
        String representing the video timestamp at which the TimeRecordedEnd is reached.

        .PARAMETER TimeRecordedEnd
        String representing the date/time at which the video stopped recording.

        .EXAMPLE
        Get-ClipEndTime -ClipEnd "00:11:00" -TimeOfChange "00:10:35.321" -TimeRecordedEnd "2018-08-10T16:20:00"
        Returns "2018-08-10T16:20:24", the date/time corresponding to the exact time that recording ended.

        .OUTPUTS
        System.String
        String representing the calculated end time of a clip.
    #>
    
    [CmdletBinding()]
    param(
        [string]$ClipEnd,
        [string]$TimeOfChange,
        [string]$TimeRecordedEnd
    )
    ([dateTime]$TimeRecordedEnd - [TimeSpan]("00:00:$(([dateTime]$TimeRecordedEnd).Second)") + ([dateTime]$ClipEnd - [dateTime]$TimeOfChange)).ToString("s")
}

function Convert-PTSToTimeStamp
{
    <#
        .SYNOPSIS
        Converts a float value of an ffmpeg PTS to a string value representing its corresponding timestamp.

        .DESCRIPTION
        Converts a float value of an ffmpeg PTS to a string value representing its corresponding timestamp.

        .PARAMETER PTS
        Float representation of PTS value of an ffmpeg scene.

        .EXAMPLE
        Convert-PTSToTimeStamp -PTS 1234567
        Returns "00:00:13.717" as a string.

        .EXAMPLE
        1234567,7654321 | Convert-PTSToTimeStamp
        Returns "00:00:13.717","00:01:25.048" as an array of strings.

        .INPUTS
        System.Single
        Accepts floats as the $PTS parameter, from pipeline or as an array of floats.

        .OUTPUTS
        System.String
        Returns a string representation of the input PTS' corresponding timestamp.
    #>
    
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline)][System.Single[]]$PTS
    )

    process
    {
        foreach ($PT in $PTS)
        {
            $TimeSpan = [timespan]::fromseconds($(Convert-PTSToSecondsString $PTS))
            "{0:HH:mm:ss.fff}" -f ([datetime]$TimeSpan.Ticks)
        }
    }
}

function Get-VideoDuration
{
    <#
        .SYNOPSIS
        Retrieves the duration of an mp4 video file.

        .DESCRIPTION
        Uses ffprobe to retrieve the video duration of an mp4 file. Returns duration as a standard timestamp or as an XML duration.

        .PARAMETER AsXML
        Switch that toggles returning of string as an XML duration rather than a standard timestamp.

        .PARAMETER VideoPath
        String(s) representing path(s) to desired video file(s).

        .EXAMPLE
        Get-VideoDuration -VideoPath "E:\OneDrive\HomeVideosProject\Chapters_7_ClipSplittingMetadataEmbedding\1999-02_1999-06_1\1999-02_1999-06_1.mp4"
        Returns "00:00:03:05.185", the string timestamp of the input video.

        .EXAMPLE
        "E:\OneDrive\HomeVideosProject\Chapters_7_ClipSplittingMetadataEmbedding\1999-02_1999-06_1\1999-02_1999-06_1.mp4","E:\OneDrive\HomeVideosProject\Chapters_7_ClipSplittingMetadataEmbedding\2000-11_2001-01_4\2000-11_2001-01_4.mp4" | Get-VideoDuration -AsXML
        Returns "P00Y00M00DT00H03M05S" and "P00Y00M00DT00H04M29S", the XML duration timestamps of the input videos.

        .INPUTS
        System.String
        String representing the path to the desired video.

        .OUTPUTS
        System.String
        Returns the string representation of a standard timestamp OR an XML duration of the duration of the input video.
    #>
    
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline, Mandatory = $true)][string[]]$VideoPath,
        [parameter(Mandatory = $false)][switch]$AsXML
    )

    process
    {
        foreach ($Video in $VideoPath)
        {
            $Duration = ffprobe -i $Video -show_entries format=duration -v quiet -of csv="p=0"
            $DurationTS = [timespan]::fromseconds($Duration)
            if ($AsXML) {$DurationTS.ToString("\P\0\0\Y\0\0\Mdd\D\Thh\Hmm\Mss\S")}
            else { $DurationTS.ToString("dd\:hh\:mm\:ss\.fff")}
        }
    }
}

function Export-ClipsFromHomeVideoChapter
{
    <#
        .SYNOPSIS
        Splits desired video into the clips described in a HomeVideo_Chapter object, then applies metadata to them.

        .DESCRIPTION
        Uses metadata from HomeVideo_DVD and HomeVideo_Chapter to define clip segments in a chapter video file, then uses ffmpeg to split the chapter video file into those segments and apply metadata to them.

        .PARAMETER HomeVideo_DVD
        HomeVideo_DVD object containing the desired HomeVideo_Chapter object.

        .PARAMETER HomeVideo_Chapter
        HomeVideo_Chapter object describing all clip metadata for the input VideoFile.

        .PARAMETER OutputFolder
        String representing the path to the desired output folder for split/exported clips.

        .PARAMETER VideoFile
        String representing the path to the video file to be split.

        .EXAMPLE
        Export-ClipsFromHomeVideoChapter -HomeVideo_DVD $DVD -HomeVideo_Chapter $DVD.DVDChapters[0] -OutputFolder "M:\Home Movies" -VideoFile "E:\OneDrive\HomeVideosProject\Chapters_7_ClipSplittingMetadataEmbedding\2000-11_2001-01_4\2000-11_2001-01_4.mp4"
        Uses metadata contained in a HomeVideo_DVD object ($DVD) and its first chapter ($DVD.DVDChapters[0]) to split a video file ("..\2000-11_2001-01_4.mp4") into separate clips and apply metadata to them. These separate clips are then exported to "M:\HomeMovies"

    #>

    [CmdletBinding()]
    param(
        [HomeVideo_DVD]$HomeVideo_DVD,
        [HomeVideo_Chapter]$HomeVideo_Chapter,
        [string]$OutputFolder,
        [string]$VideoFile
    )

    $HomeVideo_Chapter.ChapterClips | ForEach-Object {
        $ChapterTotal = $HomeVideo_DVD.DVDChapters.Count
        $DVDLabel = $HomeVideo_DVD.DVDLabel

        $ChapterNumber = $HomeVideo_Chapter.ChapterNumber
        $ClipTotal = $HomeVideo_Chapter.ChapterClips.Count
        
        $CameraOperator = $_.CameraOperator
        $ClipNumber = $_.ClipNumber
        $Collections = $_.Collections -join '" "'
        $Comment = "Disc $DVDLabel, Chapter $ChapterNumber, Clip $ClipNumber"
        $Date = $_.DateRecordedString
        $Description = $_.Description
        $FileInput = (Get-Item $VideoFile).FullName
        $People = $($_.People -join '" "')
        $TimeStart = $_.ClipStart.ToString("hh\:mm\:ss\.fff")
        $TimeEnd = $_.ClipLength.ToString("hh\:mm\:ss\.fff")
        $Timestamp = $_.DateTimeRecordedStart.ToString("s")
        $Title = $Description
        $TitleSort = $Date + "_" + $_.DateTimeRecordedStart.ToString("hh\-mm\-ss") + "_" + $_.DateTimeRecordedEnd.ToString("hh\-mm\-ss") + "_" + $Description

        $FileOutput = Join-Path (Get-Item $OutputFolder).FullName "$($TitleSort -replace '"|\&','').mp4"

        $ffmpegArgs = @(
            "-y",
            "-ss $TimeStart",
            "-i `"$FileInput`"",
            "-t $TimeEnd",
            "-codec:a:0 copy",
            "-vcodec copy",
            "-timestamp `"$Timestamp`"",
            "-metadata:s:a:0 language=eng"
            "`"$FileOutput`""
        )
        Write-Verbose "      CurrentClip ffmpeg Arguments:"
        $ffmpegArgs | ForEach-Object { Write-Verbose "       $_" }
        
        $SetMP4Metadata = @(
            "--File `"$FileOutput`"",
            "--Title `"$Title`"",
            "--Description `"$Description`"",
            "--Comment `"$Comment`"",
            "--People `"$People`"",
            "--CameraOperators `"$CameraOperator`"",
            "--Collections `"$Collections`"",
            "--ClipNumber $ClipNumber",
            "--ClipTotal $ClipTotal",
            "--ChapterNumber $ChapterNumber",
            "--ChapterTotal $ChapterTotal",
            "--Date `"$Date`"",
            "--TitleSort `"$TitleSort`""
        )
        Write-Verbose "      CurrentClip SetMP4Metadata Arguments:"
        $SetMP4Metadata | ForEach-Object { Write-Verbose "       $_" }
        
        $PythonArgs = "`"$SetMP4MetadataPy`" " + ($SetMP4Metadata -join " ")

        Start-Process "ffmpeg" -ArgumentList $ffmpegArgs -Wait -NoNewWindow
        Start-Process "python" -ArgumentList $PythonArgs -Wait -RedirectStandardError 'SetMP4Metadata.log'
        (Get-Item $FileOutput).CreationTime = $_.DateTimeRecordedStart
    }
}

function Convert-PTSToSecondsString
{
    <#
        .SYNOPSIS
        Converts a float value of an ffmpeg PTS to a string value representing seconds.

        .DESCRIPTION
        Converts a float value of an ffmpeg PTS to a string value representing seconds.

        .PARAMETER PTS
        Float representation of PTS value of an ffmpeg scene.

        .EXAMPLE
        Convert-PTSToSecondsString -PTS 1234567
        Returns "13.71741" as a string.

        .EXAMPLE
        1234567,7654321 | Convert-PTSToSecondsString
        Returns "13.71741","85.04801" as an array of strings.

        .INPUTS
        System.Single
        Accepts floats as the $PTS parameter, from pipeline or as an array of floats.

        .OUTPUTS
        System.String
        Returns a string representation of the seconds of the input PTS.
    #>
    [CmdletBinding()]
    param([parameter(ValueFromPipeline)][System.Single[]]$PTS)

    process
    {
        foreach ($PT in $PTS)
        {
            [math]::round(($PT / 90000), 5).ToString("####.00000")
        }
    }
}

function Get-ffmpegSceneChanges
{
    <#
        .SYNOPSIS
        Generates PNG screenshots of frames at which scenes change (before and after change) from a given video file.

        .DESCRIPTION
        From a video file specified by $VideoFilePath, generates PNG screenshots of frames at which scenes change (before and after change).
        Screenshots are exported to a folder named "Scene Snapshots" in the same directory as $VideoFilePath.
        Exports a CSV file in the same directory as $VideoFilePath containing pairs of PTS timestamps .

        .PARAMETER VideoFilePath
        String representing path to video file from which the timestamp pairs will be extracted.

        .EXAMPLE
        Get-ffmpegSceneChanges "E:\OneDrive\HomeVideosProject\Videos_Chapters\1994-02_1996-12_1\1994-02_1996-12_1.mp4"
        Creates a "E:\OneDrive\HomeVideosProject\Videos_Chapters\1994-02_1996-12_1\Scene Snapshots" folder in the file's directory (if not already present) and fills it with scene change screenshots. 
        Also creates "E:\OneDrive\HomeVideosProject\Videos_Chapters\1994-02_1996-12_1\1994-02_1996-12_1.csv" containing scene change pairs.

        .INPUTS
        System.String
        Accepts a string as the $VideoFilePath parameter.
    #>

    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline)][string]$VideoFilePath
    )

    Process
    {
        $VideoDirectory = (Get-Item $VideoFilePath).DirectoryName # Set $VideoDirectory to video file's parent directory
        $SceneSnapshotsDir = Join-Path $VideoDirectory "Scene Snapshots" # Set $SceneSnapshotsDir to "$VideoDirectory\Scene Snapshots"
        $VideoFile = (Get-Item $VideoFilePath) # Set $VideoFile to video file object
        $VideoFileName = $VideoFile.Name # Set $VideoFileName to $VideoFile's name+extension

        Write-Verbose $SceneSnapshotsDir

        Push-Location $VideoDirectory

        # If $SceneSnapshotsDir doesn't exist, make it
        if (!(Test-Path $SceneSnapshotsDir)) {New-Item -ItemType Directory -Path $SceneSnapshotsDir | Out-Null}
        
        # Use FFProbe to get all scene changes in the form of PTS time signatures and export them to an XML file stored in $SceneFramesRough
        try {$SceneFramesRough = ffprobe -show_frames -of xml=x=1 -f lavfi "movie=$VideoFileName,select=gt(scene\,.3)" -noprivate}
        catch {$SceneFramesRough = /usr/local/bin/ffprobe -show_frames -of xml=x=1 -f lavfi "movie=$VideoFileName,select=gt(scene\,.3)" -noprivate}

        # Set $SceneFramesRoughXML to an XML object of $SceneFramesRough
        $SceneFramesRoughXML = [xml]$SceneFramesRough

        #For each PTS, store the PTS and its preceding frame's PTS as an array within the $SceneFramesRoughTS array
        $SceneFramesRoughTS = $SceneFramesRoughXML.ffprobe.frames.frame.pkt_pts | ForEach-Object { 
            $currentFrame = $_
            , (([float]$currentFrame - 3003), # 3003 is a rough estimate of the number of PTS between frames
                ([float]$currentFrame))
        }
        
        # For each PTS pair in $SceneFramesRoughTS, convert to a PSCustomObject and export all of them to a CSV file in the $VideoDirectory
        $SceneFramesRoughTS | ForEach-Object { 
            [PSCustomObject]@{
                "Start" = (Convert-PTSToSecondsString $_[0]); 
                "End"   = (Convert-PTSToSecondsString $_[1])
            } | Export-Csv -Path (Join-Path $VideoDirectory "$($VideoFile.BaseName).csv") -Append -NoTypeInformation 
        }

        # For each PTS in each PTS pair in $SceneFramesRoughTS, use ffmpeg to extract a screenshot of the frame at the exact PTS timestamp and save it to $SceneSnapshotsDir
        $SceneFramesRoughTS | ForEach-Object { $_[0], $_[1] | ForEach-Object {
                $StartPoint = (Convert-PTSToSecondsString $_)
                $OutputFile = Join-Path $SceneSnapshotsDir "$(Convert-PTSToSecondsString $_).png"
                try
                { 
                    ffmpeg -ss $StartPoint -i "$VideoFile" -vframes 1 -vsync drop -y $OutputFile
                }
                catch
                { 
                    /usr/local/bin/ffmpeg -ss $StartPoint -i "$VideoFile" -vframes 1 -vsync drop -y $OutputFile
                }
            }
        }

        # If duplicate PTS timestamps, make a copy of the frame's screenshot with "_2" appended to the filename
        $SceneFramesRoughTS | ForEach-Object { $_[0]} | ForEach-Object { 
            if (($SceneFramesRoughTS | ForEach-Object { $_[1]}) -contains $_)
            { 
                Copy-Item (Join-Path $SceneSnapshotsDir "$(Convert-PTSToSecondsString $_).png") (Join-Path $SceneSnapshotsDir "$(Convert-PTSToSecondsString $_)_2.png") 
            }
        }

        Pop-Location
    }
}

function Convert-Times
{
    <#
        .SYNOPSIS
        Converts time formats into a standard "hh:mm:ss.fff" format.

        .DESCRIPTION
        Converts time formats (represented as a string) into a standard "hh:mm:ss.fff" format (output as a string).

        .PARAMETER InputTime
        String representing the time to be converted.

        .EXAMPLE
        PS C:> "33.21","00:12:32" | Convert-Times
        00:00:33.210
        00:12:32.000

        .EXAMPLE
        PS C:> Convert-Times "33.21"
        00:00:33.210

        .INPUTS
        System.String
        Accepts a string representing the time to be converted.

        .OUTPUTS
        System.String
        Outputs a string representing the input time in a standard "hh:mm:ss.fff" format.
    #>
    param(
        [parameter(ValueFromPipeline)][string]$InputTime
    )

    process
    {
        if ($InputTime -match '\d+\.\d+') { $OutputTime = [timeSpan]::FromSeconds([float]$InputTime) }
        else { $OutputTime = [timeSpan]$InputTime }
    
        $OutputTime.ToString("hh\:mm\:ss\.fff") 
    }
}

function New-TSPairsCSV
{
    <#
        .SYNOPSIS
        Generates a CSV file containing start/end times of clips from screenshots in a chapter's "Scene Snapshots" folder.

        .DESCRIPTION
        Accepts a chapter folder's path and the path to an output CSV. Searches for all .png and .jpg images in the "Scene Snapshots" folder within the chapter folder. These images should be named using the timestamp at which they occur in the chapter's video, in "ss.fff" format (total seconds, then milliseconds). The images are sorted by name and grouped into pairs (denoting the beginning/end of scenes). Each pair is then output to the CSV file along with an index representing their scene number within the chapter video, as well as to standard output.

        .PARAMETER Csv
        System.String
        String representing the desired output CSV's path. Defaults to a file in the root of the chapter folder's path ($Path).

        .PARAMETER Path
        System.String
        String representing the path of the chapter video's parent directory.

        .EXAMPLE
        PS C:\> New-TSPairsCSV -Path "E:\OneDrive\HomeVideosProject\Chapters_7_ClipSplittingMetadataEmbedding\1994-02_1996-12_2"

        Index    Start      End
        -----    -----      ---
            1 11.67833 620.2529
            2 620.2863  841.874
            3  841.908 925.7582
            4 925.7916  1014.08
            5 1017.683 1017.717
            6 1019.118  1677.91
            7 1677.943 1733.498

        Also outputs a CSV representation of the above objects.

        .OUTPUTS
        System.Object[]
        Array of PSCustomObjects representing Index, Start & End times of scenes. This array is also tee'd into a CSV file.
    #>
    [CmdletBinding()]
    param(
        [string]$Path,
        [string]$Csv = (Join-Path (Get-Item $Path).FullName "$((Get-Item $Path).BaseName).csv")
    )

    $Items = Get-ChildItem (Join-Path $Path "Scene Snapshots") -Name -Include *.png, *.jpg
    $ItemsFloat = ($Items | ForEach-Object { [float]($_ -replace '(?:_\d|)(?:\.png|\.jpg)', '') } | Sort-Object)
    $SortedPairs = foreach ($i in (0..($ItemsFloat.Count - 1) | Where-Object {(($_ % 2) -eq 0) -or ($_ -eq 0)}))
    {
        (, ($ItemsFloat[$i], $ItemsFloat[$i + 1]))
    }
    (1..$SortedPairs.Count) | ForEach-Object { [PSCustomObject]@{Index = $_; Start = $SortedPairs[$_ - 1][0]; End = $SortedPairs[$_ - 1][1]}} | Tee-Object -Variable "SortedPairsObject" | Export-Csv $Csv -NoTypeInformation

    $SortedPairsObject
}

function New-FrameImage
{
    <#
        .SYNOPSIS
        Generates an image of a still frame from a desired video at a desired timestamp.

        .DESCRIPTION
        Uses ffmpeg to take a still frame from the desired video at the desired timestamp and output that file as a .png

        .PARAMETER Force
        System.Management.Automation.SwitchParameter
        Forces an overwrite of an existing .png.

        .PARAMETER OutputPNG
        System.String
        Defines an output file for the image. If not present, defaults to a "Scene Snapshots" folder adjacent to the desired video.

        .PARAMETER Timestamp
        System.String
        Timestamp at which to take an image within the video.

        .PARAMETER VideoPath
        System.String
        String representing the path to the desired video.

        .EXAMPLE
        PS C:\> New-FrameImage -VideoPath "E:\OneDrive\HomeVideosProject\Chapters_7_ClipSplittingMetadataEmbedding\1994-02_1996-12_2\1994-02_1996-12_2.mp4" -Timestamp "11.67833" -OutputPNG "E:\OneDrive\HomeVideosProject\Chapters_7_ClipSplittingMetadataEmbedding\1994-02_1996-12_2\Scene Snapshots\11.67833.png" -Force
        

            Directory: E:\OneDrive\HomeVideosProject\Chapters_7_ClipSplittingMetadataEmbedding\1994-02_1996-12_2\Scene Snapshots


        Mode                LastWriteTime         Length Name
        ----                -------------         ------ ----
        -a----        8/20/2018   7:15 PM         415330 11.67833.png

        .OUTPUTS
        System.IO.FileInfo
        Object representing the newly created PNG.
    #>
    param(
        [switch]$Force,
        [string]$VideoPath,
        [string]$Timestamp,
        [string]$OutputPNG
    )

    $VideoFile = Get-Item $VideoPath
    if ($Timestamp -match '\d{2}\:\d{2}\:\d{2}\.\d+') { $Timestamp = ([timespan]$Timestamp).TotalSeconds.ToString("####0.00000") }
    elseif ($Timestamp -match '\d+\.\d+') { $Timestamp = ([timeSpan]::FromSeconds([float]$Timestamp)).TotalSeconds.ToString("####0.00000") }

    if (!$OutputPNG) { $OutputPNG = Join-Path (Join-Path $VideoFile.DirectoryName "Scene Snapshots") "$Timestamp.png"}

    $FFMpegArgs = ("-ss $Timestamp", "-i `"$VideoPath`"", '-vframes 1', '-vsync drop', '-vcodec png', '-y', "`"$OutputPNG`"")
    if (!$Force) { $FFMpegArgs = ($FFMpegArgs[(0..4) + 6] -join " ") }
    else { $FFMpegArgs = $FFMpegArgs -join " " }
    Write-Verbose $FFMpegArgs
    try {Start-Process "C:\ProgramData\chocolatey\lib\ffmpeg\tools\ffmpeg\bin\ffmpeg.exe" -ArgumentList $FFMpegArgs -Wait}
    catch { Start-Process "/usr/local/bin/ffmpeg" -ArgumentList $FFMpegArgs -Wait}
    Get-Item $OutputPNG
}

function Convert-XMLScenesToPDFs
{
    <#
        .SYNOPSIS
        Exports PDF worksheets from a HomeVideo_DVD XML database file.

        .DESCRIPTION
        Exports PDF worksheets from a HomeVideo_DVD XML database file.

        .PARAMETER ChaptersToProcess
        System.Int32[]
        Array of integers representing chapter numbers to be converted into PDF worksheets.
        
        .PARAMETER OutputDir
        System.String
        String representing the path of the desired output directory.
        
        .PARAMETER PDFTemplate
        System.String
        String representing the path of the PDF worksheet template (Defaults to a PDF file in the same directory as this module file.) 
        
        .PARAMETER XMLFile
        System.String
        String representing the path of the HomeVideo_DVD XML database file to be converted. 

        .EXAMPLE
        PS C:\>Convert-XMLScenesToPDFs -ChaptersToProcess (1..6) -OutputDir "E:\OneDrive\HomeVideosProject\Chapters_7_ClipSplittingMetadataEmbedding\1994-02_1996-12_PDFs" -XMLFile "E:\OneDrive\HomeVideosProject\XML\1994-02_1996-12.xml"
        Outputs PDF clip worksheets of chapters 1-6 in the XML file "1994-02_1996-12.xml" to the folder "1994-02_1996-12_PDFs"

    #>
    param(
        [int[]]$ChaptersToProcess,
        [string]$OutputDir,
        [string]$PDFTemplate = $ClipMetadataWorksheetPDF,
        [string]$XMLFile
    )

    [PDFForm]::PDFTemplate = $PDFTemplate
    $XML = [xml](Get-Content $XMLFile)
    $NewHomeVideoDVD = [HomeVideo_DVD]::new($XML)
    if (!$ChaptersToProcess) { $ChaptersToProcess = (1..$NewHomeVideoDVD.DVDChapters.Count)}

    $ChaptersToProcess | ForEach-Object {
        $NewHomeVideoDVD.DVDChapters[($_ - 1)].CreatePDFs(
            "$OutputDir",
            $NewHomeVideoDVD.DVDLabel,
            $_
        )
    }
}