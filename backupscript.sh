#!/bin/bash

#***********************************************#
#												#
#	System Engineering 3						#
#												#
#	Backup script								#
#												#
#	Wouter Roozeleer & Robin Kelchtermans		#
#	2 TI 1 - Odisee								#
#												#
#***********************************************#

#Initialisatie van variabelen.
maakzip=false			#boolean die bepaalt ofdat er een zip moet worden gemaakt.
array=() 				#Houdt een array bij met alle directories- of bestandpaden.
desdir=archief 			#Map waar de backup zal worden opgeslagen.

#In maakBackup wordt het eigenlijke script uitgevoerd. Er is meer info bij elk onderdeel te vinden.
maakBackup() {

#Om te beginnen voeren we verschillende tests uit om 'fouten' er uit te halen. Er wordt elke keer een foutmelding opgeroepen indien er iets niet klopt.
if [ ! -e $1  ]; then 	#Kijkt na of het config-bestand bestaat.
	foutmelding 5
	exit 1
fi

if [ ! -s $1 ]; then 	#Kijkt na of het config-bestand leeg is.
	foutmelding 3
	exit 1
fi

#Eens de tests uitgevoerd starten we het doorlezen van het bestand zelf.
echo "Bestanden worden geanalyseerd..."

while read lijn; do 	#Leest elke lijnt en zet dit in array.

	if [ ! -e $lijn ]; then		#Indien het pad of bestand niet bestaat wordt er geleidt naar de foutmelding. Merk op dat we hier geen exit doen.
		foutmelding 4 $lijn
	else
		echo "$lijn wordt verzonden naar het backup-bestand"
		array+=($lijn)
	fi
done < $1						#De lijnen worden gehaald uit het doorgegeven 'answer'.
echo "Deze files krijgen een backup: ${array[@]}"

#Eens alle bestands namen in de array zitten bepalen we de naam van de map dat de backup zal bevatten.
tijd=`date +%Y%m%d%H%M%S`
if [ "$maakzip" = true ]; then			#Indien de parameter -z werd meegegeven zal er een zip (gz) bestand worden gemaakt.
	filenaam="backup-$tijd.tar.gz"
else
	filenaam="backup-$tijd.tar"
fi

#We gaan op / -level staan
cd /

#Indien de backup map niet bestaat maken we deze aan. Nadien gaan we in die map.
if [ !  -d "$desdir" ]; then
	mkdir $desdir
fi
cd $desdir

#In de onderstaande regel maken we het tar-bestand aan, deze bezit een tijd variabele. We zorgen ervoor dat deze leeg is (/dev/null)
tar -cf $filenaam -T /dev/null --force-local
echo "Archief $filenaam werd gemaakt."

#Nu steken we alle bestanden uit de array in de backup map. Dit gebeurt via tar.
echo "De bestanden worden in $filenaam geplaatst..."
for bestand in ${array[@]}
do
	if [ "$maakzip" = true ]; then
		tar -zcvPf $filenaam $bestand --force-local
	else
		tar -rPf $filenaam $bestand --force-local
	fi
done

echo "De backup werd succesvol gemaakt. Nog een prettige dag."

#Om te bekijken welke bestanden er in de .tar zitten, gebruik: tar -tvf
}

#--------------------------------------------------------

#Alle foutmeldingen worden hieronder opgelijst. Bij het oproepen van de functie foutmelding wordt er steeds een (of meerdere) waarrden door gegeven om te bepalen over welke foutmelding het gaat.
foutmelding()
{
	case $1 in
		1) echo "U heeft geen bestand opgegeven.";;
		2) echo "Er bestaat geen map voor uw gebruiker, /home/$USER bestaat niet";; #moet aangepast worden
		3) echo "De config-bestand bevat geen paden naar bestanden of mappen.";;
		4) echo "$2 bestaat niet en wordt genegeerd.";;
		5) echo "Config-bestand bestaat niet.";;
	esac
}

#--------------------------------------------------------

#De toonHelp functie zal een kleine help geven om een basis te geven aan informatie voor de gebruiker.
toonhelp()
{
	echo Backupscript maakt een backup van specifieke folders en bestanden die werden opgegeven in een config-bestand. Voeg het volledige pad in het config-bestand om dit correct te laten werken.
	echo "Gebruik -h of --help om naar de helpfunctie te gaan."
	echo
	echo "Gebruik -z of --zip als parameter om de backup meteen te zippen."
	echo "Alle bestanden worden opgeslagen op de allerbovenste map, in archief."
	exit 1
}

#--------------------------------------------------------

#Eerst testen we of er geen parameters werden meegegeven. -h/--help geeft de toonHelp functie weer, -z bepaalt ofdat er een zip moet gemaakt worden of niet.
case $1 in
	-h | --help) toonhelp;;
	-z | --zip) maakzip=true;;
        *) echo "U heeft het verkeerde commando ingevoerd"
           toonhelp;;
esac

#Daarna stellen we de vraag om aan te duiden waar het config-bestand te vinden is. (gebeurt niet als de toonHelp functie wordt opgeroepen)
read -p "Geef de naam van het configuratie-bestand in: " answer

#Eens ingevuld analyseren we het antwoord (answer).
#	Indien het leeg is, wordt foutmelding 2 opgeroepen.
#	Indien de er een bestand werd meegegeven wordt de functie maakBackup opgeroepen. We geven hierbij ook de naam van het bestand door.
if [ -z $answer ]; then
	foutmelding 1
else
	maakBackup $answer
fi
