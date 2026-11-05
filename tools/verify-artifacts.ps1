param([string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot))

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$versionLine = Get-Content -LiteralPath (Join-Path $ProjectRoot 'gradle.properties') |
    Where-Object { $_ -match '^mod_version=' }
$modVersion = ($versionLine -split '=', 2)[1].Trim()

$targets = @(
    @{ Folder = 'build/stonecutter/1.20.1/fabric/libs'; Name = 'unilib-fabric-1.20.1'; Entry = 'fabric/UniLibFabric'; Metadata = 'fabric.mod.json'; Major = 61; Minecraft = '1.20.1' },
    @{ Folder = 'build/stonecutter/1.20.1/forge/libs'; Name = 'unilib-forge-1.20.1'; Entry = 'forge/UniLibForge'; Metadata = 'META-INF/mods.toml'; Major = 61; Minecraft = '1.20.1' },
    @{ Folder = 'build/stonecutter/1.21.1/fabric/libs'; Name = 'unilib-fabric-1.21.1'; Entry = 'fabric/UniLibFabric'; Metadata = 'fabric.mod.json'; Major = 65; Minecraft = '1.21.1' },
    @{ Folder = 'build/stonecutter/1.21.1/forge/libs'; Name = 'unilib-forge-1.21.1'; Entry = 'forge/UniLibForge'; Metadata = 'META-INF/mods.toml'; Major = 65; Minecraft = '1.21.1' },
    @{ Folder = 'build/stonecutter/1.21.1/neoforge/libs'; Name = 'unilib-neoforge-1.21.1'; Entry = 'neoforge/UniLibNeoForge'; Metadata = 'META-INF/neoforge.mods.toml'; Major = 65; Minecraft = '1.21.1' },
    @{ Folder = '1.7.10-gtnh/build/libs'; Name = 'unilib-gtnh-1.7.10'; Entry = 'gtnh/UniLibGTNH'; Metadata = 'mcmod.info'; Major = 65; Minecraft = '1.7.10' },
    @{ Folder = '1.12.2-cleanroom/build/libs'; Name = 'unilib-cleanroom-1.12.2'; Entry = 'cleanroom/UniLibCleanroom'; Metadata = 'mcmod.info'; Major = 69; Minecraft = '1.12.2' }
)

function Read-ZipText($Archive, [string]$Path) {
    $entry = $Archive.GetEntry($Path)
    if ($null -eq $entry) { throw "Missing archive entry: $Path" }
    $reader = [System.IO.StreamReader]::new($entry.Open())
    try { return $reader.ReadToEnd() } finally { $reader.Dispose() }
}

function Assert-ClassVersion($Archive, [string]$Path, [int]$Expected) {
    $entry = $Archive.GetEntry($Path)
    if ($null -eq $entry) { throw "Missing class: $Path" }
    $stream = $entry.Open()
    try {
        $bytes = [byte[]]::new(8)
        $read = 0
        while ($read -lt 8) {
            $count = $stream.Read($bytes, $read, 8 - $read)
            if ($count -eq 0) { throw "Truncated class: $Path" }
            $read += $count
        }
        $actual = [int]$bytes[6] * 256 + [int]$bytes[7]
        if ($actual -ne $Expected) { throw "${Path}: expected class version $Expected, got $actual" }
    } finally { $stream.Dispose() }
}

foreach ($target in $targets) {
    $jarPath = Join-Path $ProjectRoot "$($target.Folder)/$($target.Name)-$modVersion.jar"
    $archive = [System.IO.Compression.ZipFile]::OpenRead($jarPath)
    try {
        Assert-ClassVersion $archive 'dev/sixik/unilib/UniLib.class' 61
        Assert-ClassVersion $archive "dev/sixik/unilib/$($target.Entry).class" $target.Major
        $metadata = Read-ZipText $archive $target.Metadata
        if ($metadata.Contains('${')) { throw "Unexpanded metadata in $jarPath" }
        if (-not $metadata.Contains($modVersion)) { throw "Incorrect mod version in $jarPath" }
        if (-not $metadata.Contains($target.Minecraft)) { throw "Incorrect Minecraft version in $jarPath" }
        if ($target.Metadata.EndsWith('.json') -or $target.Metadata -eq 'mcmod.info') {
            $parsed = $metadata | ConvertFrom-Json
            if ($target.Metadata -eq 'mcmod.info') {
                if ($parsed[0].modid -ne 'unilib') { throw "Incorrect mod ID in $jarPath" }
            } elseif ($parsed.id -ne 'unilib') { throw "Incorrect mod ID in $jarPath" }
        }
        if ($target.Entry -eq 'gtnh/UniLibGTNH') {
            $tags = Read-ZipText $archive 'dev/sixik/unilib/gtnh/Tags.class'
            if (-not $tags.Contains($modVersion) -or $tags.Contains('NO-GIT-TAG-SET')) {
                throw "Incorrect GTNH annotation version in $jarPath"
            }
        }
        Write-Output "OK $($target.Name)-$modVersion.jar"
    } finally { $archive.Dispose() }
}
