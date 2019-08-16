Get-ChildItem -Path "<directory_path>" -Recurse | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays(-3))} | Remove-Item
