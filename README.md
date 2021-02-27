# Basi-di-Dati

Docente: Pellegrini Alessandro
Voto: 28

Si vuole realizzare un sistema informativo per la gestione di una bacheca elettronica di annunci. Tale bacheca permette agli utenti di inserire annunci per la vendita di materiale usato, di scambiare messaggi tra di loro (in maniera privata) per accordarsi sulla vendita/consegna dell’oggetto, o di inserire commenti (in maniera pubblica) sull’oggetto.

Un utente si registra scegliendo un username univoco, inserendo tutte le sue informazioni anagrafiche, indicando un indirizzo di residenza ed eventualmente un indirizzo di fatturazione, un numero arbitrario di recapiti (telefono, cellulare, email) indicandone uno come mezzo di comunicazione preferito, ed inserendo i dati relativi alla sua carta di credito. I dati della carta di credito non sono obbligatori.

Gli amministratori possono creare delle categorie per gli annunci. Un utente, per creare un annuncio, seleziona una categoria e scrive una descrizione dell’oggetto. Eventualmente, può decidere di caricare una foto dell’oggetto. Per creare un annuncio, un utente deve necessariamente aver inserito i dati della sua carta di credito. Quando un oggetto inserito in bacheca è stato venduto, l’utente lo indica come tale e questo non viene più visualizzato nella bacheca pubblica.
Un utente, una volta letto e scelto un annuncio, può decidere di inserire un commento pubblico o di inviare un messaggio privato all’utente che ha inserito l’annuncio. Similmente, un utente può seguire uno degli annunci, venendo così informato ogni volta che su questo viene effettuata una modifica (ad esempio, viene inserita una nuova nota).

In generale, un utente può:
	• Inserire/rimuovere nuovi annunci
	• Modificare le sue informazioni anagrafiche
	• Seguire annunci
	• Vedere gli annunci che ha aggiunto tra i preferiti, visualizzando un’indicazione legata al fatto se uno degli annunci che sta seguendo è stato modificato (un oggetto segnato come venduto o rimosso compare comunque nell’elenco degli annunci aggiunti dagli utenti, portando l’indicazione del suo stato)
	• Inviare messaggi agli altri utenti e vedere lo storico delle sue conversazioni, anche con la possibilità di rispondere ad una conversazione specifica
	• Inserire commenti agli annunci ancora attivi.

Gli amministratori prendono una percentuale su ciascun oggetto indicato come venduto. Per questo motivo, essi possono generare un report indicante per ciascun utente quanti annunci sono stati contrassegnati come venduti. Il sistema calcola un percentuale pari al 3% della somma degli importi di tali oggetti, nel caso in cui la percentuale associata non sia già stata riscossa. Il report riporta anche le informazioni sulla carta di credito dell’utente, al fine di permettere la riscossione della percentuale.
