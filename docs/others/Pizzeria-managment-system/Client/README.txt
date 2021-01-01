Quanto riportato di seguito è presente anche nella relazione.

Il codice di appoggio è stato leggermente modificato in alcuni punti per aggiungere il supporto ad altri tipi di dati 
e modificato a seguito del verificarsi di qualche failure, 
inoltre dai test è risultato più o meno tutto funzionante tranne due cose che a seguito di svariati tentativi di modifica 
non sono stati risolti (le stored procedure a seguito di test da mysql shell e da mysql workbench sono risultate corrette 
quindi il problema è nel client):
• In fase di dump del result set i valori null non vengono riconosciuti (
  nel controllo sul campo is_null della MYSQL_BIND) e appaiono come caratteri strani, inoltre in caso una tupla 
  contenga un campo null e, la tupla precedente abbia invece un valore in quel campo allora esso invece di esserci 
  un carattere strano viene stampato a schermo lo stesso valore della riga superiore 
  (molto evidente in visualizza_tavoli del manager, quando i tavoli non hanno un cliente associato e pertanto tale campo è null)

• Quando viene registrato un ordine di pizza plus come si può vedere nella stored procedure precedentemente riportata 
  il nome della pizza plus quando creata viene “assemblato” come concatenazione degli ingredienti
 e della pizza usata come base separati dal carattere “+” questo tramite la funzione CONCAT(…) messa a disposizione da mysql, 
  tuttavia il client visualizza solamente la prima stringa della concatenazione (cioè la pizza usata come base), questo anche utilizzando altri caratteri per dividere le stringhe o utilizzando CONCAT_WS(),
  per vedere se l’errore fosse un eventuale inserimento di un carattere terminatore di stringa ‘\0’ 
  tra le varie stringhe da parte delle due funzioni è stato fatto un while in fase di dump del result set per stampare a schermo 
  carattere per carattere i dati presenti nel buffer della bind in modo da ignorare eventuali terminatore, 
  tuttavia il risultato non è cambiato.