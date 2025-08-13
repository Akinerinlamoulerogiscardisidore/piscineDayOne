git commit -am $1
git add -A
git push

if test "$?" = "0"
then
    echo "Push réussi avec succés !!! "
else
    echo "Tentative de push échouée. Essayons de réparer si possible les erreurs."
    git pull --rebase origin main
    
    if test "$?" != "0"
    then
		while test "$?" != "0"
		do
			echo "Echec de nouveau."
        done
    else
	echo "Push réussi !!"
    echo "Nom du commit: $commitMessage"
    fi
fi

echo "Push réussi !!!"
echo "Nom du commit: $commitMessage."
