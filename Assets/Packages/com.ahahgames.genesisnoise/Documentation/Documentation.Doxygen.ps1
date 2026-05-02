$script:GenesisDocsDoxygenHtmlDir = $null
$script:GenesisDocsDoxygenXmlDir = $null
$script:GenesisDocsDoxygenSourcePageMap = $null
$script:GenesisDocsDoxygenWarningKeys = @{}

function Initialize-DoxygenLinkSupport {
    param([string]$ScriptDirectory)

    $doxygenRoot = Join-Path $ScriptDirectory "Doxygen"
    $script:GenesisDocsDoxygenHtmlDir = Join-Path $doxygenRoot "html"
    $script:GenesisDocsDoxygenXmlDir = Join-Path $doxygenRoot "xml"
    $script:GenesisDocsDoxygenSourcePageMap = $null
    $script:GenesisDocsDoxygenWarningKeys = @{}
}

function Normalize-GenesisDocsSourcePath {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    $normalized = $Path.Replace("\", "/")

    while ($normalized.StartsWith("./", [System.StringComparison]::Ordinal)) {
        $normalized = $normalized.Substring(2)
    }

    $normalized = $normalized.TrimStart("/")
    $packagePrefix = "Packages/com.ahahgames.genesisnoise/"
    if ($normalized.StartsWith($packagePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        $normalized = $normalized.Substring($packagePrefix.Length)
    }

    return $normalized
}

function Write-DoxygenWarningOnce {
    param(
        [string]$Key,
        [string]$Message
    )

    if ($script:GenesisDocsDoxygenWarningKeys.ContainsKey($Key)) {
        return
    }

    $script:GenesisDocsDoxygenWarningKeys[$Key] = $true
    Write-Warning $Message
}

function Get-GenesisDoxygenSourcePageMap {
    if ($null -ne $script:GenesisDocsDoxygenSourcePageMap) {
        return $script:GenesisDocsDoxygenSourcePageMap
    }

    $map = @{}
    $indexPath = Join-Path $script:GenesisDocsDoxygenXmlDir "index.xml"
    if (-not (Test-Path $indexPath)) {
        Write-DoxygenWarningOnce -Key "missing-index" -Message "Doxygen XML index was not found. Falling back to direct source links."
        $script:GenesisDocsDoxygenSourcePageMap = $map
        return $map
    }

    [xml]$indexDocument = Get-Content -LiteralPath $indexPath -Raw
    $fileCompounds = @($indexDocument.doxygenindex.compound | Where-Object { $_.kind -eq "file" })

    foreach ($compound in $fileCompounds) {
        $refId = [string]$compound.refid
        if ([string]::IsNullOrWhiteSpace($refId)) {
            continue
        }

        $compoundPath = Join-Path $script:GenesisDocsDoxygenXmlDir ($refId + ".xml")
        if (-not (Test-Path $compoundPath)) {
            continue
        }

        try {
            [xml]$compoundDocument = Get-Content -LiteralPath $compoundPath -Raw
            $locationNode = @($compoundDocument.doxygen.compounddef.location | Select-Object -First 1)
            $rawPath = if ($locationNode.Count -gt 0) { [string]$locationNode[0].file } else { "" }

            if ([string]::IsNullOrWhiteSpace($rawPath)) {
                $rawPath = [string]$compound.name
            }

            $normalizedPath = Normalize-GenesisDocsSourcePath $rawPath
            if ([string]::IsNullOrWhiteSpace($normalizedPath)) {
                continue
            }

            $map[$normalizedPath] = $refId + "_source.html"
        }
        catch {
            Write-DoxygenWarningOnce -Key ("compound-" + $refId) -Message ("Failed to read Doxygen XML for '{0}'. Falling back to direct source links when needed." -f $refId)
        }
    }

    $script:GenesisDocsDoxygenSourcePageMap = $map
    return $map
}

function Get-GenesisDoxygenSourceRelativeLink {
    param(
        [string]$FromFilePath,
        [string]$SourcePath
    )

    $normalizedSourcePath = Normalize-GenesisDocsSourcePath $SourcePath
    if ([string]::IsNullOrWhiteSpace($normalizedSourcePath)) {
        return $null
    }

    $map = Get-GenesisDoxygenSourcePageMap
    if (-not $map.ContainsKey($normalizedSourcePath)) {
        Write-DoxygenWarningOnce -Key ("missing-source-" + $normalizedSourcePath) -Message ("No Doxygen source page was found for '{0}'. Falling back to a direct source link." -f $normalizedSourcePath)
        return $null
    }

    $htmlPath = Join-Path $script:GenesisDocsDoxygenHtmlDir $map[$normalizedSourcePath]
    if (-not (Test-Path $htmlPath)) {
        Write-DoxygenWarningOnce -Key ("missing-html-" + $normalizedSourcePath) -Message ("Doxygen generated no HTML source page for '{0}'. Falling back to a direct source link." -f $normalizedSourcePath)
        return $null
    }

    return Get-MarkdownRelativePath -FromFilePath $FromFilePath -ToPath $htmlPath
}

function Get-GenesisDocumentationSourceLink {
    param(
        [string]$FromFilePath,
        [string]$SourcePath,
        [string]$PackageRoot
    )

    $doxygenLink = Get-GenesisDoxygenSourceRelativeLink -FromFilePath $FromFilePath -SourcePath $SourcePath
    if (-not [string]::IsNullOrWhiteSpace($doxygenLink)) {
        return $doxygenLink
    }

    $sourceFullPath = Join-Path $PackageRoot ($SourcePath -replace "/", "\")
    return Get-MarkdownRelativePath -FromFilePath $FromFilePath -ToPath $sourceFullPath
}
