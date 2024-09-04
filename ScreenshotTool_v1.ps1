#Load external assemblies
Add-Type -AssemblyName System.Windows.Forms;
Add-Type -AssemblyName System.Drawing;

#[void] [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
#[void] [Reflection.Assembly]::LoadWithPartialName("System.Drawing")

$aboutmsg = "Version: 1.0`nDate: 2024-01-21"

# Define the path to the Pictures folder
$path = "$env:userprofile\Pictures\Test\"

# Define the file name format
$fileNameFormat = "Screenshot {0:yyyy-MM-dd} at {0:HH-mm-ss}.png"

# Define the path to the ini file
$iniPath = "$env:localappdata\settings.ini"


# Create the menu strip
$MenuStrip = new-object System.Windows.Forms.MenuStrip
$fileToolStripMenuItem = new-object System.Windows.Forms.ToolStripMenuItem
$exitToolStripMenuItem = new-object System.Windows.Forms.ToolStripMenuItem
$settingsToolStripMenuItem = new-object System.Windows.Forms.ToolStripMenuItem
$helpToolStripMenuItem = new-object System.Windows.Forms.ToolStripMenuItem
$aboutToolStripMenuItem = new-object System.Windows.Forms.ToolStripMenuItem

# Add the menu items to the menu strip
$MenuStrip.Items.AddRange(@($fileToolStripMenuItem, $helpToolStripMenuItem))
$fileToolStripMenuItem.DropDownItems.AddRange(@($settingsToolStripMenuItem, $exitToolStripMenuItem))
$helpToolStripMenuItem.DropDownItems.AddRange(@($aboutToolStripMenuItem))

# Set the properties of the menu items
$fileToolStripMenuItem.Name = "fileToolStripMenuItem"
$fileToolStripMenuItem.Size = new-object System.Drawing.Size(35, 20)
$fileToolStripMenuItem.Text = "&File"

$exitToolStripMenuItem.Name = "exitToolStripMenuItem"
$exitToolStripMenuItem.Size = new-object System.Drawing.Size(152, 22)
$exitToolStripMenuItem.Text = "E&xit"
$exitToolStripMenuItem.Add_Click({
    $MainForm.Close()
})

$settingsToolStripMenuItem.Name = "settingsToolStripMenuItem"
$settingsToolStripMenuItem.Size = new-object System.Drawing.Size(152, 22)
$settingsToolStripMenuItem.Text = "&Settings"
$settingsToolStripMenuItem.Add_Click({
    if ($StartButton.Text -eq "Start") {
    $SettingsForm.ShowDialog()
    } elseif ($StartButton.Text -eq "Stop")  {
    [System.Windows.Forms.MessageBox]::Show('Press Stop button before open settings', 'Settings', 'OK', 'Information')
    }     
})

$helpToolStripMenuItem.Name = "helpToolStripMenuItem"
$helpToolStripMenuItem.Size = new-object System.Drawing.Size(44, 20)
$helpToolStripMenuItem.Text = "&Help"

$aboutToolStripMenuItem.Name = "aboutToolStripMenuItem"
$aboutToolStripMenuItem.Size = new-object System.Drawing.Size(152, 22)
$aboutToolStripMenuItem.Text = "&About"
$aboutToolStripMenuItem.Add_Click({
    #[System.Windows.Forms.MessageBox]::Show("Hello")
    [System.Windows.Forms.MessageBox]::Show($aboutmsg, 'About', 'OK', 'Information')

})

#############################################################################################

$timer = New-Object System.Windows.Forms.Timer
$timer.add_Tick({
            $timer.Interval = $numericUpDown.Value * 1000
            
            $iniContent = Get-Content -Path $iniPath
            #Write-Host $iniContent
                
            # Get the current date and time
            $now = Get-Date

            # Construct the file name
            $fileName = $fileNameFormat -f $now

            # Construct the full path
            $fullPath = Join-Path $iniContent $fileName

            # Capture the screenshot
            Add-Type -AssemblyName System.Windows.Forms
            $screen = [System.Windows.Forms.Screen]::PrimaryScreen
            $bounds = $screen.Bounds
            $bmp = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
            $graphics = [System.Drawing.Graphics]::FromImage($bmp)
            $graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
            $bmp.Save($fullPath)
            Write-Host "Screenshot was saved" $now

        })


# Create the forms
$MainForm = new-object System.Windows.Forms.form
$MainForm.Size = New-Object System.Drawing.Size(200, 150)
$MainForm.MainMenuStrip = $MenuStrip
$MainForm.Name = "MenuForm"
$MainForm.FormBorderStyle = 'FixedDialog'
$MainForm.MaximizeBox = $false
$MainForm.StartPosition = "CenterScreen"
#$MainForm.TopMost = $true #Always on top
$MainForm.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + '\powershell.exe')


# Create the settings window

If(!(Test-Path $iniPath)) {
    $iniDefalutContent = [Environment]::GetFolderPath("MyPictures")
    New-Item -ItemType File -Path $iniPath -Force | Out-Null
    Set-Content -Path $iniPath -Value $iniDefalutContent
}

$SettingsForm = new-object System.Windows.Forms.form
$SettingsForm.Size = new-object System.Drawing.Size(320, 120)
$SettingsForm.Name = "SettingsForm"
$SettingsForm.Text = "Settings"
$SettingsForm.Visible = $false
#$SettingsForm.TopMost = $true #Always on top
$SettingsForm.MaximizeBox = $false
$SettingsForm.MinimizeBox = $false
$SettingsForm.StartPosition = "CenterParent"
$SettingsForm.FormBorderStyle = 'FixedDialog'
$SettingsForm.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + '\powershell.exe')


$iniContent = Get-Content -Path $iniPath

######

$label2 = New-Object System.Windows.Forms.Label
$label2.Text = "Save screenshots in"
$label2.AutoSize = $true
$label2.Location = New-Object System.Drawing.Point(10, 10)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,25)
$textBox.Size = New-Object System.Drawing.Size(260,30)
$textBox.Text = $iniContent
$SettingsForm.Controls.Add($textBox)

$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = "OK"
$okButton.Location = New-Object System.Drawing.Point(10, 50)
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$SettingsForm.AcceptButton = $okButton
$okButton.Add_Click({
Set-Content -Path $iniPath -Value $FolderBrowser.SelectedPath
$FolderBrowser.Dispose()
})

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Text = "Cancel"
$cancelButton.Location = New-Object System.Drawing.Point(100,50)
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$SettingsForm.CancelButton = $cancelButton
$cancelButton.Add_Click({
$textBox.Text = $iniContent
})


$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.ShowNewFolderButton = $false
$folderBrowser.Description = "Select a folder"
#$folderBrowser.RootFolder = "MyComputer"



$PathButton = New-Object System.Windows.Forms.Button
$PathButton.Text = "..."
$PathButton.Location = New-Object System.Drawing.Point(270, 25)
$PathButton.Size = New-Object System.Drawing.Size(30,20)
$PathButton.Add_Click({
    if (($null = $folderBrowser.ShowDialog()) -eq "OK") {
    #$selectedFolder = $folderBrowser.SelectedPath
    #Write-Host "Selected folder: $selectedFolder"
    $textBox.Text = $FolderBrowser.SelectedPath
    }
})

$SettingsForm.Controls.Add($label2)
$SettingsForm.Controls.Add($okButton)
$SettingsForm.Controls.Add($cancelButton)
$SettingsForm.Controls.Add($PathButton)


$label = New-Object System.Windows.Forms.Label
$label.Text = "Select interval in seconds"
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(10, 30)

$numericUpDown = New-Object System.Windows.Forms.NumericUpDown
$numericUpDown.Location = New-Object System.Drawing.Point(10, 50)
#$numericUpDown.Size = New-Object System.Drawing.Size(120, 0)
#$numericUpDown.UpDownAlign = "Left"
$numericUpDown.Minimum = 0
$numericUpDown.Maximum = 10000
$numericUpDown.Value = 3600
$numericUpDown.Increment = 1

$StartButton = New-Object System.Windows.Forms.Button
$StartButton.Text = "Start"
$StartButton.Location = New-Object System.Drawing.Point(10, 80)
#$StartButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$StartButton.add_Click({
    if ($StartButton.Text -eq "Start") {
        $StartButton.Text = "Stop"
        $timer.Start()
    } elseif ($StartButton.Text -eq "Stop") {
        $StartButton.Text = "Start"
        $timer.Stop()        
    }
})

$MainForm.Controls.Add($MenuStrip)
$MainForm.Controls.Add($label)
$MainForm.Controls.Add($numericUpDown)
$MainForm.Controls.Add($StartButton)


# Show the form
$MainForm.ShowDialog()

# Free resources
$MainForm.Dispose()
