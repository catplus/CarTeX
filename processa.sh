#!/bin/bash
FILE="$1"
PLANTILLA="$2"
if [ "$1" == "" ] || [ "$2" == "" ]; then
   echo "La sintaxi és: fitxer_preus.txt plantilla.tex"
   exit 0
fi
FILE_TMP=$(mktemp)
DIR="$(pwd)"
TEMPLATE_HEADER="$DIR/$PLANTILLA"
TEMPLATE_FOOTER="$DIR/footer.tex"
DELIMITER="|"
NAME="$1_$(date +%F)"
PDFLATEX=$(which pdflatex)
EVINCE=$(which evince)
cp "$TEMPLATE_HEADER" $FILE_TMP
while read line;do
    COL1="$(echo $line |cut -d $DELIMITER -f 1 )"
    if [ "$COL1" == "1" ]; then
        COL2="$(echo $line |cut -d $DELIMITER -f 2 )"
        echo "\begin{center}" >> $FILE_TMP
        echo "\textbf{$COL2}" >> $FILE_TMP
        echo "\end{center}" >> $FILE_TMP
        echo "\hrule"  >> $FILE_TMP
        echo "\bigskip" >> $FILE_TMP
    elif [ "$COL1" == "2" ]; then
        COL2="$(echo $line |cut -d $DELIMITER -f 2 )"
        echo "\textbf{$COL2}" >> $FILE_TMP
        echo "\begin{quote}" >> $FILE_TMP
    elif [ "$COL1" == "3" ]; then
        COL2="$(echo $line |cut -d $DELIMITER -f 2 )"
        COL3="$(echo $line |cut -d $DELIMITER -f 3 )"
        echo "$COL2 \dotfill \ $COL3\ \euro \\\\" >> $FILE_TMP
    else
        echo "\end{quote}"  >> $FILE_TMP
    fi
done < $FILE
cat $FILE_TMP "$TEMPLATE_FOOTER" > "$DIR/$NAME.tex"
rm $FILE_TMP
$PDFLATEX "$DIR/$NAME.tex" >/dev/null 2>&1
$EVINCE "$NAME.pdf" &
