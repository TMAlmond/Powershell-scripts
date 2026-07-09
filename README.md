# Powershell-scripts
A repo for PowerShell scripts I'm developing while upskilling into Infrastructure. 

## Scripts
### Get-EndpointInfo.ps1   
**Function**  
Gathers and displays Computer name, Logged in User, OS name and version, uptime, disk space, service health and installed apps.
Also outputs EndpointHealth.csv and InstalledApps.csv to ./Logs/

**Improvements**:
- Remote support (Hostname or IP)
- Error handling
- Display assinged licenses of logged in user
