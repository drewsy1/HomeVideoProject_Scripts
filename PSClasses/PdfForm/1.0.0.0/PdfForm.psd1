@{

# Script module or binary module file associated with this manifest.
ModuleToProcess = 'PdfForm.psm1'

# Version number of this module.
ModuleVersion = '1.0.0.0'

# ID used to uniquely identify this module
GUID = 'b88716ec-8865-4539-96f6-a81b0eb34110'

# Author of this module
Author = 'adbertram'

# Copyright statement for this module
Copyright = ''

# Description of the functionality provided by this module
Description = ''

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Functions to export from this module
FunctionsToExport = @(
    'Find-ITextSharpLibrary',
    'Get-PdfFieldNames',
    'Save-PdfField'
)

RequiredAssemblies = @('itextsharp.dll')

# Cmdlets to export from this module
CmdletsToExport = @(*)

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module
AliasesToExport = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess.
# This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{}

}
