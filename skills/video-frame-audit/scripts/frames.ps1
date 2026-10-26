# frames.ps1 <video> "t1,t2,..." <out.jpg> [cellW]  : exact timestamps in a grid (4 per row), time printed on each cell
param($video, $times, $out, [int]$cw = 480)
$ff = '%USERPROFILE%\YouTubeChannel\v4\node_modules\@remotion\compositor-win32-x64-msvc'
$ts = $times -split ',' | ForEach-Object { [double]$_.Trim() }
$w = (& "$ff\ffprobe.exe" -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 $video) -split ','
$ch = [int]([math]::Round($cw * [int]$w[1] / [int]$w[0]))
$tmp = Join-Path $env:TEMP "frames_$([guid]::NewGuid().ToString('N'))"; New-Item -ItemType Directory $tmp | Out-Null
$procs = for ($i = 0; $i -lt $ts.Count; $i++) {
  Start-Process -FilePath "$ff\ffmpeg.exe" -ArgumentList @('-v','error','-y','-ss',"$($ts[$i])",'-i',"`"$video`"",'-frames:v','1','-vf',"scale=$($cw):$($ch)","`"$(Join-Path $tmp "$i.jpg")`"") -NoNewWindow -PassThru
}
$procs | Wait-Process
Add-Type -AssemblyName System.Drawing
$cols = [math]::Min(4, $ts.Count); $rows = [math]::Ceiling($ts.Count / 4)
$bmp = New-Object System.Drawing.Bitmap ($cols * $cw), ($rows * $ch)
$g = [System.Drawing.Graphics]::FromImage($bmp); $g.Clear([System.Drawing.Color]::Black)
$font = New-Object System.Drawing.Font 'Arial', 13
for ($i = 0; $i -lt $ts.Count; $i++) {
  $f = Join-Path $tmp "$i.jpg"
  if (Test-Path $f) {
    $img = [System.Drawing.Image]::FromFile($f)
    $x = ($i % 4) * $cw; $y = [math]::Floor($i / 4) * $ch
    $g.DrawImage($img, $x, $y, $cw, $ch); $img.Dispose()
    $g.FillRectangle([System.Drawing.Brushes]::Black, $x, $y, 70, 22)
    $g.DrawString(('{0:0.0}s' -f $ts[$i]), $font, [System.Drawing.Brushes]::Yellow, $x + 2, $y + 2)
  }
}
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Jpeg); $g.Dispose(); $bmp.Dispose()
Remove-Item -Recurse -Force $tmp
$out
