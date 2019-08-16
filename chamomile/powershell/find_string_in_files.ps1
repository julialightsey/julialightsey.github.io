Get-ChildItem -Recurse | Select-String "advo" | Select-Object Filename | Out-File contain_advo.txt

Get-ChildItem -Recurse | Select-String -Pattern "find_me" | group path | select name

-- 
-- get context, 2 lines before and 3 after
Get-ChildItem -Recurse | Select-String -Pattern "find_me" -Context 2, 3

-- complex https://ardalis.com/find-string-in-files-with-given-extension-using-powershell
$file_list = get-childitem -recurse | where {$_.extension -eq ".<extension>"}
select-string <find_me> $file_list | format-table path | out-file result_01.txt
