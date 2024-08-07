function New-HTMLDiagram {
    <#
    .SYNOPSIS
    Creates a new HTML diagram with customizable options.

    .DESCRIPTION
    This function creates a new HTML diagram with customizable options such as diagram data, height, width, image bundling, background image, background size, auto-resize, loading bar, filtering, and more.

    .PARAMETER Diagram
    Specifies the diagram data to be displayed. This should be a ScriptBlock containing the diagram configuration.

    .PARAMETER Height
    Specifies the height of the diagram.

    .PARAMETER Width
    Specifies the width of the diagram.

    .PARAMETER BundleImages
    Indicates whether to bundle images used in the diagram.

    .PARAMETER BackGroundImage
    Specifies the background image for the diagram.

    .PARAMETER BackgroundSize
    Specifies the size of the background image. Default is '100% 100%'.

    .PARAMETER NoAutoResize
    Indicates whether auto-resize functionality is disabled.

    .PARAMETER DisableLoader
    Indicates whether the loading bar should be disabled.

    .PARAMETER EnableFiltering
    Indicates whether filtering functionality is enabled.

    .PARAMETER MinimumFilteringChars
    Specifies the minimum number of characters required for filtering.

    .PARAMETER EnableFilteringButton
    Indicates whether a filtering button should be displayed.

    .EXAMPLE
    New-HTMLDiagram -Diagram {
        // Diagram configuration settings here
    } -Height 500 -Width 800 -BundleImages -BackGroundImage 'https://example.com/background.jpg' -BackgroundSize 'cover' -DisableLoader -EnableFiltering -MinimumFilteringChars 2 -EnableFilteringButton

    Creates a new HTML diagram with custom configuration settings including height, width, bundled images, background image, disabled loading bar, enabled filtering, and a filtering button.

    .EXAMPLE
    New-HTMLDiagram -Diagram {
        // More diagram configuration settings
    } -Height 600 -Width 1000

    Creates a new HTML diagram with additional configuration settings and default options for height and width.

    #>
    [alias('Diagram', 'New-Diagram')]
    [CmdletBinding()]
    param(
        [ScriptBlock] $Diagram,
        [object] $Height,
        [object] $Width,
        [switch] $BundleImages,
        [uri] $BackGroundImage,
        [string] $BackgroundSize = '100% 100%',
        [switch] $NoAutoResize, # Doesn't seem to do anything
        [alias('DisableLoadingBar')]
        [switch] $DisableLoader,
        [switch] $EnableFiltering,
        [int] $MinimumFilteringChars = 3,
        [switch] $EnableFilteringButton
    )
    if (-not $Script:HTMLSchema.Features) {
        Write-Warning 'New-HTMLDiagram - Creation of HTML aborted. Most likely New-HTML is missing.'
        Exit
    }
    $Script:HTMLSchema.Features.MainFlex = $true

    $DataEdges = [System.Collections.Generic.List[System.Collections.IDictionary]]::new()
    $DataNodes = [ordered] @{ }
    $DataEvents = [System.Collections.Generic.List[System.Collections.IDictionary]]::new()

    [Array] $Settings = & $Diagram
    foreach ($Node in $Settings) {
        if ($Node.Type -eq 'DiagramNode') {
            $ID = $Node.Settings['id']
            $DataNodes[$ID] = $Node.Settings
            #$DataEdges.Add($Node.Edges)
            foreach ($From in $Node.Edges.From) {
                foreach ($To in $Node.Edges.To) {
                    $Edge = Copy-Dictionary -Dictionary $Node.Edges  #$Node.Edges.Clone()
                    $Edge['from'] = $From
                    $Edge['to'] = $To
                    $DataEdges.Add($Edge)
                }
            }
        } elseif ($Node.Type -eq 'DiagramOptionsInteraction') {
            $DiagramOptionsInteraction = $Node.Settings
        } elseif ($Node.Type -eq 'DiagramOptionsManipulation') {
            $DiagramOptionsManipulation = $Node.Settings
        } elseif ($Node.Type -eq 'DiagramOptionsPhysics') {
            $DiagramOptionsPhysics = $Node.Settings
        } elseif ($Node.Type -eq 'DiagramOptionsLayout') {
            $DiagramOptionsLayout = $Node.Settings
        } elseif ($Node.Type -eq 'DiagramOptionsNodes') {
            $DiagramOptionsNodes = $Node.Settings
        } elseif ($Node.Type -eq 'DiagramOptionsEdges') {
            $DiagramOptionsEdges = $Node.Settings
        } elseif ($Node.Type -eq 'DiagramLink') {
            if ($Node.Settings.From -and $Node.Settings.To) {
                foreach ($From in $Node.Settings.From) {
                    foreach ($To in $Node.Settings.To) {
                        $Edge = $Node.Edges.Clone()
                        $Edge['from'] = $From
                        $Edge['to'] = $To
                        $DataEdges.Add($Edge)
                    }
                }
            }
            $DataEdges.Add($Node.Edges)
        } elseif ($Node.Type -eq 'DiagramEvent') {
            $DataEvents.Add($Node.Settings)
        }
    }
    <#
    {id: 14, shape: 'circularImage', image: DIR + '14.png'},
    {id: 15, shape: 'circularImage', image: DIR + 'missing.png', brokenImage: DIR + 'missingBrokenImage.png', label:"when images\nfail\nto load"},
    {id: 16, shape: 'circularImage', image: DIR + 'anotherMissing.png', brokenImage: DIR + '9.png', label:"fallback image in action"}
    {id: 5, label:'colorObject', color: {background:'pink', border:'purple'}},
    {id: 6, label:'colorObject + highlight', color: {background:'#F03967', border:'#713E7F',highlight:{background:'red',border:'black'}}},
    {id: 7, label:'colorObject + highlight + hover', color: {background:'cyan', border:'blue',highlight:{background:'red',border:'blue'},hover:{background:'white',border:'red'}}}
    {id: 1,label: 'User 1',group: 'users'},
    {id: 2,label: 'User 2',group: 'users'},
    {id: 3,label: 'Usergroup 1',group: 'usergroups'}
    nodes.push({id: 1, label: 'Main', image: DIR + 'Network-Pipe-icon.png', shape: 'image'});
    nodes.push({id: 2, label: 'Office', image: DIR + 'Network-Pipe-icon.png', shape: 'image'});
    nodes.push({id: 3, label: 'Wireless', image: DIR + 'Network-Pipe-icon.png', shape: 'image'});
    {id: 3,  shape: 'image', image: DIR + '3.png', label: "imagePadding{2,10,8,20}+size", imagePadding: { left: 2, top: 10, right: 8, bottom: 20}, size: 40, color: { border: 'green', background: 'yellow', highlight: { border: 'yellow', background: 'green' }, hover: { border: 'orange', background: 'grey' } } },
    {id: 9,  shape: 'image', image: DIR + '9.png', label: "useImageSize + imagePadding:15", shapeProperties: { useImageSize: true }, imagePadding: 30, color: { border: 'blue', background: 'orange', highlight: { border: 'orange', background: 'blue' }, hover: { border: 'orange', background: 'grey' } } },
    var url = "data:image/svg+xml;charset=utf-8,"+ encodeURIComponent(svg);
    {id: 2, label: 'Using SVG', image: url, shape: 'image'}

    #>

    $IconsAvailable = $false
    [Array] $Nodes = foreach ($_ in $DataNodes.Keys) {
        if ($DataNodes[$_]['image']) {
            if ($BundleImages) {
                $DataNodes[$_]['image'] = Convert-Image -Image $DataNodes[$_]['image']
            }
        }
        $NodeJson = $DataNodes[$_] | ConvertTo-JsonLiteral -Depth 5 -AdvancedReplace @{ '.' = '\.'; '$' = '\$' } #| ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }
        if ($DataNodes[$_].icon) {
            $IconsAvailable = $true
        }
        # We need to fix wrong escaped chars, Unescape breaks other parts
        $Replace = @{
            '"\"Font Awesome 5 Solid\""'        = "'`"Font Awesome 5 Solid`"'"
            '"\"Font Awesome 5 Brands\""'       = "'`"Font Awesome 5 Brands`"'"
            '"\"Font Awesome 5 Regular\""'      = "'`"Font Awesome 5 Regular`"'"
            '"\"Font Awesome 5 Free\""'         = "'`"Font Awesome 5 Free`"'"
            '"\"Font Awesome 5 Free Regular\""' = "'`"Font Awesome 5 Free Regular`"'"
            '"\"Font Awesome 5 Free Solid\""'   = "'`"Font Awesome 5 Free Solid`"'"
            '"\"Font Awesome 5 Free Brands\""'  = "'`"Font Awesome 5 Free Brands`"'"
            '"\\u'                              = '"\u'
        }
        foreach ($R in $Replace.Keys) {
            $NodeJson = $NodeJson.Replace($R, $Replace[$R])
        }
        $NodeJson
    }
    [Array] $Edges = foreach ($_ in $DataEdges) {
        $_ | ConvertTo-JsonLiteral -Depth 5 -AdvancedReplace @{ '.' = '\.'; '$' = '\$' } #| ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }
    }

    $Options = @{
        autoResize = -not $NoAutoResize.IsPresent # Doesn't seem to do anything
    }
    if ($DiagramOptionsInteraction) {
        if ($DiagramOptionsInteraction['interaction']) {
            $Options['interaction'] = $DiagramOptionsInteraction['interaction']
        }
    }
    if ($DiagramOptionsManipulation) {
        if ($DiagramOptionsManipulation['manipulation']) {
            $Options['manipulation'] = $DiagramOptionsManipulation['manipulation']
        }
    }
    if ($DiagramOptionsPhysics) {
        if ($DiagramOptionsPhysics['physics']) {
            $Options['physics'] = $DiagramOptionsPhysics['physics']
        }
    }
    if ($DiagramOptionsLayout) {
        if ($DiagramOptionsLayout['layout']) {
            $Options['layout'] = $DiagramOptionsLayout['layout']
        }
    }
    if ($DiagramOptionsEdges) {
        if ($DiagramOptionsEdges['edges']) {
            $Options['edges'] = $DiagramOptionsEdges['edges']
        }
    }
    if ($DiagramOptionsNodes) {
        if ($DiagramOptionsNodes['nodes']) {
            $Options['nodes'] = $DiagramOptionsNodes['nodes']
        }
    }

    if ($BundleImages -and $BackGroundImage) {
        $Image = Convert-Image -Image $BackGroundImage
    } else {
        $Image = $BackGroundImage
    }

    $newInternalDiagramSplat = @{
        Nodes                 = $Nodes
        Edges                 = $Edges
        Options               = $Options
        Width                 = $Width
        Height                = $Height
        BackgroundImage       = $Image
        Events                = $DataEvents
        IconsAvailable        = $IconsAvailable
        DisableLoader         = $DisableLoader
        EnableFiltering       = $EnableFiltering.IsPresent
        MinimumFilteringChars = $MinimumFilteringChars
    }
    if ($PSBoundParameters.ContainsKey('EnableFilteringButton')) {
        $newInternalDiagramSplat['EnableFilteringButton'] = $EnableFilteringButton.IsPresent
    }
    New-InternalDiagram @newInternalDiagramSplat
}
