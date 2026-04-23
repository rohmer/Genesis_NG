Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$packageRoot = Split-Path -Parent $scriptDir
$outputDir = Join-Path $scriptDir "Nodes"
$nodePagesDir = Join-Path $outputDir "_nodes"
$imageDir = Join-Path $outputDir "_images"

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

function Get-TextureOperationFallback {
    param([string]$Operation)

    switch ($Operation) {
        "Texture Addition" { return "Adds the input textures per pixel." }
        "Texture Subtraction" { return "Subtracts one texture input from another per pixel." }
        "Texture Multiplication" { return "Multiplies the input textures per pixel." }
        "Texture Division" { return "Divides one texture input by another per pixel." }
        "Texture Maximum" { return "Returns the per-pixel maximum of the input textures." }
        "Texture Minimum" { return "Returns the per-pixel minimum of the input textures." }
        default {
            $code = $Operation -replace "^Texture\s+", ""
            return "Applies ``$code`` to the source texture per pixel."
        }
    }
}

function Get-FallbackDocumentation {
    param(
        [string]$Menu,
        [string]$NodeName,
        [string]$ShaderName
    )

    $exactFallbacks = @{
        "Color/Levels" = "Adjusts black point, white point, gamma, and output range for the input."
        "Flow/For Start" = "Begins a for-loop flow block."
        "For End" = "Closes a for-loop flow block."
        "Generators/Shapes/Polygon 2D" = "Generates a 2D polygon shape."
        "Generators/Shapes/Random N-Gon" = "Generates a random N-sided polygon."
        "Operations/Vector To Texture" = "Converts vector data into a texture representation."
        "Operations/Volume To Vector Field" = "Converts a volume input into a vector field texture."
        "Output/Texture 2D" = "Writes the graph result to a 2D texture output."
        "Recipe/Recipe" = "Defines a reusable recipe graph."
        "Recipe/Recipe Input" = "Declares an input for a reusable recipe graph."
        "Recipe/Recipe Output" = "Declares an output for a reusable recipe graph."
        "Utility/Debug" = "Inspects values during graph authoring and debugging."
    }

    if ($exactFallbacks.ContainsKey($Menu)) {
        return $exactFallbacks[$Menu]
    }

    switch -Regex ($Menu) {
        "^Function/Cast/To (.+)$" {
            return "Casts the input value to $($Matches[1])."
        }
        "^Function/Constant/(.+)$" {
            return "Outputs a constant $($Matches[1].ToLowerInvariant()) value."
        }
        "^Function/Math/Abs$" { return "Returns the absolute value of the input." }
        "^Function/Math/Addition$" { return "Adds the input values." }
        "^Function/Math/Clamp$" { return "Clamps the input to a specified range." }
        "^Function/Math/Cos$" { return "Returns the cosine of the input." }
        "^Function/Math/Divide$" { return "Divides one input by another." }
        "^Function/Math/Log$" { return "Returns the logarithm of the input." }
        "^Function/Math/Max$" { return "Returns the larger of the input values." }
        "^Function/Math/Min$" { return "Returns the smaller of the input values." }
        "^Function/Math/Multiply$" { return "Multiplies the input values." }
        "^Function/Math/Pow$" { return "Raises the input to a power." }
        "^Function/Math/Sin$" { return "Returns the sine of the input." }
        "^Function/Math/Subtract$" { return "Subtracts one input from another." }
        "^Function/Math/Tan$" { return "Returns the tangent of the input." }
        "^Function/Random/Float$" { return "Generates a random float value." }
        "^Function/Random/Integer$" { return "Generates a random integer value." }
        "^Function/Random/Point in (.+)$" {
            return "Generates a random point inside a $($Matches[1].ToLowerInvariant())."
        }
        "^Function/Texture/(.+)$" {
            return Get-TextureOperationFallback $Matches[1]
        }
        default {
            if (-not [string]::IsNullOrWhiteSpace($ShaderName)) {
                return "Graph node backed by the shader ``$ShaderName``."
            }

            return "Genesis graph node available at menu path ``$Menu``."
        }
    }
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

function Get-NodeRecords {
    $nodeFiles = Get-ChildItem -Path (Join-Path $packageRoot "Runtime/Nodes") -Recurse -File -Filter *.cs
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
        $subsection = if ($segments.Count -gt 2) { $segments[1] } else { "General" }
        $categorySlug = New-Slug $root
        $nodeSlug = New-Slug (($segments | Select-Object -Skip 1) -join " ")
        $fileSlug = New-Slug $file.BaseName

        $nameMatch = [regex]::Match($content, 'public\s+override\s+string\s+name\s*=>\s*"([^"]+)"')
        $groupMatch = [regex]::Match($content, 'public\s+override\s+string\s+NodeGroup\s*=>\s*"([^"]+)"')
        $shaderMatch = [regex]::Match($content, 'public\s+override\s+string\s+ShaderName\s*=>\s*"([^"]+)"')
        $docMatches = [regex]::Matches($content, '\[Documentation\(@"(?s)(.*?)"\)\]')

        $name = if ($nameMatch.Success) { $nameMatch.Groups[1].Value } else { $segments[$segments.Count - 1] }
        $group = if ($groupMatch.Success) { $groupMatch.Groups[1].Value } else { "" }
        $shaderName = if ($shaderMatch.Success) { $shaderMatch.Groups[1].Value } else { "" }
        $docText = Get-PreferredDocumentation $docMatches
        $usedFallback = [string]::IsNullOrWhiteSpace($docText)

        if ($usedFallback) {
            $docText = Get-FallbackDocumentation -Menu $primaryMenu -NodeName $name -ShaderName $shaderName
        }

        $sourcePath = Get-SourceRelativePath $file.FullName
        $categoryFileName = (New-Slug $root) + ".md"
        $nodePageRelativePath = "_nodes/$categorySlug/$nodeSlug.md"
        $imageRelativePath = "_images/$categorySlug/$nodeSlug.png"

        $records.Add([pscustomobject]@{
            Name = $name
            PrimaryMenu = $primaryMenu
            Menus = $menus
            Root = $root
            Subsection = $subsection
            CategorySlug = $categorySlug
            CategoryFileName = $categoryFileName
            NodeSlug = $nodeSlug
            FileSlug = $fileSlug
            NodePageRelativePath = $nodePageRelativePath
            ImageRelativePath = $imageRelativePath
            NodeGroup = $group
            ShaderName = $shaderName
            Documentation = $docText
            Summary = Get-DocumentationSummary $docText
            UsedFallback = $usedFallback
            SourcePath = $sourcePath
        })
    }

    return $records
}

function Resolve-NodeRecordPaths {
    param([System.Collections.IEnumerable]$Nodes)

    $nodeList = @($Nodes)
    $duplicateGroups = @($nodeList | Group-Object NodePageRelativePath | Where-Object { $_.Count -gt 1 })

    foreach ($group in $duplicateGroups) {
        foreach ($node in $group.Group) {
            $resolvedSlug = "$($node.NodeSlug)-$($node.FileSlug)"
            $node.NodePageRelativePath = "_nodes/$($node.CategorySlug)/$resolvedSlug.md"
            $node.ImageRelativePath = "_images/$($node.CategorySlug)/$resolvedSlug.png"
        }
    }

    return $nodeList
}

function Write-NodePage {
    param([psobject]$Node)

    $pagePath = Join-Path $outputDir ($Node.NodePageRelativePath -replace "/", "\")
    $pageDirectory = Split-Path -Parent $pagePath
    $imagePath = Join-Path $outputDir ($Node.ImageRelativePath -replace "/", "\")
    $categoryPath = Join-Path $outputDir $Node.CategoryFileName
    $readmePath = Join-Path $outputDir "README.md"
    $sourceFullPath = Join-Path $packageRoot ($Node.SourcePath -replace "/", "\")
    $builder = New-Object System.Text.StringBuilder

    Ensure-Directory $pageDirectory

    [void]$builder.AppendLine("# $($Node.Name)")
    [void]$builder.AppendLine()
    [void]$builder.AppendLine('> This file is auto-generated by `Documentation/Generate-GenesisNodeDocs.ps1`.')
    [void]$builder.AppendLine()
    [void]$builder.AppendLine("[Back to index]($(Get-MarkdownRelativePath -FromFilePath $pagePath -ToPath $readmePath)) | [Back to $($Node.Root)]($(Get-MarkdownRelativePath -FromFilePath $pagePath -ToPath $categoryPath))")
    [void]$builder.AppendLine()
    [void]$builder.AppendLine("## Snapshot")
    [void]$builder.AppendLine()

    if (Test-Path $imagePath) {
        $imageLink = Get-MarkdownRelativePath -FromFilePath $pagePath -ToPath $imagePath
        [void]$builder.AppendLine("![Snapshot of $($Node.Name)]($imageLink)")
    }
    else {
        [void]$builder.AppendLine("_Screenshot not generated yet. Run the Unity menu item ``Tools/Genesis Documentation`` to capture node images._")
    }

    [void]$builder.AppendLine()
    [void]$builder.AppendLine("## Details")
    [void]$builder.AppendLine()
    [void]$builder.AppendLine("- Menu: ``$($Node.PrimaryMenu)``")

    if ($Node.Menus.Count -gt 1) {
        $aliases = @($Node.Menus | Select-Object -Skip 1 | ForEach-Object { "``$_``" }) -join ", "
        [void]$builder.AppendLine("- Aliases: $aliases")
    }

    if (-not [string]::IsNullOrWhiteSpace($Node.NodeGroup)) {
        [void]$builder.AppendLine("- Node group: ``$($Node.NodeGroup)``")
    }

    if (-not [string]::IsNullOrWhiteSpace($Node.ShaderName)) {
        [void]$builder.AppendLine("- Shader: ``$($Node.ShaderName)``")
    }

    [void]$builder.AppendLine("- Source: [$($Node.SourcePath)]($(Get-MarkdownRelativePath -FromFilePath $pagePath -ToPath $sourceFullPath))")
    [void]$builder.AppendLine()
    [void]$builder.AppendLine("## Documentation")
    [void]$builder.AppendLine()
    [void]$builder.AppendLine($Node.Documentation)

    Set-Content -Path $pagePath -Value $builder.ToString().TrimEnd() -Encoding utf8
}

function Write-CategoryPage {
    param(
        [string]$Category,
        [string]$FileName,
        [System.Collections.IEnumerable]$Nodes
    )

    $nodeList = @($Nodes | Sort-Object Subsection, Name, PrimaryMenu)
    $inlineCount = @($nodeList | Where-Object { -not $_.UsedFallback }).Count
    $fallbackCount = @($nodeList | Where-Object { $_.UsedFallback }).Count
    $path = Join-Path $outputDir $FileName
    $readmePath = Join-Path $outputDir "README.md"
    $builder = New-Object System.Text.StringBuilder

    [void]$builder.AppendLine("# Genesis Nodes: $Category")
    [void]$builder.AppendLine()
    [void]$builder.AppendLine('> This file is auto-generated by `Documentation/Generate-GenesisNodeDocs.ps1`.')
    [void]$builder.AppendLine()
    [void]$builder.AppendLine("[Back to index]($(Get-MarkdownRelativePath -FromFilePath $path -ToPath $readmePath))")
    [void]$builder.AppendLine()
    [void]$builder.AppendLine("## Overview")
    [void]$builder.AppendLine()
    [void]$builder.AppendLine("- Node count: $($nodeList.Count)")
    [void]$builder.AppendLine("- Inline docs from source: $inlineCount")
    [void]$builder.AppendLine("- Generated fallback docs: $fallbackCount")
    [void]$builder.AppendLine()

    $groups = $nodeList | Group-Object Subsection | Sort-Object Name
    foreach ($group in $groups) {
        [void]$builder.AppendLine("## $($group.Name)")
        [void]$builder.AppendLine()
        [void]$builder.AppendLine("| Node | Summary |")
        [void]$builder.AppendLine("| --- | --- |")

        foreach ($node in ($group.Group | Sort-Object Name, PrimaryMenu)) {
            $summary = Escape-MarkdownTableText $node.Summary
            $pageLink = Get-MarkdownRelativePath -FromFilePath $path -ToPath (Join-Path $outputDir ($node.NodePageRelativePath -replace "/", "\"))
            [void]$builder.AppendLine("| [$($node.Name)]($pageLink) | $summary |")
        }

        [void]$builder.AppendLine()
    }

    Set-Content -Path $path -Value $builder.ToString().TrimEnd() -Encoding utf8
}

Ensure-Directory $outputDir

if (Test-Path $nodePagesDir) {
    Get-ChildItem -Path $nodePagesDir -Force | ForEach-Object {
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

Ensure-Directory $nodePagesDir

Get-ChildItem -Path $outputDir -File -Filter *.md | ForEach-Object {
    try {
        Remove-Item -Path $_.FullName -Force -ErrorAction Stop
    }
    catch {
        # Best effort cleanup. Existing files will be overwritten below.
    }
}

$nodes = @(Resolve-NodeRecordPaths (Get-NodeRecords) | Sort-Object Root, Subsection, Name, PrimaryMenu)
$categories = $nodes | Group-Object Root | Sort-Object Name
$duplicatePages = @($nodes | Group-Object NodePageRelativePath | Where-Object { $_.Count -gt 1 })

if ($duplicatePages.Count -gt 0) {
    $duplicates = $duplicatePages | ForEach-Object { $_.Name } | Sort-Object
    throw "Duplicate generated node page paths detected: $($duplicates -join ', ')"
}

foreach ($node in $nodes) {
    Write-NodePage -Node $node
}

$readme = New-Object System.Text.StringBuilder

[void]$readme.AppendLine("# Genesis Node Reference")
[void]$readme.AppendLine()
[void]$readme.AppendLine('> This directory is auto-generated by `Documentation/Generate-GenesisNodeDocs.ps1` from `Runtime/Nodes`.')
[void]$readme.AppendLine()
[void]$readme.AppendLine("## Summary")
[void]$readme.AppendLine()
[void]$readme.AppendLine("- Unique node classes: $($nodes.Count)")
[void]$readme.AppendLine("- Top-level categories: $($categories.Count)")
[void]$readme.AppendLine("- Inline docs from source: $(@($nodes | Where-Object { -not $_.UsedFallback }).Count)")
[void]$readme.AppendLine("- Generated fallback docs: $(@($nodes | Where-Object { $_.UsedFallback }).Count)")
[void]$readme.AppendLine()
[void]$readme.AppendLine("## Categories")
[void]$readme.AppendLine()
[void]$readme.AppendLine("| Category | Nodes | Inline Docs | Fallback Docs | File |")
[void]$readme.AppendLine("| --- | ---: | ---: | ---: | --- |")

foreach ($category in $categories) {
    $categoryName = $category.Name
    $categoryNodes = @($category.Group | Sort-Object Subsection, Name, PrimaryMenu)
    $inlineCount = @($categoryNodes | Where-Object { -not $_.UsedFallback }).Count
    $fallbackCount = @($categoryNodes | Where-Object { $_.UsedFallback }).Count
    $fileName = (New-Slug $categoryName) + ".md"

    Write-CategoryPage -Category $categoryName -FileName $fileName -Nodes $categoryNodes

    [void]$readme.AppendLine("| $categoryName | $($categoryNodes.Count) | $inlineCount | $fallbackCount | [$categoryName]($fileName) |")
}

[void]$readme.AppendLine()
[void]$readme.AppendLine("## Regenerate")
[void]$readme.AppendLine()
[void]$readme.AppendLine("- Unity: run ``Tools/Genesis Documentation`` to capture screenshots and refresh all markdown pages.")
[void]$readme.AppendLine("- CLI: run the script below to refresh markdown only from the current source files.")
[void]$readme.AppendLine()
[void]$readme.AppendLine('```powershell')
[void]$readme.AppendLine("pwsh ./Documentation/Generate-GenesisNodeDocs.ps1")
[void]$readme.AppendLine('```')

Set-Content -Path (Join-Path $outputDir "README.md") -Value $readme.ToString().TrimEnd() -Encoding utf8
