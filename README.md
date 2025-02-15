# Installed Applications Report Generator

This PowerShell script generates an HTML report of all installed applications on a Windows machine. The report includes the application name, version, manufacturer, file size, and the installation or update date. The script allows the user to specify the output location for the report.

## Features

- Lists all installed applications on your Windows system.
- Displays the application name, version, manufacturer, file size (in MB), and installed/updated date.
- Allows for custom sorting of each column by clicking the column header.
- Asks for the path where the report should be saved.
- Generates a visually appealing HTML report using Google Fonts and responsive CSS.

## Prerequisites

- **Windows PowerShell 5.1 or later**.
- Administrative privileges may be required to access all installed applications.

## How to Use

1. **Download or Clone the Repository**: 
   - Download the script or clone this repository to your local machine.
   
   ```bash
   git clone https://github.com/your-repo/installed-applications-report.git

2. **Run the Script**:

- Open PowerShell with administrative privileges.
- Navigate to the directory where the script is located.
- Run the script by typing the file name (e.g. .\installed_applications.ps1)

3. **Provide Output Path**:

- When prompted, enter the full path where you want to save the HTML report file (e.g., D:\Scripts\InstalledAppsReport.html). You can also press Enter to save the report in the current directory.

4. **Open the Report**:

- Navigate to the specified location and open the generated HTML file in your web browser.

#### Example
```
PS C:\Users\YourUsername\Desktop\AppList> .\installed_packages_report.ps1
Enter the full path where you want to save the report file (e.g., D:\Scripts\InstalledAppsReport.html): D:\Reports\InstalledAppsReport.html
The report has been saved to D:\Reports\InstalledAppsReport.html

```
# Features

#### Custom Sorting
- The generated HTML report supports dynamic sorting. Click on any column header to sort the table by that column in ascending or descending order.

#### Responsive Design
- The report is designed to be responsive and visually appealing with:

- Google Fonts (Roboto) for a clean and modern look.
- Responsive CSS that adapts to different screen sizes, making the report viewable on mobile devices.

#### Error Handling
- If the provided output path does not exist, the script will attempt to create the directory.
- If the script encounters any missing information (such as date or app version), it will display "N/A" in the report.


# Limitations
- The InstallDate property is not always available for every application, so some entries may show "N/A" for the installation date.
- Administrative privileges may be required to access all installed applications.

# License
- This project is licensed under the MIT License. See the LICENSE file for more details.

# Contributing
- Contributions are welcome! Please feel free to open an issue or submit a pull request.
- This script is a work in progress. More changes can be expected in the upcoming versions.

#  Contact
For any questions or feedback, please contact via Github profile page.


This `README.md` provides comprehensive instructions on using the script, explains its features, and makes it easier for other users to understand the purpose and usage.
