function EmailBody {
    <#
    .SYNOPSIS
    Defines styling properties for an email body content.

    .DESCRIPTION
    This function defines styling properties for an email body content such as color, background color, font size, font weight, font style, font family, alignment, text decoration, text transform, direction, and more.

    .PARAMETER EmailBody
    Specifies the ScriptBlock containing the email body content.

    .PARAMETER Color
    Specifies the color of the text in the email body.

    .PARAMETER BackGroundColor
    Specifies the background color of the email body.

    .PARAMETER LineHeight
    Specifies the line height of the text in the email body.

    .PARAMETER Size
    Specifies the font size of the text in the email body.

    .PARAMETER FontWeight
    Specifies the weight of the font in the email body. Valid values are 'normal', 'bold', 'bolder', 'lighter', or numeric values from 100 to 900.

    .PARAMETER FontStyle
    Specifies the style of the font in the email body. Valid values are 'normal', 'italic', or 'oblique'.

    .PARAMETER FontVariant
    Specifies the variant of the font in the email body. Valid values are 'normal' or 'small-caps'.

    .PARAMETER FontFamily
    Specifies the font family of the text in the email body.

    .PARAMETER Alignment
    Specifies the alignment of the text in the email body. Valid values are 'left', 'center', 'right', or 'justify'.

    .PARAMETER TextDecoration
    Specifies the decoration of the text in the email body. Valid values are 'none', 'line-through', 'overline', or 'underline'.

    .PARAMETER TextTransform
    Specifies the transformation of the text in the email body. Valid values are 'uppercase', 'lowercase', or 'capitalize'.

    .PARAMETER Direction
    Specifies the direction of the text in the email body. Valid value is 'rtl'.

    .PARAMETER Online
    Switch parameter to indicate if the email body content is online.

    .PARAMETER Format
    Switch parameter to format the email body content.

    .PARAMETER Minify
    Switch parameter to minify the email body content.

    .PARAMETER Parameter
    Specifies additional parameters for styling the email body content.

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0)][ScriptBlock] $EmailBody,
        [string] $Color,
        [string] $BackGroundColor,
        [string] $LineHeight,
        [alias('Size')][object] $FontSize,
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $FontWeight,
        [ValidateSet('normal', 'italic', 'oblique')][string] $FontStyle,
        [ValidateSet('normal', 'small-caps')][string] $FontVariant,
        [string] $FontFamily ,
        [ValidateSet('left', 'center', 'right', 'justify')][string] $Alignment,
        [ValidateSet('none', 'line-through', 'overline', 'underline')][string] $TextDecoration,
        [ValidateSet('uppercase', 'lowercase', 'capitalize')][string] $TextTransform,
        [ValidateSet('rtl')][string] $Direction,
        [switch] $Online,
        [switch] $Format,
        [switch] $Minify,
        [System.Collections.IDictionary] $Parameter
    )

    $newHTMLSplat = @{}
    $newTableSplat = @{}
    if ($Alignment) {
        $newHTMLSplat.Alignment = $Alignment
        $newTableSplat.'text-align' = $Alignment
    }
    if ($FontSize) {
        $newHTMLSplat.FontSize = $FontSize
        $newTableSplat.'font-size' = ConvertFrom-Size -FontSize $FontSize
    }
    if ($TextTransform) {
        $newHTMLSplat.TextTransform = $TextTransform
        $newTableSplat.'text-transform' = $TextTransform
    }
    if ($Color) {
        $newHTMLSplat.Color = $Color
        $newTableSplat.'text-color' = ConvertFrom-Color -Color $Color
    }
    if ($FontFamily) {
        $newHTMLSplat.FontFamily = $FontFamily
        $newTableSplat.'font-family' = $FontFamily
    }
    if ($Direction) {
        $newHTMLSplat.Direction = $Direction
        $newTableSplat.'direction' = $Direction
    }
    if ($FontStyle) {
        $newHTMLSplat.FontStyle = $FontStyle
        $newTableSplat.'font-style' = $FontStyle
    }
    if ($TextDecoration) {
        $newHTMLSplat.TextDecoration = $TextDecoration
        $newTableSplat.'text-decoration' = $TextDecoration
    }
    if ($BackGroundColor) {
        $newHTMLSplat.BackGroundColor = $BackGroundColor
        $newTableSplat.'background-color' = ConvertFrom-Color -Color $BackGroundColor
    }
    if ($FontVariant) {
        $newHTMLSplat.FontVariant = $FontVariant
        $newTableSplat.'font-variant' = $FontVariant
    }
    if ($FontWeight) {
        $newHTMLSplat.FontWeight = $FontWeight
        $newTableSplat.'font-weight' = $FontWeight
    }
    if ($LineHeight) {
        $newHTMLSplat.LineHeight = $LineHeight
        $newTableSplat.'line-height' = $LineHeight
    }
    if ($newHTMLSplat.Count -gt 0) {
        $SpanRequired = $true
    } else {
        $SpanRequired = $false
    }
    # This is used if Email is used and someone would set Online switch there.
    # Since we moved New-HTML here - we need to do some workaround
    if (-not $Online) {
        if ($Script:EmailSchema -and $Script:EmailSchema['Online']) {
            $HTMLOnline = $true
        } else {
            $HTMLOnline = $false
        }
    } else {
        $HTMLOnline = $true
    }


    $Body = New-HTML -Online:$HTMLOnline {
        # Email is special and we want margins to be 0px
        $Script:HTMLSchema['Email'] = $true
        #$Script:CurrentConfiguration['Features']['Main']['HeaderAlways']['CssInLine']['body']['margin'] = '0px'
        $Script:CurrentConfiguration['Features']['DefaultImage']['HeaderAlways']['CssInLine']['.logo']['margin'] = '0px'
        $Script:CurrentConfiguration['Features']['DefaultHeadings']['HeaderAlways']['CssInLine']['h1']['margin'] = '0px'
        $Script:CurrentConfiguration['Features']['DefaultHeadings']['HeaderAlways']['CssInLine']['h2']['margin'] = '0px'
        $Script:CurrentConfiguration['Features']['DefaultHeadings']['HeaderAlways']['CssInLine']['h3']['margin'] = '0px'
        $Script:CurrentConfiguration['Features']['DefaultHeadings']['HeaderAlways']['CssInLine']['h4']['margin'] = '0px'
        $Script:CurrentConfiguration['Features']['DefaultHeadings']['HeaderAlways']['CssInLine']['h5']['margin'] = '0px'
        $Script:CurrentConfiguration['Features']['DefaultHeadings']['HeaderAlways']['CssInLine']['h6']['margin'] = '0px'
        $Script:CurrentConfiguration['Features']['DefaultText']['HeaderAlways']['CssInLine']['.defaultText']['margin'] = '0px'
        $Script:CurrentConfiguration['Features']['DataTables']['HeaderAlways']['CssInLine']['div.dataTables_wrapper']['margin'] = '0px'
        $Script:CurrentConfiguration['Features']['DataTables']['HeaderAlways']['CssInLine']['div.dataTables_wrapper']['margin'] = '0px'

        # Since settings for table via span doesn't apply to tables we need to use direct method of changing CSS
        if ($newTableSplat) {
            foreach ($Key in $newTableSplat.Keys) {
                $Script:CurrentConfiguration['Features']['DataTablesEmail']['HeaderAlways']['CssInLine']['table'][$Key] = $newTableSplat[$Key]
            }
        }
        if ($Parameter) {
            # This is to support special case of executing external scriptblocks
            [Array] $ArrayParamerers = foreach ($Key in $Parameter.Keys) {
                if ($null -eq $Parameter[$Key]) {
                    , $null
                } else {
                    , $Parameter[$Key]
                }
            }
            $Template = Add-ParametersToScriptBlock -ScriptBlock $EmailBody -Parameter $Parameter
            if ($SpanRequired) {
                New-HTMLSpanStyle @newHTMLSplat {
                    Invoke-Command -ScriptBlock $Template -ArgumentList $ArrayParamerers
                }
            } else {
                Invoke-Command -ScriptBlock $Template -ArgumentList $ArrayParamerers
            }
        } else {
            if ($SpanRequired) {
                New-HTMLSpanStyle @newHTMLSplat {
                    Invoke-Command -ScriptBlock $EmailBody
                }
            } else {
                Invoke-Command -ScriptBlock $EmailBody
            }
        }
    } -Format:$Format -Minify:$Minify
    # This section makes sure that if any script is present in HTML it will be removed.
    # Our goal here is to make HTML in EMAIL as small as possible without added junk which won't be read anyways
    # https://docs.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.regexoptions?view=net-5.0
    $options = [Text.RegularExpressions.RegexOptions] 'Singleline,IgnoreCase' #, CultureInvariant'
    $OutputToCheck = [Regex]::Matches($Body, '(?<=<script)(.*?)(?=<\/script>)', $options) | Select-Object -ExpandProperty Value
    foreach ($Script in $OutputToCheck) {
        $Body = $Body.Replace("<script$Script</script>", '')
    }

    if ($Script:EmailSchema -and $Script:EmailSchema['AttachSelf']) {
        # if attach self is used we will generate better version with JS present, proper margins and so on
        $AttachSelfBody = New-HTML -Online:$HTMLOnline {
            if ($Parameter) {
                # This is to support special case of executing external scriptblocks
                [Array] $ArrayParamerers = foreach ($Key in $Parameter.Keys) {
                    , $Parameter[$Key]
                }
                $Template = Add-ParametersToScriptBlock -ScriptBlock $EmailBody -Parameter $Parameter
                if ($SpanRequired) {
                    New-HTMLSpanStyle @newHTMLSplat {
                        Invoke-Command -ScriptBlock $Template -ArgumentList $ArrayParamerers
                    }
                } else {
                    Invoke-Command -ScriptBlock $Template -ArgumentList $ArrayParamerers
                }
            } else {
                if ($SpanRequired) {
                    New-HTMLSpanStyle @newHTMLSplat {
                        Invoke-Command -ScriptBlock $EmailBody
                    }
                } else {
                    Invoke-Command -ScriptBlock $EmailBody
                }
            }
        } -Format:$Format -Minify:$Minify

        @{
            Body           = $Body
            AttachSelfBody = $AttachSelfBody
        }
    } else {
        # if attach self is not used we need only one version of code
        $Body
    }

}

Register-ArgumentCompleter -CommandName EmailBody -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName EmailBody -ParameterName BackgroundColor -ScriptBlock $Script:ScriptBlockColors