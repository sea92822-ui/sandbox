param(
    [string]$username
)

$results = @{}
$found = 0
$total = 0

$sites = @{
    'Telegram'   = "https://t.me/$username"
    'Instagram'  = "https://www.instagram.com/$username/"
    'TwitterX'   = "https://twitter.com/$username"
    'GitHub'     = "https://github.com/$username"
    'TikTok'     = "https://www.tiktok.com/@$username"
    'VK'         = "https://vk.com/$username"
    'Facebook'   = "https://www.facebook.com/$username"
    'YouTube'    = "https://www.youtube.com/@$username"
    'Twitch'     = "https://www.twitch.tv/$username"
    'Reddit'     = "https://www.reddit.com/user/$username"
    'Steam'      = "https://steamcommunity.com/id/$username"
    'Spotify'    = "https://open.spotify.com/user/$username"
    'SoundCloud' = "https://soundcloud.com/$username"
    'Pinterest'  = "https://www.pinterest.com/$username"
    'Tumblr'     = "https://$username.tumblr.com"
    'Snapchat'   = "https://www.snapchat.com/add/$username"
    'Medium'     = "https://medium.com/@$username"
    'Patreon'    = "https://www.patreon.com/$username"
    'Behance'    = "https://www.behance.net/$username"
    'Dribbble'   = "https://dribbble.com/$username"
    'Codepen'    = "https://codepen.io/$username"
    'Replit'     = "https://replit.com/@$username"
    'GitLab'     = "https://gitlab.com/$username"
    'DeviantArt' = "https://www.deviantart.com/$username"
    'AboutMe'    = "https://about.me/$username"
    'Keybase'    = "https://keybase.io/$username"
    'BitBucket'  = "https://bitbucket.org/$username"
    'Flickr'     = "https://www.flickr.com/people/$username"
    'Vimeo'      = "https://vimeo.com/$username"
    'Ebay'       = "https://www.ebay.com/usr/$username"
    'Wikipedia'  = "https://en.wikipedia.org/wiki/User:$username"
    'Rumble'     = "https://rumble.com/user/$username"
    'Poshmark'   = "https://poshmark.com/closet/$username"
    'Gravatar'   = "https://en.gravatar.com/$username"
    'MySpace'    = "https://myspace.com/$username"
}

$total = $sites.Count
$i = 0

Write-Host "`n[!] Proveryu $total saitov..." -ForegroundColor Cyan
Write-Host ""

foreach ($site in $sites.Keys) {
    $i++
    $url = $sites[$site]
    $status = "NE NAIDEN"
    
    try {
        $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
        if ($r.StatusCode -eq 200) {
            $status = "NAIDEN"
            $found++
            Write-Host ("[$i/$total] [+] ${site} : $url") -ForegroundColor Green
        }
    } catch {
        Write-Host ("[$i/$total] [-] ${site}") -ForegroundColor DarkGray
    }
    
    $results[$site] = $status
}

# Write report
$desktop = [Environment]::GetFolderPath("Desktop")
$outfile = "$desktop\TG_Dox\${username}_dox.txt"

if (!(Test-Path "$desktop\TG_Dox")) {
    New-Item -ItemType Directory -Path "$desktop\TG_Dox" -Force | Out-Null
}

"================================" | Out-File $outfile
"SHERLOCK REPORT: @$username" | Out-File $outfile -Append
"Date: $(Get-Date)" | Out-File $outfile -Append
"================================" | Out-File $outfile -Append
"" | Out-File $outfile -Append
"NAIDENO SAITOV: $found из $total" | Out-File $outfile -Append
"" | Out-File $outfile -Append

"--- NAIDENO ($found) ---" | Out-File $outfile -Append
foreach ($s in ($results.Keys | Sort-Object)) {
    if ($results[$s] -eq "NAIDEN") {
        "[+] $s : $($sites[$s])" | Out-File $outfile -Append
    }
}

"" | Out-File $outfile -Append
"--- NE NAIDENO ($($total - $found)) ---" | Out-File $outfile -Append
foreach ($s in ($results.Keys | Sort-Object)) {
    if ($results[$s] -ne "NAIDEN") {
        "[-] $s" | Out-File $outfile -Append
    }
}

"" | Out-File $outfile -Append
"================================" | Out-File $outfile -Append
"GOTOVO" | Out-File $outfile -Append
"================================" | Out-File $outfile -Append

Write-Host ""
Write-Host "[!] Gotovo! Naideno $found iz $total" -ForegroundColor Green
Write-Host "[!] Otchet: $outfile" -ForegroundColor Yellow

# Keep window open
Read-Host "`nPress Enter to exit"
