# Define the interval in seconds
#$interval = 3600
$interval = 10 #Test 10 seconds

# Define the path to the Pictures folder
$path = "$env:userprofile\Pictures\"

# Define the file name format
$fileNameFormat = "Screenshot {0:yyyy-MM-dd} at {0:HH-mm-ss}.png"

# Loop indefinitely
while ($true) {
    # Get the current date and time
    $now = Get-Date

    # Construct the file name
    $fileName = $fileNameFormat -f $now

    # Construct the full path
    $fullPath = Join-Path $path $fileName

    # Capture the screenshot
    Add-Type -AssemblyName System.Windows.Forms
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen
    $bounds = $screen.Bounds
    $bmp = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bmp)
    $graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
    $bmp.Save($fullPath)

    # Wait for the specified interval
    Start-Sleep -Seconds $interval
}
