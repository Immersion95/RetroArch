param(
    [Parameter(Mandatory=$true)][string]$CaptureDirectory,
    [Parameter(Mandatory=$true)][ValidateSet(0,1)][int]$ExpectedAudio,
    [int]$ExpectedFrameskip = -1,
    [string]$Executable,
    [int]$ProgramExit = 0
)
$ErrorActionPreference = 'Stop'
$meta = @{}
$flags = New-Object 'System.Collections.Generic.List[long]'
$problems = New-Object 'System.Collections.Generic.List[string]'
$ffOn = 0; $ffOff = 0; $menuOn = 0; $menuOff = 0
$csv = Join-Path $CaptureDirectory 'retroarch_frame_trace.csv'
if (Test-Path -LiteralPath $csv) {
    foreach ($line in [IO.File]::ReadLines($csv)) {
        if ($line.StartsWith('# ')) {
            $kv = $line.Substring(2).Split(@('='), 2)
            if ($kv.Length -eq 2) { $meta[$kv[0]] = $kv[1] }
        } elseif ($line -match '^\d+,') {
            $v = $line.Split(',')
            if ($v.Length -lt 7) { $problems.Add('Ligne CSV tronquee.'); continue }
            switch ($v[3]) {
                'FRAME_BEGIN' { $flags.Add([long]$v[5]) }
                'FAST_FORWARD' { if ([long]$v[5] -eq 1) { $ffOn++ } else { $ffOff++ } }
                'MENU_ENTER' { $menuOn++ }
                'MENU_EXIT' { $menuOff++ }
            }
        }
    }
} else { $problems.Add('CSV absent : mauvais executable ou fermeture anormale.') }
if ($meta['build'] -ne 'ff_audio_test_v3_1') { $problems.Add('Ce fichier ne provient pas du build FF test V3.1.') }
if ($meta['capture_started'] -ne '1') { $problems.Add('Capture non demarree : presser F12 pendant le jeu.') }
if ($meta['events_lost'] -ne '0') { $problems.Add('Le tampon est incomplet ou sature.') }
if ($meta['audio_requested'] -ne [string]$ExpectedAudio) { $problems.Add('Le mode audio demande ne correspond pas au lanceur.') }
if ($flags.Count -eq 0) { $problems.Add('Aucune frame de core enregistree.') }
$mismatch = 0
foreach ($mask in $flags) {
    $enabled = ($mask -band 128) -ne 0
    $active = ($mask -band 256) -ne 0
    $started = ($mask -band 512) -ne 0
    if ($ExpectedAudio -eq 0) {
        if ($enabled -or $active -or $started) { $mismatch++ }
    } elseif (-not $enabled -or -not $active -or -not $started) { $mismatch++ }
    if ($ExpectedFrameskip -ge 0 -and [int](($mask -band 16384) -ne 0) -ne $ExpectedFrameskip) {
        $problems.Add('Le saut d''images ne correspond pas au test demande.')
        break
    }
}
if ($mismatch -gt 0) { $problems.Add("Etat audio different du test sur $mismatch frames. Comparaison audio invalide.") }
$protocolComplete = $ffOn -gt 0 -and $ffOff -gt 0 -and $menuOn -gt 0 -and $menuOff -gt 0
if (-not $protocolComplete) { $problems.Add('Sequence incomplete : avance rapide puis retour par le menu non observes entierement.') }
Write-Host ''
Write-Host "Core : $($meta['core']) ; video active : $($meta['active_video'])"
Write-Host "Audio demande : $ExpectedAudio ; actif : $($meta['audio_active_at_start']) ; demarre : $($meta['audio_started_at_start']) ; frames : $($flags.Count)"
$before = Read-Host 'Avant avance rapide : fluide / saccade / incertain (Entree pour passer)'
$after = Read-Host 'Apres avance rapide : fluide / saccade / incertain (Entree pour passer)'
$menu = Read-Host 'Apres fermeture du menu : fluide / saccade / incertain (Entree pour passer)'
$digest = $null
if ($Executable -and (Test-Path -LiteralPath $Executable)) {
    $digest = (Get-FileHash -LiteralPath $Executable -Algorithm SHA256).Hash
}
$report = [ordered]@{
    test_valid = $problems.Count -eq 0
    expected_audio = $ExpectedAudio
    expected_frameskip = $ExpectedFrameskip
    core_frames = $flags.Count
    audio_mismatched_frames = $mismatch
    protocol_complete = $protocolComplete
    fast_forward_enter = $ffOn
    fast_forward_exit = $ffOff
    menu_enter = $menuOn
    menu_exit = $menuOff
    program_exit = $ProgramExit
    executable_sha256 = $digest
    metadata = $meta
    observations = @{ before_ff = $before; after_ff = $after; after_menu = $menu }
    problems = @($problems.ToArray())
}
$report | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $CaptureDirectory 'verification.json') -Encoding UTF8
if ($problems.Count) {
    Write-Host 'CAPTURE A VERIFIER :' -ForegroundColor Yellow
    foreach ($problem in $problems) { Write-Host "- $problem" }
} else { Write-Host 'CAPTURE VALIDE pour la comparaison demandee.' -ForegroundColor Green }
$zip = $CaptureDirectory + '.zip'
Compress-Archive -LiteralPath $CaptureDirectory -DestinationPath $zip -ErrorAction Stop
Write-Host "ZIP a transmettre : $zip"
if ($problems.Count) { exit 2 }
exit 0
