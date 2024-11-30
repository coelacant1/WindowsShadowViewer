Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

try {
    # File paths for saving user and computer names
    $scriptPath = $PSScriptRoot
    $savedDataPath = "$scriptPath\SavedData.csv"

    # Load saved data if available
    $usernames = New-Object System.Collections.Generic.List[string]
    $computernames = New-Object System.Collections.Generic.List[string]
    if (Test-Path $savedDataPath) {
        $savedData = Get-Content $savedDataPath -Raw
        $savedLines = $savedData -split "`n"
        if ($savedLines.Length -ge 2) {
            $usernames.AddRange($savedLines[0] -split ",")
            $computernames.AddRange($savedLines[1] -split ",")
        }
    }

    # Form setup
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Shadow Viewer Tool - CC 2024"
    $form.Size = New-Object System.Drawing.Size(480, 300)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.ControlBox = $true

    # Computer Name label and dropdown
    $computerLabel = New-Object System.Windows.Forms.Label
    $computerLabel.Text = "Computer Name:"
    $computerLabel.Location = New-Object System.Drawing.Point(10, 20)
    $computerLabel.Size = New-Object System.Drawing.Size(120, 20)
    $form.Controls.Add($computerLabel)

    $computerInput = New-Object System.Windows.Forms.ComboBox
    $computerInput.Location = New-Object System.Drawing.Point(140, 20)
    $computerInput.Size = New-Object System.Drawing.Size(200, 20)
    $computerInput.DropDownStyle = 'DropDown'
    $computerInput.Items.AddRange($computernames)
    $computerInput.Text = ""
    $form.Controls.Add($computerInput)

    # Username label and dropdown
    $usernameLabel = New-Object System.Windows.Forms.Label
    $usernameLabel.Text = "SSH Username:"
    $usernameLabel.Location = New-Object System.Drawing.Point(10, 60)
    $usernameLabel.Size = New-Object System.Drawing.Size(120, 20)
    $form.Controls.Add($usernameLabel)

    $usernameInput = New-Object System.Windows.Forms.ComboBox
    $usernameInput.Location = New-Object System.Drawing.Point(140, 60)
    $usernameInput.Size = New-Object System.Drawing.Size(200, 20)
    $usernameInput.DropDownStyle = 'DropDown'
    $usernameInput.Items.AddRange($usernames)
    $usernameInput.Text = ""
    $form.Controls.Add($usernameInput)

    # Password label and textbox
    $passwordLabel = New-Object System.Windows.Forms.Label
    $passwordLabel.Text = "SSH Password:"
    $passwordLabel.Location = New-Object System.Drawing.Point(10, 100)
    $passwordLabel.Size = New-Object System.Drawing.Size(120, 20)
    $form.Controls.Add($passwordLabel)

    $passwordInput = New-Object System.Windows.Forms.TextBox
    $passwordInput.Location = New-Object System.Drawing.Point(140, 100)
    $passwordInput.Size = New-Object System.Drawing.Size(200, 20)
    $passwordInput.UseSystemPasswordChar = $true
    $form.Controls.Add($passwordInput)

    # Session ID label and textbox (read-only)
    $sessionLabel = New-Object System.Windows.Forms.Label
    $sessionLabel.Text = "Session ID:"
    $sessionLabel.Location = New-Object System.Drawing.Point(10, 140)
    $sessionLabel.Size = New-Object System.Drawing.Size(120, 20)
    $form.Controls.Add($sessionLabel)

    $sessionInput = New-Object System.Windows.Forms.TextBox
    $sessionInput.Location = New-Object System.Drawing.Point(140, 140)
    $sessionInput.Size = New-Object System.Drawing.Size(200, 20)
    $sessionInput.ReadOnly = $true
    $form.Controls.Add($sessionInput)

    # Control checkbox
    $controlCheckbox = New-Object System.Windows.Forms.CheckBox
    $controlCheckbox.Text = "Request Control"
    $controlCheckbox.Location = New-Object System.Drawing.Point(10, 180)
    $controlCheckbox.Size = New-Object System.Drawing.Size(150, 20)
    $controlCheckbox.Checked = $false
    $form.Controls.Add($controlCheckbox)

    # Query button
    $queryButton = New-Object System.Windows.Forms.Button
    $queryButton.Text = "Query Session"
    $queryButton.Location = New-Object System.Drawing.Point(10, 210)
    $queryButton.Size = New-Object System.Drawing.Size(120, 30)
    $form.Controls.Add($queryButton)

    # Connect button
    $connectButton = New-Object System.Windows.Forms.Button
    $connectButton.Text = "Connect"
    $connectButton.Location = New-Object System.Drawing.Point(140, 210)
    $connectButton.Size = New-Object System.Drawing.Size(120, 30)
    $connectButton.Enabled = $false
    $form.Controls.Add($connectButton)

    # Connect as RunAs button
    $runAsButton = New-Object System.Windows.Forms.Button
    $runAsButton.Text = "Connect as RunAs User"
    $runAsButton.Location = New-Object System.Drawing.Point(270, 210)
    $runAsButton.Size = New-Object System.Drawing.Size(150, 30)
    $runAsButton.Enabled = $false
    $form.Controls.Add($runAsButton)

    # Function to save data
    function Save-Data {
        $currentUsername = $usernameInput.Text.Trim()
        $currentComputerName = $computerInput.Text.Trim()

        Write-Host "Before Update - Usernames: $($usernames -join ",")"
        Write-Host "Before Update - Computernames: $($computernames -join ",")"

        if (-not [string]::IsNullOrEmpty($currentUsername) -and (-not $usernames.Contains($currentUsername))) {
            $usernames.Add($currentUsername)
        }
        if (-not [string]::IsNullOrEmpty($currentComputerName) -and (-not $computernames.Contains($currentComputerName))) {
            $computernames.Add($currentComputerName)
        }

        Write-Host "After Update - Usernames: $($usernames -join ",")"
        Write-Host "After Update - Computernames: $($computernames -join ",")"

        # Update saved data with current usernames and computer names
        $usernameLine = ($usernames -join ",")
        $computerLine = ($computernames -join ",")

        Set-Content -Path $savedDataPath -Value "$usernameLine`n$computerLine" -NoNewline
    }


    # Function to query session
    function Get-Session {
        Write-Host "Querying session..." -ForegroundColor Green
        $computerName = $computerInput.Text
        $username = $usernameInput.Text
        $password = $passwordInput.Text
        $command = "query session"

        if ([string]::IsNullOrEmpty($computerName) -or [string]::IsNullOrEmpty($username) -or [string]::IsNullOrEmpty($password)) {
            Write-Host "Missing required fields. Query aborted." -ForegroundColor Red
            [System.Windows.Forms.MessageBox]::Show("Please fill in all fields.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        try {
            # Build plink command with -agent and handle host key confirmation
            $plinkCommand = "echo y | plink `"$computerName`" -agent -l `"$username`" -pw `"$password`" -t `"$command`""
            Write-Host "Executing command: $plinkCommand" -ForegroundColor Yellow

            # Execute plink command
            $processInfo = New-Object System.Diagnostics.ProcessStartInfo
            $processInfo.FileName = "cmd.exe"
            $processInfo.Arguments = "/c $plinkCommand"
            $processInfo.RedirectStandardOutput = $true
            $processInfo.RedirectStandardError = $true
            $processInfo.UseShellExecute = $false
            $processInfo.CreateNoWindow = $true

            $process = [System.Diagnostics.Process]::Start($processInfo)
            $output = $process.StandardOutput.ReadToEnd()
            $errorE = $process.StandardError.ReadToEnd()
            $process.WaitForExit()

            if ($errorE) {
                Write-Host "Error output: $errorE" -ForegroundColor Red
            }

            Write-Host "Command output:`n$output" -ForegroundColor Cyan

            # Find the line containing "Active"
            $activeSessionLine = $output -split "`r?`n" | Where-Object { $_ -match "Active" }

            if ($activeSessionLine) {
                # Extract the session ID (assume it's the numeric value in the third column)
                $sessionID = ($activeSessionLine -split '\s+') | Where-Object { $_ -match '^[0-9]+$' } | Select-Object -First 1
                Write-Host "Active session found. Session ID: $sessionID" -ForegroundColor Green
                $sessionInput.Text = $sessionID
                $connectButton.Enabled = $true
                $runAsButton.Enabled = $true
                Save-Data
            } else {
                Write-Host "No active sessions found." -ForegroundColor Red
                $sessionInput.Text = "None available"
                $connectButton.Enabled = $false
                $runAsButton.Enabled = $false
            }
        } catch {
            Write-Host "Exception occurred during query: $_" -ForegroundColor Red
            [System.Windows.Forms.MessageBox]::Show("Failed to query session. Ensure credentials are correct.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }

    # Query button click event
    $queryButton.Add_Click({ Get-Session })

    # Connect button click event
    $connectButton.Add_Click({
        try {
            Write-Host "Attempting to connect to RDP session..." -ForegroundColor Green
            $sessionID = $sessionInput.Text
            $computerName = $computerInput.Text
            if ($sessionID -eq "None available" -or [string]::IsNullOrEmpty($sessionID)) {
                Write-Host "No valid session ID to connect." -ForegroundColor Red
                [System.Windows.Forms.MessageBox]::Show("No valid session ID to connect.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                return
            }

            # Build the mstsc command with optional /control parameter
            $mstscCommand = "mstsc /V:`"$computerName`" /shadow:`"$sessionID`" /noConsentPrompt"
            if ($controlCheckbox.Checked) {
                $mstscCommand += " /control"
            }

            Write-Host "Executing command: $mstscCommand" -ForegroundColor Yellow

            # Execute mstsc command
            Start-Process cmd.exe -ArgumentList "/c $mstscCommand" -NoNewWindow
            Write-Host "Connected to RDP session." -ForegroundColor Green
        } catch {
            Write-Host "Failed to connect to RDP session: $_" -ForegroundColor Red
            [System.Windows.Forms.MessageBox]::Show("Failed to connect. Ensure the computer is accessible.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })

    # RunAs button click event
    $runAsButton.Add_Click({
        try {
            Write-Host "Attempting to connect to RDP session as RunAs user..." -ForegroundColor Green
            $sessionID = $sessionInput.Text
            $computerName = $computerInput.Text
            if ($sessionID -eq "None available" -or [string]::IsNullOrEmpty($sessionID)) {
                Write-Host "No valid session ID to connect." -ForegroundColor Red
                [System.Windows.Forms.MessageBox]::Show("No valid session ID to connect.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                return
            }

            # Build the mstsc command with optional /control parameter
            $mstscCommand = "mstsc /V:`"$computerName`" /shadow:`"$sessionID`" /noConsentPrompt"
            if ($controlCheckbox.Checked) {
                $mstscCommand += " /control"
            }

            # Build the runas command
            $runAsCommand = "runas /netonly /user:`"$($usernameInput.Text)`" `"$mstscCommand`""

            Write-Host "Executing RunAs command: $runAsCommand" -ForegroundColor Yellow

            # Execute runas command
            Start-Process cmd.exe -ArgumentList "/k $runAsCommand"
        } catch {
            Write-Host "Failed to connect to RDP session as RunAs user: $_" -ForegroundColor Red
            [System.Windows.Forms.MessageBox]::Show("Failed to connect as RunAs user. Ensure credentials are correct.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })

    # Run the form
    $form.ShowDialog()

} catch {
    Write-Host "Unhandled exception: $_" -ForegroundColor Red
}
