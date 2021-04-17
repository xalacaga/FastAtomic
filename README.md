# FastAtomic
 Script powershell pour executer les tests Atomics-Red de façon simplifiée
 Ce script fait appel aux differents scripts proposés par :
 https://github.com/redcanaryco/atomic-red-team
 
 # Usage
 
 .\FastAtomicRed.ps1 -Install
(Installe tout les prérequis)

.\FastAtomicRed.ps1 -Update
(Met à jour les dépots Atomic et regénère le fichier Excel avec les tests par OS)

.\FastAtomicRed.ps1
(Lance le programme)   

# TODO
- Faire des scenarii de tests automatique pour un ensemble de techniques préalablement choisies ou deja packagées.
- Exporter dans fichier Excel les resultats (Detection du test dans un SIEM ou autre (OUI/NON)

 

