@{
    # Script module or binary module file associated with this manifest.
    ModuleToProcess = 'PSHomeVideoProject.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0.0'

    # ID used to uniquely identify this module
    GUID = 'f5f40d8e-00f8-4795-ab06-1a5a09dea9a3'

    # Author of this module
    Author = 'Drew Westgate'

    # Copyright statement for this module
    Copyright = ''

    # Description of the functionality provided by this module
    Description = 'Collection of functions and classes for the Westgate home video transfer project'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'

    # Functions to export from this module
    FunctionsToExport = @(
        "Get-ClipStartTime",
        "Get-ClipEndTime",
        "Convert-PTSToTimeStamp",
        "Get-VideoDuration",
        #"Split-ChaptersIntoClips",
        "Convert-PTSToSecondsString",
        "Get-ffmpegSceneChanges",
        "Convert-Times",
        "New-PDFWorksheetsFromClips",
        "New-TSPairsCSV",
        "New-PDFsFromScenes",
        "New-FrameImage",
        "New-PDFsFromXML",
        "Export-ClipsFromHomeVideoChapter"
    )

    # Cmdlets to export from this module
    CmdletsToExport = @(
        "Get-ClipStartTime",
        "Get-ClipEndTime",
        "Convert-PTSToTimeStamp",
        "Get-VideoDuration",
        #"Split-ChaptersIntoClips",
        #"Convert-PTSToSecondsString",
        "Get-ffmpegSceneChanges",
        #"Convert-Times",
        "New-PDFWorksheetsFromClips",
        "New-TSPairsCSV"
        #"New-PDFsFromScenes",
        #"New-FrameImage"
        "Export-ClipsFromHomeVideoChapter"
    )

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess.
    # This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{}

    NestedModules = @("Classes\PDFForm.psm1", "Classes\HomeVideo.psm1")
}
