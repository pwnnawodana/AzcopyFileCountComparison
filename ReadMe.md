⚠️ Caution
This is a script template sample, that used for compare same type folder path file count & size. Highly suggest to reverify the script before run because this script already modified to hide confidential information. Also, due to that can have some runtime errors as well.

### Process
Add root directory or directories in the mentioned text file, make sure to add paths line by line

Before run the process need to install the azcopy tool to the system and also require to add it to environment variable as will
You can follow below steps to configure this on windows
    
### AZCopy
AZ copy is the base tool use to perform whole task
- Step 1
  Download AZ Copy tool & Extract in preferred location (Ex : C:\Azcopy)
- Step 2
  Open start menu (windows).
  Click Environment variables.
  Under system variables select Path and click edit.
  Click new and place azcopy.exe parent directory (if exe at "C:\Azcopy\azcopy.exe" then place "C:\Azcopy\" as value without double quotes) path within then click ok on all windows.
- Step 3
  Open cmd and run "azcopy --version" in that. if you get version value, good to go. 