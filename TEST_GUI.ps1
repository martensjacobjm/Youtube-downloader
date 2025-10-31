# Test Windows Forms GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'TEST - Fungerar GUI?'
$form.Size = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = 'CenterScreen'

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(50, 50)
$label.Size = New-Object System.Drawing.Size(300, 30)
$label.Text = 'OM DU SER DET HAR I ETT FONSTER SA FUNGERAR GUI!'
$form.Controls.Add($label)

$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(150, 100)
$button.Size = New-Object System.Drawing.Size(100, 30)
$button.Text = 'OK'
$button.Add_Click({ $form.Close() })
$form.Controls.Add($button)

[void]$form.ShowDialog()
