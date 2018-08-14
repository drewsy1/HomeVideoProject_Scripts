#Import-Module (Join-Path $PSScriptRoot "PDFForm.ps1") -Force
$ModuleFolder = (Get-Item $script:MyInvocation.MyCommand.Path).Directory
$PSClassesChildren = $ModuleFolder.Parent.Parent.Parent.FullName | Get-ChildItem -Recurse
$iTextSharpDLL = $PSClassesChildren | Where-Object -Property Name -Match 'itextsharp.dll' | Select-Object -ExpandProperty FullName
$PdfFormModule = $PSClassesChildren | Where-Object -Property Name -Match 'PdfForm.psd1' | Select-Object -ExpandProperty FullName
$ClipMetadataWorksheetFile = Get-ChildItem $ModuleFolder.Parent.FullName | Where-Object -Property Name -Match 'ClipMetadataWorksheet' | Select-Object -ExpandProperty FullName

class PDFClipForm
{
    static [string]$iTextSharpDLLPath = $iTextSharpDLL
    [string]$StartTimeString
    [string]$StartTimestampString
    [string]$EndTimeString
    [string]$EndTimestampString
    [string]$DateString
    hidden [object]$Module = (Import-Module $PdfFormModule -Force)
    [hashtable]$PeopleHash = @{
        "Dennis Frost Sr."  = $null;
        "Edward Frost"      = $null;
        "Hilda Frost"       = $null;
        "Irene McKay"       = $null;
        "Bernard Westgate"  = $null;
        "Beth Westgate"     = $null;
        "Dennis Westgate"   = $null;
        "Drew Westgate"     = $null;
        "Mary Westgate"     = $null;
        "Merideth Westgate" = $null;
        "Zachary Westgate"  = $null;
    }
    [hashtable]$CollectionsHash = @{
        "Birthday"                      = $null;
        "Blackmail"                     = $null;
        "Christmas"                     = $null;
        "Easter"                        = $null;
        "Frost-McKay Cousins"           = $null;
        "Frost-McKay Family Gatherings" = $null;
        "Grandma's House"                = $null;
        "Halloween"                     = $null;
        "Hot Springs"                   = $null;
        "Outside Playtime"              = $null;
        "Play/Performance"              = $null;
        "Playtime"                      = $null;
        "Pre-School"                    = $null;
        "School"                        = $null;
        "Swimming"                      = $null;
        "Swinging"                      = $null;
        "Thatchers"                     = $null;
        "Westgate Cousins"              = $null;
        "Westgate Family Gatherings"    = $null;
    }
    [timespan]$StartTimestamp
    [timespan]$EndTimestamp
    [string]$Description
    [string]$CameraOperator
    [string[]]$People
    [string[]]$Collections
    [int]$FormClipNumber
    [int]$ClipNumber
    [datetime]$StartDateTime
    [datetime]$EndDateTime
    CreatePDFClipForm([object]$PDFReader, [int]$FormClipNumber)
    {
        $this.ClipNumber = [int]($PDFReader.AcroFields.GetField("ClipNumber_$FormClipNumber"))
        $this.StartTimestampString = $PDFReader.AcroFields.GetField("StartTimestamp_$FormClipNumber")
        $this.EndTimestampString = $PDFReader.AcroFields.GetField("EndTimestamp_$FormClipNumber")
        $this.DateString = $PDFReader.AcroFields.GetField("Date_$FormClipNumber")
        $this.StartTimeString = $PDFReader.AcroFields.GetField("StartTime_$FormClipNumber")
        $this.EndTimeString = $PDFReader.AcroFields.GetField("EndTime_$FormClipNumber")
        $this.CameraOperator = $PDFReader.AcroFields.GetField("CameraOperator_$FormClipNumber")
        $this.Description = $PDFReader.AcroFields.GetField("Description_$FormClipNumber")
        $this.PeopleHash = @{
            "Dennis Frost Sr."  = [bool]($PDFReader.AcroFields.GetField("DennisFrostSr_$FormClipNumber"));
            "Edward Frost"      = [bool]($PDFReader.AcroFields.GetField("EdwardFrost_$FormClipNumber"));
            "Hilda Frost"       = [bool]($PDFReader.AcroFields.GetField("HildaFrost_$FormClipNumber"));
            "Irene McKay"       = [bool]($PDFReader.AcroFields.GetField("IreneMcKay_$FormClipNumber"));
            "Bernard Westgate"  = [bool]($PDFReader.AcroFields.GetField("BernardWestgate_$FormClipNumber"));
            "Beth Westgate"     = [bool]($PDFReader.AcroFields.GetField("BethWestgate_$FormClipNumber"));
            "Dennis Westgate"   = [bool]($PDFReader.AcroFields.GetField("DennisWestgate_$FormClipNumber"));
            "Drew Westgate"     = [bool]($PDFReader.AcroFields.GetField("DrewWestgate_$FormClipNumber"));
            "Mary Westgate"     = [bool]($PDFReader.AcroFields.GetField("MaryWestgate_$FormClipNumber"));
            "Merideth Westgate" = [bool]($PDFReader.AcroFields.GetField("MeridethWestgate_$FormClipNumber"));
            "Zachary Westgate"  = [bool]($PDFReader.AcroFields.GetField("ZacharyWestgate_$FormClipNumber"));
        }
        $this.CollectionsHash = @{
            "Birthday"                      = [bool]($PDFReader.AcroFields.GetField("Birthday_$FormClipNumber"));
            "Blackmail"                     = [bool]($PDFReader.AcroFields.GetField("Blackmail_$FormClipNumber"));
            "Christmas"                     = [bool]($PDFReader.AcroFields.GetField("Christmas_$FormClipNumber"));
            "Easter"                        = [bool]($PDFReader.AcroFields.GetField("Easter_$FormClipNumber"));
            "Frost-McKay Cousins"           = [bool]($PDFReader.AcroFields.GetField("FrostMcKayCousins_$FormClipNumber"));
            "Frost-McKay Family Gatherings" = [bool]($PDFReader.AcroFields.GetField("FrostMcKayFamilyGatherings_$FormClipNumber"));
            "Grandma's House"                = [bool]($PDFReader.AcroFields.GetField("GrandmasHouse_$FormClipNumber"));
            "Halloween"                     = [bool]($PDFReader.AcroFields.GetField("Halloween_$FormClipNumber"));
            "Hot Springs"                   = [bool]($PDFReader.AcroFields.GetField("HotSprings_$FormClipNumber"));
            "Outside Playtime"              = [bool]($PDFReader.AcroFields.GetField("OutsidePlaytime_$FormClipNumber"));
            "Play/Performance"              = [bool]($PDFReader.AcroFields.GetField("PlayPerformance_$FormClipNumber"));
            "Playtime"                      = [bool]($PDFReader.AcroFields.GetField("Playtime_$FormClipNumber"));
            "Pre-School"                    = [bool]($PDFReader.AcroFields.GetField("PreSchool_$FormClipNumber"));
            "School"                        = [bool]($PDFReader.AcroFields.GetField("School_$FormClipNumber"));
            "Swimming"                      = [bool]($PDFReader.AcroFields.GetField("Swimming_$FormClipNumber"));
            "Swinging"                      = [bool]($PDFReader.AcroFields.GetField("Swinging_$FormClipNumber"));
            "Thatchers"                     = [bool]($PDFReader.AcroFields.GetField("Thatchers_$FormClipNumber"));
            "Westgate Cousins"              = [bool]($PDFReader.AcroFields.GetField("WestgateCousins_$FormClipNumber"));
            "Westgate Family Gatherings"    = [bool]($PDFReader.AcroFields.GetField("WestgateFamilyGatherings_$FormClipNumber"));
        }
        
        if ($this.StartTimestampString) { $this.StartTimestamp = [timespan]($this.StartTimestampString) }
        if ($this.EndTimestampString) { $this.EndTimestamp = [timespan]($this.EndTimestampString) }
        if ($this.DateString -and $this.StartTimeString) { $this.StartDateTime = [datetime]($this.DateString) + [timespan]($this.StartTimeString) }
        if ($this.DateString -and $this.EndTimeString) { $this.EndDateTime = [datetime]($this.DateString) + [timespan]($this.EndTimeString) }
        $this.People = ($this.PeopleHash.Keys | Where-Object { $this.PeopleHash."$_" })
        $this.Collections = ($this.CollectionsHash.Keys | Where-Object { $this.CollectionsHash."$_" })
    }

    PDFClipForm ([string]$PDF, [int]$FormClipNumber = 1)
    {
        $this.FormClipNumber = $FormClipNumber

        Add-Type -Path [PDFClipForm]::iTextSharpDLLPath
        $PDFReader = New-Object iTextSharp.text.pdf.pdfreader -ArgumentList (Get-Item $PDF).FullName

        $this.CreatePDFClipForm($PDFReader, $FormClipNumber)

        $PDFReader.Close()
    }

    PDFClipForm ([object]$PDFReader, [int]$FormClipNumber = 1)
    {
        $this.FormClipNumber = $FormClipNumber

        $this.CreatePDFClipForm($PDFReader, $FormClipNumber)
    }

    PDFClipForm ([int]$FormClipNumber = 1)
    {
        $this.FormClipNumber = $FormClipNumber
    }

    [string]SetDateStringFromDateTime ()
    {
        $this.DateString = $this.StartDateTime.ToString("yyyy\-MM\-dd")
        return $this.DateString
    }

    [string]SetTimeStringFromDateTime ([bool]$IsEndTime = $false)
    {
        if ($IsEndTime)
        {
            $this.EndTimeString = $this.EndDateTime.ToString("hh\:mm\:ss\.fff")
            return $this.EndTimeString
        }
        else
        {
            $this.StartTimeString = $this.StartDateTime.ToString("hh\:mm\:ss\.fff")
            return $this.StartTimeString
        }
    }

    [string]SetTimestampStringFromTimeSpan ([bool]$IsEndTimestamp = $false)
    {
        if ($IsEndTimeStamp)
        {
            $this.EndTimestampString = $this.EndTimestamp.ToString("hh\:mm\:ss\.fff")
            return $this.EndTimestampString
        }
        else
        {
            $this.StartTimestampString = $this.StartTimestamp.ToString("hh\:mm\:ss\.fff")
            return $this.StartTimestampString
        }
    }

    [void]SetAllTimeDateStrings ()
    {
        $this.SetDateStringFromDateTime() | Write-Verbose
        $this.SetTimeStringFromDateTime($false) | Write-Verbose
        $this.SetTimeStringFromDateTime($true) | Write-Verbose
        $this.SetTimestampStringFromTimeSpan($true) | Write-Verbose
        $this.SetTimestampStringFromTimeSpan($false) | Write-Verbose
    }

    [hashtable]SetPeopleHashFromArray(){
        $this.People | ForEach-Object{ $this.PeopleHash."$_" = "On" }
        return $this.PeopleHash
    }

    [hashtable]SetCollectionsHashFromArray(){
        $this.Collections | ForEach-Object{ $this.CollectionsHash."$_" = "On" }
        return $this.CollectionsHash
    }

}

class PDFForm
{
    static [string]$PDFTemplate = $ClipMetadataWorksheetFile
    static [string]$iTextSharpDLLPath = $iTextSharpDLL
    hidden [object]$Module = (Import-Module $PdfFormModule -Force)
    [string]$VideoNumber
    [string]$Reviewer
    [PDFClipForm]$ClipForm2
    [PDFClipForm]$ClipForm1
    [int]$ChapterNumber

    PDFForm ()
    {
        $this.ClipForm1 = [PDFClipForm]::new(1)
        $this.ClipForm2 = [PDFClipForm]::new(2)

    }

    PDFForm ([string]$PDF)
    {
        Add-Type -Path ([PDFForm]::iTextSharpDLLPath)
        $PDFReader = New-Object iTextSharp.text.pdf.pdfreader -ArgumentList (Get-Item $PDF).FullName

        $this.Reviewer = $PDFReader.AcroFields.GetField("Reviewer")
        $this.VideoNumber = $PDFReader.AcroFields.GetField("VideoNumber")
        $this.ChapterNumber = [int]($PDFReader.AcroFields.GetField("ChapterNumber"))
        $this.ClipForm1 = [PDFClipForm]::new($PDFReader, 1)
        $this.ClipForm2 = [PDFClipForm]::new($PDFReader, 2)

        $PDFReader.Close()
    }

    [hashtable]GetHashtable ()
    {
        if ($this.ChapterNumber) {$ChapterNumberString = [string]($this.ChapterNumber)} else {$ChapterNumberString = ""}
        
        $Clips = ($this.ClipForm1, $this.ClipForm2 | ForEach-Object {
                $CurrentFormClipNumber = $_.FormClipNumber
                if ($_.ClipNumber) {$ClipNumberString = [string]($_.ClipNumber)} else {$ClipNumberString = ""}
                
                @{
                    "ClipNumber_$CurrentFormClipNumber"                 = $ClipNumberString;
                    "StartTimestamp_$CurrentFormClipNumber"             = $_.StartTimestampString;
                    "EndTimestamp_$CurrentFormClipNumber"               = $_.EndTimestampString;
                    "Date_$CurrentFormClipNumber"                       = $_.DateString;
                    "StartTime_$CurrentFormClipNumber"                  = $_.StartTimeString;
                    "EndTime_$CurrentFormClipNumber"                    = $_.EndTimeString;
                    "CameraOperator_$CurrentFormClipNumber"             = $_.CameraOperator
                    "Description_$CurrentFormClipNumber"                = $_.Description
                    "DennisFrostSr_$CurrentFormClipNumber"              = $_.PeopleHash."Dennis Frost Sr.";
                    "EdwardFrost_$CurrentFormClipNumber"                = $_.PeopleHash."Edward Frost";
                    "HildaFrost_$CurrentFormClipNumber"                 = $_.PeopleHash."Hilda Frost";
                    "IreneMcKay_$CurrentFormClipNumber"                 = $_.PeopleHash."Irene McKay";
                    "BernardWestgate_$CurrentFormClipNumber"            = $_.PeopleHash."Bernard Westgate";
                    "BethWestgate_$CurrentFormClipNumber"               = $_.PeopleHash."Beth Westgate";
                    "DennisWestgate_$CurrentFormClipNumber"             = $_.PeopleHash."Dennis Westgate";
                    "DrewWestgate_$CurrentFormClipNumber"               = $_.PeopleHash."Drew Westgate";
                    "MaryWestgate_$CurrentFormClipNumber"               = $_.PeopleHash."Mary Westgate";
                    "MeridethWestgate_$CurrentFormClipNumber"           = $_.PeopleHash."Merideth Westgate";
                    "ZacharyWestgate_$CurrentFormClipNumber"            = $_.PeopleHash."Zachary Westgate";
                    "Birthday_$CurrentFormClipNumber"                   = $_.CollectionsHash."Birthday";
                    "Blackmail_$CurrentFormClipNumber"                  = $_.CollectionsHash."Blackmail";
                    "Christmas_$CurrentFormClipNumber"                  = $_.CollectionsHash."Christmas";
                    "Easter_$CurrentFormClipNumber"                     = $_.CollectionsHash."Easter";
                    "FrostMcKayCousins_$CurrentFormClipNumber"          = $_.CollectionsHash."Frost-McKay Cousins";
                    "FrostMcKayFamilyGatherings_$CurrentFormClipNumber" = $_.CollectionsHash."Frost-McKay Family Gatherings";
                    "GrandmasHouse_$CurrentFormClipNumber"              = $_.CollectionsHash."Grandma's House";
                    "Halloween_$CurrentFormClipNumber"                  = $_.CollectionsHash."Halloween";
                    "HotSprings_$CurrentFormClipNumber"                 = $_.CollectionsHash."Hot Springs";
                    "OutsidePlaytime_$CurrentFormClipNumber"            = $_.CollectionsHash."Outside Playtime";
                    "PlayPerformance_$CurrentFormClipNumber"            = $_.CollectionsHash."Play/Performance";
                    "Playtime_$CurrentFormClipNumber"                   = $_.CollectionsHash."Playtime";
                    "PreSchool_$CurrentFormClipNumber"                  = $_.CollectionsHash."Pre-School";
                    "School_$CurrentFormClipNumber"                     = $_.CollectionsHash."School";
                    "Swimming_$CurrentFormClipNumber"                   = $_.CollectionsHash."Swimming";
                    "Swinging_$CurrentFormClipNumber"                   = $_.CollectionsHash."Swinging";
                    "Thatchers_$CurrentFormClipNumber"                  = $_.CollectionsHash."Thatchers";
                    "WestgateCousins_$CurrentFormClipNumber"            = $_.CollectionsHash."Westgate Cousins";
                    "WestgateFamilyGatherings_$CurrentFormClipNumber"   = $_.CollectionsHash."Westgate Family Gatherings";
                }
            })
        
        $VideoChapter = @{
            "Reviewer"      = $this.Reviewer;
            "VideoNumber"   = $this.VideoNumber;
            "ChapterNumber" = $ChapterNumberString;
        }
        
        return ($VideoChapter + $Clips[0] + $Clips[1])
    }

    [void] WriteToPDF([string]$PDF)
    {
        Add-Type -Path ([PDFForm]::iTextSharpDLLPath)
        $OutputFile = $this.GetHashtable()
        Save-PdfField -Fields $OutputFile -InputPdfFilePath ([PDFForm]::PDFTemplate) -OutputPdfFilePath $PDF -ITextSharpLibrary ([PDFForm]::iTextSharpDLLPath)
    }
}