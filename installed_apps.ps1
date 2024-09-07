# Function to get the list of installed applications
function Get-InstalledApps {
    Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*,
                    HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Where-Object { $_.DisplayName -and $_.DisplayName.Trim() -ne "" } |
    Select-Object @{Name='DisplayName'; Expression = {if ($_.DisplayName) { $_.DisplayName } else { "N/A" }}},
                  @{Name='DisplayVersion'; Expression = {if ($_.DisplayVersion) { $_.DisplayVersion } else { "N/A" }}},
                  @{Name='Publisher'; Expression = {if ($_.Publisher) { $_.Publisher } else { "N/A" }}},
                  @{Name='SizeMB'; Expression = {if ($_.EstimatedSize) {[math]::Round($_.EstimatedSize / 1024, 2)} else { "N/A" }}},
                  @{Name='InstallDate'; Expression = {
                      if ($_.InstallDate) {
                          # Convert date from YYYYMMDD format
                          try {
                              [datetime]::ParseExact($_.InstallDate.ToString(), "yyyyMMdd", $null).ToString("yyyy-MM-dd")
                          } catch {
                              "N/A"
                          }
                      } else {
                          "N/A"
                      }
                  }}
}

# Function to generate HTML content
function New-HTMLContent {
    param ($apps)

    # Add Google Fonts, responsive CSS, and dynamic sorting JavaScript
    $html = @"
<html>
<head>
    <title>Installed Apps</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f8f9fa;
            color: #333;
        }
        h1 {
            text-align: center;
            font-weight: 500;
            color: #007bff;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
            overflow-x: auto;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        th {
            background-color: #007bff;
            color: white;
            font-weight: 700;
            cursor: pointer;
        }
        th.sorted-asc::after {
            content: " ▲";
        }
        th.sorted-desc::after {
            content: " ▼";
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        tr:hover {
            background-color: #e9ecef;
        }
        @media screen and (max-width: 768px) {
            table, thead, tbody, th, td, tr {
                display: block;
            }
            tr {
                margin-bottom: 15px;
            }
            th, td {
                text-align: right;
                padding: 10px;
                position: relative;
                border: none;
                display: flex;
                justify-content: space-between;
            }
            th::before, td::before {
                content: attr(data-label);
                font-weight: 700;
                flex: 1;
                text-align: left;
            }
        }
    </style>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const table = document.querySelector('table');
            const headers = table.querySelectorAll('th');
            let isAscending = true;

            headers.forEach((header, index) => {
                header.addEventListener('click', () => {
                    const rowsArray = Array.from(table.querySelectorAll('tbody tr'));
                    const isSortedAsc = header.classList.contains('sorted-asc');
                    
                    rowsArray.sort((a, b) => {
                        const aText = a.children[index].textContent.trim();
                        const bText = b.children[index].textContent.trim();

                        let aValue = aText;
                        let bValue = bText;

                        // Handle numeric and date columns
                        if (index === 3) { // File Size column
                            aValue = parseFloat(aText.replace(/[^0-9.]/g, '')) || 0;
                            bValue = parseFloat(bText.replace(/[^0-9.]/g, '')) || 0;
                        } else if (index === 4) { // Install Date column
                            aValue = Date.parse(aText) || 0;
                            bValue = Date.parse(bText) || 0;
                        }

                        if (isAscending) {
                            return aValue > bValue ? 1 : aValue < bValue ? -1 : 0;
                        } else {
                            return aValue < bValue ? 1 : aValue > bValue ? -1 : 0;
                        }
                    });

                    isAscending = !isAscending;
                    headers.forEach(th => th.classList.remove('sorted-asc', 'sorted-desc'));
                    header.classList.add(isAscending ? 'sorted-asc' : 'sorted-desc');
                    
                    const tbody = table.querySelector('tbody');
                    rowsArray.forEach(row => tbody.appendChild(row));
                });
            });
        });
    </script>
</head>
<body>
    <h1>Installed Apps</h1>
    <table>
        <thead>
            <tr>
                <th>Name</th>
                <th>App. Version</th>
                <th>Manufacturer</th>
                <th>File Size (MB)</th>
                <th>Installed/Updated Date</th>
            </tr>
        </thead>
        <tbody>
"@

    # Generate HTML table rows for each application
    foreach ($app in $apps) {
        $html += "<tr>"
        $html += "<td>$($app.DisplayName)</td>"
        $html += "<td>$($app.DisplayVersion)</td>"
        $html += "<td>$($app.Publisher)</td>"
        $html += "<td>$($app.SizeMB)</td>"
        $html += "<td>$($app.InstallDate)</td>"
        $html += "</tr>"
    }

    $html += @"
        </tbody>
    </table>
</body>
</html>
"@

    return $html
}

# Execution of Main script
$apps = Get-InstalledApps

# Asks file path along with file name from user before saving
$outputPath = Read-Host "Enter the full path where you want to save the report file (e.g., D:\Scripts\InstalledAppsReport.html)"

# Validate the provided path
if ([System.IO.Path]::IsPathRooted($outputPath)) {
    # Ensure the directory exists
    $directory = [System.IO.Path]::GetDirectoryName($outputPath)
    if (-not (Test-Path -Path $directory)) {
        Write-Output "The directory '$directory' does not exist. Creating it now."
        New-Item -Path $directory -ItemType Directory -Force
    }
    
    # Generate the HTML content
    $htmlContent = New-HTMLContent -apps $apps

    # Save the output to the specified path
    $htmlContent | Out-File -FilePath $outputPath -Encoding UTF8
    Write-Output "The report has been saved to $outputPath"
} else {
    Write-Output "The provided path is not valid. Please provide a full path."
}