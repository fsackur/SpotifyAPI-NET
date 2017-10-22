
using namespace SpotifyAPI.Local
using namespace SpotifyAPI.Local.Enums
using namespace SpotifyAPI.Local.Models
Add-Type -Path C:\dev\SpotifyAPI-NET\SpotifyAPI.Example\bin\Debug\SpotifyAPI.dll

Update-FormatData Spotify.Format.ps1xml

if (-not $SpotifyLocal) {
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
    $Global:SpotifyLocal = New-Object SpotifyLocalAPI ($ApiConfig)
    if (-not $SpotifyLocal.Connect()) {
        $ApiConfig.HostUrl = "http://$($Listening.LocalAddress)"
        $Global:SpotifyLocal = New-Object SpotifyLocalAPI ($ApiConfig)
        if (-not $SpotifyLocal.Connect()) {
            throw "Failed to connect to local Spotify instance"
        }
    }

}

function Play-Track {
    $null = $SpotifyLocal.Play()
}

function Pause-Track {
    $null = $SpotifyLocal.Pause()
}

function Get-Track {
    $Track = $SpotifyLocal.GetStatus().Track
    $Track | 
        Add-Member -MemberType ScriptProperty -Name Track -Value {$this.TrackResource.Name} -PassThru | 
        Add-Member -MemberType ScriptProperty -Name Artist -Value {$this.ArtistResource.Name} -PassThru | 
        Add-Member -MemberType ScriptProperty -Name Album -Value {$this.AlbumResource.Name} -PassThru
}