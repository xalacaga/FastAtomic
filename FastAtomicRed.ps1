<#   
.SYNOPSIS
FastAtomicRed Permet de gagner du temps dans la conduite des tests elabores avec Atomic Red Team
.DESCRIPTION
Il suffit d executer le script et d indiquer le numero de technique et sous technique choisie . le reste est automatique 
.PARAMETER Install
Ce parametre installe l'ensemble des prerequis (Git et Atomic)
.PARAMETER Update
Ce parametre met e jour les depots git atomic
.EXAMPLE
.\FastAtomicRed.ps1 -Install
Installe tout les prerequis
.\FastAtomicRed.ps1 -Update
Met a jour les depots Atomic et regenere le fichier Excel avec les tests par OS
.\FastAtomicRed.ps1
Lance le programme    
.NOTES
    NAME:    FastAtomicRed.ps1
    AUTHOR:    Xavier BEGUE
    EMAIL:    xavier.begue@gmail.com
    VERSION HISTORY:

    1.0     2021.04.1
            Initial Version
    1.1     2021.04.17
            Ajout Fonctionnalité Excel import/export   
    1.2     2021.08.24
            Correction bug d'install     
#>

#### Fonctions

 ##### Fin Fonctions

####Debut Script Install/update

param (
     [Parameter()]
     [switch]$Install,
     [switch]$Update
)
$sourcegit = 'https://github.com/git-for-windows/git/releases/download/v2.31.1.windows.1/Git-2.31.1-64-bit.exe'
$depot = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path

 if ($Install.IsPresent) {
    Write-Host "Installation des prérequis" -ForegroundColor Blue
     Write-Host "Téléchargement Git For Windows" -ForegroundColor Green
    Invoke-WebRequest -Uri $sourcegit -OutFile $depot\git.exe
    Write-Host "Faire l'installation de GIT par defaut"
    Start-Process -FilePath "$depot\git.exe" -Wait
    Install-Module PowershellGet -Scope CurrentUser -Force
    Install-Module -Name powershell-yaml -Scope CurrentUser -Force
    PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force   
    Import-Module posh-git -Scope CurrentUser -Force
    Add-PoshGitToProfile
    New-Item -Path c:\Atomic -ItemType Directory
    New-Item -Path c:\FastAtomic -ItemType Directory
    git clone https://github.com/redcanaryco/atomic-red-team.git c:\Atomic\atomic-red-team
    git clone https://github.com/redcanaryco/invoke-atomicredteam.git c:\Atomic\invoke-atomicredteam
    ##install Module Excel
    Install-Module -Name ImportExcel -RequiredVersion 4.0.8 -Scope CurrentUser -Force
    exit
 }elseif ($Update.IsPresent) {
    Write-Host "Mise à jour des dépots" -ForegroundColor Green
    git -C C:\Atomic\atomic-red-team pull
    git -C C:\Atomic\invoke-atomicredteam pull
    Write-Host "Mise à jour de la matrice Mitre (xlsx)" -ForegroundColor Green
    Remove-Item C:\FastAtomic\matrice.xlsx
    Import-Csv -Path C:\Atomic\atomic-red-team\atomics\Indexes\Indexes-CSV\windows-index.csv | Export-Excel -Path C:\FastAtomic\matrice.xlsx -AutoSize -TableName MatriceWindows -WorkSheetname 'Matrice Windows'
    Import-Csv -Path C:\Atomic\atomic-red-team\atomics\Indexes\Indexes-CSV\linux-index.csv | Export-Excel -Path C:\FastAtomic\matrice.xlsx -AutoSize -TableName MatriceLinux -WorkSheetname 'Matrice Linux'
    Import-Csv -Path C:\Atomic\atomic-red-team\atomics\Indexes\Indexes-CSV\macos-index.csv | Export-Excel -Path C:\FastAtomic\matrice.xlsx -AutoSize -TableName MatriceMACOS -WorkSheetname 'Matrice MacOS'
     exit
 }
 
###Fin script Install/update
Clear-Host
Write-host "Initialisation du programme AtomicRed....." -foregroundcolor DarkGreen
Write-host "##################################" -ForegroundColor Blue
Write-host "#         FastAtomicRed          #" -ForegroundColor Blue
Write-host "##############################XBE#" -ForegroundColor Blue
Import-Module "C:\Atomic\invoke-atomicredteam\Invoke-AtomicRedTeam.psd1" -Force
Import-module ImportExcel
Set-Location -Path "C:\FastAtomic"
$PSDefaultParameterValues = @{"Invoke-AtomicTest:PathToAtomicsFolder"="C:\Atomic\atomic-red-team\atomics"}
#Debut Fonctions
function Get-Maj {
    Write-Host "Mise à jour des dépots" -ForegroundColor Green
    git -C C:\Atomic\atomic-red-team pull
    git -C C:\Atomic\invoke-atomicredteam pull
    Write-Host "Mise à jour de la matrice Mitre (xlsx)" -ForegroundColor Green
    Remove-Item C:\FastAtomic\matrice.xlsx
    Import-Csv -Path C:\Atomic\atomic-red-team\atomics\Indexes\Indexes-CSV\windows-index.csv | Export-Excel -Path C:\FastAtomic\matrice.xlsx -AutoSize -TableName MatriceWindows -WorkSheetname 'Matrice Windows'
    Import-Csv -Path C:\Atomic\atomic-red-team\atomics\Indexes\Indexes-CSV\linux-index.csv | Export-Excel -Path C:\FastAtomic\matrice.xlsx -AutoSize -TableName MatriceLinux -WorkSheetname 'Matrice Linux'
    Import-Csv -Path C:\Atomic\atomic-red-team\atomics\Indexes\Indexes-CSV\macos-index.csv | Export-Excel -Path C:\FastAtomic\matrice.xlsx -AutoSize -TableName MatriceMACOS -WorkSheetname 'Matrice MacOS'
     
 }
 # Fin Fonctions
$Maj = Read-host "Voulez vous mettre à jour le repository Atomic ?(o/n)"

if ($Maj -eq "o") {
Get-Maj
}

$Technique = [string]
write-host "Pour quel système voulez vous faire les tests ?"
write-Host "1 - Windows"
write-Host "2 - Linux"
$Environment = read-host "Choix: 1-2 (défaut:Windows)"
switch ($Environment)
 {
    1 {$Environment="Windows"}
    2 {$Environment="Linux"}
    default {$Environment="Windows"}
  }
Write-Host "#################################################" -ForegroundColor Green

   
Write-Host "Vos tests seront fait vers une plateforme " -NoNewline; Write-Host $Environment -ForegroundColor Green

if($Environment -eq "Linux")
{
    Write-Host "#################################################" -ForegroundColor Green    
$IP = Read-Host "Quelle est l'adresse IP du poste à contacter ?"
$User = Read-Host "Quel est le nom utilisateur distant pour la connexion ssh" 
$sess = New-PSSession -HostName $IP -Username $User
}
$yes="o"
Do{
    Write-Host "#################################################" -ForegroundColor Green 
Do{
$Technique = read-host -Prompt "Choix de la Technique T(XXXX.XX)"
$Folder = "C:\Atomic\atomic-red-team\atomics\T$Technique"
}until (Test-Path -Path $Folder)
Clear-Host
if($Technique.Length -igt 0){
        Write-Host "Résume rapide de la technique : T$Technique" -foregroundcolor DarkGreen
    Write-Host "############################################" -ForegroundColor Green

    if($Environment -eq "Windows")
    {
    Import-Excel -Path .\matrice.xlsx -WorksheetName 'Matrice Windows' | Where-Object 'Technique #' -eq T$Technique | Out-GridView -Title "Résumé"
    }else 
    {
    Import-Excel -Path .\matrice.xlsx -WorksheetName 'Matrice Linux' | Where-Object 'Technique #' -eq T$Technique | Out-GridView -Title "Résumé"
    }
   

    if($Environment -eq "Linux")
{
    Invoke-AtomicTest T$Technique -Session $sess -ShowDetailsBrief
}
    Invoke-AtomicTest T$Technique -ShowDetailsBrief
}
else{
    Write-Host "Vous n'avez pas fait de saisie..."-foregroundcolor Red
    exit
}
    $num = read-host "Numéro du test (Nombre après le - )"

if($num.Length -igt 0){
    $detail = read-host "Voulez vous un détail complet de la Technique (o/n)?"
    if ($detail -eq "o" -and $Environment -eq "Windows") {Invoke-AtomicTest T$Technique -TestNumbers $num -ShowDetails}
    if ($detail -eq "o" -and $Environment -eq "Linux"){Invoke-AtomicTest T$Technique -Session $sess -TestNumbers $num -ShowDetails}
    $lancement = read-host "Voulez vous lancer le test (o/n)?"
    if ($lancement -eq "o"){
    Write-Host "Préparation des prérequis" -foregroundcolor DarkGreen
    if ($Environment -eq "Windows"){Invoke-AtomicTest T$Technique -TestNumbers $num -CheckPrereqs}
    else {Invoke-AtomicTest T$Technique -Session $sess -TestNumbers $num -CheckPrereqs}
    if ($Environment -eq "Windows"){Invoke-AtomicTest T$Technique -TestNumbers $num -GetPrereqs}
    else {Invoke-AtomicTest T$Technique -Session $sess -TestNumbers $num -GetPrereqs}
    Write-Host "Exécution du test" -foregroundcolor DarkGreen
    if ($Environment -eq "Windows"){Invoke-AtomicTest T$Technique -TestNumbers $num}
    else {Invoke-AtomicTest T$Technique -Session $sess -TestNumbers $num}
}}
else{
    Write-Host "Vous n'avez pas fait de saisie... !" -foregroundcolor Red
    exit
}
$clean = read-host "Voulez vous effacer votre test (o/n)?"
if ($clean -eq "o" -and $Environment -eq "Windows") {Invoke-AtomicTest T$Technique -TestNumbers $num -Cleanup}
if ($clean -eq "o" -and $Environment -eq "Linux") {Invoke-AtomicTest T$Technique -Session $sess -TestNumbers $num -Cleanup}
Clear-Host
$yes=Read-Host "Voulez vous faire un autre test (o/n)?" 
Clear-Host
}Until($yes -eq "n")
Write-Host "Bye!" -foregroundcolor DarkGreen