Import-module ImportExcel
Set-Location -Path "C:\FastAtomic"
Import-Excel -Path .\matrice.xlsx -WorksheetName 'Matrice Windows' -HeaderName 'Tactic',"Technique #" | Where-Object 'Technique #' -eq T1552.001