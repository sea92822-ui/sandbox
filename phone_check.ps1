param(
    [string]$phone
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  PHONE DOX - POISK FIO PO NOMERU" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Clean phone
$phoneClean = $phone -replace '[^0-9]', ''

if ($phoneClean.Length -lt 7) {
    Write-Host "[-] Nomer slishkom korotkiy!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# Format display
if ($phoneClean.StartsWith("48") -and $phoneClean.Length -ge 11) {
    $local = $phoneClean.Substring(2)
    if ($local.Length -eq 9) {
        $display = "+48 $($local.Substring(0,3)) $($local.Substring(3,3)) $($local.Substring(6,3))"
    } else {
        $display = "+$phoneClean"
    }
    $country = "Poland"
} elseif ($phoneClean.StartsWith("7") -and $phoneClean.Length -ge 11) {
    $local = $phoneClean.Substring(1)
    if ($local.Length -eq 10) {
        $display = "+7 $($local.Substring(0,3)) $($local.Substring(3,3))-$($local.Substring(6,2))-$($local.Substring(8,2))"
    } else {
        $display = "+$phoneClean"
    }
    $country = "Russia"
} else {
    $display = "+$phoneClean"
    $country = "Unknown"
}

Write-Host "[*] Nomer: $display" -ForegroundColor Yellow
Write-Host "[*] Strana: $country" -ForegroundColor Yellow
Write-Host ""

# Prepare output
$desktop = [Environment]::GetFolderPath("Desktop")
$outDir = "$desktop\TG_Dox"
if (!(Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
$outFile = "$outDir\phone_${phoneClean}_dox.txt"

"========================================" | Out-File $outFile
"PHONE DOX REPORT" | Out-File $outFile -Append
"Phone: $display" | Out-File $outFile -Append
"Date: $(Get-Date)" | Out-File $outFile -Append
"========================================" | Out-File $outFile -Append
"" | Out-File $outFile -Append

# ===== 1. TELEGRAM CHECK =====
Write-Host "[1] Proveryu Telegram..." -ForegroundColor Cyan
$tgName = ""
try {
    $tgUrl1 = "https://t.me/+$phoneClean"
    $r = Invoke-WebRequest -Uri $tgUrl1 -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    
    # Try to parse name from Telegram page
    $content = $r.Content
    
    # Try og:title
    $m = [regex]::Match($content, '<meta property="og:title" content="([^"]+)"')
    if ($m.Success) {
        $tgName = $m.Groups[1].Value
        if ($tgName -ne "Telegram" -and $tgName -ne "Telegram Messenger") {
            Write-Host "  [+] Telegram name: $tgName" -ForegroundColor Green
        } else {
            $tgName = ""
        }
    }
    
    # Try canonical title
    if (!$tgName) {
        $m = [regex]::Match($content, '<title>([^<]+)</title>')
        if ($m.Success) {
            $title = $m.Groups[1].Value
            if ($title -ne "Telegram" -and $title -notlike "*Telegram*") {
                $tgName = $title
                Write-Host "  [+] Telegram title: $tgName" -ForegroundColor Green
            }
        }
    }
    
    # Try og:description
    if (!$tgName) {
        $m = [regex]::Match($content, '<meta property="og:description" content="([^"]+)"')
        if ($m.Success) {
            $desc = $m.Groups[1].Value
            if ($desc -and $desc -notlike "*Telegram*") {
                $tgName = $desc
                Write-Host "  [+] Telegram desc: $tgName" -ForegroundColor Green
            }
        }
    }
    
    if (!$tgName) {
        # Check if page says "This user doesn't exist"
        if ($content -match "doesn't exist" -or $content -match "not found") {
            Write-Host "  [-] Telegram: net akkaunta" -ForegroundColor DarkGray
        } else {
            Write-Host "  [?] Telegram: stranica est, no imya ne udalos dostat" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "  [-] Telegram: ne dostupen" -ForegroundColor DarkGray
}

if ($tgName) {
    "Telegram name: $tgName" | Out-File $outFile -Append
} else {
    "Telegram: NE NAIDEN" | Out-File $outFile -Append
}
"" | Out-File $outFile -Append

# ===== 2. WHATSAPP CHECK =====
Write-Host "[2] Proveryu WhatsApp..." -ForegroundColor Cyan
try {
    $waUrl = "https://wa.me/$phoneClean"
    $r = Invoke-WebRequest -Uri $waUrl -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($r.StatusCode -eq 200) {
        Write-Host "  [+] WhatsApp: nomer zaregistrirovan" -ForegroundColor Green
        "WhatsApp: NAIDEN ($waUrl)" | Out-File $outFile -Append
    }
} catch {
    Write-Host "  [-] WhatsApp: net ili ne dostupen" -ForegroundColor DarkGray
    "WhatsApp: NE NAIDEN" | Out-File $outFile -Append
}
"" | Out-File $outFile -Append

# ===== 3. SOCIAL SEARCH (VK, FB, IG etc) =====
Write-Host "[3] Ishu v sotsialnykh setyakh..." -ForegroundColor Cyan

$socialSites = @(
    @{Name="VK"; URL="https://vk.com/search?c%5Bq%5D=$phoneClean&c%5Bsection%5D=people"},
    @{Name="Facebook"; URL="https://www.facebook.com/search/people/?q=%2B$phoneClean"},
    @{Name="Instagram"; URL="https://www.instagram.com/web/search/topsearch/?query=$phoneClean"},
    @{Name="Odnoklassniki"; URL="https://ok.ru/search?st.query=$phoneClean"},
    @{Name="LinkedIn"; URL="https://www.linkedin.com/search/results/people/?keywords=$phoneClean"}
)

$foundSocial = @()
foreach ($s in $socialSites) {
    $name = $s.Name
    $url = $s.URL
    try {
        $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        if ($r.StatusCode -eq 200) {
            $foundSocial += $url
            Write-Host "  [+] $name" -ForegroundColor Green
        }
    } catch {
        Write-Host "  [-] $name" -ForegroundColor DarkGray
    }
}

if ($foundSocial.Count -gt 0) {
    "Sotsialnye seti (naydeno):" | Out-File $outFile -Append
    foreach ($url in $foundSocial) { "  $url" | Out-File $outFile -Append }
} else {
    "Sotsialnye seti: NE NAIDENO" | Out-File $outFile -Append
}
"" | Out-File $outFile -Append

# ===== 4. LEAK DATABASES =====
Write-Host "[4] Ssylki na bazy utechek..." -ForegroundColor Cyan

$leakSites = @(
    @{Name="LeakCheck"; URL="https://leakcheck.io/search?q=$phoneClean"},
    @{Name="Scylla"; URL="https://scylla.so/search?q=$phoneClean"},
    @{Name="IntelX"; URL="https://intelx.io/?s=%2B$phoneClean"},
    @{Name="SnusBase"; URL="https://snusbase.com/search?q=$phoneClean"},
    @{Name="HashesOrg"; URL="https://hashes.org/search?q=$phoneClean"},
    @{Name="Dehashed"; URL="https://dehashed.com/search?q=$phoneClean"}
)

"Bazy utechek (otkryt vruchnuyu):" | Out-File $outFile -Append
foreach ($s in $leakSites) {
    Write-Host "  [?] $($s.Name): $($s.URL)" -ForegroundColor Yellow
    "  $($s.Name): $($s.URL)" | Out-File $outFile -Append
}
"" | Out-File $outFile -Append

# ===== 5. PHONE LOOKUP SERVICES =====
Write-Host "[5] Ssylki na phone-lookup..." -ForegroundColor Cyan

$phoneSites = @(
    @{Name="GetContact"; URL="https://getcontact.com/en/search?q=$phoneClean"},
    @{Name="Truecaller"; URL="https://www.truecaller.com/search/$phoneClean"},
    @{Name="Numlookup"; URL="https://www.numlookup.com/$phoneClean"},
    @{Name="Phonebooks"; URL="https://www.phonebooks.com/search/$phoneClean"}
)

if ($country -eq "Poland") {
    $phoneSites += @{Name="PanParabola"; URL="https://panparabola.pl/szukaj?q=$phoneClean"}
    $phoneSites += @{Name="SpisAbonentow"; URL="https://www.spisabonentow.pl/szukaj/$phoneClean"}
    $phoneSites += @{Name="TeleAdres"; URL="https://teleadreson.pl/search?q=$phoneClean"}
}

"Phone lookup (otkryt vruchnuyu):" | Out-File $outFile -Append
foreach ($s in $phoneSites) {
    Write-Host "  [?] $($s.Name): $($s.URL)" -ForegroundColor Yellow
    "  $($s.Name): $($s.URL)" | Out-File $outFile -Append
}
"" | Out-File $outFile -Append

# ===== 6. GOOGLE DORKS =====
Write-Host "[6] Google Dorks..." -ForegroundColor Cyan
$dorkUrl = "https://www.google.com/search?q=%2B$phoneClean"
$yandexUrl = "https://yandex.ru/search/?text=%2B$phoneClean"
Write-Host "  [?] Google: $dorkUrl" -ForegroundColor Yellow
Write-Host "  [?] Yandex: $yandexUrl" -ForegroundColor Yellow
"" | Out-File $outFile -Append
"Google: $dorkUrl" | Out-File $outFile -Append
"Yandex: $yandexUrl" | Out-File $outFile -Append
"" | Out-File $outFile -Append

# ===== SUMMARY =====
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
if ($tgName) {
    Write-Host "[!] FIO naideno v Telegram: $tgName" -ForegroundColor Green
    Write-Host "[!] Otchet: $outFile" -ForegroundColor Yellow
    
    "========================================" | Out-File $outFile -Append
    "FIO: $tgName" | Out-File $outFile -Append
    "========================================" | Out-File $outFile -Append
} else {
    Write-Host "[!] FIO ne naideno avtomaticheski" -ForegroundColor Red
    Write-Host "[!] Otkroy ssylki v otchete vruchnuyu" -ForegroundColor Yellow
    Write-Host "[!] Otchet: $outFile" -ForegroundColor Yellow
}

"========================================" | Out-File $outFile -Append
"Generated by TG DOX v4.0" | Out-File $outFile -Append
"========================================" | Out-File $outFile -Append

Read-Host "`nPress Enter to exit"
