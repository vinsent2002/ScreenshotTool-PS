#Load external assemblies
Add-Type -AssemblyName System.Windows.Forms;
Add-Type -AssemblyName System.Drawing;

#Minimize PowerShell Window
function Set-WindowState {
param(
    [Parameter()]
    [ValidateSet('FORCEMINIMIZE', 'HIDE', 'MAXIMIZE', 'MINIMIZE', 'RESTORE', 
                 'SHOW', 'SHOWDEFAULT', 'SHOWMAXIMIZED', 'SHOWMINIMIZED', 
                 'SHOWMINNOACTIVE', 'SHOWNA', 'SHOWNOACTIVATE', 'SHOWNORMAL')]
    [Alias('Style')]
    [String] $State = 'SHOW',
    
    [Parameter(ValueFromPipelineByPropertyname='True')]
    [System.IntPtr] $MainWindowHandle = (Get-Process –id $pid).MainWindowHandle,

    [Parameter()]
    [switch] $PassThru

)
BEGIN
{

$WindowStates = @{
    'FORCEMINIMIZE'   = 11
    'HIDE'            = 0
    'MAXIMIZE'        = 3
    'MINIMIZE'        = 6
    'RESTORE'         = 9
    'SHOW'            = 5
    'SHOWDEFAULT'     = 10
    'SHOWMAXIMIZED'   = 3
    'SHOWMINIMIZED'   = 2
    'SHOWMINNOACTIVE' = 7
    'SHOWNA'          = 8
    'SHOWNOACTIVATE'  = 4
    'SHOWNORMAL'      = 1
}
    
$Win32ShowWindowAsync = Add-Type –memberDefinition @” 
[DllImport("user32.dll")] 
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow); 
“@ -name “Win32ShowWindowAsync” -namespace Win32Functions –passThru

}
PROCESS
{
    $Win32ShowWindowAsync::ShowWindowAsync($MainWindowHandle, $WindowStates[$State]) | Out-Null
    Write-Verbose ("Set Window State on '{0}' to '{1}' " -f $MainWindowHandle, $State)

    if ($PassThru)
    {
        Write-Output $MainWindowHandle
    }

}
END
{
}

}

Set-Alias -Name 'Set-WindowStyle' -Value 'Set-WindowState'

#Get-Process powershell | Set-WindowState -State MINIMIZE
$process = Get-WmiObject Win32_Process | Where-Object {($_.CommandLine -like "*$PSCommandPath*") -and ($_.Name -eq "powershell.exe")}
Get-Process -id $process.ProcessId | Set-WindowState -State MINIMIZE
#Get-Process WindowsTerminal.exe | Set-WindowState -State MINIMIZE #Windows 11

$PicturesFolder = "$env:USERPROFILE\Pictures"
$SettingsRegKeyPath = "HKCU:\SOFTWARE\VinSoft"

If(!(Test-Path -Path $SettingsRegKeyPath)) {
    New-Item -Path $SettingsRegKeyPath | Out-Null
    New-ItemProperty -Path $SettingsRegKeyPath -Name "SavePath1" -Value $PicturesFolder -PropertyType String | Out-Null
    New-ItemProperty -Path $SettingsRegKeyPath -Name "SavePath2" -Value $PicturesFolder -PropertyType String | Out-Null
    New-ItemProperty -Path $SettingsRegKeyPath -Name "SavePath3" -Value $PicturesFolder -PropertyType String | Out-Null
    New-ItemProperty -Path $SettingsRegKeyPath -Name "SavePath4" -Value $PicturesFolder -PropertyType String | Out-Null
    New-ItemProperty -Path $SettingsRegKeyPath -Name "SavePath5" -Value $PicturesFolder -PropertyType String | Out-Null
}

#About
$aboutmsg = "Version: 2.0 Alpha`nDate: 2024-02-25"

# Define the form
$form = New-Object Windows.Forms.Form
$form.Text = "Alpha"
$form.Size = New-Object Drawing.Size(500, 300)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.StartPosition = "CenterScreen"
#$form.TopMost = $true #Always on top
$form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + '\powershell.exe')

$SettingsForm = new-object System.Windows.Forms.form
$SettingsForm.Size = new-object System.Drawing.Size(400, 400)
$SettingsForm.Name = "SettingsForm"
$SettingsForm.Text = "Settings"
$SettingsForm.Visible = $false
$SettingsForm.TopMost = $true #Always on top
$SettingsForm.MaximizeBox = $false
$SettingsForm.MinimizeBox = $false
$SettingsForm.StartPosition = "CenterParent"
$SettingsForm.FormBorderStyle = 'FixedDialog'
$SettingsForm.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + '\powershell.exe')

$SettingsRegKey = Get-ItemProperty -Path "HKCU:\SOFTWARE\VinSoft"

$textBox6, $textBox7, $textBox8, $textBox9, $textBox10 = 1..5 | ForEach-Object {
    New-Object System.Windows.Forms.TextBox
}

$textBoxes = @($textBox6, $textBox7, $textBox8, $textBox9, $textBox10)
$textBoxes | ForEach-Object {
    $_.Width = 300
}


$textBox6.Location = New-Object System.Drawing.Point(20, 20)
$textBox6.Text = $SettingsRegKey.SavePath1

$textBox7.Location = New-Object System.Drawing.Point(20, 50)
$textBox7.Text = $SettingsRegKey.SavePath2

$textBox8.Location = New-Object System.Drawing.Point(20, 80)
$textBox8.Text = $SettingsRegKey.SavePath3

$textBox9.Location = New-Object System.Drawing.Point(20, 110)
$textBox9.Text = $SettingsRegKey.SavePath4

$textBox10.Location = New-Object System.Drawing.Point(20, 140)
$textBox10.Text = $SettingsRegKey.SavePath5

#FolderBrowserDialog
$FolderBrowserDialog1, $FolderBrowserDialog2, $FolderBrowserDialog3, $FolderBrowserDialog4, $FolderBrowserDialog5 = 1..5 | ForEach-Object {
    New-Object System.Windows.Forms.FolderBrowserDialog
}

$FolderBrowserDialogs = @($FolderBrowserDialog1, $FolderBrowserDialog2, $FolderBrowserDialog3, $FolderBrowserDialog4, $FolderBrowserDialog5)
$FolderBrowserDialogs | ForEach-Object {
    $_.ShowNewFolderButton = $false
    $_.Description ="Select a folder to save screenshots"
}


$PathButton1 = New-Object System.Windows.Forms.Button
$PathButton1.Text = "..."
$PathButton1.Location = New-Object System.Drawing.Point(320, 20)
$PathButton1.Size = New-Object System.Drawing.Size(30,20)
$PathButton1.Add_Click({
    if ($FolderBrowserDialog1.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    #$selectedFolder = $folderBrowser.SelectedPath
    #Write-Host "Selected folder: $selectedFolder"
    $textBox6.Text = $FolderBrowserDialog1.SelectedPath
    }
})

$PathButton2 = New-Object System.Windows.Forms.Button
$PathButton2.Text = "..."
$PathButton2.Location = New-Object System.Drawing.Point(320, 50)
$PathButton2.Size = New-Object System.Drawing.Size(30,20)
$PathButton2.Add_Click({
    if ($FolderBrowserDialog2.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    #$selectedFolder = $folderBrowser.SelectedPath
    #Write-Host "Selected folder: $selectedFolder"
    $textBox7.Text = $FolderBrowserDialog2.SelectedPath
    }
})

$PathButton3 = New-Object System.Windows.Forms.Button
$PathButton3.Text = "..."
$PathButton3.Location = New-Object System.Drawing.Point(320, 80)
$PathButton3.Size = New-Object System.Drawing.Size(30,20)
$PathButton3.Add_Click({
    if ($FolderBrowserDialog3.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    #$selectedFolder = $folderBrowser.SelectedPath
    #Write-Host "Selected folder: $selectedFolder"
    $textBox8.Text = $FolderBrowserDialog3.SelectedPath
    }
})

$PathButton4 = New-Object System.Windows.Forms.Button
$PathButton4.Text = "..."
$PathButton4.Location = New-Object System.Drawing.Point(320, 110)
$PathButton4.Size = New-Object System.Drawing.Size(30,20)
$PathButton4.Add_Click({
    if ($FolderBrowserDialog4.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    #$selectedFolder = $folderBrowser.SelectedPath
    #Write-Host "Selected folder: $selectedFolder"
    $textBox9.Text = $FolderBrowserDialog4.SelectedPath
    }
})

$PathButton5 = New-Object System.Windows.Forms.Button
$PathButton5.Text = "..."
$PathButton5.Location = New-Object System.Drawing.Point(320, 140)
$PathButton5.Size = New-Object System.Drawing.Size(30,20)
$PathButton5.Add_Click({
    if ($FolderBrowserDialog5.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    #$selectedFolder = $folderBrowser.SelectedPath
    #Write-Host "Selected folder: $selectedFolder"
    $textBox10.Text = $FolderBrowserDialog5.SelectedPath
    }
})



$SettingsForm.Controls.Add($textBox6)
$SettingsForm.Controls.Add($textBox7)
$SettingsForm.Controls.Add($textBox8)
$SettingsForm.Controls.Add($textBox9)
$SettingsForm.Controls.Add($textBox10)

$SettingsForm.Controls.Add($PathButton1)
$SettingsForm.Controls.Add($PathButton2)
$SettingsForm.Controls.Add($PathButton3)
$SettingsForm.Controls.Add($PathButton4)
$SettingsForm.Controls.Add($PathButton5)


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
    $Form.Close()
    $Form.Dispose()
    Write-Host "Error" -BackgroundColor Red
})

$settingsToolStripMenuItem.Name = "settingsToolStripMenuItem"
$settingsToolStripMenuItem.Size = new-object System.Drawing.Size(152, 22)
$settingsToolStripMenuItem.Text = "&Settings"
$settingsToolStripMenuItem.Add_Click({
    #if ($StartButton.Text -eq "Start") {
    #$SettingsForm.ShowDialog()
    #} elseif ($StartButton.Text -eq "Stop")  {
    #[System.Windows.Forms.MessageBox]::Show('Press Stop button before open settings', 'Settings', 'OK', 'Information')
    #}
    $SettingsForm.ShowDialog()     
})

$helpToolStripMenuItem.Name = "helpToolStripMenuItem"
$helpToolStripMenuItem.Size = new-object System.Drawing.Size(44, 20)
$helpToolStripMenuItem.Text = "&Help"

$aboutToolStripMenuItem.Name = "aboutToolStripMenuItem"
$aboutToolStripMenuItem.Size = new-object System.Drawing.Size(152, 22)
$aboutToolStripMenuItem.Text = "&About"
$aboutToolStripMenuItem.Add_Click({

    [System.Windows.Forms.MessageBox]::Show($aboutmsg, 'About this script', 'OK', 'Information')

})


#CheckBox
$CheckBox1, $CheckBox2, $CheckBox3, $CheckBox4, $CheckBox5 = 1..5 | ForEach-Object {
    New-Object Windows.Forms.CheckBox
}


$CheckBox1.Text = "Screenshoot #1"
$CheckBox1.Location = New-Object Drawing.Point(10, 30)
$CheckBox1.Add_CheckedChanged({
    if ($checkbox1.Checked) {
        $numericUpDown1.Enabled = $true
        $numericUpDown6.Enabled = $true
        $CheckBox2.Enabled = $true 
    } else {
        $numericUpDown1.Enabled = $false
        $numericUpDown2.Enabled = $false
        $numericUpDown3.Enabled = $false
        $numericUpDown4.Enabled = $false
        $numericUpDown5.Enabled = $false
        $numericUpDown6.Enabled = $false
        
        $CheckBox2.Checked = $false
        $CheckBox3.Checked = $false
        $CheckBox4.Checked = $false
        $CheckBox5.Checked = $false
        
        $CheckBox2.Enabled = $false
        $CheckBox3.Enabled = $false
        $CheckBox4.Enabled = $false
        $CheckBox5.Enabled = $false

    }
})

$CheckBox2.Text = "Screenshoot #2"
$CheckBox2.Location = New-Object Drawing.Point(10, 50)
$CheckBox2.Enabled = $false
$CheckBox2.Add_CheckedChanged({
    if ($CheckBox2.Checked) {
        $CheckBox3.Enabled = $true
        $numericUpDown2.Enabled = $true
    } else {
        $CheckBox3.Enabled = $false
        $numericUpDown2.Enabled = $false

        $CheckBox3.Checked = $false
        $CheckBox4.Checked = $false
        $CheckBox5.Checked = $false
    }
})

$CheckBox3.Text = "Screenshoot #3"
$CheckBox3.Location = New-Object Drawing.Point(10, 70)
$CheckBox3.Enabled = $false
$CheckBox3.Add_CheckedChanged({
    if ($CheckBox3.Checked) {
        $CheckBox4.Enabled = $true
        $numericUpDown3.Enabled = $true
    } else {
        $CheckBox4.Enabled = $false
        $numericUpDown3.Enabled = $false

        $CheckBox4.Checked = $false
        $CheckBox5.Checked = $false
    }
})

$CheckBox4.Text = "Screenshoot #4"
$CheckBox4.Location = New-Object Drawing.Point(10, 90)
$CheckBox4.Enabled = $false
$CheckBox4.Add_CheckedChanged({
    if ($CheckBox4.Checked) {
        $CheckBox5.Enabled = $true
        $numericUpDown4.Enabled = $true
    } else {
        $CheckBox5.Enabled = $false
        $numericUpDown4.Enabled = $false

        $CheckBox5.Checked = $false
    }
})

$CheckBox5.Text = "Screenshoot #5"
$CheckBox5.Location = New-Object Drawing.Point(10, 110)
$CheckBox5.Enabled = $false
$CheckBox5.Add_CheckedChanged({
    if ($CheckBox5.Checked) {
        $numericUpDown5.Enabled = $true
    } else {
        $numericUpDown5.Enabled = $false
    }
})

#numericUpDown
$numericUpDown1, $numericUpDown2, $numericUpDown3, $numericUpDown4, $numericUpDown5, $numericUpDown6 = 1..6 | ForEach-Object {
    New-Object System.Windows.Forms.NumericUpDown
}

$numericUpDowns = @($numericUpDown1, $numericUpDown2, $numericUpDown3, $numericUpDown4, $numericUpDown5, $numericUpDown6)
$numericUpDowns | ForEach-Object {
    $_.Enabled = $false
    $_.Width = 60
    $_.Height = 30
    $_.DecimalPlaces = 1
    $_.Increment = 0.1
}

$numericUpDown1.Location = New-Object System.Drawing.Point(125, 30)
#$numericUpDown1.Enabled = $false
#$numericUpDown1.Size = New-Object System.Drawing.Size(20, 0)
#$numericUpDown.UpDownAlign = "Left"
#$numericUpDown.Minimum = 0
#$numericUpDown.Maximum = 10000
#$numericUpDown.Value = 0
#$numericUpDown.Increment = 1

$numericUpDown2.Location = New-Object System.Drawing.Point(125, 50)
$numericUpDown2.Value = 0.5

$numericUpDown3.Location = New-Object System.Drawing.Point(125, 70)
$numericUpDown3.Value = 1

$numericUpDown4.Location = New-Object System.Drawing.Point(125, 90)
$numericUpDown4.Value = 1.5

$numericUpDown5.Location = New-Object System.Drawing.Point(125, 110)
$numericUpDown5.Value = 2

$numericUpDown6.Location = New-Object System.Drawing.Point(125, 130)
$numericUpDown6.Minimum = 0
$numericUpDown6.Maximum = 10000
$numericUpDown6.Value = 3600

$label1, $label2, $label3, $label4, $label5, $label6 = 1..6 | ForEach-Object {
    New-Object System.Windows.Forms.Label
}

$numericUpDowns = @($label1, $label2, $label3, $label4, $label5, $label6)
$numericUpDowns | ForEach-Object {
    $_.Text = "seconds"
    $_.AutoSize = $true
}

$label1.Location = New-Object System.Drawing.Point(190, 33)

$label2.Location = New-Object System.Drawing.Point(190, 53)

$label3.Location = New-Object System.Drawing.Point(190, 73)

$label4.Location = New-Object System.Drawing.Point(190, 93)

$label5.Location = New-Object System.Drawing.Point(190, 113)

$label6.Location = New-Object System.Drawing.Point(190, 133)

#$textBoxInterval = New-Object Windows.Forms.TextBox
#$textBoxInterval.Location = New-Object Drawing.Point(150, 30)

#$labelFolder = New-Object Windows.Forms.Label
#$labelFolder.Text = "Folder Path:"
#$labelFolder.Location = New-Object Drawing.Point(20, 70)

#$textBoxFolder = New-Object Windows.Forms.TextBox
#$textBoxFolder.Location = New-Object Drawing.Point(150, 70)

# Add a button to start capturing screenshots
#$buttonStart = New-Object Windows.Forms.Button
#$buttonStart.Text = "Start Capture"
#$buttonStart.Location = New-Object Drawing.Point(150, 110)
#$buttonStart.Add_Click({
    # Get user input
#    $interval = [double]::Parse($textBoxInterval.Text)
#    $folderPath = $textBoxFolder.Text

    # Implement screenshot logic here (similar to the previous script)
    # ...

    # For now, let's just display a message
#    [Windows.Forms.MessageBox]::Show("Screenshots will be captured every $interval seconds and saved in $folderPath.")
#})

# Add controls to the form
#$form.Controls.Add($labelInterval)
#$form.Controls.Add($textBoxInterval)
#$form.Controls.Add($labelFolder)
#$form.Controls.Add($textBoxFolder)
#$form.Controls.Add($buttonStart)

$form.Controls.Add($CheckBox1)
$form.Controls.Add($CheckBox2)
$form.Controls.Add($CheckBox3)
$form.Controls.Add($CheckBox4)
$form.Controls.Add($CheckBox5)

$form.Controls.Add($numericUpDown1)
$form.Controls.Add($numericUpDown2)
$form.Controls.Add($numericUpDown3)
$form.Controls.Add($numericUpDown4)
$form.Controls.Add($numericUpDown5)
$form.Controls.Add($numericUpDown6)

$form.Controls.Add($label1)
$form.Controls.Add($label2)
$form.Controls.Add($label3)
$form.Controls.Add($label4)
$form.Controls.Add($label5)
$form.Controls.Add($label6)

$Form.Controls.Add($MenuStrip)

# Show the form
$form.ShowDialog()


#pause
