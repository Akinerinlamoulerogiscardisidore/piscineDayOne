read -p "Entrez le message de votre commit: " commitMessage
git commit -am $commitMessage
git add -A
git push
if test "$?" = "0"
then
    echo "Push réussi avec succés !!! "
else
    echo "Tentative de push échouée. Essayons de réparer si possible les erreurs."
    git pull origin main
    if test "$?" != "0"
    then
	while test "$?" != "0"
        do
          echo "Echec de nouveau."
          git pull --rebase
	  echo "J'ai fait une rebase."
          git push
        done
     else
	echo "Push réussi !!"
     fi
fi

echo "Nom du commit: $commitMessage."
