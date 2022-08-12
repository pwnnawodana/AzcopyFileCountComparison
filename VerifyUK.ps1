# used file url pattern  : root_url/some-code-value/version-{value}

# ========== Update content From here ============
# Azcopy
$New_SHARE = 'https://New_SHARE.file.core.windows.net/xxx'
$New_SAS = 'SAS(Read, List)'
$Old_SHARE = 'https://Old_SHARE.file.core.windows.net/xxx'
$Old_SAS = 'SAS(Read, List)'
# Az
$account_name = 'azure storage resource name'
$connection_String = 'resource_connection_string' # ⚠️ caution : have full permisson 
$share_name = 'structured-spider'
# ========== Update content To here ============
$report_root = './Report'
$report = "$($report_root)/Report $(Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }).csv"
$Status = ""
$note = ""
# SPV File
$SPV_Content = Get-Content .\SPV-test.txt

function WriteMe {
    param (
        [string]$line_number,
        [string]$spv,   
        [string]$status,
        [string]$note
    )
    Add-Content $report "$($line_number), $($sp),  $($status), $($note)"
}
    
if ($(Test-Path $report_root) -eq $false) {
    New-Item $report_root -Type Directory
}

Add-Content $report "Line Number, SPV, Status, Note"
$line_number = 0
foreach ($item in $SPV_Content) {
    $line_number++
    $sp = $item.Split(' ')[0]
    $version = $item.Split(' ')[1]
    Write-Host "$('{0:d5}' -f [int]$line_number) : $($item) " -NoNewline
    
    $isParentExist = $(az storage directory exists --name "$($sp)" --account-name $account_name --connection-string  $connection_String --share-name "$($share_name)"  | ConvertFrom-Json).exists
    if ($isParentExist) {
        $isVersionExist = $(az storage directory exists --name "$($sp)/$($version)" --account-name $account_name --connection-string  $connection_String --share-name "$($share_name)"  | ConvertFrom-Json).exists
        if ($isVersionExist) {
            $Newshare_list = $(azcopy list "$($New_SHARE)/$($sp)/$($version)?$($New_SAS)" --running-tally)
            $oldshare_list = $(azcopy list "$($Old_SHARE)/$($sp)/$($version)?$($Old_SAS)" --running-tally)
            $New_File_Count = ($Newshare_list | Select-Object -last 1).Replace('INFO: Total file size: ', '')
            $New_File_Size = ($Newshare_list | Select-Object -last 2 | Select-Object -first 1).Replace('INFO: File count: ', '') - 1
            $Old_File_Count = ($oldshare_list | Select-Object -last 1).Replace('INFO: Total file size: ', '')
            $Old_File_Size = ($oldshare_list | Select-Object -last 2 | Select-Object -first 1).Replace('INFO: File count: ', '') - 1
            if (($New_File_Count -eq $Old_File_Count) -and ($New_File_Size -eq $Old_File_Size)) {
                $Status = "Success"
                Write-Host $Status -ForegroundColor Green
            }
            else {
                $Status = "CountSizeNotMatch"
                Write-Host $Status -ForegroundColor Yellow
                $note = $New_File_Count -eq $Old_File_Count ? "Count Match $($New_File_Count)" : "Count NotMatch [ old-$($Old_File_Count) | New-$($New_File_Count) ]"
                $note += $New_File_Size -eq $Old_File_Size ? "Size Match $($New_File_Size)" : "Size NotMatch [old-$($Old_File_Size) | New-$($New_File_Size) ]"
            }
        }
        else {
            $Status = "VersionNotFound"
            Write-Host $Status -ForegroundColor Yellow
        }
    }
    else {
        $Status = "ParentNotFound"
        Write-Host $Status -ForegroundColor Red
    }
    WriteMe -line_number $line_number -spv $item -status $Status -note $note
}

