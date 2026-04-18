Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$packageRoot = Split-Path -Parent $scriptDir
$outputDir = Join-Path $scriptDir "Shaders"
$shaderPagesDir = Join-Path $outputDir "_shaders"
$shadersRoot = Join-Path $packageRoot "Runtime/Shaders"
$nodesRoot = Join-Path $packageRoot "Runtime/Nodes"
$nodeDocsRoot = Join-Path $scriptDir "Nodes"

function New-Slug {
    param([string]$Text)

    $value = $Text.ToLowerInvariant()
    $value = [regex]::Replace($value, "[^a-z0-9]+", "-").Trim("-")

    if ([string]::IsNullOrWhiteSpace($value)) {
        return "index"
    }

    return $value
}

function Normalize-AsciiText {
    param([string]$Text)

    if ($null -eq $Text) {
        return $null
    }

    $normalized = $Text -replace "`r", ""
    $normalized = $normalized.Replace([string][char]0x2011, "-")
    $normalized = $normalized.Replace([string][char]0x2013, "-")
    $normalized = $normalized.Replace([string][char]0x2014, "-")
    $normalized = $normalized.Replace([string][char]0x2018, "'")
    $normalized = $normalized.Replace([string][char]0x2019, "'")
    $normalized = $normalized.Replace([string][char]0x201C, '"')
    $normalized = $normalized.Replace([string][char]0x201D, '"')
    $normalized = $normalized.Replace([string][char]0x2192, "->")
    $normalized = $normalized.Replace([string][char]0x2022, "-")
    $normalized = $normalized.Replace([string][char]0x2714, "-")
    $normalized = $normalized.Replace([string][char]0x2026, "...")
    $normalized = $normalized.Replace([string][char]0x00D7, "x")
    $normalized = $normalized.Replace([string][char]0x2212, "-")
    $normalized = $normalized.Replace([string][char]0x27A1, "->")
    $normalized = $normalized.Replace([string][char]0xFE0F, "")
    $normalized = $normalized.Normalize([Text.NormalizationForm]::FormKD)
    $normalized = [regex]::Replace($normalized, "[^\x00-\x7F]", "")

    return $normalized
}

function Clean-DocumentationText {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $null
    }

    $text = Normalize-AsciiText $Text
    $lines = New-Object System.Collections.Generic.List[string]

    foreach ($line in ($text -split "`n")) {
        $candidate = $line.TrimEnd()

        if ($candidate -match '^\s*\[Documentation\(@""?\s*$') {
            continue
        }

        if ($candidate -match '^\s*\)\]\s*$') {
            continue
        }

        $lines.Add($candidate)
    }

    while ($lines.Count -gt 0 -and [string]::IsNullOrWhiteSpace($lines[0])) {
        $lines.RemoveAt(0)
    }

    while ($lines.Count -gt 0 -and [string]::IsNullOrWhiteSpace($lines[$lines.Count - 1])) {
        $lines.RemoveAt($lines.Count - 1)
    }

    if ($lines.Count -eq 0) {
        return $null
    }

    $clean = ($lines -join "`n")
    $clean = [regex]::Replace($clean, "(`n){3,}", "`n`n")

    return $clean.Trim()
}

function Get-PreferredDocumentation {
    param([System.Text.RegularExpressions.MatchCollection]$Matches)

    $docs = New-Object System.Collections.Generic.List[string]

    foreach ($match in $Matches) {
        $clean = Clean-DocumentationText $match.Groups[1].Value
        if (-not [string]::IsNullOrWhiteSpace($clean)) {
            $docs.Add($clean)
        }
    }

    if ($docs.Count -eq 0) {
        return $null
    }

    return ($docs | Sort-Object Length -Descending | Select-Object -First 1)
}

function Get-DocumentationSummary {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return ""
    }

    foreach ($line in ($Text -split "`n")) {
        $trimmed = $line.Trim()

        if ([string]::IsNullOrWhiteSpace($trimmed)) {
            continue
        }

        if ($trimmed -eq "---") {
            continue
        }

        if ($trimmed.StartsWith("|")) {
            continue
        }

        if ($trimmed.StartsWith("- ")) {
            $trimmed = $trimmed.Substring(2).Trim()
        }

        if ($trimmed.Length -gt 180) {
            return $trimmed.Substring(0, 177) + "..."
        }

        return $trimmed
    }

    return ""
}

function Get-SourceRelativePath {
    param([string]$FullName)

    return $FullName.Substring($packageRoot.Length + 1).Replace("\", "/")
}

function Ensure-Directory {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Get-MarkdownRelativePath {
    param(
        [string]$FromFilePath,
        [string]$ToPath
    )

    $fromDirectory = Split-Path -Parent ([IO.Path]::GetFullPath($FromFilePath))
    if (-not $fromDirectory.EndsWith([IO.Path]::DirectorySeparatorChar)) {
        $fromDirectory += [IO.Path]::DirectorySeparatorChar
    }

    $toFullPath = [IO.Path]::GetFullPath($ToPath)
    $fromUri = [Uri]$fromDirectory
    $toUri = [Uri]$toFullPath
    $relativeUri = $fromUri.MakeRelativeUri($toUri)
    return [Uri]::UnescapeDataString($relativeUri.ToString())
}

function Escape-MarkdownTableText {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return ""
    }

    $value = ($Text -replace "`r", " " -replace "`n", " ").Trim()
    return $value.Replace("|", "\|")
}

function Get-OptionalPropertyValue {
    param(
        [object]$Object,
        [string]$Name,
        $Default = $null
    )

    if ($null -eq $Object) {
        return $Default
    }

    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $Default
    }

    return $property.Value
}

function Get-NodeRecords {
    $nodeFiles = Get-ChildItem -Path $nodesRoot -Recurse -File -Filter *.cs
    $records = New-Object System.Collections.Generic.List[object]

    foreach ($file in $nodeFiles) {
        $content = Get-Content -Raw -Path $file.FullName
        $menuMatches = [regex]::Matches($content, 'NodeMenuItem\("([^"]+)"')

        if ($menuMatches.Count -eq 0) {
            continue
        }

        $menus = @($menuMatches | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique)
        $primaryMenu = $menus[0]
        $segments = $primaryMenu -split "/"
        $root = $segments[0]
        $categorySlug = New-Slug $root
        $nodeSlug = New-Slug (($segments | Select-Object -Skip 1) -join " ")
        $fileSlug = New-Slug $file.BaseName

        $nameMatch = [regex]::Match($content, 'public\s+override\s+string\s+name\s*=>\s*"([^"]+)"')
        $shaderMatch = [regex]::Match($content, 'public\s+override\s+string\s+ShaderName\s*=>\s*"([^"]+)"')
        $docMatches = [regex]::Matches($content, '\[Documentation\(@"(?s)(.*?)"\)\]')

        $records.Add([pscustomobject]@{
            Name = if ($nameMatch.Success) { $nameMatch.Groups[1].Value } else { $segments[$segments.Count - 1] }
            PrimaryMenu = $primaryMenu
            Root = $root
            CategorySlug = $categorySlug
            NodeSlug = $nodeSlug
            FileSlug = $fileSlug
            NodePageRelativePath = "_nodes/$categorySlug/$nodeSlug.md"
            ShaderName = if ($shaderMatch.Success) { $shaderMatch.Groups[1].Value } else { "" }
            Documentation = Get-PreferredDocumentation $docMatches
            Summary = Get-DocumentationSummary (Get-PreferredDocumentation $docMatches)
            SourcePath = Get-SourceRelativePath $file.FullName
        })
    }

    $duplicatePages = @($records | Group-Object NodePageRelativePath | Where-Object { $_.Count -gt 1 })
    foreach ($group in $duplicatePages) {
        foreach ($node in $group.Group) {
            $resolvedSlug = "$($node.NodeSlug)-$($node.FileSlug)"
            $node.NodePageRelativePath = "_nodes/$($node.CategorySlug)/$resolvedSlug.md"
        }
    }

    return [object[]]$records
}

function Get-CommentDocumentation {
    param([string]$Content)

    $lines = $Content -split "`r?`n"
    $commentLines = New-Object System.Collections.Generic.List[string]

    foreach ($line in $lines) {
        $trimmed = $line.Trim()

        if ($trimmed -match '^\s*Shader\s+"') {
            break
        }

        if ([string]::IsNullOrWhiteSpace($trimmed)) {
            if ($commentLines.Count -gt 0) {
                $commentLines.Add("")
            }
            continue
        }

        if ($trimmed.StartsWith("//")) {
            $commentLines.Add($trimmed.Substring(2).Trim())
            continue
        }

        if ($trimmed.StartsWith("/*")) {
            $commentLines.Add(($trimmed -replace '^\s*/\*+', '' -replace '\*/\s*$', '').Trim())
            continue
        }

        if ($trimmed.StartsWith("*")) {
            $commentLines.Add(($trimmed -replace '^\s*\*+', '').Trim())
            continue
        }

        if ($trimmed.StartsWith("*/")) {
            continue
        }

        if ($commentLines.Count -gt 0) {
            break
        }
    }

    $commentText = ($commentLines -join "`n").Trim()
    if ([string]::IsNullOrWhiteSpace($commentText)) {
        return $null
    }

    return Normalize-AsciiText $commentText
}

function Get-PropertyBlockLines {
    param([string]$Content)

    $lines = $Content -split "`r?`n"
    $blockLines = New-Object System.Collections.Generic.List[string]
    $waitingForOpen = $false
    $insideBlock = $false
    $braceDepth = 0

    foreach ($line in $lines) {
        if (-not $insideBlock -and -not $waitingForOpen) {
            if ($line -match '^\s*Properties\b') {
                $waitingForOpen = $true
            }
            else {
                continue
            }
        }

        if ($waitingForOpen -and -not $insideBlock) {
            $openCount = ([regex]::Matches($line, '\{')).Count
            $closeCount = ([regex]::Matches($line, '\}')).Count

            if ($openCount -gt 0) {
                $insideBlock = $true
                $waitingForOpen = $false
                $braceDepth += ($openCount - $closeCount)
            }

            continue
        }

        if ($insideBlock) {
            $openCount = ([regex]::Matches($line, '\{')).Count
            $closeCount = ([regex]::Matches($line, '\}')).Count
            $braceDepth += ($openCount - $closeCount)

            if ($braceDepth -lt 0) {
                break
            }

            if ($braceDepth -eq 0 -and $line.Trim() -eq "}") {
                break
            }

            $blockLines.Add($line)
        }
    }

    return [object[]]$blockLines
}

function Get-PropertyRecords {
    param([string]$Content)

    $records = New-Object System.Collections.Generic.List[object]
    $pendingAttributeText = ""

    foreach ($line in (Get-PropertyBlockLines $Content)) {
        $trimmed = $line.Trim()

        if ([string]::IsNullOrWhiteSpace($trimmed)) {
            continue
        }

        if ($trimmed.StartsWith("//")) {
            continue
        }

        $candidate = if ([string]::IsNullOrWhiteSpace($pendingAttributeText)) {
            $trimmed
        }
        else {
            "$pendingAttributeText $trimmed"
        }

        $propertyMatch = [regex]::Match($candidate, '^(?<attributeText>(?:\[[^\]]+\]\s*)*)(?<reference>[_A-Za-z0-9]+)\("(?<display>[^"]+)",\s*(?<type>.+?)\)\s*=\s*(?<default>.+)$')

        if (-not $propertyMatch.Success) {
            if ($trimmed.StartsWith("[")) {
                $pendingAttributeText = $candidate
            }
            else {
                $pendingAttributeText = ""
            }

            continue
        }

        $pendingAttributeText = ""
        $tooltip = ""
        $attributeValues = New-Object System.Collections.Generic.List[string]

        foreach ($attributeMatch in [regex]::Matches($propertyMatch.Groups["attributeText"].Value, '\[(.*?)\]')) {
            $attributeValue = $attributeMatch.Groups[1].Value.Trim()
            $tooltipMatch = [regex]::Match($attributeValue, '^(?i:tooltip|tooltip)\((?<tooltip>.*)\)$')

            if ($tooltipMatch.Success) {
                $tooltip = Normalize-AsciiText $tooltipMatch.Groups["tooltip"].Value.Trim('"')
                continue
            }

            if ($attributeValue -match '^(?i:tooltip|tooltip)$') {
                continue
            }

            $attributeValues.Add((Normalize-AsciiText $attributeValue).Trim())
        }

        $propertyType = Normalize-AsciiText $propertyMatch.Groups["type"].Value.Trim()
        $defaultValue = Normalize-AsciiText $propertyMatch.Groups["default"].Value.Trim()

        $records.Add([pscustomobject]@{
            Reference = $propertyMatch.Groups["reference"].Value
            DisplayName = Normalize-AsciiText $propertyMatch.Groups["display"].Value.Trim()
            Type = $propertyType
            Default = $defaultValue
            Tooltip = $tooltip
            Attributes = @($attributeValues)
            IsTexture = @("2D", "3D", "Cube") -contains $propertyType
        })
    }

    return [object[]]$records
}

function Get-IncludeRecords {
    param([string]$Content)

    $includes = New-Object System.Collections.Generic.List[object]

    foreach ($match in [regex]::Matches($Content, '(?m)^\s*#include\s+"([^"]+)"')) {
        $includePath = $match.Groups[1].Value.Trim()
        $sourcePath = $null

        if ($includePath.StartsWith("Packages/com.ahahgames.genesisnoise/", [System.StringComparison]::OrdinalIgnoreCase)) {
            $relativePackagePath = $includePath.Substring("Packages/com.ahahgames.genesisnoise/".Length)
            $fullIncludePath = Join-Path $packageRoot ($relativePackagePath -replace "/", "\")

            if (Test-Path $fullIncludePath) {
                $sourcePath = Get-SourceRelativePath $fullIncludePath
            }
        }

        $includes.Add([pscustomobject]@{
            IncludePath = $includePath
            SourcePath = $sourcePath
        })
    }

    return [object[]]($includes | Sort-Object IncludePath -Unique)
}

function Get-PragmaRecords {
    param([string]$Content)

    $allPragmas = @([regex]::Matches($Content, '(?m)^\s*#pragma\s+(.+?)\s*$') | ForEach-Object {
        (Normalize-AsciiText $_.Groups[1].Value).Trim()
    })

    return [pscustomobject]@{
        Target = ($allPragmas | Where-Object { $_ -match '^target\s+' } | Select-Object -First 1)
        ShaderFeatures = @($allPragmas | Where-Object { $_ -match '^(shader_feature|multi_compile)\b' } | Select-Object -Unique)
        EntryPoints = @($allPragmas | Where-Object { $_ -match '^(vertex|fragment)\b' } | Select-Object -Unique)
        Other = @($allPragmas | Where-Object { $_ -notmatch '^(target|shader_feature|multi_compile|vertex|fragment)\b' } | Select-Object -Unique)
    }
}

function Get-ShaderOverview {
    param(
        [string]$CommentDocumentation,
        [object[]]$LinkedNodes,
        [object[]]$Properties,
        [string]$ShaderName
    )

    if (-not [string]::IsNullOrWhiteSpace($CommentDocumentation)) {
        return $CommentDocumentation
    }

    $nodeList = @($LinkedNodes)
    if ($nodeList.Count -gt 0) {
        $preferredNode = $nodeList | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Documentation) } | Select-Object -First 1
        if ($null -ne $preferredNode -and -not [string]::IsNullOrWhiteSpace($preferredNode.Documentation)) {
            return $preferredNode.Documentation
        }

        if (-not [string]::IsNullOrWhiteSpace($nodeList[0].Summary)) {
            return $nodeList[0].Summary
        }
    }

    $preferredProperty = @($Properties | Where-Object { -not $_.IsTexture -and -not [string]::IsNullOrWhiteSpace($_.Tooltip) } | Select-Object -First 1)
    if ($preferredProperty.Count -gt 0) {
        return $preferredProperty[0].Tooltip
    }

    return "Genesis shader implementation backed by ``$ShaderName``."
}

function Get-ShaderRecords {
    param([System.Collections.IEnumerable]$NodeRecords)

    $nodeLookup = @{}
    foreach ($node in $NodeRecords) {
        if ([string]::IsNullOrWhiteSpace($node.ShaderName)) {
            continue
        }

        if (-not $nodeLookup.ContainsKey($node.ShaderName)) {
            $nodeLookup[$node.ShaderName] = New-Object System.Collections.Generic.List[object]
        }

        $nodeLookup[$node.ShaderName].Add($node)
    }

    $shaderFiles = Get-ChildItem -Path $shadersRoot -Recurse -File -Filter *.shader
    $records = New-Object System.Collections.Generic.List[object]

    foreach ($file in $shaderFiles) {
        $content = Get-Content -Raw -Path $file.FullName
        $relativePath = Get-SourceRelativePath $file.FullName
        $relativeWithinShaders = $relativePath.Substring("Runtime/Shaders/".Length)
        $relativeWithoutExtension = [IO.Path]::ChangeExtension($relativeWithinShaders, $null)
        $pathSegments = $relativeWithoutExtension -split "[/\\]"
        $category = if ($pathSegments.Count -gt 0) { $pathSegments[0] } else { "General" }
        $subsection = if ($pathSegments.Count -gt 2) { $pathSegments[1] } else { "General" }
        $categorySlug = New-Slug $category
        $shaderSlug = if ($pathSegments.Count -gt 1) {
            New-Slug (($pathSegments | Select-Object -Skip 1) -join " ")
        }
        else {
            New-Slug $file.BaseName
        }

        $shaderNameMatch = [regex]::Match($content, '(?m)^\s*Shader\s+"([^"]+)"')
        $shaderName = if ($shaderNameMatch.Success) { $shaderNameMatch.Groups[1].Value.Trim() } else { $file.BaseName }
        $displayName = if ($shaderName.Contains("/")) { ($shaderName -split "/")[-1] } else { $shaderName }
        $properties = @(Get-PropertyRecords $content)
        $linkedNodes = @()

        if ($nodeLookup.ContainsKey($shaderName)) {
            $linkedNodes = foreach ($linkedNode in $nodeLookup[$shaderName]) {
                $linkedNode
            }
        }
        $commentDocumentation = Get-CommentDocumentation $content
        $overview = Get-ShaderOverview -CommentDocumentation $commentDocumentation -LinkedNodes $linkedNodes -Properties $properties -ShaderName $shaderName
        $summary = Get-DocumentationSummary $overview
        $pragmaRecords = Get-PragmaRecords $content
        $pageRelativePath = "_shaders/$categorySlug/$shaderSlug.md"

        $records.Add([pscustomobject]@{
            Name = $displayName
            ShaderName = $shaderName
            Category = $category
            CategorySlug = $categorySlug
            CategoryFileName = (New-Slug $category) + ".md"
            Subsection = $subsection
            ShaderSlug = $shaderSlug
            RelativeWithinShaders = $relativeWithinShaders.Replace("\", "/")
            SourcePath = $relativePath
            PageRelativePath = $pageRelativePath
            Overview = $overview
            Summary = $summary
            Properties = $properties
            TextureProperties = @($properties | Where-Object { $_.IsTexture })
            ParameterProperties = @($properties | Where-Object { -not $_.IsTexture })
            Includes = @(Get-IncludeRecords $content)
            Pragmas = $pragmaRecords
            LinkedNodes = @($linkedNodes | Sort-Object Name, PrimaryMenu)
        })
    }

    $duplicatePages = @($records | Group-Object PageRelativePath | Where-Object { $_.Count -gt 1 })
    foreach ($group in $duplicatePages) {
        foreach ($record in $group.Group) {
            $resolvedSlug = New-Slug ($record.RelativeWithinShaders -replace '\.shader$', '')
            $record.PageRelativePath = "_shaders/$($record.CategorySlug)/$resolvedSlug.md"
        }
    }

    return [object[]]$records
}

function Write-PropertyTable {
    param(
        [System.Text.StringBuilder]$Builder,
        [System.Collections.IEnumerable]$Properties
    )

    $propertyList = @($Properties)
    if ($propertyList.Count -eq 0) {
        [void]$Builder.AppendLine("_None._")
        [void]$Builder.AppendLine()
        return
    }

    [void]$Builder.AppendLine("| Property | Label | Type | Default | Tooltip | Attributes |")
    [void]$Builder.AppendLine("| --- | --- | --- | --- | --- | --- |")

    foreach ($property in $propertyList) {
        $attributesText = Escape-MarkdownTableText (($property.Attributes -join ", ").Trim())
        $tooltipText = Escape-MarkdownTableText $property.Tooltip
        $defaultText = Escape-MarkdownTableText $property.Default
        $typeText = Escape-MarkdownTableText $property.Type
        $labelText = Escape-MarkdownTableText $property.DisplayName

        [void]$Builder.AppendLine("| ``$($property.Reference)`` | $labelText | ``$typeText`` | ``$defaultText`` | $tooltipText | $attributesText |")
    }

    [void]$Builder.AppendLine()
}

function Write-ShaderPage {
    param([psobject]$Shader)

    $pagePath = Join-Path $outputDir ($Shader.PageRelativePath -replace "/", "\")
    $pageDirectory = Split-Path -Parent $pagePath
    $readmePath = Join-Path $outputDir "README.md"
    $categoryPath = Join-Path $outputDir $Shader.CategoryFileName
    $sourceFullPath = Join-Path $packageRoot ($Shader.SourcePath -replace "/", "\")
    $builder = New-Object System.Text.StringBuilder

    Ensure-Directory $pageDirectory

    [void]$builder.AppendLine("# $($Shader.Name)")
    [void]$builder.AppendLine()
    [void]$builder.AppendLine('> This file is auto-generated by `Documentation/Generate-GenesisShaderDocs.ps1`.')
    [void]$builder.AppendLine()
    [void]$builder.AppendLine("[Back to index]($(Get-MarkdownRelativePath -FromFilePath $pagePath -ToPath $readmePath)) | [Back to $($Shader.Category)]($(Get-MarkdownRelativePath -FromFilePath $pagePath -ToPath $categoryPath))")
    [void]$builder.AppendLine()
    [void]$builder.AppendLine("## Overview")
    [void]$builder.AppendLine()
    [void]$builder.AppendLine($Shader.Overview)
    [void]$builder.AppendLine()
    [void]$builder.AppendLine("## Details")
    [void]$builder.AppendLine()
    [void]$builder.AppendLine("- Shader: ``$($Shader.ShaderName)``")
    [void]$builder.AppendLine("- Category: ``$($Shader.Category)``")
    [void]$builder.AppendLine("- Source: [$($Shader.SourcePath)]($(Get-MarkdownRelativePath -FromFilePath $pagePath -ToPath $sourceFullPath))")
    [void]$builder.AppendLine("- Texture inputs: $($Shader.TextureProperties.Count)")
    [void]$builder.AppendLine("- Parameters: $($Shader.ParameterProperties.Count)")
    [void]$builder.AppendLine("- Linked nodes: $($Shader.LinkedNodes.Count)")
    [void]$builder.AppendLine()
    [void]$builder.AppendLine("## Texture Inputs")
    [void]$builder.AppendLine()
    Write-PropertyTable -Builder $builder -Properties $Shader.TextureProperties
    [void]$builder.AppendLine("## Parameters")
    [void]$builder.AppendLine()
    Write-PropertyTable -Builder $builder -Properties $Shader.ParameterProperties
    [void]$builder.AppendLine("## Includes")
    [void]$builder.AppendLine()

    if ($Shader.Includes.Count -eq 0) {
        [void]$builder.AppendLine("_None._")
        [void]$builder.AppendLine()
    }
    else {
        foreach ($include in $Shader.Includes) {
            $includePathValue = [string](Get-OptionalPropertyValue -Object $include -Name "IncludePath" -Default $include)
            $includeSourcePath = [string](Get-OptionalPropertyValue -Object $include -Name "SourcePath" -Default "")

            if (-not [string]::IsNullOrWhiteSpace($includeSourcePath)) {
                $includeFullPath = Join-Path $packageRoot ($includeSourcePath -replace "/", "\")
                $includeLink = Get-MarkdownRelativePath -FromFilePath $pagePath -ToPath $includeFullPath
                [void]$builder.AppendLine("- [$includePathValue]($includeLink)")
            }
            else {
                [void]$builder.AppendLine("- ``$includePathValue``")
            }
        }

        [void]$builder.AppendLine()
    }

    [void]$builder.AppendLine("## Pragmas")
    [void]$builder.AppendLine()

    if (-not [string]::IsNullOrWhiteSpace($Shader.Pragmas.Target)) {
        [void]$builder.AppendLine("- Target: ``$($Shader.Pragmas.Target)``")
    }

    foreach ($entryPoint in $Shader.Pragmas.EntryPoints) {
        [void]$builder.AppendLine("- Entry point: ``$entryPoint``")
    }

    foreach ($feature in $Shader.Pragmas.ShaderFeatures) {
        [void]$builder.AppendLine("- Shader feature: ``$feature``")
    }

    foreach ($pragma in $Shader.Pragmas.Other) {
        [void]$builder.AppendLine("- Other pragma: ``$pragma``")
    }

    if ([string]::IsNullOrWhiteSpace($Shader.Pragmas.Target) -and $Shader.Pragmas.EntryPoints.Count -eq 0 -and $Shader.Pragmas.ShaderFeatures.Count -eq 0 -and $Shader.Pragmas.Other.Count -eq 0) {
        [void]$builder.AppendLine("_None._")
    }

    [void]$builder.AppendLine()
    [void]$builder.AppendLine("## Used By Nodes")
    [void]$builder.AppendLine()

    if ($Shader.LinkedNodes.Count -eq 0) {
        [void]$builder.AppendLine("_No Genesis node wrapper currently references this shader._")
    }
    else {
        [void]$builder.AppendLine("| Node | Menu | Summary |")
        [void]$builder.AppendLine("| --- | --- | --- |")

        foreach ($node in $Shader.LinkedNodes) {
            $nodePagePath = Join-Path $nodeDocsRoot ($node.NodePageRelativePath -replace "/", "\")
            $nodeLink = if (Test-Path $nodePagePath) {
                Get-MarkdownRelativePath -FromFilePath $pagePath -ToPath $nodePagePath
            }
            else {
                $null
            }

            $nodeLabel = if ($null -ne $nodeLink) { "[$($node.Name)]($nodeLink)" } else { $node.Name }
            $menuText = Escape-MarkdownTableText $node.PrimaryMenu
            $summaryText = Escape-MarkdownTableText $node.Summary
            [void]$builder.AppendLine("| $nodeLabel | ``$menuText`` | $summaryText |")
        }
    }

    Set-Content -Path $pagePath -Value $builder.ToString().TrimEnd() -Encoding utf8
}

function Write-CategoryPage {
    param(
        [string]$Category,
        [string]$FileName,
        [System.Collections.IEnumerable]$Shaders
    )

    $shaderList = @($Shaders | Sort-Object Subsection, Name, ShaderName)
    $path = Join-Path $outputDir $FileName
    $readmePath = Join-Path $outputDir "README.md"
    $builder = New-Object System.Text.StringBuilder

    [void]$builder.AppendLine("# Genesis Shaders: $Category")
    [void]$builder.AppendLine()
    [void]$builder.AppendLine('> This file is auto-generated by `Documentation/Generate-GenesisShaderDocs.ps1`.')
    [void]$builder.AppendLine()
    [void]$builder.AppendLine("[Back to index]($(Get-MarkdownRelativePath -FromFilePath $path -ToPath $readmePath))")
    [void]$builder.AppendLine()
    [void]$builder.AppendLine("## Overview")
    [void]$builder.AppendLine()
    [void]$builder.AppendLine("- Shader count: $($shaderList.Count)")
    [void]$builder.AppendLine("- Linked to Genesis nodes: $(@($shaderList | Where-Object { $_.LinkedNodes.Count -gt 0 }).Count)")
    [void]$builder.AppendLine("- Orphan shaders: $(@($shaderList | Where-Object { $_.LinkedNodes.Count -eq 0 }).Count)")
    [void]$builder.AppendLine()

    $groups = $shaderList | Group-Object Subsection | Sort-Object Name
    foreach ($group in $groups) {
        [void]$builder.AppendLine("## $($group.Name)")
        [void]$builder.AppendLine()
        [void]$builder.AppendLine("| Shader | Hidden Name | Nodes | Summary |")
        [void]$builder.AppendLine("| --- | --- | ---: | --- |")

        foreach ($shader in ($group.Group | Sort-Object Name, ShaderName)) {
            $pageLink = Get-MarkdownRelativePath -FromFilePath $path -ToPath (Join-Path $outputDir ($shader.PageRelativePath -replace "/", "\"))
            $summaryText = Escape-MarkdownTableText $shader.Summary
            $hiddenName = Escape-MarkdownTableText $shader.ShaderName
            [void]$builder.AppendLine("| [$($shader.Name)]($pageLink) | ``$hiddenName`` | $($shader.LinkedNodes.Count) | $summaryText |")
        }

        [void]$builder.AppendLine()
    }

    Set-Content -Path $path -Value $builder.ToString().TrimEnd() -Encoding utf8
}

Ensure-Directory $outputDir

if (Test-Path $shaderPagesDir) {
    Get-ChildItem -Path $shaderPagesDir -Force | ForEach-Object {
        try {
            Get-ChildItem -Path $_.FullName -Force -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
                $_.IsReadOnly = $false
            }

            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction Stop
        }
        catch {
            # Best effort cleanup. Current pages are rewritten below.
        }
    }
}

Ensure-Directory $shaderPagesDir

Get-ChildItem -Path $outputDir -File -Filter *.md | ForEach-Object {
    try {
        Remove-Item -Path $_.FullName -Force -ErrorAction Stop
    }
    catch {
        # Best effort cleanup. Existing files will be overwritten below.
    }
}

$nodes = @(Get-NodeRecords | Sort-Object Root, Name, PrimaryMenu)
$shaders = @(Get-ShaderRecords -NodeRecords $nodes | Sort-Object Category, Subsection, Name, ShaderName)
$categories = $shaders | Group-Object Category | Sort-Object Name

foreach ($shader in $shaders) {
    Write-ShaderPage -Shader $shader
}

$readme = New-Object System.Text.StringBuilder

[void]$readme.AppendLine("# Genesis Shader Reference")
[void]$readme.AppendLine()
[void]$readme.AppendLine('> This directory is auto-generated by `Documentation/Generate-GenesisShaderDocs.ps1` from `Runtime/Shaders`.')
[void]$readme.AppendLine()
[void]$readme.AppendLine("## Summary")
[void]$readme.AppendLine()
[void]$readme.AppendLine("- Unique shader files: $($shaders.Count)")
[void]$readme.AppendLine("- Top-level categories: $($categories.Count)")
[void]$readme.AppendLine("- Shaders linked to Genesis nodes: $(@($shaders | Where-Object { $_.LinkedNodes.Count -gt 0 }).Count)")
[void]$readme.AppendLine("- Orphan shaders: $(@($shaders | Where-Object { $_.LinkedNodes.Count -eq 0 }).Count)")
[void]$readme.AppendLine()
[void]$readme.AppendLine("## Categories")
[void]$readme.AppendLine()
[void]$readme.AppendLine("| Category | Shaders | Linked | Orphans | File |")
[void]$readme.AppendLine("| --- | ---: | ---: | ---: | --- |")

foreach ($category in $categories) {
    $categoryName = $category.Name
    $categoryShaders = @($category.Group | Sort-Object Subsection, Name, ShaderName)
    $linkedCount = @($categoryShaders | Where-Object { $_.LinkedNodes.Count -gt 0 }).Count
    $orphanCount = @($categoryShaders | Where-Object { $_.LinkedNodes.Count -eq 0 }).Count
    $fileName = (New-Slug $categoryName) + ".md"

    Write-CategoryPage -Category $categoryName -FileName $fileName -Shaders $categoryShaders
    [void]$readme.AppendLine("| $categoryName | $($categoryShaders.Count) | $linkedCount | $orphanCount | [$categoryName]($fileName) |")
}

[void]$readme.AppendLine()
[void]$readme.AppendLine("## Regenerate")
[void]$readme.AppendLine()
[void]$readme.AppendLine('```powershell')
[void]$readme.AppendLine("pwsh ./Documentation/Generate-GenesisShaderDocs.ps1")
[void]$readme.AppendLine('```')

Set-Content -Path (Join-Path $outputDir "README.md") -Value $readme.ToString().TrimEnd() -Encoding utf8
