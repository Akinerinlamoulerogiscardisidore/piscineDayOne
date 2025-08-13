git commit -am $1
git add -A
git push

if test "$?" = "0"
then
    echo "Push réussi avec succés !!! "
else
    echo "Tentative de push échouée. Essayons de réparer si possible les erreurs."
    git pull --rebase origin main
    while test "$?" != "0"
	do
		echo "Echec de nouveau."
	done

fi

echo "Push réussi !!!"
echo "Nom du commit: $1"
