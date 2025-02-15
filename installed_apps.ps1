# Function to get the list of installed applications
function Get-InstalledApps {
    $uninstallPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    
    Get-ItemProperty $uninstallPaths | Where-Object { $_.DisplayName -and $_.DisplayName.Trim() -ne "" } |
    Select-Object @{
        Name = 'DisplayName'; 
        Expression = { $_.DisplayName }
    },
    @{
        Name = 'DisplayVersion'; 
        Expression = { $_.DisplayVersion -or 'N/A' }
    },
    @{
        Name = 'Publisher'; 
        Expression = { $_.Publisher -or 'N/A' }
    },
    @{
        Name = 'SizeMB'; 
        Expression = { 
            if ($_.EstimatedSize) { 
                [math]::Round($_.EstimatedSize / 1024, 2) 
            } else { 'N/A' }
        }
    },
    @{
        Name = 'InstallDate'; 
        Expression = { 
            if ($_.InstallDate) {
                try {
                    [datetime]::ParseExact($_.InstallDate.ToString(), "yyyyMMdd", $null).ToString("yyyy-MM-dd")
                } catch {
                    "N/A"
                }
            } else { 'N/A' }
        }
    }
}

# Function to read the HTML template and inject dynamic content
function Get-HTMLTemplate {
    $templatePath = ".\InstalledAppsTemplate.html"
    $template = Get-Content $templatePath -Raw

    return $template
}

# Execution of Main script
$apps = Get-InstalledApps

# Ask the user to enter a file path or leave blank to use the current script directory
$outputPath = Read-Host "Enter the full path where you want to save the report file (e.g., D:\Scripts\InstalledAppsReport.html) or press Enter to save in the current directory"

# If no path is entered, use the current script directory
if ([string]::IsNullOrEmpty($outputPath)) {
    $outputPath = Join-Path -Path (Get-Location) -ChildPath "InstalledAppsReport.html"
    Write-Output "No path entered. Saving to current directory: $outputPath"
}

# Generate HTML content from the template
$htmlContent = Get-HTMLTemplate

# Inject app data into the HTML template
$tableRows = ""
foreach ($app in $apps) {
    $tableRows += "<tr>"
    $tableRows += "<td>$($app.DisplayName)</td>"
    $tableRows += "<td>$($app.DisplayVersion)</td>"
    $tableRows += "<td>$($app.Publisher)</td>"
    $tableRows += "<td>$($app.SizeMB)</td>"
    $tableRows += "<td>$($app.InstallDate)</td>"
    $tableRows += "</tr>"
}

$htmlContent = $htmlContent -replace "<!-- TableRows -->", $tableRows

# Validate the provided path
if ([System.IO.Path]::IsPathRooted($outputPath)) {
    $directory = [System.IO.Path]::GetDirectoryName($outputPath)
    if (-not (Test-Path -Path $directory)) {
        Write-Output "The directory '$directory' does not exist. Creating it now."
        New-Item -Path $directory -ItemType Directory -Force
    }

    try {
        $htmlContent | Out-File -FilePath $outputPath -Encoding UTF8
        Write-Output "The report has been saved to $outputPath"
    } catch {
        Write-Error "An error occurred while generating or saving the report: $_"
    }
} else {
    Write-Output "The provided path is not valid. Please provide a full path."
}
