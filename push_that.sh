read -p "Entrez le message de votre commit: " commitMessage
git commit -am $commitMessage
git add -A
git push
echo "Push réussi !!!"
echo "Nom du commit: $commitMessage."
