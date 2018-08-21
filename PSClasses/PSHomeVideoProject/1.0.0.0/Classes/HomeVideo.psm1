Using Module .\PDFForm.psm1

class HomeVideo_Clip
{
    [int]$ClipNumber
    [timespan]$ClipStart
    [timespan]$ClipEnd
    [timespan]$ClipLength
    [string]$ClipStartString
    [string]$ClipEndString
    [string]$ClipLengthString
    [datetime]$DateTimeRecordedStart
    [datetime]$DateTimeRecordedEnd
    [string]$DateRecordedString
    [string]$TimeRecordedStartString = ""
    [string]$TimeRecordedEndString = ""
    [string]$Description
    [string[]]$People
    [string[]]$Collections
    [string]$CameraOperator
    static [xml]$HomeVideo_ClipXML = @'
<VideoClip ClipNumber="" xmlns="http://www2.latech.edu/~aew027/">
    <ClipStart></ClipStart>
    <ClipEnd></ClipEnd>
    <ClipLength></ClipLength>
    <DateRecorded></DateRecorded>
    <TimeRecordedStart></TimeRecordedStart>
    <TimeRecordedEnd></TimeRecordedEnd>
    <Description></Description>
    <People>
        <Person></Person>
    </People>
    <Collections>
        <Collection></Collection>
    </Collections>
    <CameraOperator>
        <Person></Person>
    </CameraOperator>
</VideoClip>    
'@

    static [datetime]StringToDatetime([string]$String){ return [datetime]$String }

    static [string]DateToString([datetime]$Datetime){ return $Datetime.ToString("yyyy\-MM\-dd") }

    static [string]TimestampToString([timespan]$Timestamp){ return $Timestamp.ToString("hh\:mm\:ss\.fff") }

    static [string]TimeToString([datetime]$Datetime){ return $Datetime.ToString("hh\:mm\:ss\.fff") }

    static [string]LengthToString([timespan]$Length){ return $Length.ToString("\P\0\0\Y\0\0\Mdd\D\Thh\Hmm\Mss\S") }

    static [timespan]StringToTimestamp([string]$String){ return [timespan]$String }

    static [timespan]SecondsToTimestamp([string]$String){ return [timespan]::FromSeconds($String)}

    HomeVideo_Clip(){}

    HomeVideo_Clip([int]$ClipNum){ $this.ClipNumber = $ClipNum }

    HomeVideo_Clip([int]$ClipNum, [string]$ClipSta, [string]$ClipEn){ 
        $this.ClipNumber = $ClipNum 
        $this.ClipStart = [HomeVideo_Clip]::SecondsToTimestamp($ClipSta)
        $this.ClipEnd = [HomeVideo_Clip]::SecondsToTimestamp($ClipEn)
        $this.ClipStartString = $this.ClipStart.ToString("hh\:mm\:ss\.fff")
        $this.ClipEndString = $this.ClipEnd.ToString("hh\:mm\:ss\.fff")
        $this.ClipLength = $this.ClipEnd - $this.ClipStart
        $this.ClipLengthString = [HomeVideo_Clip]::LengthToString($this.ClipLength)
    }

    HomeVideo_Clip([int]$ClipNum, [string]$ClipSta, [string]$ClipEn, [string]$DateRecord, [string]$TimeRecordedStar, [string]$TimeRecordedEn, [string]$Descript, [string[]]$Peop, [string[]]$Collect, [string]$CameraOperat ){
        $this.ClipNumber = $ClipNum
        $this.ClipStartString = $ClipSta
        $this.ClipEndString = $ClipEn
        $this.DateRecordedString = $DateRecord
        $this.TimeRecordedStartString = $TimeRecordedStar
        $this.TimeRecordedEndString = $TimeRecordedEn
        $this.Description = $Descript
        $this.People = $Peop | Sort-Object
        $this.Collections = $Collect | Sort-Object
        $this.CameraOperator = $CameraOperat

        $this.ClipStart = [HomeVideo_Clip]::StringToTimestamp($this.ClipStartString)
        $this.ClipEnd = [HomeVideo_Clip]::StringToTimestamp($this.ClipEndString)
        $this.ClipLength = $this.ClipEnd - $this.ClipStart
        $this.ClipLengthString = [HomeVideo_Clip]::LengthToString($this.ClipLength)
        $this.DateTimeRecordedStart = [HomeVideo_Clip]::StringToDatetime("$($this.DateRecordedString)T$($this.TimeRecordedStartString)")
        $this.DateTimeRecordedEnd = [HomeVideo_Clip]::StringToDatetime("$($this.DateRecordedString)T$($this.TimeRecordedEndString)")
    }

    HomeVideo_Clip([int]$ClipNum, [timespan]$ClipSta, [timespan]$ClipEn, [datetime]$TimeRecordedStar, [datetime]$TimeRecordedEn, [string]$Descript, [string[]]$Peop, [string[]]$Collect, [string]$CameraOperat ){
        $this.ClipNumber = $ClipNum
        $this.ClipStart = $ClipSta
        $this.ClipEnd = $ClipEn
        $this.DateTimeRecordedStart = $TimeRecordedStar
        $this.DateTimeRecordedEnd = $TimeRecordedEn
        $this.Description = $Descript
        $this.People = $Peop | Sort-Object
        $this.Collections = $Collect | Sort-Object
        $this.CameraOperator = $CameraOperat

        $this.ClipStartString = [HomeVideo_Clip]::TimestampToString($this.ClipStart)
        $this.ClipEndString = [HomeVideo_Clip]::TimestampToString($this.ClipEnd)
        $this.ClipLength = $this.ClipEnd - $this.ClipStart
        $this.ClipLengthString = [HomeVideo_Clip]::LengthToString($this.ClipLength)
        $this.DateRecordedString = [HomeVideo_Clip]::DateToString($this.DateTimeRecordedStart)
        $this.TimeRecordedStartString = [HomeVideo_Clip]::TimeToString($this.DateTimeRecordedStart)
        $this.TimeRecordedEndString = [HomeVideo_Clip]::TimeToString($this.DateTimeRecordedEnd)
    }

    HomeVideo_Clip([System.Xml.XmlNode]$Clip){
        $this.ClipNumber = $Clip.ClipNumber
        $this.ClipStartString = $Clip.ClipStart
        $this.ClipEndString = $Clip.ClipEnd
        $this.DateRecordedString = $Clip.DateRecorded
        $this.TimeRecordedStartString = $Clip.TimeRecordedStart
        $this.TimeRecordedEndString = $Clip.TimeRecordedEnd
        $this.Description = $Clip.Description
        $this.People = $Clip.People.Person | Sort-Object
        $this.Collections = $Clip.Collections.Collection | Sort-Object
        $this.CameraOperator = $Clip.CameraOperator.Person

        $this.ClipStart = [HomeVideo_Clip]::StringToTimestamp($this.ClipStartString)
        $this.ClipEnd = [HomeVideo_Clip]::StringToTimestamp($this.ClipEndString)
        $this.ClipLength = $this.ClipEnd - $this.ClipStart
        $this.ClipLengthString = [HomeVideo_Clip]::LengthToString($this.ClipLength)
        if($this.DateRecordedString -and $this.TimeRecordedStartString){
            $this.DateTimeRecordedStart = [HomeVideo_Clip]::StringToDatetime($this.DateRecordedString+"T"+$this.TimeRecordedStartString)
        }
        if($this.DateRecordedString -and $this.TimeRecordedEndString){
            $this.DateTimeRecordedEnd = [HomeVideo_Clip]::StringToDatetime($this.DateRecordedString+"T"+$this.TimeRecordedEndString)
        }
    }

    [xml]ToXML(){
        $ClipXML = [HomeVideo_Clip]::HomeVideo_ClipXML.Clone()

        if($this.ClipNumber){$ClipXML.VideoClip.ClipNumber = [string]($this.ClipNumber)}

        if($this.ClipStart){ $ClipXML.VideoClip.ClipStart = $this.ClipStartString }

        if($this.ClipEndString){ $ClipXML.VideoClip.ClipEnd = $this.ClipEndString }

        if($this.ClipLengthString){ $ClipXML.VideoClip.ClipLength = $this.ClipLengthString }
        elseif ($this.ClipLength) {
            $this.ChapterLengthString = [HomeVideo_Clip]::LengthToString($this.ClipLength)
            $ClipXML.VideoClip.ClipLength = $this.ClipLengthString
        }

        if($this.DateRecordedString){ $ClipXML.VideoClip.DateRecorded = $this.DateRecordedString }
        elseif ($this.DateRecorded) {
            $this.DateRecordedString = [HomeVideo_Clip]::DateToString($this.DateRecorded)
            $ClipXML.VideoClip.DateRecorded = $this.DateRecordedString
        }

        if($this.TimeRecordedStartString -eq "0001-01-01"){$ClipXML.VideoClip.TimeRecordedStart = ""}
        elseif ($this.TimeRecordedStartString){ $ClipXML.VideoClip.TimeRecordedStart = $this.TimeRecordedStartString }
        elseif ($this.DateTimeRecordedStart -ne [datetime]"0001-01-01") {
            $this.TimeRecordedStartString = [HomeVideo_Clip]::DateToString($this.DateTimeRecordedStart)
            $ClipXML.VideoClip.TimeRecordedStart = $this.TimeRecordedStartString
        }

        if($this.TimeRecordedEndString -eq "0001-01-01"){$ClipXML.VideoClip.TimeRecordedEnd = ""}
        elseif ($this.TimeRecordedEndString){ $ClipXML.VideoClip.TimeRecordedEnd = $this.TimeRecordedEndString }
        elseif ($this.DateTimeRecordedEnd -ne [datetime]"0001-01-01") {
            $this.TimeRecordedEndString = [HomeVideo_Clip]::DateToString($this.DateTimeRecordedEnd)
            $ClipXML.VideoClip.TimeRecordedEnd = $this.TimeRecordedEndString
        }

        if($this.Description){ $ClipXML.VideoClip.Description = $this.Description }

        if($this.CameraOperator){ $ClipXML.VideoClip.CameraOperator.Person = $this.CameraOperator }

        if($this.People){ $ClipXML.VideoClip.People.InnerXML = "<Person>$($this.People -join "</Person><Person>")</Person>" }

        if($this.Collections){ $ClipXML.VideoClip.Collections.InnerXML = "<Collection>$($this.Collections -join "</Collection><Collection>")</Collection>" }
        
        return $ClipXML
    }
}

class HomeVideo_Chapter
{
    [int]$ChapterNumber
    [timespan]$ChapterLength
    [string]$ChapterLengthString
    [object[]]$ChapterClips
    static [xml]$HomeVideo_ChapterXML = [xml]@'
<DVDChapter DVDChapterNumber="" xmlns="http://www2.latech.edu/~aew027/">
    <DVDChapterLength></DVDChapterLength>
    <VideoClips>
    </VideoClips>
</DVDChapter>
'@
    
    static [string]LengthToString([timespan]$Length){ return $Length.ToString("\P\0\0\Y\0\0\Mdd\D\Thh\Hmm\Mss\S") }

    static [timespan]StringToLength([string]$String){ return [timespan]$String }

    [void]AddChapterClip($HomeVideo_Clip){ 
        $this.ChapterClips += $HomeVideo_Clip
        #return $this.ChapterClips
    }

    HomeVideo_Chapter([int]$ChapterNum){
        $this.ChapterNumber = $ChapterNum
    }

    HomeVideo_Chapter([int]$ChapterNum, [object[]]$ChapterCli){
        $this.ChapterNumber = $ChapterNum
        $this.ChapterClips = $ChapterCli
    }

    HomeVideo_Chapter([int]$ChapterNum, [timespan]$ChapterLen){
        $this.ChapterNumber = $ChapterNum
        $this.ChapterLength = $ChapterLen
        $this.ChapterLengthString = [HomeVideo_Chapter]::LengthToString($ChapterLen)
    }

    HomeVideo_Chapter([int]$ChapterNum, [string]$ChapterLen){
        $this.ChapterNumber = $ChapterNum
        $this.ChapterLengthString = $ChapterLen
        $this.ChapterLength = [HomeVideo_Chapter]::StringToLength($ChapterLen)
    }

    HomeVideo_Chapter([int]$ChapterNum, [timespan]$ChapterLen, [object[]]$ChapterCli){
        $this.ChapterNumber = $ChapterNum
        $this.ChapterLength = $ChapterLen
        $this.ChapterLengthString = [HomeVideo_Chapter]::LengthToString($ChapterLen)
        $this.ChapterClips = $ChapterCli
    }

    HomeVideo_Chapter([int]$ChapterNum, [string]$ChapterLen, [object[]]$ChapterCli){
        $this.ChapterNumber = $ChapterNum
        $this.ChapterLengthString = $ChapterLen
        $this.ChapterLength = [HomeVideo_Chapter]::StringToLength($ChapterLen)
        $this.ChapterClips = $ChapterCli
    }

    HomeVideo_Chapter([System.Xml.XmlNode]$Chapter){
        $this.ChapterNumber = $Chapter.DVDChapterNumber
        $this.ChapterLengthString = $Chapter.DVDChapterLength -replace 'P\d+Y\d+M\d+DT(\d+)H(\d+)M(\d+)S','$1:$2:$3.000'
        $this.ChapterLength = [HomeVideo_Chapter]::StringToLength($this.ChapterLengthString)
        if($Chapter.VideoClips.VideoClip){
            $Chapter.VideoClips.VideoClip | ForEach-Object{ $this.AddChapterClip([HomeVideo_Clip]::new($_)) }
            $this.ChapterClips = $this.ChapterClips | Sort-Object -Property ClipNumber    
        }
    }

    [void]AddClipFromPDF([PDFClipForm]$PDFClipForm){
        $NewClip = [HomeVideo_Clip]::new(
            $PDFClipForm.ClipNumber,
            $PDFClipForm.StartTimestampString,
            $PDFClipForm.EndTimestampString,
            $PDFClipForm.DateString,
            $PDFClipForm.StartTimeString,
            $PDFClipForm.EndTimeString,
            $PDFClipForm.Description,
            $PDFClipForm.People,
            $PDFClipForm.Collections,
            $PDFClipForm.CameraOperator
        )
        $this.AddChapterClip($NewClip)
    }

    [void]AddClipsFromPDF([string]$PDFFormPath){
        $PDFForm = [PDFForm]::new($PDFFormPath)
        if($PDFForm.ClipForm1.ClipNumber){$this.AddClipFromPDF($PDFForm.ClipForm1)}
        if($PDFForm.ClipForm2.ClipNumber){$this.AddClipFromPDF($PDFForm.ClipForm2)}
    }

    [xml]ToXML([xml]$DVDXML){
        $ChapterXML = [HomeVideo_Chapter]::HomeVideo_ChapterXML.Clone()
        if($this.ChapterNumber){$ChapterXML.DVDChapter.DVDChapterNumber = [string]($this.ChapterNumber)}

        if($this.ChapterLengthString){ $ChapterXML.DVDChapter.DVDChapterLength = [HomeVideo_Chapter]::LengthToString($this.ChapterLength) }
        elseif ($this.ChapterLength) {
            $this.ChapterLengthString = [string]::LengthToString($this.ChapterLength)
            $ChapterXML.DVDChapter.DVDChapterLength = $this.ChapterLengthString
        }

        if($this.ChapterClips.Count){ 
            $this.ChapterClips | ForEach-Object{
                $node = $_.ToXML().VideoClip
                $newClip = $ChapterXML.ImportNode($node, $true)
                $VideoClips = $ChapterXML.DVDChapter.ChildNodes[1]
                $VideoClips.AppendChild($newClip)
            }
        }

        return $ChapterXML
    }

    [void]CreatePDFs([string]$PDFOutputDir, [string]$DVDName, [string]$ChapterNumber){
        if(($this.ChapterClips.Count % 2) -eq 0){ $ClipCount = $this.ChapterClips.Count - 1; $LastClip = $null }
        else{ $ClipCount = $this.ChapterClips.Count - 2; $LastClip = $this.ChapterClips[($ClipCount + 1)] }
        
        (0..($ClipCount)) | ForEach-Object{
            if($_ % 2){}
            else{
                $OutputFileName = "$($DVDName)_$($ChapterNumber)_$(($_/2)+1).pdf"
                Write-Verbose $OutputFileName
                $OutputPath = (Join-Path $PDFOutputDir $OutputFileName)
                Write-Verbose $OutputPath

                $PDFForm = [PDFForm]::new()

                $PDFForm.VideoNumber = $DVDName
                $PDFForm.ChapterNumber = $ChapterNumber

                $PDFForm.ClipForm1.ClipNumber = $this.ChapterClips[$_].ClipNumber
                $PDFForm.ClipForm1.StartTimestampString = $this.ChapterClips[$_].ClipStartString
                $PDFForm.ClipForm1.EndTimestampString = $this.ChapterClips[$_].ClipEndString
                $PDFForm.ClipForm1.DateString = $this.ChapterClips[$_].DateRecordedString
                if($this.ChapterClips[$_] -ne [datetime]"0001-01-01"){$PDFForm.ClipForm1.StartTimeString = $this.ChapterClips[$_].TimeRecordedStartString}
                $PDFForm.ClipForm1.EndTimeString = $this.ChapterClips[$_].TimeRecordedEndString
                $PDFForm.ClipForm1.CameraOperator = $this.ChapterClips[$_].CameraOperator
                $PDFForm.ClipForm1.Description = $this.ChapterClips[$_].Description
                $PDFForm.ClipForm1.People = $this.ChapterClips[$_].People
                $PDFForm.ClipForm1.Collections = $this.ChapterClips[$_].Collections
                $PDFForm.ClipForm1.SetPeopleHashFromArray()
                $PDFForm.ClipForm1.SetCollectionsHashFromArray()
                
                $PDFForm.ClipForm2.ClipNumber = $this.ChapterClips[$_+1].ClipNumber
                $PDFForm.ClipForm2.StartTimestampString = $this.ChapterClips[$_+1].ClipStartString
                $PDFForm.ClipForm2.EndTimestampString = $this.ChapterClips[$_+1].ClipEndString
                $PDFForm.ClipForm2.DateString = $this.ChapterClips[$_+1].DateRecordedString
                $PDFForm.ClipForm2.StartTimeString = $this.ChapterClips[$_+1].TimeRecordedStartString
                $PDFForm.ClipForm2.EndTimeString = $this.ChapterClips[$_+1].TimeRecordedEndString
                $PDFForm.ClipForm2.CameraOperator = $this.ChapterClips[$_+1].CameraOperator
                $PDFForm.ClipForm2.Description = $this.ChapterClips[$_+1].Description
                $PDFForm.ClipForm2.People = $this.ChapterClips[$_+1].People
                $PDFForm.ClipForm2.Collections = $this.ChapterClips[$_+1].Collections
                $PDFForm.ClipForm2.SetPeopleHashFromArray()
                $PDFForm.ClipForm2.SetCollectionsHashFromArray()

                Write-Verbose $OutputPath
                $PDFForm.WriteToPDF($OutputPath)
                Get-Item $OutputPath
            }
        }

        if($LastClip){
            $OutputFileName = "$($DVDName)_$($ChapterNumber)_$((($ClipCount+1)/2)+1).pdf"
            $OutputPath = (Join-Path $PDFOutputDir $OutputFileName)

            $PDFForm = [PDFForm]::new()

            $PDFForm.VideoNumber = $DVDName
            $PDFForm.ChapterNumber = $ChapterNumber

            $PDFForm.ClipForm1.ClipNumber = $LastClip.ClipNumber
            $PDFForm.ClipForm1.StartTimestamp = $LastClip.ClipStartString
            $PDFForm.ClipForm1.EndTimestamp = $LastClip.ClipEndString
            $PDFForm.ClipForm1.DateString = $LastClip.DateRecordedString
            $PDFForm.ClipForm1.StartTimeString = $LastClip.TimeRecordedStartString
            $PDFForm.ClipForm1.EndTimeString = $LastClip.TimeRecordedEndString
            $PDFForm.ClipForm1.CameraOperator = $LastClip.CameraOperator
            $PDFForm.ClipForm1.Description = $LastClip.Description
            $PDFForm.ClipForm1.People = $LastClip.People
            $PDFForm.ClipForm1.Collections = $LastClip.Collections
            $PDFForm.ClipForm1.SetPeopleHashFromArray()
            $PDFForm.ClipForm1.SetCollectionsHashFromArray()

            $PDFForm.WriteToPDF($OutputPath)
            Get-Item $OutputPath
        }
    }
}

class HomeVideo_DVD
{
    [string]$DVDLabel
    [datetime]$DateBurned
    [string]$DateBurnedString
    [datetime]$DateRipped
    [string]$DateRippedString
    [object[]]$DVDChapters
    static [xml]$HomeDVDXML = [xml]@'
<?xml version="1.0" encoding="utf-8"?>
    <HomeVideoLibrary xmlns="http://www2.latech.edu/~aew027/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www2.latech.edu/~aew027/ HomeVideoDVD_Schema.xsd">
        <HomeVideoDVD DVDLabel="">
          <DateBurned></DateBurned>
          <DateRipped></DateRipped>
            <DVDChapters>
            </DVDChapters>
        </HomeVideoDVD>
    </HomeVideoLibrary>
'@

    [void]AddDVDChapter($HomeVideo_Chapter){ 
        $this.DVDChapters += $HomeVideo_Chapter
        #return $this.DVDChapters
    }

    static [datetime]StringToDatetime([string]$String){ return [datetime]$String }

    static [string]DateToString([datetime]$Datetime){ return $Datetime.ToString("yyyy\-MM\-dd") }

    [HomeVideo_DVD]SetParamsFromXMLValues([xml]$XML){
        Write-Verbose "DVDLabel = $($XML.HomeVideoLibrary.HomeVideoDVD.DVDLabel)"
        $this.DVDLabel = $XML.HomeVideoLibrary.HomeVideoDVD.DVDLabel

        Write-Verbose "DateBurnedString = $($XML.HomeVideoLibrary.HomeVideoDVD.DateBurned)"
        $this.DateBurnedString = $XML.HomeVideoLibrary.HomeVideoDVD.DateBurned

        Write-Verbose "DateBurned = $([HomeVideo_DVD]::StringToDatetime($XML.HomeVideoLibrary.HomeVideoDVD.DateBurned))"
        $this.DateBurned = [HomeVideo_DVD]::StringToDatetime($XML.HomeVideoLibrary.HomeVideoDVD.DateBurned)
        
        Write-Verbose "DateRippedString = $($XML.HomeVideoLibrary.HomeVideoDVD.DateRipped)"
        $this.DateRippedString = $XML.HomeVideoLibrary.HomeVideoDVD.DateRipped
        
        Write-Verbose "DateRipped = $([HomeVideo_DVD]::StringToDatetime($XML.HomeVideoLibrary.HomeVideoDVD.DateRipped))"
        $this.DateRipped = [HomeVideo_DVD]::StringToDatetime($XML.HomeVideoLibrary.HomeVideoDVD.DateRipped)
        
        return $this
    }

    #HomeVideo_DVD(){}

    HomeVideo_DVD([string]$DVDLab, [string]$DateBurn, [string]$DateRip, [datetime]$DateBurnDT, [datetime]$DateRipDT){
        $this.DVDLabel = $DVDLab

        $this.DateBurnedString = $DateBurn
        $this.DateRippedString = $DateRip

        $this.DateBurned = $DateBurnDT
        $this.DateRipped = $DateRipDT

    }

    HomeVideo_DVD([string]$DVDLab, [string]$DateBurn, [string]$DateRip){
        $this.DVDLabel = $DVDLab

        $this.DateBurnedString = $DateBurn
        $this.DateRippedString = $DateRip

        $this.DateBurned = [HomeVideo_DVD]::StringToDatetime($this.DateBurnedString)
        $this.DateRipped = [HomeVideo_DVD]::StringToDatetime($this.DateRippedString)
    }

    HomeVideo_DVD([string]$DVDLab, [datetime]$DateBurnDT, [datetime]$DateRipDT){
        $this.DVDLabel = $DVDLab

        $this.DateBurned = $DateBurnDT
        $this.DateRipped = $DateRipDT

        $this.DateBurnedString = [HomeVideo_DVD]::DateToString($this.DateBurnedDT)
        $this.DateRippedString = [HomeVideo_DVD]::DateToString($this.DateRippedDT)
    }

    HomeVideo_DVD([XML]$XML){
        $this.SetParamsFromXMLValues($XML)

        $XML.HomeVideoLibrary.HomeVideoDVD.DVDChapters.DVDChapter | ForEach-Object{ 
            $this.AddDVDChapter([HomeVideo_Chapter]::new($_)) 
        }
        $this.DVDChapters = $this.DVDChapters | Sort-Object -Property ChapterNumber
    }

    HomeVideo_DVD([string]$PDFFormPath){
        $PDFForm = [PDFForm]::new($PDFFormPath)
        $this.DVDLabel = $PDFForm.ChapterNumber

        $NewDVDChapter = [HomeVideo_Chapter]::new($PDFForm.ChapterNumber)
        $NewDVDChapter.AddClipFromPDF($PDFForm.ClipForm1)
        $NewDVDChapter.AddClipFromPDF($PDFForm.ClipForm2)

        $this.AddDVDChapter($NewDVDChapter)

    }

    [xml]ToXML(){
        $HomeVideoDVDXML = [HomeVideo_DVD]::HomeDVDXML.Clone()

        if($this.DVDLabel){ $HomeVideoDVDXML.HomeVideoLibrary.HomeVideoDVD.DVDLabel = $this.DVDLabel }
        
        if($this.DateBurnedString){ $HomeVideoDVDXML.HomeVideoLibrary.HomeVideoDVD.DateBurned = $this.DateBurnedString }
        elseif ($this.DateBurned) {
            $this.DateBurnedString = [HomeVideo_DVD]::DateToString($this.DateBurned)
            $HomeVideoDVDXML.HomeVideoLibrary.HomeVideoDVD.DateBurned = $this.DateBurnedString
        }

        if($this.DateRippedString){ $HomeVideoDVDXML.HomeVideoLibrary.HomeVideoDVD.DateRipped = $this.DateRippedString }
        elseif ($this.DateRipped) {
            $this.DateRippedString = [HomeVideo_DVD]::DateToString($this.DateRipped)
            $HomeVideoDVDXML.HomeVideoLibrary.HomeVideoDVD.DateRipped = $this.DateRippedString
        }
        
        if($this.DVDChapters){
            $this.DVDChapters | ForEach-Object{
                $node = $_.ToXML($HomeVideoDVDXML).DVDChapter
                $newChapter = $HomeVideoDVDXML.ImportNode($node, $true)
                $DVDChapters = $HomeVideoDVDXML.HomeVideoLibrary.HomeVideoDVD.ChildNodes[2]
                $DVDChapters.AppendChild($newChapter)
            }
        }

        return $HomeVideoDVDXML
    }
}