﻿function New-DefaultSettings {
    <#
    .SYNOPSIS
    Creates a new default settings object with predefined values for various properties.

    .DESCRIPTION
    This function creates a new default settings object with predefined values for properties related to email, features, charts, carousel, diagrams, logos, tabs, table options, tab panels, custom CSS and JS headers and footers, and wizard list.

    .EXAMPLE
    $defaultSettings = New-DefaultSettings
    Creates a new default settings object with all properties initialized to their default values.

    #>
    [cmdletBinding()]
    param()
    [ordered]@{
        Email             = $false
        Features          = [ordered] @{ } # tracks features for CSS/JS implementation
        Charts            = [System.Collections.Generic.List[string]]::new()
        Carousel          = [System.Collections.Generic.List[string]]::new()
        Diagrams          = [System.Collections.Generic.List[string]]::new()
        Logos             = ""
        # Tabs Tracking/Options (Top Level Ones)
        TabsHeaders       = [System.Collections.Generic.List[System.Collections.IDictionary]]::new() # tracks / stores headers
        TabsHeadersNested = [System.Collections.Generic.List[System.Collections.IDictionary]]::new() # tracks / stores headers
        TableOptions      = [ordered] @{
            DataStore        = ''
            # Applies to only JavaScript and AjaxJSON store
            DataStoreOptions = [ordered] @{
                BoolAsString          = $false
                NumberAsString        = $false
                DateTimeFormat        = '' #"yyyy-MM-dd HH:mm:ss"
                NewLineFormat         = @{
                    NewLineCarriage = '<br>'
                    NewLine         = "\n"
                    Carriage        = "\r"
                }
                NewLineFormatProperty = @{
                    NewLineCarriage = '<br>'
                    NewLine         = "\n"
                    Carriage        = "\r"
                }
            }
            Type             = 'Structured'
            Folder           = if ($FilePath) { Split-Path -Path $FilePath } else { '' }
        }
        # TabPanels Tracking
        TabPanelsList     = [System.Collections.Generic.List[string]]::new()
        Table             = [ordered] @{}
        TableSimplify     = $false # Tracks current table only
        CustomHeaderCSS   = [ordered] @{}
        CustomFooterCSS   = [ordered] @{}
        CustomHeaderJS    = [ordered] @{}
        CustomFooterJS    = [ordered] @{}

        # WizardList Tracking
        WizardList        = [System.Collections.Generic.List[string]]::new()
    }
}