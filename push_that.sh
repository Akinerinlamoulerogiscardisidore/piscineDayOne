git commit -am $1
git add -A
git push

if test "$?" = "0"
then
    echo "Push réussi avec succès !!! "
else
    echo "Tentative de push échouée. Essayons de réparer si possible les erreurs."
    git pull --rebase origin main
    while test "$?" != "0"
	do
		echo "Echec de nouveau."
		git pull --rebase origin main
		git commit -am $1
		git add -A
		git push
	done

fi

echo "Dernier check. Push réussi !!!"
echo "Nom du commit: $1"
