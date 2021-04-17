<#   
.SYNOPSIS
FastAtomicRed Permet de gagner du temps dans la conduite des tests elabores avec Atomic Red Team
.DESCRIPTION
Il suffit d executer le script et d indiquer le numero de technique et sous technique choisie . le reste est automatique 
.PARAMETER Install
Ce parametre install l'ensemble des prerequis (Git et Atomic)
.PARAMETER Update
Ce parametre met e jour les depots git atomic
.EXAMPLE
.\FastAtomicRed.ps1 -Install
Installe tout les prerequis
.\FastAtomicRed.ps1 -Update
Met a jour les depots Atomic
.\FastAtomicRed.ps1
Lance le programme    
.NOTES
    NAME:    FastAtomicRed.ps1
    AUTHOR:    Xavier BEGUE
    EMAIL:    xavier.begue@aviation-civile.gouv.fr

    VERSION HISTORY:

    1.0     2021.04.1
            Initial Version
#>


####Debut Script Install/update

param (
     [Parameter()]
     [switch]$Install,
     [switch]$Update
)
$sourcegit = 'https://github.com/git-for-windows/git/releases/download/v2.31.1.windows.1/Git-2.31.1-64-bit.exe'
$depot = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path

 if ($Install.IsPresent) {
    Write-Host "Installation des prerequis" -ForegroundColor Blue
     Write-Host "Telechargement Git For Windows" -ForegroundColor Green
    Invoke-WebRequest -Uri $sourcegit -OutFile $depot\git.exe
    Write-Host "Faire l installation de GIT par defaut"
    Start-Process -FilePath "$depot\git.exe" -Wait
    Install-Module PowershellGet -Force
    PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force   
    Import-Module posh-git
    Add-PoshGitToProfile
    New-Item -Path c:\Atomic -ItemType Directory
    git clone https://github.com/redcanaryco/atomic-red-team.git c:\Atomic\atomic-red-team
    git clone https://github.com/redcanaryco/invoke-atomicredteam.git c:\Atomic\invoke-atomicredteam
    Install-Module -Name ImportExcel -RequiredVersion 4.0.8
    exit
 }elseif ($Update.IsPresent) {
     Write-Host "Mise a jour des dépots" -ForegroundColor Green
     git pull C:\Atomic\atomic-red-team
     git pull C:\Atomic\invoke-atomicredteam
     exit
 }
###Fin script Install/update

Write-host "Initialisation du programme AtomicRed....." -foregroundcolor DarkGreen
Write-host "##################################" -ForegroundColor Blue
Write-host "#      FastAtomicRed - DGAC      #" -ForegroundColor Blue
Write-host "##############################XBE#" -ForegroundColor Blue
Import-Module "C:\Atomic\invoke-atomicredteam\Invoke-AtomicRedTeam.psd1" -Force
Import-module ImportExcel
$PSDefaultParameterValues = @{"Invoke-AtomicTest:PathToAtomicsFolder"="C:\Atomic\atomic-red-team\atomics"}
$Technique = [string]
###Choix environement
write-host "Pour quel systeme voulez vous faire les tests ?"
write-Host "1 - Windows"
write-Host "2 - Linux"
$Environment = read-host "Choix: 1-2 (defaut:Windows)"
switch ($Environment)
 {
    1 {$Environment="Windows"}
    2 {$Environment="Linux"}
    default {$Environment="Windows"}
  }
Write-Host "Vos tests seront fait vers une plateforme " -NoNewline; Write-Host $Environment -ForegroundColor Green
if($Environment -eq "Linux")
{
$IP = Read-Host "Quelle est l adresse IP du poste a contacter ?"
$User = Read-Host "Quel est le nom utilisateur distant pour la connexion ssh" 
$sess = New-PSSession -HostName $IP -Username $User
}
###Fin Choix Environnement
$yes="o"
Do{

    Write-Host "#################################################" -ForegroundColor Green 
$Technique = read-host "Choix de la Technique T(XXXX.XX)"
if($Technique.Length -igt 0){
    Write-Host "Resume rapide de ou des techniques associees" -foregroundcolor DarkGreen
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
$num = read-host "Numero de la Technique (Nombre apres le - )" 

if($num.Length -igt 0){
    $detail = read-host "Voulez vous un detail complet de la Technique (o/n)?"
    if ($detail -eq "o" -and $Environment -eq "Windows") {Invoke-AtomicTest T$Technique -TestNumbers $num -ShowDetails}
    if ($detail -eq "o" -and $Environment -eq "Linux"){Invoke-AtomicTest T$Technique -Session $sess -TestNumbers $num -ShowDetails}
    $lancement = read-host "Voulez vous lancer le test (o/n)?"
    if ($lancement -eq "o"){
    Write-Host "Preparation des prerequis" -foregroundcolor DarkGreen
    if ($Environment -eq "Windows"){Invoke-AtomicTest T$Technique -TestNumbers $num -CheckPrereqs}
    else {Invoke-AtomicTest T$Technique -Session $sess -TestNumbers $num -CheckPrereqs}
    if ($Environment -eq "Windows"){Invoke-AtomicTest T$Technique -TestNumbers $num -GetPrereqs}
    else {Invoke-AtomicTest T$Technique -Session $sess -TestNumbers $num -GetPrereqs}
    Write-Host "Execution du test" -foregroundcolor DarkGreen
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