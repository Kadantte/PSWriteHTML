﻿function New-HTMLChart {
    <#
    .SYNOPSIS
    Creates a new HTML chart with customizable settings.

    .DESCRIPTION
    This function creates a new HTML chart with customizable settings such as title, subtitle, dimensions, colors, and more.

    .PARAMETER ChartSettings
    Specifies the settings for the chart. This should be a ScriptBlock containing the chart configuration.

    .PARAMETER Title
    Specifies the title of the chart.

    .PARAMETER TitleAlignment
    Specifies the alignment of the chart title. Valid values are 'center', 'left', or 'right'.

    .PARAMETER TitleMargin
    Specifies the margin of the chart title.

    .PARAMETER TitleOffsetX
    Specifies the horizontal offset of the chart title.

    .PARAMETER TitleOffsetY
    Specifies the vertical offset of the chart title.

    .PARAMETER TitleFloating
    Specifies whether the chart title should float.

    .PARAMETER TitleFontSize
    Specifies the font size of the chart title.

    .PARAMETER TitleFontWeight
    Specifies the font weight of the chart title. Valid values are 'normal', 'bold', 'bolder', 'lighter', or numeric values from '100' to '900'.

    .PARAMETER TitleFontFamily
    Specifies the font family of the chart title.

    .PARAMETER TitleColor
    Specifies the color of the chart title.

    .PARAMETER SubTitle
    Specifies the subtitle of the chart.

    .PARAMETER SubTitleAlignment
    Specifies the alignment of the chart subtitle. Valid values are 'center', 'left', or 'right'.

    .PARAMETER SubTitleMargin
    Specifies the margin of the chart subtitle.

    .PARAMETER SubTitleOffsetX
    Specifies the horizontal offset of the chart subtitle.

    .PARAMETER SubTitleOffsetY
    Specifies the vertical offset of the chart subtitle.

    .PARAMETER SubTitleFloating
    Specifies whether the chart subtitle should float.

    .PARAMETER SubTitleFontSize
    Specifies the font size of the chart subtitle.

    .PARAMETER SubTitleFontWeight
    Specifies the font weight of the chart subtitle. Valid values are 'normal', 'bold', 'bolder', 'lighter', or numeric values from '100' to '900'.

    .PARAMETER SubTitleFontFamily
    Specifies the font family of the chart subtitle.

    .PARAMETER SubTitleColor
    Specifies the color of the chart subtitle.

    .PARAMETER Height
    Specifies the height of the chart. Default is 350.

    .PARAMETER Width
    Specifies the width of the chart.

    .PARAMETER Gradient
    Indicates whether to use gradient colors in the chart.

    .PARAMETER Patterned
    Indicates whether to use patterned colors in the chart.

    .PARAMETER Id
    Specifies the ID of the chart. If not provided, a random ID will be generated.

    .PARAMETER Group
    Specifies the group to which the chart belongs.

    .EXAMPLE
    New-HTMLChart -Title "Sales Data" -ChartSettings {
        // Chart configuration settings here
    }

    Creates a new HTML chart with the title "Sales Data" and custom chart settings.

    .EXAMPLE
    New-HTMLChart -Title "Sales Data" -SubTitle "Quarterly Sales" -Height 400 -Width 600 -Gradient -Id "SalesChart"

    Creates a new HTML chart with the title "Sales Data", subtitle "Quarterly Sales", height of 400, width of 600, gradient colors, and specified ID.

    #>
    [alias('Chart')]
    [CmdletBinding()]
    param(
        [ScriptBlock] $ChartSettings,
        [string] $Title,
        [ValidateSet('center', 'left', 'right')][string] $TitleAlignment,
        [nullable[int]] $TitleMargin,
        [nullable[int]] $TitleOffsetX,
        [nullable[int]] $TitleOffsetY,
        [nullable[int]] $TitleFloating,
        [object] $TitleFontSize,
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $TitleFontWeight,
        [string] $TitleFontFamily,
        [string] $TitleColor,

        [string] $SubTitle,
        [ValidateSet('center', 'left', 'right')][string] $SubTitleAlignment,
        [nullable[int]] $SubTitleMargin,
        [nullable[int]] $SubTitleOffsetX,
        [nullable[int]] $SubTitleOffsetY,
        [nullable[int]] $SubTitleFloating,
        [object] $SubTitleFontSize,
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $SubTitleFontWeight,
        [string] $SubTitleFontFamily,
        [string] $SubTitleColor,

        [Object] $Height = 350,
        [Object] $Width,
        [alias('GradientColors')][switch] $Gradient,
        [alias('PatternedColors')][switch] $Patterned,
        [string] $Id,
        [string] $Group
    )
    $Theme = $null
    $Events = $null
    $Script:HTMLSchema.Features.MainFlex = $true

    if (-not $Id) {
        $Id = "ChartID-" + (Get-RandomStringName -Size 8)
    }

    $Chart = [ordered] @{
        id     = $Id
        group  = $Group
        height = ConvertFrom-Size -Size $Height
        width  = ConvertFrom-Size -Size $Width
    }

    # Lets build Title Block
    $TitleBlock = @{
        text     = $Title
        align    = $TitleAlignment
        margin   = $TitleMargin
        offsetX  = $TitleOffsetX
        offsetY  = $TitleOffsetY
        floating = $TitleFloating
        style    = @{
            fontSize   = ConvertFrom-Size -Size $TitleFontSize
            fontWeight = $TitleFontWeight
            fontFamily = $TitleFontFamily
            color      = ConvertFrom-Color -Color $TitleColor
        }
    }
    Remove-EmptyValue -Hashtable $TitleBlock -Recursive -Rerun 2

    # Lets build SubTitle Block
    $SubTitleBlock = @{
        text     = $SubTitle
        align    = $SubTitleAlignment
        margin   = $SubTitleMargin
        offsetX  = $SubTitleOffsetX
        offsetY  = $SubTitleOffsetY
        floating = $SubTitleFloating
        style    = @{
            fontSize   = ConvertFrom-Size -Size $SubTitleFontSize
            fontWeight = $SubTitleFontWeight
            fontFamily = $SubTitleFontFamily
            color      = ConvertFrom-Color -Color $SubTitleColor
        }
    }
    Remove-EmptyValue -Hashtable $SubTitleBlock -Recursive -Rerun 2

    # defaults
    $DataLabel = [ordered] @{
        enabled = $true
    }
    $Markers = [ordered] @{}

    # Datasets Bar/Line
    $DataSet = [System.Collections.Generic.List[object]]::new()
    $DataName = [System.Collections.Generic.List[object]]::new()

    $DataSeries = [System.Collections.Generic.List[System.Collections.IDictionary]]::new()
    $LineStroke = [System.Collections.Generic.List[System.Collections.IDictionary]]::new()
    $DataSetChartTimeLine = [System.Collections.Generic.List[PSCustomObject]]::new()

    # Legend Variables
    $Colors = [System.Collections.Generic.List[string]]::new()

    $ChartAxisY = [System.Collections.Generic.List[System.Collections.IDictionary]]::new()

    # Bar default definitions
    [bool] $BarHorizontal = $true
    [bool] $BarDataLabelsEnabled = $true
    [int] $BarDataLabelsOffsetX = -6
    [string] $BarDataLabelsFontSize = '12px'
    [bool] $BarDistributed = $false

    [string] $Type = ''

    # Reading all charts definitions and converting them to proper entries
    [Array] $Settings = & $ChartSettings
    foreach ($Setting in $Settings) {
        if ($Setting.ObjectType -eq 'Bar') {
            # For Bar Charts
            if (-not $Type) {
                # this makes sure type is not set if BarOptions is used which already set type to BarStacked or similar
                $Type = $Setting.ObjectType
            }
            $DataSet.Add($Setting.Value)
            $DataName.Add($Setting.Name)
            $DataSeries.Add($Setting.series)

            if ($Setting.Color) {
                $Setting.Color | ForEach-Object {
                    $Colors.Add($_)
                }
            }

        } elseif ($Setting.ObjectType -eq 'Pie' -or $Setting.ObjectType -eq 'Donut') {
            # For Pie Charts
            $Type = $Setting.ObjectType
            $DataSet.Add($Setting.Value)
            $DataName.Add($Setting.Name)

            if ($Setting.Color) {
                $Setting.Color | ForEach-Object {
                    $Colors.Add($_)
                }
            }
        } elseif ($Setting.ObjectType -eq 'Spark') {
            # For Spark Charts
            $Type = $Setting.ObjectType
            $DataSet.Add(
                [ordered] @{
                    Name   = $Setting.Name
                    Values = $Setting.Value
                }
            )
            if ($Setting.Color) {
                $Setting.Color | ForEach-Object {
                    $Colors.Add($_)
                }
            }
        } elseif ($Setting.ObjectType -eq 'Radial') {
            $Type = $Setting.ObjectType
            $DataSet.Add($Setting.Value)
            $DataName.Add($Setting.Name)

            if ($Setting.Color) {
                $Setting.Color | ForEach-Object {
                    $Colors.Add($_)
                }
            }
        } elseif ($Setting.ObjectType -eq 'Legend') {
            # For Bar Charts
            $DataLegend = $Setting.Names
            if ($null -ne $Setting.Color) {
                $Setting.Color | ForEach-Object {
                    $Colors.Add($_)
                }
            }
            $Legend = $Setting.Legend
        } elseif ($Setting.ObjectType -eq 'BarOptions') {
            # For Bar Charts
            $Type = $Setting.Type
            $BarHorizontal = $Setting.Horizontal
            $BarDataLabelsEnabled = $Setting.DataLabelsEnabled
            $BarDataLabelsOffsetX = $Setting.DataLabelsOffsetX
            $BarDataLabelsFontSize = $Setting.DataLabelsFontSize
            $BarDataLabelsColor = $Setting.DataLabelsColor
            $BarDistributed = $Setting.Distributed

            # This is required to support legacy ChartBarOptions - Gradient -Patterned
            if ($null -ne $Setting.PatternedColors) {
                $Patterned = $Setting.PatternedColors
            }
            if ($null -ne $Setting.GradientColors) {
                $Gradient = $Setting.GradientColors
            }
        } elseif ($Setting.ObjectType -eq 'Toolbar') {
            # For All Charts
            $Toolbar = $Setting.Toolbar
        } elseif ($Setting.ObjectType -eq 'Theme') {
            # For All Charts
            $Theme = $Setting.Theme
        } elseif ($Setting.ObjectType -eq 'Marker') {
            # For All Charts
            $Markers = $Setting.markers
        } elseif ($Setting.ObjectType -eq 'Line') {
            # For Line Charts
            $Type = $Setting.ObjectType

            if ($Setting.series) {
                $DataSeries.Add($Setting.series)
            }
            if ($Setting.stroke.count -gt 0) {
                $LineStroke.Add($setting.stroke)
            }
            if ($Setting.Color) {
                $Colors.Add($Setting.Color)
            }
        } elseif ($Setting.ObjectType -eq 'ChartAxisX') {
            $ChartAxisX = $Setting.ChartAxisX
        } elseif ($Setting.ObjectType -eq 'ChartGrid') {
            $GridOptions = $Setting.Grid
        } elseif ($Setting.ObjectType -eq 'ChartAxisY') {
            $ChartAxisY.Add($Setting.ChartAxisY)
        } elseif ($Setting.ObjectType -eq 'TimeLine') {
            $Type = 'rangeBar'
            $DataSetChartTimeLine.Add($Setting.TimeLine)
        } elseif ($Setting.ObjectType -eq 'ChartToolTip') {
            $ChartToolTip = $Setting.ChartToolTip
        } elseif ($Setting.ObjectType -eq 'DataLabel') {
            $DataLabel = $Setting.DataLabel
        } elseif ($Setting.ObjectType -eq 'ChartEvents') {
            $Events = $Setting.Event
        } elseif ($Setting.ObjectType -eq 'RadialOptions') {
            $PlotOptions = $Setting.plotOptions
        } elseif ($Setting.ObjectType -eq 'Fill') {
            $Design = $Setting.Design
        }
    }

    if ($Type -in @('bar', 'barStacked', 'barStacked100Percent')) {
        #if ($DataLegend.Count -lt $DataSet[0].Count) {
        #    Write-Warning -Message "Chart Legend count doesn't match values count. Skipping."
        #}
        # Fixes dataset/dataname to format expected by New-HTMLChartBar
        $HashTable = [ordered] @{ }
        $ArrayCount = $DataSet[0].Count
        if ($ArrayCount -eq 1) {
            $HashTable.1 = $DataSet
        } else {
            for ($i = 0; $i -lt $ArrayCount; $i++) {
                $HashTable.$i = [System.Collections.Generic.List[object]]::new()
            }
            foreach ($Value in $DataSet) {
                for ($h = 0; $h -lt $Value.Count; $h++) {
                    $HashTable[$h].Add($Value[$h])
                }
            }
        }

        $SplatChart = [ordered] @{
            Data               = $($HashTable.Values)
            DataNames          = $DataName
            Colors             = $Colors
            DataLegend         = $DataLegend

            Type               = $Type
            Horizontal         = $BarHorizontal
            DataLabelsEnabled  = $BarDataLabelsEnabled
            DataLabelsOffsetX  = $BarDataLabelsOffsetX
            DataLabelsFontSize = $BarDataLabelsFontSize
            Distributed        = $BarDistributed
            DataLabelsColor    = $BarDataLabelsColor
            ChartAxisX         = $ChartAxisX
            ChartAxisY         = $ChartAxisY

            # Every the same
            Legend             = $Legend
            Chart              = $Chart
            Theme              = $Theme
            Toolbar            = $Toolbar
            GridOptions        = $GridOptions
            PatternedColors    = $Patterned
            GradientColors     = $Gradient
            Events             = $Events
            Title              = $TitleBlock
            SubTitle           = $SubTitleBlock
            Design             = $Design
        }

        New-HTMLChartBar @SplatChart

    } elseif ($Type -eq 'Line') {
        if (-not $ChartAxisX) {
            Write-Warning -Message 'Chart Category (Chart Axis X) is missing.'
            return
        }
        $SplatChartLine = @{
            Chart           = $Chart
            Series          = $DataSeries
            Stroke          = $LineStroke
            DataLabel       = $DataLabel
            Legend          = $Legend
            Markers         = $Markers
            Colors          = $Colors
            #DataLabelsEnabled  = $BarDataLabelsEnabled
            #DataLabelsOffsetX  = $BarDataLabelsOffsetX
            #DataLabelsFontSize = $BarDataLabelsFontSize
            #DataLabelsColor    = $BarDataLabelsColor
            ChartAxisX      = $ChartAxisX
            ChartAxisY      = $ChartAxisY
            #Height          = $Height
            #Width           = $Width
            Theme           = $Theme
            Toolbar         = $Toolbar
            GridOptions     = $GridOptions
            PatternedColors = $Patterned
            GradientColors  = $Gradient
            Events          = $Events
            Title           = $TitleBlock
            SubTitle        = $SubTitleBlock
            Design          = $Design
        }
        New-HTMLChartLine @SplatChartLine
    } elseif ($Type -eq 'Pie' -or $Type -eq 'Donut') {
        $SplatChart = @{
            Data            = $DataSet
            DataNames       = $DataName
            Colors          = $Colors

            # Every the same
            Legend          = $Legend
            Chart           = $Chart
            Theme           = $Theme
            Toolbar         = $Toolbar
            GridOptions     = $GridOptions
            PatternedColors = $Patterned
            GradientColors  = $Gradient
            Events          = $Events
            Title           = $TitleBlock
            SubTitle        = $SubTitleBlock
            Design          = $Design
        }

        New-HTMLChartPie @SplatChart -Type $Type
    } elseif ($Type -eq 'Spark') {
        $SplatChart = @{
            Data            = $DataSet
            #DataNames       = $DataName
            Colors          = $Colors

            ChartAxisX      = $ChartAxisX

            # Every the same
            Legend          = $Legend
            Chart           = $Chart
            Theme           = $Theme
            Toolbar         = $Toolbar
            GridOptions     = $GridOptions
            PatternedColors = $Patterned
            GradientColors  = $Gradient
            Events          = $Events
            Title           = $TitleBlock
            SubTitle        = $SubTitleBlock
            Design          = $Design
        }
        New-HTMLChartSpark @SplatChart
    } elseif ($Type -eq 'Radial') {
        $SplatChart = @{
            Data            = $DataSet
            DataNames       = $DataName
            Colors          = $Colors

            PlotOptions     = $PlotOptions
            # Every the same
            Legend          = $Legend
            Chart           = $Chart
            Theme           = $Theme
            Toolbar         = $Toolbar
            GridOptions     = $GridOptions
            PatternedColors = $Patterned
            GradientColors  = $Gradient
            Events          = $Events
            Title           = $TitleBlock
            SubTitle        = $SubTitleBlock
            Design          = $Design
        }
        New-HTMLChartRadial @SplatChart
    } elseif ($Type -eq 'rangeBar') {
        $SplatChart = @{
            Data            = $DataSetChartTimeLine
            ChartAxisX      = $ChartAxisX
            ChartAxisY      = $ChartAxisY
            ChartToolTip    = $ChartToolTip

            # Every the same
            Legend          = $Legend
            Chart           = $Chart
            Theme           = $Theme
            Toolbar         = $Toolbar
            GridOptions     = $GridOptions
            PatternedColors = $Patterned
            GradientColors  = $Gradient
            Events          = $Events
            Title           = $TitleBlock
            SubTitle        = $SubTitleBlock
            Design          = $Design
        }
        New-HTMLChartTimeLine @SplatChart
    }
}

Register-ArgumentCompleter -CommandName New-HTMLChart -ParameterName TitleColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLChart -ParameterName SubTitleColor -ScriptBlock $Script:ScriptBlockColors