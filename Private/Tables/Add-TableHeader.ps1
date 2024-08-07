﻿function Add-TableHeader {
    <#
    .SYNOPSIS
    Adds table headers to a table with specified styles and responsive operations.

    .DESCRIPTION
    The Add-TableHeader function adds table headers to a table based on the provided HeaderRows, HeaderStyle, HeaderTop, HeaderResponsiveOperations, and HeaderNames parameters. It prepares styles for merged headers, standard header rows, and responsive operations.

    .PARAMETER HeaderRows
    Specifies the list of custom objects representing header rows.

    .PARAMETER HeaderStyle
    Specifies the list of custom objects representing header styles.

    .PARAMETER HeaderTop
    Specifies the list of custom objects representing top headers.

    .PARAMETER HeaderResponsiveOperations
    Specifies the list of custom objects representing responsive operations for headers.

    .PARAMETER HeaderNames
    Specifies an array of header names.

    .EXAMPLE
    Add-TableHeader -HeaderRows $headerRows -HeaderStyle $headerStyle -HeaderTop $headerTop -HeaderResponsiveOperations $responsiveOps -HeaderNames @("Name", "Age", "Location")
    Adds table headers with specified styles and responsive operations for the given header rows.

    .EXAMPLE
    $headerRows = @(
        [PSCustomObject]@{ Names = @("Name", "Age"); Title = "Personal Info"; Style = "Bold" },
        [PSCustomObject]@{ Names = @("Location"); Title = "Address"; Style = "Italic" }
    )
    $headerStyle = @(
        [PSCustomObject]@{ Names = @("Name", "Age"); Style = "Bold" },
        [PSCustomObject]@{ Names = @("Location"); Style = "Italic" }
    )
    $headerTop = @(
        [PSCustomObject]@{ Names = @("Name", "Age"); Top = "True" },
        [PSCustomObject]@{ Names = @("Location"); Top = "False" }
    )
    $responsiveOps = @(
        [PSCustomObject]@{ Names = @("Name", "Age"); ResponsiveOperations = "Collapse" },
        [PSCustomObject]@{ Names = @("Location"); ResponsiveOperations = "Hide" }
    )
    Add-TableHeader -HeaderRows $headerRows -HeaderStyle $headerStyle -HeaderTop $headerTop -HeaderResponsiveOperations $responsiveOps -HeaderNames @("Name", "Age", "Location")
    Adds table headers with specified styles and responsive operations using sample data.

    #>
    [CmdletBinding()]
    param(
        [System.Collections.Generic.List[PSCustomObject]] $HeaderRows,
        [System.Collections.Generic.List[PSCUstomObject]] $HeaderStyle,
        [System.Collections.Generic.List[PSCUstomObject]] $HeaderTop,
        [System.Collections.Generic.List[PSCUstomObject]] $HeaderResponsiveOperations,
        [string[]] $HeaderNames
    )
    if ($HeaderRows.Count -eq 0 -and $HeaderStyle.Count -eq 0 -and $HeaderTop.Count -eq 0 -and $HeaderResponsiveOperations.Count -eq 0) {
        return
    }

    # Prepares for styles to merged headers
    [Array] $MergeColumns = foreach ($Row in $HeaderRows) {
        $Index = foreach ($R in $Row.Names) {
            [array]::indexof($HeaderNames.ToUpper(), $R.ToUpper())
        }
        if ($Index -contains -1) {
            Write-Warning -Message "Table Header can't be processed properly. Names on the list to merge were not found in Table Header."
        } else {
            @{
                Index = $Index
                Title = $Row.Title
                Count = $Index.Count
                Style = $Row.Style
                Used  = $false
            }
        }
    }

    $ResponsiveOperations = @{ }
    foreach ($Row in $HeaderResponsiveOperations) {
        foreach ($_ in $Row.Names) {
            $Index = [array]::indexof($HeaderNames.ToUpper(), $_.ToUpper())
            $ResponsiveOperations[$Index] = @{
                Index                = $Index
                ResponsiveOperations = $Row.ResponsiveOperations
                Used                 = $false
            }
        }
    }

    # Prepares for styles to standard header rows
    $Styles = @{ }
    foreach ($Row in $HeaderStyle) {
        foreach ($_ in $Row.Names) {
            $Index = [array]::indexof($HeaderNames.ToUpper(), $_.ToUpper())
            $Styles[$Index] = @{
                Index = $Index
                Title = $Row.Title
                Count = $Index.Count
                Style = $Row.Style
                Used  = $false
            }
        }
    }


    if ($HeaderTop.Count -gt 0) {
        $UsedColumns = 0
        $ColumnsTotal = $HeaderNames.Count
        $TopHeader = New-HTMLTag -Tag 'tr' {
            foreach ($_ in $HeaderTop) {
                if ($_.ColumnCount -eq 0) {
                    $UsedColumns = $ColumnsTotal - $UsedColumns
                    New-HTMLTag -Tag 'th' -Attributes @{ colspan = $UsedColumns; style = ($_.Style) } -Value { $_.Title }
                } else {
                    if ($_.ColumnCount -le $ColumnsTotal) {
                        $UsedColumns = $UsedColumns + $_.ColumnCount
                    } else {
                        $UsedColumns = - ($ColumnsTotal - $_.ColumnCount)
                    }
                    New-HTMLTag -Tag 'th' -Attributes @{ colspan = $_.ColumnCount; style = ($_.Style) } -Value { $_.Title }
                }

            }
        }
    }


    $AddedHeader = @(
        $NewHeader = [System.Collections.Generic.List[string]]::new()
        $TopHeader
        New-HTMLTag -Tag 'tr' {
            for ($i = 0; $i -lt $HeaderNames.Count; $i++) {
                $Found = $false
                foreach ($_ in $MergeColumns) {
                    if ($_.Index -contains $i) {
                        if ($_.Used -eq $false) {
                            New-HTMLTag -Tag 'th' -Attributes @{ colspan = $_.Count; style = ($_.Style); class = $ResponsiveOperations[$i] } -Value { $_.Title }
                            $_.Used = $true
                            $Found = $true
                        } else {
                            $Found = $true
                            # Do Nothing
                        }
                    }
                }
                if (-not $Found) {
                    if ($MergeColumns.Count -eq 0) {
                        # if there are no columns that are supposed to get a Title (merged Title over 2 or more columns) we remove rowspan completly and just apply style
                        # the style will apply, however if Style will be empty it will be removed by New-HTMLTag function
                        New-HTMLTag -Tag 'th' { $HeaderNames[$i] } -Attributes @{ style = $Styles[$i].Style; class = $ResponsiveOperations[$i].ResponsiveOperations }
                    } else {
                        # Since we're adding Title we need to use Rowspan. Rowspan = 2 means spaning row over 2 rows
                        New-HTMLTag -Tag 'th' { $HeaderNames[$i] } -Attributes @{ rowspan = 2; style = $Styles[$i].Style; class = $ResponsiveOperations[$i].ResponsiveOperations }
                    }
                } else {
                    $Head = New-HTMLTag -Tag 'th' { $HeaderNames[$i] } -Attributes @{ style = $Styles[$i].Style; class = $ResponsiveOperations[$i].ResponsiveOperations }
                    $NewHeader.Add($Head)
                }
            }
        }
        if ($NewHeader.Count) {
            New-HTMLTag -Tag 'tr' {
                $NewHeader
            }
        }
    )
    return $AddedHeader
}