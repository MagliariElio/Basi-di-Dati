-- ------------------------------------
USE `BachecaElettronicadb`
-- ------------------------------------

-- Registrazione di un utente UCC-------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.registra_utente_UCC ;
CREATE PROCEDURE BachecaElettronicadb.registra_utente_UCC (IN username VARCHAR(45), IN password VARCHAR(45), IN numeroCarta VARCHAR(16), IN dataScadenza DATE, IN cvc INT, IN cf_anagrafico VARCHAR(16), IN cognome VARCHAR(20), IN nome VARCHAR(20), IN indirizzoDiResidenza VARCHAR(20), IN cap INT, IN indirizzoDiFatturazione VARCHAR(20), IN tipoRecapitoPreferito VARCHAR(20), IN recapitoPreferito VARCHAR(20), IN tipoRecapitoNonPreferito VARCHAR(20), IN recapitoNonPreferito VARCHAR(20))
BEGIN
	declare idStorico INT;
	
	
	
	/*if exists (SELECT Username FROM BachecaElettronicadb.UCC WHERE Username=username) then
		signal sqlstate '45002' set message_text = "User was inserted as UCC";
	end if;
	if exists (SELECT Username FROM BachecaElettronicadb.USCC WHERE Username=username) then
		signal sqlstate '45003' set message_text = "User was inserted as USCC";
	end if;*/
		
	call BachecaElettronicadb.inserisci_Storico(idStorico);
	call BachecaElettronicadb.inserimentoInfoAnagrafiche(cf_anagrafico, cognome, nome, indirizzoDiResidenza, cap, indirizzoDiFatturazione, tipoRecapitoPreferito, recapitoPreferito);
	call BachecaElettronicadb.inserisci_RecapitoNonPreferito(tipoRecapitoNonPreferito, recapitoNonPreferito, cf_anagrafico);		
	
	INSERT INTO BachecaElettronicadb.UCC (Username, Password, NumeroCarta, DataScadenza, CVC, StoricoConversazione_ID, CF_Anagrafico)
	VALUES(username, password, numeroCarta, dataScadenza, cvc, idStorico, cf_anagrafico);
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento di uno Storico Conversazioni -------------------------- Impostare un livello di isolamento per evitare errori con last_insert_id()
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.inserisci_Storico ;
CREATE PROCEDURE BachecaElettronicadb.inserisci_Storico (OUT id INT)
BEGIN
		INSERT INTO BachecaElettronicadb.StoricoConversazione (ID) VALUES(NULL);
		SET id = LAST_INSERT_ID();
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento Recapito non preferito -------------------------------- 
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.inserisci_RecapitoNonPreferito ;
CREATE PROCEDURE BachecaElettronicadb.inserisci_RecapitoNonPreferito (IN tipo VARCHAR(40), IN recapito VARCHAR(20), IN cf_anagrafico VARCHAR(16))
BEGIN
	
	if not exists (SELECT CF FROM BachecaElettronicadb.InformazioneAnagrafica WHERE CF=cf_anagrafico) then
		signal sqlstate '45004' set message_text = "Fiscal Code not found";
	end if;
	
	INSERT INTO BachecaElettronicadb.RecapitoNonPreferito (Recapito, Tipo, InformazioneAnagrafica_CF) VALUES(recapito, tipo, cf_anagrafico);

END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Registrazione di un utente USCC -----------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.registra_utente_USCC ;
CREATE PROCEDURE BachecaElettronicadb.registra_utente_USCC (IN username VARCHAR(45), IN password VARCHAR(45), IN cf_anagrafico VARCHAR(16), IN cognome VARCHAR(20), IN nome VARCHAR(20), IN indirizzoDiResidenza VARCHAR(20), IN cap INT, IN indirizzoDiFatturazione VARCHAR(20), IN tipoRecapitoPreferito VARCHAR(20), IN recapitoPreferito VARCHAR(20), IN tipoRecapitoNonPreferito VARCHAR(20), IN recapitoNonPreferito VARCHAR(20))
BEGIN
	declare idStorico INT;
	
	begin 
		rollback;
		resignal;
	end;
	
	start transaction;
	
	/*if exists (SELECT Username FROM BachecaElettronicadb.UCC WHERE Username=username) then
		signal sqlstate '45002' set message_text = "User was inserted as UCC";
	end if;
	if exists (SELECT Username FROM BachecaElettronicadb.USCC WHERE Username=username) then
		signal sqlstate '45003' set message_text = "User was inserted as USCC";
	end if;*/
	
	call BachecaElettronicadb.inserisci_Storico(idStorico);
	call BachecaElettronicadb.inserimentoInfoAnagrafiche(cf_anagrafico, cognome, nome, indirizzoDiResidenza, cap, indirizzoDiFatturazione, tipoRecapitoPreferito, recapitoPreferito);
	call BachecaElettronicadb.inserisci_RecapitoNonPreferito(tipoRecapitoNonPreferito, recapitoNonPreferito, cf_anagrafico);		

	
	INSERT INTO BachecaElettronicadb.USCC (Username, Password, StoricoConversazione_ID, CF_Anagrafico) 
	VALUES(username, password, idStorico, cf_anagrafico);
	
	commit;

	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento delle Informazioni Anagrafiche ------------------------ 
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.inserimentoInfoAnagrafiche ;
CREATE PROCEDURE BachecaElettronicadb.inserimentoInfoAnagrafiche (IN cf VARCHAR(16), IN cognome VARCHAR(20), IN nome VARCHAR(20), IN indirizzoDiResidenza VARCHAR(20), IN cap INT, IN indirizzoDiFatturazione VARCHAR(20), IN tipoRecapitoPreferito VARCHAR(20), IN recapitoPreferito VARCHAR(20))
BEGIN
	
	INSERT INTO BachecaElettronicadb.InformazioneAnagrafica (CF, Cognome, Nome, IndirizzoDiResidenza, CAP, IndirizzoDiFatturazione, tipoRecapitoPreferito, RecapitoPreferito) 
	VALUES(cf, cognome, nome, indirizzoDiResidenza, cap, indirizzoDiFatturazione, tipoRecapitoPreferito, recapitoPreferito);

END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Modifica delle Informazioni Anagrafiche --------------------------- Modifico le informazioni a seconda delle cose che voglio modificare
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.modificaInfoAnagrafiche ;
CREATE PROCEDURE BachecaElettronicadb.modificaInfoAnagrafiche (IN cf VARCHAR(16), IN cognome VARCHAR(20), IN nome VARCHAR(20), IN indirizzoDiResidenza VARCHAR(20), IN cap INT, IN indirizzoDiFatturazione VARCHAR(20), IN tipoRecapitoPreferito VARCHAR(20), IN recapitoPreferito VARCHAR(40))
BEGIN
	if ((SELECT count(CF) FROM BachecaElettronicadb.InformazioneAnagrafica WHERE BachecaElettronicadb.InformazioneAnagrafica.CF=cf)=1) then
		IF cognome IS NOT NULL THEN
			UPDATE BachecaElettronicadb.InformazioneAnagrafica SET Cognome=cognome WHERE CF=cf;
		END IF;
		IF nome IS NOT NULL THEN
			UPDATE BachecaElettronicadb.InformazioneAnagrafica SET Nome=nome WHERE CF=cf;
		END IF;
		IF indirizzoDiResidenza IS NOT NULL THEN
			UPDATE BachecaElettronicadb.InformazioneAnagrafica SET IndirizzoDiResidenza=indirizzoDiResidenza WHERE CF=cf;
		END IF;
		IF indirizzoDiFatturazione IS NOT NULL THEN
			UPDATE BachecaElettronicadb.InformazioneAnagrafica SET IndirizzoDiFatturazione=indirizzoDiFatturazione WHERE CF=cf;
		END IF;
		IF cap IS NOT NULL THEN
			UPDATE BachecaElettronicadb.InformazioneAnagrafica SET CAP=cap, IndirizzoDiFatturazione=indirizzoDiFatturazione WHERE CF=cf;
		END IF;
		IF tipoRecapitoPreferito IS NOT NULL THEN
			UPDATE BachecaElettronicadb.InformazioneAnagrafica SET TipoRecapitoPreferito=tipoRecapitoPreferito WHERE CF=cf;
		END IF;
		IF recapitoPreferito IS NOT NULL THEN
			UPDATE BachecaElettronicadb.InformazioneAnagrafica SET RecapitoPreferito=recapitoPreferito WHERE CF=cf;
		END IF;	
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento di una nuova categoria --------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.inserimentoNuovaCategoria ;
CREATE PROCEDURE BachecaElettronicadb.inserimentoNuovaCategoria (IN nome VARCHAR(20))
	BEGIN
	if ((SELECT count(Nome) FROM BachecaElettronicadb.Categoria WHERE BachecaElettronicadb.Categoria.Nome=nome)=0) then
		INSERT INTO BachecaElettronicadb.Categoria (Nome) 
		VALUES(nome);
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione categoria ----------------------------------------- Impostare un livello di isolamento
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaCategoria ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaCategoria ()
	BEGIN
		SELECT Nome
		FROM BachecaElettronicadb.Categoria;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento di un nuovo annuncio ---------------------------------- Impostare una livello di isolamento - Le categorie potrebbere essere preimpostate
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.inserimentoNuovoAnnuncio ;
CREATE PROCEDURE BachecaElettronicadb.inserimentoNuovoAnnuncio (IN descrizione VARCHAR(100), IN importo INT, IN foto BINARY, IN ucc_username VARCHAR(45), IN categoria_nome VARCHAR(20))
BEGIN
	if ((SELECT(count(Username)) FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username=ucc_username) != 1) then
		signal sqlstate '45000' set message_text = 'User not found';
	end if;
	if ((SELECT(count(Nome)) FROM BachecaElettronicadb.Categoria WHERE BachecaElettronicadb.Categoria.Nome=categoria_nome) != 1) then
		signal sqlstate '45001' set message_text = 'Category not found';
	end if;
			
	IF foto IS NULL THEN	-- evito di sovrascrivere una foto già esistente
		INSERT INTO BachecaElettronicadb.Annuncio (Codice, Stato, Descrizione, Importo, UCC_Username, Categoria_Nome) VALUES(NULL, 'Attivo', descrizione, importo, ucc_username, categoria_nome);
	ELSE
		INSERT INTO BachecaElettronicadb.Annuncio (Codice, Stato, Descrizione, Importo, Foto, UCC_Username, Categoria_Nome) VALUES(NULL, 'Attivo', descrizione, importo, foto, ucc_username, categoria_nome);
	END IF;
			
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento o Rimozione di una foto in annuncio ------------------- Impostare un livello di isolamento per evitare repeatible read - Evento: avverti utenti che seguono l'annuncio - Inserisci o rimuovi foto a seconda del parametro
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.modificaFotoAnnuncio ;
CREATE PROCEDURE BachecaElettronicadb.modificaFotoAnnuncio (IN codice INT, IN foto BINARY)
BEGIN
	if ((SELECT(count(codice)) FROM BachecaElettronicadb.Annuncio WHERE Codice=codice AND Stato='Attivo') = 1) then
		UPDATE BachecaElettronicadb.Annuncio
		SET Foto = foto
		WHERE Codice=codice;
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizza annuncio -----------------------------------------------  Impostare un livello di isolamento
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaAnnuncio ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaAnnuncio ()
BEGIN
	SELECT *
	FROM BachecaElettronicadb.Annuncio;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento o Rimozione commento ---------------------------------- Evento: avverti utenti che seguono l'annuncio - Inserimento o Rimozione del commento a seconda del parametro
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.modificaCommento ;
CREATE PROCEDURE BachecaElettronicadb.modificaCommento (IN testo VARCHAR(45), IN annuncio_codice INT, IN ID_rimozione_commento INT)
BEGIN
	if ((SELECT(count(Annuncio_Codice)) FROM BachecaElettronicadb.Annuncio WHERE Codice=annuncio_codice AND Stato='Attivo') = 1) then
		IF (ID_rimozione_commento = 0) then	
			INSERT INTO BachecaElettronicadb.Commento (Testo, Annuncio_Codice) VALUES(testo, annuncio_codice);
		else
			DELETE FROM BachecaElettronicadb.Commento
			WHERE ID = ID_rimozione_commento;
		end IF;
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione commento ------------------------------------------ Impostare un livello di isolamento
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaCommento ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaCommento (IN annuncio_codice INT)
BEGIN
	if ((SELECT(count(Annuncio_Codice)) FROM BachecaElettronicadb.Annuncio WHERE Codice=annuncio_codice AND Stato='Attivo') = 1) then
		SELECT Testo, Annuncio_codice  -- AS "Codice dell'annuncio"
		FROM BachecaElettronicadb.Commento
		WHERE Annuncio_Codice = annuncio_codice;
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Invio messaggio da parte USCC ------------------------------------- Evento: arrivato un nuovo messaggio
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.invioMessaggioUSCC ;
CREATE PROCEDURE BachecaElettronicadb.invioMessaggioUSCC (IN conversazione_codice INT, IN uscc_username VARCHAR(45), IN ucc_username VARCHAR(45), IN testo VARCHAR(100))
BEGIN
	declare conversazioni_table, last_id_conversazione, storico_id_ucc, storico_id_uscc INT;
	
	if ((SELECT count(Username) FROM BachecaElettronicadb.USCC WHERE Username=uscc_username) = 1) then

		if conversazione_codice IS NOT NULL then   -- controllo se esiste già una conversazione	
			SELECT Conversazione_Codice INTO conversazioni_table
			FROM BachecaElettronicadb.`Partecipa-USCC`
			WHERE USCC_Username=uscc_username and Conversazione_Codice=conversazione_codice;
			
			IF conversazioni_table IS NOT NULL THEN  -- controllo se la ricerca ha avuto esito positivo
				INSERT INTO BachecaElettronicadb.Messaggio (Data, Conversazione_Codice, Testo)
				VALUES (now(), conversazione_codice, testo);
			-- ELSE
				-- errore codice inserito è errato
			END IF;										
		end if;
		
		if (conversazione_codice IS NULL AND (SELECT count(Username) FROM BachecaElettronicadb.UCC WHERE Username=ucc_username)=1) then -- la conversazione non esiste, quindi viene creata una nuova
					
			call BachecaElettronicadb.inserimentoConversazione(last_id_conversazione);
			
			INSERT INTO BachecaElettronicadb.`Partecipa-USCC` (Conversazione_Codice, USCC_Username) VALUES(last_id_conversazione, uscc_username);	-- inserisco la partecipazione per USCC
			INSERT INTO BachecaElettronicadb.`Partecipa-UCC` (Conversazione_Codice, UCC_Username) VALUES(last_id_conversazione, ucc_username);		-- inserisco la partecipazione per UCC
			INSERT INTO BachecaElettronicadb.Messaggio (ID, Data, Conversazione_Codice, Testo) VALUES(NULL, now(), last_id_conversazione, testo);
			
			SELECT StoricoConversazione_ID INTO storico_id_ucc
			FROM BachecaElettronicadb.UCC
			WHERE Username=ucc_username;
			
			SELECT StoricoConversazione_ID INTO storico_id_uscc
			FROM BachecaElettronicadb.USCC
			WHERE Username=uscc_username;
			
			INSERT INTO BachecaElettronicadb.Tracciato (Conversazione_Codice, StoricoConversazione_ID) VALUES(last_id_conversazione, storico_id_ucc);	-- traccio lo storico di UCC
			INSERT INTO BachecaElettronicadb.Tracciato (Conversazione_Codice, StoricoConversazione_ID) VALUES(last_id_conversazione, storico_id_uscc);	-- traccio lo storico di USCC
			INSERT INTO BachecaElettronicadb.ConversazioneCodice (CodiceConv, StoricoConversazione_ID) VALUES(last_id_conversazione, storico_id_ucc); 	-- inserisco il nuovo codice della conversazione nello storico di UCC
			INSERT INTO BachecaElettronicadb.ConversazioneCodice (CodiceConv, StoricoConversazione_ID) VALUES(last_id_conversazione, storico_id_uscc); 	-- inserisco il nuovo codice della conversazione nello storico di USCC
		end if;
			
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------


-- Inserimento Conversazione ----------------------------------------- Impostare un livello di isolamento
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.inserimentoConversazione ;
CREATE PROCEDURE BachecaElettronicadb.inserimentoConversazione (OUT id_conversazione INT)
BEGIN
	INSERT INTO BachecaElettronicadb.Conversazione (Codice) VALUES(NULL);
	SET id_conversazione = LAST_INSERT_ID();
END//
DELIMITER ;
-- -------------------------------------------------------------------


-- Invio messaggio da parte UCC AD UN USCC --------------------------- Evento: arrivato un nuovo messaggio
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.invioMessaggio_UCC_USCC ;
CREATE PROCEDURE BachecaElettronicadb.invioMessaggio_UCC_USCC (IN conversazione_codice INT, IN ucc_username VARCHAR(45), IN uscc_username VARCHAR(45), IN testo VARCHAR(100))
BEGIN
	declare conversazioni_table, last_id_conversazione, storico_id_ucc, storico_id_uscc INT;
	
	if ((SELECT count(Username) FROM BachecaElettronicadb.UCC WHERE Username=ucc_username) = 1) then

		if conversazione_codice IS NOT NULL then   -- controllo se esiste già una conversazione	
			SELECT Conversazione_Codice INTO conversazioni_table
			FROM BachecaElettronicadb.`Partecipa-UCC`
			WHERE UCC_Username=ucc_username and Conversazione_Codice=conversazione_codice;
			
			IF conversazioni_table IS NOT NULL THEN  -- controllo se la ricerca ha avuto esito positivo
				INSERT INTO BachecaElettronicadb.Messaggio (Data, Conversazione_Codice, Testo)
				VALUES (now(), conversazione_codice, testo);
			-- ELSE
				-- errore codice inserito è errato
			END IF;

		end if;
		
		if (conversazione_codice IS NULL AND (SELECT count(Username) FROM BachecaElettronicadb.USCC WHERE Username=uscc_username)=1) then -- la conversazione non esiste, quindi viene creata una nuova
						
			call BachecaElettronicadb.inserimentoConversazione(last_id_conversazione);
			
			INSERT INTO BachecaElettronicadb.`Partecipa-UCC` (Conversazione_Codice, UCC_Username) VALUES(last_id_conversazione, ucc_username);		-- inserisco la partecipazione per UCC
			INSERT INTO BachecaElettronicadb.`Partecipa-USCC` (Conversazione_Codice, UCC_Username) VALUES(last_id_conversazione, uscc_username);	-- inserisco la partecipazione per USCC
			INSERT INTO BachecaElettronicadb.Messaggio (ID, Data, Conversazione_Codice, Testo) VALUES(NULL, now(), last_id_conversazione, testo);
			
			SELECT StoricoConversazione_ID INTO storico_id_ucc
			FROM BachecaElettronicadb.UCC
			WHERE Username=ucc_username;
			
			SELECT StoricoConversazione_ID INTO storico_id_uscc
			FROM BachecaElettronicadb.USCC
			WHERE Username=uscc_username;
			
			INSERT INTO BachecaElettronicadb.Tracciato (Conversazione_Codice, StoricoConversazione_ID) VALUES(last_id_conversazione, storico_id_ucc);	-- traccio lo storico di UCC
			INSERT INTO BachecaElettronicadb.Tracciato (Conversazione_Codice, StoricoConversazione_ID) VALUES(last_id_conversazione, storico_id_uscc);	-- traccio lo storico di USCC
			INSERT INTO BachecaElettronicadb.ConversazioneCodice (CodiceConv, StoricoConversazione_ID) VALUES(last_id_conversazione, storico_id_ucc); 	-- inserisco il nuovo codice della conversazione nello storico di UCC
			INSERT INTO BachecaElettronicadb.ConversazioneCodice (CodiceConv, StoricoConversazione_ID) VALUES(last_id_conversazione, storico_id_uscc); 	-- inserisco il nuovo codice della conversazione nello storico di USCC
		end if;
			
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Invio messaggio da parte UCC AD UN UCC ---------------------------- Evento: arrivato un nuovo messaggio
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.invioMessaggio_UCC_UCC ;
CREATE PROCEDURE BachecaElettronicadb.invioMessaggio_UCC_UCC (IN conversazione_codice INT, IN ucc_username_1 VARCHAR(45), IN ucc_username_2 VARCHAR(45), IN testo VARCHAR(100))
BEGIN
	declare conversazioni_table, last_id_conversazione, storico_id_ucc_1, storico_id_ucc_2 INT;
	
	if ((SELECT count(Username) FROM BachecaElettronicadb.UCC WHERE Username=ucc_username_1) = 1) then

		if conversazione_codice IS NOT NULL then   					-- controllo se esiste già una conversazione	
			SELECT Conversazione_Codice INTO conversazioni_table
			FROM BachecaElettronicadb.`Partecipa-UCC`
			WHERE UCC_Username=ucc_username_1 and Conversazione_Codice=conversazione_codice;
			
			IF conversazioni_table IS NOT NULL THEN  				-- controllo se la ricerca ha avuto esito positivo
				INSERT INTO BachecaElettronicadb.Messaggio (Data, Conversazione_Codice, Testo)
				VALUES (now(), conversazione_codice, testo);
			-- ELSE
				-- errore codice inserito è errato
			END IF;

		end if;
		
		if (conversazione_codice IS NULL AND (SELECT count(Username) FROM BachecaElettronicadb.UCC WHERE Username=ucc_username_2)=1) then -- la conversazione non esiste, quindi viene creata una nuova
						
			call BachecaElettronicadb.inserimentoConversazione(last_id_conversazione);
			
			INSERT INTO BachecaElettronicadb.`Partecipa-UCC` (Conversazione_Codice, UCC_Username) VALUES(last_id_conversazione, ucc_username_1);	-- inserisco la partecipazione per il primo UCC
			INSERT INTO BachecaElettronicadb.`Partecipa-UCC` (Conversazione_Codice, UCC_Username) VALUES(last_id_conversazione, ucc_username_2);	-- inserisco la partecipazione per il secondo UCC
			INSERT INTO BachecaElettronicadb.Messaggio (ID, Data, Conversazione_Codice, Testo) VALUES(NULL, now(), last_id_conversazione, testo);
			
			SELECT StoricoConversazione_ID INTO storico_id_ucc_1
			FROM BachecaElettronicadb.UCC
			WHERE Username=ucc_username_1;
			
			SELECT StoricoConversazione_ID INTO storico_id_ucc_2
			FROM BachecaElettronicadb.UCC
			WHERE Username=ucc_username_2;
			
			INSERT INTO BachecaElettronicadb.Tracciato (Conversazione_Codice, StoricoConversazione_ID) VALUES(last_id_conversazione, storico_id_ucc_1);		-- traccio lo storico del primo UCC
			INSERT INTO BachecaElettronicadb.Tracciato (Conversazione_Codice, StoricoConversazione_ID) VALUES(last_id_conversazione, storico_id_ucc_2);		-- traccio lo storico del secondo UCC
			INSERT INTO BachecaElettronicadb.ConversazioneCodice (CodiceConv, StoricoConversazione_ID) VALUES(last_id_conversazione, storico_id_ucc_1); 	-- inserisco il nuovo codice della conversazione nello storico del primo UCC
			INSERT INTO BachecaElettronicadb.ConversazioneCodice (CodiceConv, StoricoConversazione_ID) VALUES(last_id_conversazione, storico_id_ucc_2); 	-- inserisco il nuovo codice della conversazione nello storico del secondo UCC
		end if;
			
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizza messaggio ---------------------------------------------- Impostare un livello di isolamento
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaMessaggio ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaMessaggio (IN conversazione_codice INT)
BEGIN
	if ((SELECT(count(Codice)) FROM BachecaElettronicadb.Conversazione WHERE Codice=conversazione_codice) = 1) then
		SELECT Testo, Data
		FROM BachecaElettronicadb.Messaggio
		WHERE Conversazione_Codice = conversazione_codice
		ORDER BY Data ASC;
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Seguire un annuncio UCC -------------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.seguiAnnuncioUCC ;
CREATE PROCEDURE BachecaElettronicadb.seguiAnnuncioUCC (IN codice_annuncio INT, IN ucc_username VARCHAR(45))
BEGIN
	if ((SELECT(count(Codice)) FROM BachecaElettronicadb.Annuncio WHERE Codice=codice_annuncio and Stato='Attivo') = 1) then
		INSERT INTO BachecaElettronicadb.`Seguito-UCC`(UCC_Username, Annuncio_Codice) VALUES(ucc_username, codice_annuncio);
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Seguire un annuncio USCC ------------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.seguiAnnuncioUSCC ;
CREATE PROCEDURE BachecaElettronicadb.seguiAnnuncioUSCC (IN codice_annuncio INT, IN uscc_username VARCHAR(45))
BEGIN
	if ((SELECT(count(Codice)) FROM BachecaElettronicadb.Annuncio WHERE Codice=codice_annuncio and Stato='Attivo') = 1) then
		INSERT INTO BachecaElettronicadb.`Seguito-USCC`(USCC_Username, Annuncio_Codice) VALUES(uscc_username, codice_annuncio);
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento nota in un Annuncio -----------------------------------	Attivare evento avverti utente che seguono l'annuncio
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.inserisciNota ;
CREATE PROCEDURE BachecaElettronicadb.inserisciNota (IN codice_annuncio INT, IN testo VARCHAR(45))
BEGIN
	if ((SELECT(count(Codice)) FROM BachecaElettronicadb.Annuncio WHERE Codice=codice_annuncio and Stato='Attivo') = 1) then
		INSERT INTO BachecaElettronicadb.Nota (ID, Testo, Annuncio_Codice) VALUES(NULL, testo, codice_annuncio);
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizza nota --------------------------------------------------- Impostare un livello di isolamento
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaNota ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaNota (IN annuncio_Codice INT)
BEGIN
	if ((SELECT(count(Codice)) FROM BachecaElettronicadb.Annuncio WHERE Codice=annuncio_Codice and Stato='Attivo') = 1) then
		SELECT Testo, Annuncio_Codice AS "Codice dell'annuncio"
		FROM BachecaElettronicadb.Nota
		WHERE Annuncio_Codice = annuncio_Codice;
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Rimozione di un Annuncio ------------------------------------------	Attivare evento avverti utente che seguono l'annuncio - Attivare evento genera report
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.rimuoviAnnuncio ;
CREATE PROCEDURE BachecaElettronicadb.rimuoviAnnuncio (IN codice_annuncio INT)
BEGIN
	if ((SELECT(count(Codice)) FROM BachecaElettronicadb.Annuncio WHERE Codice=codice_annuncio and Stato='Attivo') = 1) then
		UPDATE BachecaElettronica.Annuncio
		SET Stato = 'Rimosso'
		WHERE Codice = codice_annuncio;
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione degli Annunci seguiti UCC ------------------------- Impostare un livello di isolamento
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaAnnunciSeguiti_UCC ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaAnnunciSeguiti_UCC (IN ucc_username VARCHAR(45))
BEGIN
	if ((SELECT(count(Username)) FROM BachecaElettronicadb.UCC WHERE Username=ucc_username) = 1) then
		SELECT Annuncio_Codice, Stato
		FROM BachecaElettronicadb.`Seguito-UCC` AS seguiti JOIN BachecaElettronicadb.Annuncio AS annuncio ON seguiti.Annuncio_Codice=annuncio.Codice
		WHERE seguiti.UCC_Username = ucc_username;
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione degli Annunci seguiti USCC ------------------------ Impostare un livello di isolamento
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaAnnunciSeguiti_USCC ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaAnnunciSeguiti_USCC (IN uscc_username VARCHAR(45))
BEGIN
	if ((SELECT(count(Username)) FROM BachecaElettronicadb.USCC WHERE Username=uscc_username) = 1) then
		SELECT Annuncio_Codice, Stato
		FROM BachecaElettronicadb.`Seguito-USCC` AS seguiti JOIN BachecaElettronicadb.Annuncio AS annuncio ON seguiti.Annuncio_Codice=annuncio.Codice
		WHERE seguiti.USCC_Username = uscc_username;
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione Storico USCC -------------------------------------- Impostare un livello di isolamento
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaStorico_USCC ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaStorico_USCC (IN uscc_username VARCHAR(45))
BEGIN
	declare idStorico INT;
	if ((SELECT(count(Username)) FROM BachecaElettronicadb.USCC WHERE Username=uscc_username) = 1) then
		SELECT StoricoConversazione_ID INTO idStorico FROM BachecaElettronicadb.USCC WHERE Username=uscc_username;
		
		SELECT CodiceConv AS `Codice Conversazione`
		FROM BachecaElettronicadb.ConversazioneCodice
		WHERE StoricoConversazione_ID = idStorico;
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione Storico UCC --------------------------------------- Impostare un livello di isolamento
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaStorico_UCC ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaStorico_UCC (IN ucc_username VARCHAR(45))
BEGIN
	declare idStorico INT;
	if ((SELECT(count(Username)) FROM BachecaElettronicadb.UCC WHERE Username=ucc_username) = 1) then
		SELECT StoricoConversazione_ID INTO idStorico FROM BachecaElettronicadb.UCC WHERE Username=ucc_username;
		
		SELECT CodiceConv AS `Codice Conversazione`
		FROM BachecaElettronicadb.ConversazioneCodice
		WHERE StoricoConversazione_ID = idStorico;
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Generazione di un nuovo report ------------------------------------ Controllare se bisogna attivare un evento per non calcolare ogni volta annunci già calcolati
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.generaReport ;
CREATE PROCEDURE BachecaElettronicadb.generaReport (IN ucc_username VARCHAR(45))
BEGIN
	declare numeroCarta VARCHAR(16);
	declare codice_annuncio INT;
	declare importo INT DEFAULT 0;
	declare loop_import INT DEFAULT 0;
	declare sum_import CURSOR FOR SELECT Codice FROM BachecaElettronica.Annuncio WHERE UCC_Username=ucc_username and Stato='Venduto';
	declare continue handler for not found set loop_import=1;
	
	-- begin 
		-- rollback;
		-- resignal;
	-- end;
	
	-- start transaction;
		if ((SELECT(count(Username)) FROM BachecaElettronicadb.UCC WHERE Username=ucc_username) = 1) then
			SELECT NumeroCarta INTO numeroCarta FROM BachecaElettronicadb.UCC WHERE Username=ucc_username;
			
			if sum_import is not null then
				OPEN sum_import;
				calculate_import: WHILE(loop_import=0) DO
					FETCH sum_import INTO codice_annuncio;
					IF loop_import = 1 THEN
						LEAVE calculate_import;
					END IF;
					SET importo = importo + (SELECT Importo FROM BachecaElettronicadb.Annuncio WHERE Codice=codice_annuncio);
				end  WHILE;
				CLOSE sum_import;
			end if;
		
			INSERT INTO BachecaElettronicadb.Report (UCC_Username, ImportoTotale, NumeroCarta, Data, Riscosso, SommaAmministratore)
			VALUES(ucc_username, importo, numeroCarta, now(), 0, 0);
		else
			signal sqlstate '45000' set message_text = "User not found\n";
		end if;
	-- commit;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Riscossione di un report ------------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.riscossioneReport ;
CREATE PROCEDURE BachecaElettronicadb.riscossioneReport (IN ucc_username VARCHAR(45), IN data DATETIME)
BEGIN
		declare importo INT;
		SELECT ImportoTotale FROM BachecaElettronicadb.Report WHERE UCC_Username=ucc_username and Data=data INTO importo;
		
		UPDATE BachecaElettronicadb.Report
		SET Riscosso = 1, SommaAmministratore = importo*0.3
		WHERE UCC_Username = ucc_username and Data = data and Riscosso = 0;
		
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Selezione Conversazione dallo Storico UCC -------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.selezionaConversazioneStorico_UCC ;
CREATE PROCEDURE BachecaElettronicadb.selezionaConversazioneStorico_UCC (IN ucc_username VARCHAR(45), IN codiceConv INT)
BEGIN
	declare idStorico INT;
	if ((SELECT(count(Username)) FROM BachecaElettronicadb.UCC WHERE Username=ucc_username) = 1) then
		SELECT StoricoConversazione_ID INTO idStorico FROM BachecaElettronicadb.UCC WHERE Username=ucc_username;
		
		SELECT CodiceConv AS `Codice Conversazione`
		FROM BachecaElettronicadb.ConversazioneCodice
		WHERE StoricoConversazione_ID = idStorico and CodiceConv = codiceConv;
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Selezione Conversazione dallo Storico USCC ------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.selezionaConversazioneStorico_USCC ;
CREATE PROCEDURE BachecaElettronicadb.selezionaConversazioneStorico_USCC (IN ucc_username VARCHAR(45), IN codiceConv INT)
BEGIN
	declare idStorico INT;
	if ((SELECT(count(Username)) FROM BachecaElettronicadb.USCC WHERE Username=uscc_username) = 1) then
		SELECT StoricoConversazione_ID INTO idStorico FROM BachecaElettronicadb.USCC WHERE Username=uscc_username;
		
		SELECT CodiceConv AS `Codice Conversazione`
		FROM BachecaElettronicadb.ConversazioneCodice
		WHERE StoricoConversazione_ID = idStorico and CodiceConv = codiceConv;
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Login ------------------------------------------------------------- Impostare un livello di isolamento
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.login ;
CREATE PROCEDURE BachecaElettronicadb.login (IN username VARCHAR(45), IN password VARCHAR(45), OUT role INT)
BEGIN
	
	SET role = -1;
	
	if exists (SELECT Username FROM BachecaElettronicadb.Amministratore WHERE Username = username and Password = password) then
		SET role = 1;
	end if;

	if exists (SELECT Username FROM BachecaElettronicadb.UCC WHERE Username = username and Password = password) and role = -1 then
		SET role = 2;
	end if;
	
	if exists (SELECT Username FROM BachecaElettronicadb.USCC WHERE Username = username and Password = password) and role = -1 then
		SET role = 3;
	end if;
	
	if (role = -1) then
		SET role = 4;
	end if;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------
