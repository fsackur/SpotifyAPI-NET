
using namespace SpotifyAPI.Local
using namespace SpotifyAPI.Local.Enums
using namespace SpotifyAPI.Local.Models
Add-Type -Path C:\dev\SpotifyAPI-NET\SpotifyAPI.Example\bin\Debug\SpotifyAPI.dll


if (-not $Spotify) {
    if (-not [SpotifyLocalAPI]::IsSpotifyRunning()) {
        throw "Spotify is not running"
    }
    if (-not [SpotifyLocalAPI]::IsSpotifyWebHelperRunning()) {
        throw "Spotify web helper is not running"
    }
    
    $SpotifyProcessIds = (Get-Process Spotify).Id
    $Listening = Get-NetTCPConnection -OwningProcess $SpotifyProcessIds -LocalAddress "127.0.0.1" -State Listen

    $ApiConfig = [SpotifyLocalAPIConfig]::new()
    $ApiConfig.Port = $Listening.LocalPort
    $ApiConfig.HostUrl = "https://$($Listening.LocalAddress)"
    $Global:Spotify = New-Object SpotifyLocalAPI ($ApiConfig)
    if (-not $Spotify.Connect()) {
        $ApiConfig.HostUrl = "http://$($Listening.LocalAddress)"
        $Global:Spotify = New-Object SpotifyLocalAPI ($ApiConfig)
        if (-not $Spotify.Connect()) {
            throw "Failed to connect to local Spotify instance"
        }
    }

}

function Play-Track {
    $null = $Spotify.Play()
}

function Pause-Track {
    $null = $Spotify.Pause()
}

function Get-Track {
    $Spotify.GetStatus().Track
}