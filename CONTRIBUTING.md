# Contributing / Contribuer

Thanks for your interest in **kali-thumbnails**! / Merci de ton intérêt pour ce projet !

## Report a problem / Signaler un problème

Open an issue and include: / Ouvre un ticket (issue) en précisant :

- your Kali version and desktop (`cat /etc/os-release`, XFCE/Thunar) / ta version de Kali et ton bureau
- the file type that has no thumbnail and the output of `xdg-mime query filetype "your file"` / le type de fichier sans miniature et le résultat de la commande ci-dessus
- the command you ran, for example `bash kali-miniatures-complet.sh --psd` / la commande lancée
- any error message printed by the script / les messages d'erreur éventuels

## Propose a change / Proposer une modification

1. Fork the repository and create a branch. / Fais un fork et crée une branche.
2. Keep the script a single file that can be re-run safely. / Garde un script unique, relançable sans risque.
3. Check the syntax before sending: `bash -n kali-miniatures-complet.sh`. / Vérifie la syntaxe avant d'envoyer.
4. Update `README.md` and `docs/MODE-EMPLOI.txt` if you add an option. / Mets à jour le README et le mode d'emploi si tu ajoutes une option.
5. Open a pull request describing what you changed and how you tested it. / Ouvre une pull request en décrivant ce que tu as changé et testé.

By contributing, you agree that your contribution is released under the [MIT License](LICENSE).
