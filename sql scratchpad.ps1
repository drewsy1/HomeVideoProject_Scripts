using module "C:\Users\dreww\src\Git\HomeVideoProject_Scripts\PSClasses\PSHomeVideoProject\1.0.0.0\Classes\PDFForm.psm1"
using module "C:\Users\dreww\src\Git\HomeVideoProject_Scripts\PSClasses\PSHomeVideoProject\1.0.0.0\Classes\HomeVideo.psm1"

$VerbosePreference = 2
Import-Module "C:\Users\dreww\src\Git\HomeVideoProject_Scripts\PSClasses\PSHomeVideoProject\1.0.0.0\PSHomeVideoProject.psd1" -Force

$SQLServerInstanceName = "HAL9000"
$SQLServerInstance = Get-SqlInstance -ServerInstance $SQLServerInstanceName
$SQLDatabaseName = "HomeVideoDB"
$SQLDatabase = $SQLServerInstance | Get-SqlDatabase -Name $SQLDatabaseName
$XMLFolder = "E:\OneDrive\HomeVideosProject\XML"
$DVDLabel = "1997-10_1998-03"
$XMLFile = Join-Path $XMLFolder "$DVDLabel.xml"
#$HomeVideo = [HomeVideo_DVD]::new([xml](Get-Content $XMLFile))

$SqlcmdParams = @{
    ServerInstance = $SQLServerInstance
    Database = $SQLDatabaseName
}

$SqlTableDataParams = @{
    ServerInstance = $SQLServerInstanceName
    DatabaseName = $SQLDatabaseName
    SchemaName = "dbo"
}

$TagsPeople = @{ 
    "Bernard Westgate" = 1
    "Beth Westgate" = 2
    "Dennis Frost Sr." = 3
    "Dennis Westgate" = 4
    "Drew Westgate" = 5
    "Edward Frost" = 6
    "Hilda Frost" = 7
    "Irene McKay" = 8
    "Mary Westgate" = 9
    "Merideth Westgate" = 10
    "Zachary Westgate" = 11
}

$TagsCollections = @{
    "Baby Moments"                  = 1;
    "Birthday"                      = 2;
    "Blackmail"                     = 3;
    "Christmas"                     = 4;
    "Church"                        = 5;
    "Driving"                       = 6;
    "Easter"                        = 7;
    "Frost-McKay Cousins"           = 8;
    "Frost-McKay Family Gatherings" = 9;
    "Grandma's House"               = 10;
    "Halloween"                     = 11;
    "Hot Springs"                   = 12;
    "Misc. Holidays"                = 13;
    "Outside Playtime"              = 14;
    "Play/Performance"              = 15;
    "Playtime"                      = 16;
    "Pre-School"                    = 17;
    "School"                        = 18;
    "Swimming"                      = 19;
    "Swinging"                      = 20;
    "Thatchers"                     = 21;
    "Trips/Vacations"               = 22;
    "Westgate Cousins"              = 23;
    "Westgate Family Gatherings"    = 24;
}

function Clear-TableData {
    param([string]$Table)
    
    Invoke-Sqlcmd @SqlcmdParams "DELETE FROM $Table"
    Invoke-Sqlcmd @SqlcmdParams "DBCC CHECKIDENT($Table, RESEED, 0)"
}

"E:\OneDrive\HomeVideosProject\XML\1994-02_1996-12.xml","E:\OneDrive\HomeVideosProject\XML\1996-12_1997-05.xml","E:\OneDrive\HomeVideosProject\XML\1997-10_1998-03.xml" | %{ 
    $HomeVideo = [HomeVideo_DVD]::new([xml](Get-Content $_)) 
    $DVDRow = Invoke-Sqlcmd @SqlcmdParams "SELECT * FROM DVD WHERE DVDLabel LIKE '$($HomeVideo.DVDLabel)'"
    $DVDChapters = $HomeVideo.DVDChapters | %{
        [PSCustomObject]@{
            ChapterID=$null
            ChapterNumber=$_.ChapterNumber
            DVDID=$DVDRow.DVDID
            ChapterLength=$_.ChapterLengthString
        }
    }
    #$DVDChapters | Write-SqlTableData @SqlTableDataParams -TableName "Chapter"
    #$DVDChapters | Export-Csv Chapters.csv -NoTypeInformation -Append
    <#$HomeVideo.DVDChapters | %{
        Invoke-Sqlcmd @SqlcmdParams "SELECT * FROM CHAPTER WHERE (DVDID LIKE '$($DVDRow.DVDID)') AND (ChapterNumber LIKE '$($_.ChapterNumber)')"
    } | Sort ChapterID#>

    $HomeVideo.DVDChapters | %{
        $ChapterRow = Invoke-Sqlcmd @SqlcmdParams "SELECT * FROM Chapter WHERE ChapterNumber LIKE '$($_.ChapterNumber)' AND DVDID LIKE '$($DVDRow.DVDID)'"
        $ChapterID = $ChapterRow.ChapterID
    
        $_.ChapterClips | %{
            [PSCustomObject]@{
                ClipID=$null
                ChapterID=$ChapterID
                ClipNumber=$_.ClipNumber
                ClipTimeStart=$_.DateTimeRecordedStart
                ClipTimeEnd=$_.DateTimeRecordedEnd
                ClipVidTimeStart=$_.ClipStartString
                ClipVidTimeEnd=$_.ClipEndString
                ClipVidTimeLength=($_.ClipEnd - $_.ClipStart).ToString("hh\:mm\:ss\.fff")
                ClipReviewer=$_.Reviewer
                CameraOperator=$_.CameraOperator
                Description=$_.Description
            }
        } | Write-SqlTableData @SqlTableDataParams -TableName "Clip"
    }

    $HomeVideo.DVDChapters | %{
        $ChapterRow = Invoke-Sqlcmd @SqlcmdParams "SELECT * FROM Chapter WHERE ChapterNumber LIKE '$($_.ChapterNumber)' AND DVDID LIKE '$($DVDRow.DVDID)'"
        $ChapterID = $ChapterRow.ChapterID

        $_.ChapterClips | %{
            $ClipRow = Invoke-Sqlcmd @SqlcmdParams "SELECT * FROM Clip WHERE ClipNumber LIKE '$($_.ClipNumber)' AND ChapterID LIKE '$($ChapterID)'"
            $ClipID = $ClipRow.ClipID

            $Clip_TagsPeople = $_.People | %{ 
                $TagsPeopleID = $TagsPeople.$_
                [PSCustomObject]@{ ClipID = $ClipID; PeopleID = $TagsPeopleID }
            }
            if($_.People){Write-SqlTableData @SqlTableDataParams -TableName "Clip_TagsPeople" -InputData $Clip_TagsPeople}

            $Clip_TagsCollections = $_.Collections | %{ 
                $TagsCollectionsID = $TagsCollections.$_
                [PSCustomObject]@{ ClipID = $ClipID; CollectionsID = $TagsCollectionsID } 
            }
            if($_.Collections){Write-SqlTableData @SqlTableDataParams -TableName "Clip_TagsCollections" -InputData $Clip_TagsCollections}
        }
    }#>
}

#Read-SqlTableData @SqlTableDataParams -TableName "Chapter"


#Read-SqlTableData @SqlTableDataParams -TableName "Clip"


