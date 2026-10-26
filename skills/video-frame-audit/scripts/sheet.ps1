# sheet.ps1 <video> <n> <cols> <cellW> <cellH> <out.jpg>  : n evenly spaced frames tiled into one contact sheet
param($video, [int]$n, [int]$cols, [int]$cw, [int]$ch, $out)
$ff = '%USERPROFILE%\YouTubeChannel\v4\node_modules\@remotion\compositor-win32-x64-msvc'
$dur = [double](& "$ff\ffprobe.exe" -v error -show_entries format=duration -of csv=p=0 $video)
$tmp = Join-Path $env:TEMP "sheet_$([guid]::NewGuid().ToString('N'))"; New-Item -ItemType Directory $tmp | Out-Null
Add-Type -AssemblyName System.Drawing
$rows = [math]::Ceiling($n / $cols)
$bmp = New-Object System.Drawing.Bitmap ($cols * $cw), ($rows * $ch)
$g = [System.Drawing.Graphics]::FromImage($bmp); $g.Clear([System.Drawing.Color]::Black)
$font = New-Object System.Drawing.Font 'Arial', 11
# extract all frames in parallel (one ffmpeg per frame), then tile
$procs = for ($i = 0; $i -lt $n; $i++) {
  $t = $dur * ($i + 0.5) / $n
  Start-Process -FilePath "$ff\ffmpeg.exe" -ArgumentList @('-v','error','-y','-ss',"$t",'-i',"`"$video`"",'-frames:v','1','-vf',"scale=$($cw):$($ch)","`"$(Join-Path $tmp "$i.jpg")`"") -NoNewWindow -PassThru
}
$procs | Wait-Process
for ($i = 0; $i -lt $n; $i++) {
  $t = $dur * ($i + 0.5) / $n
  $f = Join-Path $tmp "$i.jpg"
  if (Test-Path $f) {
    $img = [System.Drawing.Image]::FromFile($f)
    $x = ($i % $cols) * $cw; $y = [math]::Floor($i / $cols) * $ch
    $g.DrawImage($img, $x, $y, $cw, $ch); $img.Dispose()
    $g.FillRectangle([System.Drawing.Brushes]::Black, $x, $y, 52, 18)
    $g.DrawString(('{0:0.0}s' -f $t), $font, [System.Drawing.Brushes]::Yellow, $x + 2, $y + 1)
  }
}
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Jpeg); $g.Dispose(); $bmp.Dispose()
Remove-Item -Recurse -Force $tmp
"$out  dur=$dur"

