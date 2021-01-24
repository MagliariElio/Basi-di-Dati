
-- STORED PROCEDURES

-- ------------------------------------
USE `BachecaElettronicadb`
-- ------------------------------------

-- Registrazione di un utente UCC-------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.registra_utente_UCC ;
CREATE PROCEDURE BachecaElettronicadb.registra_utente_UCC (IN username VARCHAR(45), IN password VARCHAR(45), IN numeroCarta VARCHAR(16), IN dataScadenza DATE, IN cvc INT, IN cf_anagrafico VARCHAR(16), IN cognome VARCHAR(20), IN nome VARCHAR(20), IN indirizzoDiResidenza VARCHAR(20), IN cap INT, IN indirizzoDiFatturazione VARCHAR(20), IN tipoRecapitoPreferito VARCHAR(20), IN recapitoPreferito VARCHAR(20), IN tipoRecapitoNonPreferito VARCHAR(20), IN recapitoNonPreferito VARCHAR(20))
BEGIN
	declare idStorico INT;
	
	if (SELECT count(Username) FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username=username) > 0 then
		signal sqlstate '45002' set message_text = "User was inserted as UCC";
	elseif (SELECT count(Username) FROM BachecaElettronicadb.USCC WHERE BachecaElettronicadb.USCC.Username=username) > 0 then
		signal sqlstate '45003' set message_text = "User was inserted as USCC";
	end if;
		
	call BachecaElettronicadb.inserisci_Storico(idStorico);
	call BachecaElettronicadb.inserimentoInfoAnagrafiche(cf_anagrafico, cognome, nome, indirizzoDiResidenza, cap, indirizzoDiFatturazione, tipoRecapitoPreferito, recapitoPreferito);
	call BachecaElettronicadb.inserisci_RecapitoNonPreferito(tipoRecapitoNonPreferito, recapitoNonPreferito, cf_anagrafico);		
	
	INSERT INTO BachecaElettronicadb.UCC (Username, Password, NumeroCarta, DataScadenza, CVC, StoricoConversazione_ID, CF_Anagrafico)
	VALUES(username, md5(password), numeroCarta, dataScadenza, cvc, idStorico, cf_anagrafico);
	
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
	
	if not exists (SELECT CF FROM BachecaElettronicadb.InformazioneAnagrafica WHERE BachecaElettronicadb.InformazioneAnagrafica.CF=cf_anagrafico) then
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
	
	if (SELECT count(Username) FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username=username) > 0 then
		signal sqlstate '45002' set message_text = "User was inserted as UCC";
	elseif (SELECT count(Username) FROM BachecaElettronicadb.USCC WHERE BachecaElettronicadb.USCC.Username=username) > 0 then
		signal sqlstate '45003' set message_text = "User was inserted as USCC";
	end if;
	
	call BachecaElettronicadb.inserisci_Storico(idStorico);
	call BachecaElettronicadb.inserimentoInfoAnagrafiche(cf_anagrafico, cognome, nome, indirizzoDiResidenza, cap, indirizzoDiFatturazione, tipoRecapitoPreferito, recapitoPreferito);
	call BachecaElettronicadb.inserisci_RecapitoNonPreferito(tipoRecapitoNonPreferito, recapitoNonPreferito, cf_anagrafico);		

	
	INSERT INTO BachecaElettronicadb.USCC (Username, Password, StoricoConversazione_ID, CF_Anagrafico) 
	VALUES(username, md5(password), idStorico, cf_anagrafico);
	
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
	
	if (SELECT count(Nome) FROM BachecaElettronicadb.Categoria WHERE BachecaElettronicadb.Categoria.Nome=nome) > 0 then
		signal sqlstate '45005' set message_text = "Category already exists";
	end if;
	
	INSERT INTO BachecaElettronicadb.Categoria (Nome) VALUES(nome);

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
			
	IF foto IS NULL THEN
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
CREATE PROCEDURE BachecaElettronicadb.visualizzaAnnuncio (IN annuncio_codice INT, IN username VARCHAR(45))
BEGIN
	if ((SELECT(count(Username)) FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username=username) != 1) then
		signal sqlstate '45000' set message_text = 'User not found';
	end if;	
	
	IF (annuncio_codice IS NOT NULL AND username IS NOT NULL) THEN
		SELECT *
		FROM BachecaElettronicadb.Annuncio
		WHERE BachecaElettronicadb.Annuncio.UCC_Username=username AND BachecaElettronicadb.Annuncio.Codice=annuncio_codice;
	ELSEIF (annuncio_codice IS NULL AND username IS NOT NULL) THEN
		SELECT *
		FROM BachecaElettronicadb.Annuncio
		WHERE BachecaElettronicadb.Annuncio.UCC_Username=username;
	ELSEIF (annuncio_codice IS NOT NULL AND username IS NULL) THEN
		SELECT *
		FROM BachecaElettronicadb.Annuncio
		WHERE BachecaElettronicadb.Annuncio.Codice=annuncio_codice;
	ELSE
		SELECT *
		FROM BachecaElettronicadb.Annuncio;
	end IF;
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
	if (SELECT(count(Codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=codice_annuncio and Stato='Attivo') = 0 then
		signal sqlstate '45006' set message_text = "Ad not found";
	end if;
	
	INSERT INTO BachecaElettronicadb.`Seguito-UCC`(UCC_Username, Annuncio_Codice) VALUES(ucc_username, codice_annuncio);

END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Seguire un annuncio USCC ------------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.seguiAnnuncioUSCC ;
CREATE PROCEDURE BachecaElettronicadb.seguiAnnuncioUSCC (IN codice_annuncio INT, IN uscc_username VARCHAR(45))
BEGIN
	if (SELECT(count(Codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=codice_annuncio and Stato='Attivo') = 0 then
		signal sqlstate '45006' set message_text = "Ad not found";
	end if;		
	
	INSERT INTO BachecaElettronicadb.`Seguito-USCC`(USCC_Username, Annuncio_Codice) VALUES(uscc_username, codice_annuncio);

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
	
	if exists (SELECT Username FROM BachecaElettronicadb.Amministratore WHERE BachecaElettronicadb.Amministratore.Username = username and BachecaElettronicadb.Amministratore.Password = md5(password)) then
		SET role = 1;
	end if;

	if exists (SELECT Username FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username = username and BachecaElettronicadb.UCC.Password = md5(password)) and role = -1 then
		SET role = 2;
	end if;
	
	if exists (SELECT Username FROM BachecaElettronicadb.USCC WHERE BachecaElettronicadb.USCC.Username = username and BachecaElettronicadb.USCC.Password = md5(password)) and role = -1 then
		SET role = 3;
	end if;
	
	if (role = -1) then
		SET role = 4;
	end if;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- UCC USERS

call BachecaElettronicadb.registra_utente_UCC ('sigkreco', '9fca81f9', '2614339716052408', STR_TO_DATE('14-07-2022', '%d-%m-%Y'), 464, 'GRCKRS80A01D612N', 'Greco', 'Kris', 'Piazza Ivano', 54835, 'Piazza Ivano', 'email', 'sigkreco@gmail.com', 'cellulare', '3930909457');
call BachecaElettronicadb.registra_utente_UCC ('dottbo', '7db05b4e', '6011633458641380', STR_TO_DATE('27-07-2023', '%d-%m-%Y'), 786, 'CLMMGN80A01F205N', 'Colombo', 'Morgana', 'Borgo Rinaldi', 85649, 'Borgo Rinaldi', 'email', 'dottbo@gmail.com', 'cellulare', '3931493778');
call BachecaElettronicadb.registra_utente_UCC ('fioreeri', '46dc97c5', '4532642309851754', STR_TO_DATE('18-02-2023', '%d-%m-%Y'), 677, 'NREFNT80A01L219S', 'Neri', 'Fiorentino', 'Piazza Felicia', 29565, 'Piazza Felicia', 'email', 'fioreeri@gmail.com', 'cellulare', '3930657671');
call BachecaElettronicadb.registra_utente_UCC ('dottmeco', '297830af', '4024007159858512', STR_TO_DATE('05-08-2023', '%d-%m-%Y'), 596, 'GRCMTT80A01L219K', 'Greco', 'Mietta', 'Borgo Gerlando', 31870, 'Borgo Gerlando', 'email', 'dottmeco@gmail.com', 'cellulare', '39361475321');
call BachecaElettronicadb.registra_utente_UCC ('gianatti', 'c9ef9c3b', '6011183407249588', STR_TO_DATE('12-02-2022', '%d-%m-%Y'), 386, 'FRRGNT80A01D612X', 'Ferretti', 'Gianantonio', 'Contrada Ludovico', 48282, 'Contrada Ludovico', 'email', 'gianatti@gmail.com', 'cellulare', '3932927839');
call BachecaElettronicadb.registra_utente_UCC ('zelidando', '050b9d32', '4556498618751842', STR_TO_DATE('21-11-2023', '%d-%m-%Y'), 546, 'RLNZLD80A01F205K', 'Orlando', 'Zelida', 'Borgo Grasso', 18346, 'Borgo Grasso', 'email', 'zelidando@gmail.com', 'cellulare', '393372740');
call BachecaElettronicadb.registra_utente_UCC ('marisri', 'bbf6c6fd', '4215526105393042', STR_TO_DATE('15-01-2022', '%d-%m-%Y'), 916, 'BRBMST80A01F205Z', 'Barbieri', 'Maristella', 'Incrocio Lombardi', 09237, 'Incrocio Lombardi', 'email', 'marisri@gmail.com', 'cellulare', '3930242516');
call BachecaElettronicadb.registra_utente_UCC ('dotteli', 'febcad94', '2720467222285229', STR_TO_DATE('20-02-2021', '%d-%m-%Y'), 955, 'VTLRMS80A01H501W', 'Vitali', 'Ermes', 'Strada Renzo', 50004, 'Strada Renzo', 'email', 'dotteli@gmail.com', 'cellulare', '3939032638');
call BachecaElettronicadb.registra_utente_UCC ('dottmnti', 'e5064e35', '348980262831138', STR_TO_DATE('19-09-2021', '%d-%m-%Y'), 880, 'CNTMCL80A01L219O', 'Conti', 'Marcella', 'Borgo Maristella', 67725, 'Borgo Maristella', 'email', 'dottmnti@gmail.com', 'cellulare', '39382797926');
call BachecaElettronicadb.registra_utente_UCC ('shaino', '60e5fded', '5380888839165583', STR_TO_DATE('27-05-2022', '%d-%m-%Y'), 375, 'MRNSHR80A01D612V', 'Marino', 'Shaira', 'Piazza Damico', 44402, 'Piazza Damico', 'email', 'shaino@gmail.com', 'cellulare', '393001562');
call BachecaElettronicadb.registra_utente_UCC ('marceosa', 'ea5db7bf', '4532759681008199', STR_TO_DATE('22-05-2022', '%d-%m-%Y'), 732, 'DEXMCL80A01L219S', 'De', 'Marcella', 'Strada Jarno', 16029, 'Strada Jarno', 'email', 'marceosa@gmail.com', 'cellulare', '393066508150');
call BachecaElettronicadb.registra_utente_UCC ('marianco', 'f4fcc395', '4716786679206970', STR_TO_DATE('01-03-2021', '%d-%m-%Y'), 449, 'DMCMNT80A01F205O', 'Damico', 'Marianita', 'Via Marina', 96925, 'Via Marina', 'email', 'marianco@gmail.com', 'cellulare', '3930566077');
call BachecaElettronicadb.registra_utente_UCC ('karimmina', '2e3c0288', '2338985153127114', STR_TO_DATE('22-08-2023', '%d-%m-%Y'), 331, 'MSSKRM80A01D612S', 'Messina', 'Karim', 'Incrocio Cosetta', 29332, 'Incrocio Cosetta', 'email', 'karimmina@gmail.com', 'cellulare', '3939666122');
call BachecaElettronicadb.registra_utente_UCC ('sigprzo', 'e434fdad', '4556351084946562', STR_TO_DATE('24-02-2022', '%d-%m-%Y'), 857, 'RZZPRM80A01D612F', 'Rizzo', 'Priamo', 'Strada Baldassarre', 54424, 'Strada Baldassarre', 'email', 'sigprzo@gmail.com', 'cellulare', '39367983428');
call BachecaElettronicadb.registra_utente_UCC ('drrusso', 'f59e4383', '2221097967625273', STR_TO_DATE('08-10-2023', '%d-%m-%Y'), 546, 'RSSRTH80A01H501M', 'Russo', 'Ruth', 'Via Bibiana', 61682, 'Via Bibiana', 'email', 'drrusso@gmail.com', 'cellulare', '3930247336');
call BachecaElettronicadb.registra_utente_UCC ('elgarosi', 'c56ea5a9', '4716027162871', STR_TO_DATE('13-04-2021', '%d-%m-%Y'), 833, 'RSSLGE80A01D612I', 'Rossi', 'Elga', 'Piazza Fiorenzo', 69603, 'Piazza Fiorenzo', 'email', 'elgarosi@gmail.com', 'cellulare', '393382555');
call BachecaElettronicadb.registra_utente_UCC ('drtomssi', 'd8881c06', '4532940377975046', STR_TO_DATE('01-12-2022', '%d-%m-%Y'), 671, 'GRSTMS80A01F205M', 'Grassi', 'Tommaso', 'Contrada Mancini', 37342, 'Contrada Mancini', 'email', 'drtomssi@gmail.com', 'cellulare', '39329697658');
call BachecaElettronicadb.registra_utente_UCC ('dottbri', 'a9015a1c', '2597032511919472', STR_TO_DATE('14-05-2022', '%d-%m-%Y'), 459, 'FBBNZE80A01H501Q', 'Fabbri', 'Enzo', 'Strada Eriberto', 14502, 'Strada Eriberto', 'email', 'dottbri@gmail.com', 'cellulare', '39314284065');
call BachecaElettronicadb.registra_utente_UCC ('cirarizo', 'dd56abbd', '5181668460220639', STR_TO_DATE('17-04-2022', '%d-%m-%Y'), 162, 'RZZCRI80A01D612O', 'Rizzo', 'Cira', 'Contrada Giancarlo', 20024, 'Contrada Giancarlo', 'email', 'cirarizo@gmail.com', 'cellulare', '3934416351');
call BachecaElettronicadb.registra_utente_UCC ('ingvitno', '7c9b3d2c', '6011192973734006', STR_TO_DATE('10-04-2022', '%d-%m-%Y'), 493, 'GRDVLB80A01H501B', 'Giordano', 'Vitalba', 'Rotonda Ortensia', 46884, 'Rotonda Ortensia', 'email', 'ingvitno@gmail.com', 'cellulare', '3935358838');
call BachecaElettronicadb.registra_utente_UCC ('drgiulri', '7c18e47f', '2617666417727707', STR_TO_DATE('21-05-2022', '%d-%m-%Y'), 146, 'NREGTT80A01H501V', 'Neri', 'Giulietta', 'Rotonda Romolo', 33547, 'Rotonda Romolo', 'email', 'drgiulri@gmail.com', 'cellulare', '393348589');
call BachecaElettronicadb.registra_utente_UCC ('demirra', '7173b98c', '4716704654544414', STR_TO_DATE('28-01-2024', '%d-%m-%Y'), 952, 'SRRDME80A01L219Q', 'Serra', 'Demi', 'Rotonda Martino', 31067, 'Rotonda Martino', 'email', 'demirra@gmail.com', 'cellulare', '39367443877');
call BachecaElettronicadb.registra_utente_UCC ('ritamoti', '051c8c01', '4916047254953710', STR_TO_DATE('23-10-2023', '%d-%m-%Y'), 222, 'MNTRTI80A01D612Y', 'Monti', 'Rita', 'Via Monti', 66783, 'Via Monti', 'email', 'ritamoti@gmail.com', 'cellulare', '39306493203');
call BachecaElettronicadb.registra_utente_UCC ('ingaina', 'b692feaa', '4539265685950223', STR_TO_DATE('01-10-2022', '%d-%m-%Y'), 555, 'FRNNTN80A01H501A', 'Farina', 'Antonio', 'Rotonda Barone', 80553, 'Rotonda Barone', 'email', 'ingaina@gmail.com', 'cellulare', '393385107');
call BachecaElettronicadb.registra_utente_UCC ('concci', '901a1003', '375312892989712', STR_TO_DATE('25-05-2021', '%d-%m-%Y'), 763, 'RCCCCT80A01H501D', 'Ricci', 'Concetta', 'Contrada Clodovea', 87509, 'Contrada Clodovea', 'email', 'concci@gmail.com', 'cellulare', '393195776');
call BachecaElettronicadb.registra_utente_UCC ('cirinoco', 'b6c8b032', '4485746108016050', STR_TO_DATE('16-11-2022', '%d-%m-%Y'), 761, 'DMCCRN80A01D612N', 'Damico', 'Cirino', 'Borgo Romano', 84889, 'Borgo Romano', 'email', 'cirinoco@gmail.com', 'cellulare', '3931960395');
call BachecaElettronicadb.registra_utente_UCC ('dindocmbo', 'b7b1f70e', '2371881767593650', STR_TO_DATE('18-12-2021', '%d-%m-%Y'), 217, 'CLMDND80A01L219O', 'Colombo', 'Dindo', 'Incrocio Martinelli', 92824, 'Incrocio Martinelli', 'email', 'dindocmbo@gmail.com', 'cellulare', '39337936248');
call BachecaElettronicadb.registra_utente_UCC ('odonebri', '974c52c6', '2720730256811610', STR_TO_DATE('29-06-2022', '%d-%m-%Y'), 744, 'FBBDNO80A01H501N', 'Fabbri', 'Odone', 'Via Rossetti', 58873, 'Via Rossetti', 'email', 'odonebri@gmail.com', 'cellulare', '3930676257');
call BachecaElettronicadb.registra_utente_UCC ('ferdndo', '61240bf9', '2720617108454956', STR_TO_DATE('15-09-2023', '%d-%m-%Y'), 570, 'RLNFDN80A01F205D', 'Orlando', 'Ferdinando', 'Rotonda Mazza', 26058, 'Rotonda Mazza', 'email', 'ferdndo@gmail.com', 'cellulare', '39366758575');
call BachecaElettronicadb.registra_utente_UCC ('concetta', '4453563d', '2564394088210563', STR_TO_DATE('12-08-2022', '%d-%m-%Y'), 333, 'TSTCCT80A01D612M', 'Testa', 'Concetta', 'Borgo Arduino', 56921, 'Borgo Arduino', 'email', 'concetta@gmail.com', 'cellulare', '39342441715');
call BachecaElettronicadb.registra_utente_UCC ('guidocte', 'e4dcaf13', '4556191300456990', STR_TO_DATE('24-02-2021', '%d-%m-%Y'), 448, 'CNTGDU80A01L219T', 'Conte', 'Guido', 'Rotonda Mariapia', 56055, 'Rotonda Mariapia', 'email', 'guidocte@gmail.com', 'cellulare', '3932384802');
call BachecaElettronicadb.registra_utente_UCC ('fulviino', 'a223e8d4', '4539927486282730', STR_TO_DATE('28-01-2023', '%d-%m-%Y'), 272, 'MRNFLV80A01D612Z', 'Marino', 'Fulvio', 'Strada Pagano', 96067, 'Strada Pagano', 'email', 'fulviino@gmail.com', 'cellulare', '3938748085');
call BachecaElettronicadb.registra_utente_UCC ('lisalli', '3146cac6', '2720808344330601', STR_TO_DATE('29-03-2022', '%d-%m-%Y'), 513, 'MRTLSI80A01L219I', 'Martinelli', 'Lisa', 'Incrocio Jack', 14732, 'Incrocio Jack', 'email', 'lisalli@gmail.com', 'cellulare', '39307343514');
call BachecaElettronicadb.registra_utente_UCC ('dottloara', '61439ef5', '2367426462901448', STR_TO_DATE('19-04-2021', '%d-%m-%Y'), 279, 'FRRLRS80A01L219D', 'Ferrara', 'Loris', 'Piazza Palumbo', 10190, 'Piazza Palumbo', 'email', 'dottloara@gmail.com', 'cellulare', '393375813');
call BachecaElettronicadb.registra_utente_UCC ('flaviadi', 'c3fd9e6a', '4024007102378618', STR_TO_DATE('29-11-2023', '%d-%m-%Y'), 292, 'RNLFVN80A01L219H', 'Rinaldi', 'Flaviana', 'Strada Mazza', 45069, 'Strada Mazza', 'email', 'flaviadi@gmail.com', 'cellulare', '393374210');
call BachecaElettronicadb.registra_utente_UCC ('bibialia', '36ac869f', '4024007150052008', STR_TO_DATE('23-03-2021', '%d-%m-%Y'), 658, 'BTTBBN80A01H501J', 'Battaglia', 'Bibiana', 'Borgo Rosalba', 01273, 'Borgo Rosalba', 'email', 'bibialia@gmail.com', 'cellulare', '3939196753');
call BachecaElettronicadb.registra_utente_UCC ('karito', '8173d903', '343981825566505', STR_TO_DATE('24-04-2023', '%d-%m-%Y'), 252, 'MTAKRM80A01F205H', 'Amato', 'Karim', 'Contrada Lucia', 28858, 'Contrada Lucia', 'email', 'karito@gmail.com', 'cellulare', '393065908');
call BachecaElettronicadb.registra_utente_UCC ('ritadati', '72da993a', '4539721324414328', STR_TO_DATE('13-04-2022', '%d-%m-%Y'), 484, 'DNTRTI80A01D612N', 'Donati', 'Rita', 'Strada Thea', 53453, 'Strada Thea', 'email', 'ritadati@gmail.com', 'cellulare', '393318369');
call BachecaElettronicadb.registra_utente_UCC ('drkayri', 'd1ca4524', '5342055821768637', STR_TO_DATE('10-10-2022', '%d-%m-%Y'), 682, 'FBBKYL80A01D612Z', 'Fabbri', 'Kayla', 'Contrada Bianco', 30327, 'Contrada Bianco', 'email', 'drkayri@gmail.com', 'cellulare', '393935215');
call BachecaElettronicadb.registra_utente_UCC ('ruthrici', '4bc9048d', '6011925970299063', STR_TO_DATE('10-10-2022', '%d-%m-%Y'), 318, 'RCCRTH80A01L219H', 'Ricci', 'Ruth', 'Strada Hector', 03764, 'Strada Hector', 'email', 'ruthrici@gmail.com', 'cellulare', '393366608');
call BachecaElettronicadb.registra_utente_UCC ('samuesso', 'd5317da9', '2379040932774669', STR_TO_DATE('14-12-2022', '%d-%m-%Y'), 535, 'RSSSML80A01L219N', 'Russo', 'Samuel', 'Strada Sue', 84879, 'Strada Sue', 'email', 'samuesso@gmail.com', 'cellulare', '393630433198');
call BachecaElettronicadb.registra_utente_UCC ('dottmti', 'aebdb624', '340067856370398', STR_TO_DATE('14-07-2022', '%d-%m-%Y'), 862, 'BNDMHL80A01F205Z', 'Benedetti', 'Michele', 'Via Marino', 14579, 'Via Marino', 'email', 'dottmti@gmail.com', 'cellulare', '39387903919');
call BachecaElettronicadb.registra_utente_UCC ('dottaini', 'e89c39e2', '4539270488071037', STR_TO_DATE('03-05-2023', '%d-%m-%Y'), 993, 'PLLLBN80A01D612I', 'Pellegrini', 'Albino', 'Via Pellegrino', 59331, 'Via Pellegrino', 'email', 'dottaini@gmail.com', 'cellulare', '393394868');
call BachecaElettronicadb.registra_utente_UCC ('sigmsta', '0c25aef7', '377511943143132', STR_TO_DATE('26-06-2022', '%d-%m-%Y'), 257, 'CSTMRC80A01L219N', 'Costa', 'Marco', 'Rotonda Gerlando', 22603, 'Rotonda Gerlando', 'email', 'sigmsta@gmail.com', 'cellulare', '39303203796');
call BachecaElettronicadb.registra_utente_UCC ('dottari', 'd8ea58b4', '5322483449397684', STR_TO_DATE('03-02-2021', '%d-%m-%Y'), 608, 'SRTDNC80A01L219W', 'Sartori', 'Audenico', 'Incrocio Rudy', 87617, 'Incrocio Rudy', 'email', 'dottari@gmail.com', 'cellulare', '3930862121');
call BachecaElettronicadb.registra_utente_UCC ('ingridelo', 'e76ab043', '4716409017103169', STR_TO_DATE('23-02-2022', '%d-%m-%Y'), 297, 'DNGNRD80A01H501V', 'Dangelo', 'Ingrid', 'Borgo Antonino', 09478, 'Borgo Antonino', 'email', 'ingridelo@gmail.com', 'cellulare', '39375880456');	
call BachecaElettronicadb.registra_utente_UCC ('baldco', '060936a0', '4916488455597759', STR_TO_DATE('25-09-2023', '%d-%m-%Y'), 672, 'DMCBDS80A01F205P', 'Damico', 'Baldassarre', 'Incrocio Barbieri', 32700, 'Incrocio Barbieri', 'email', 'baldco@gmail.com', 'cellulare', '39309181754');
call BachecaElettronicadb.registra_utente_UCC ('luigile', '72f886ff', '378758859158104', STR_TO_DATE('19-10-2021', '%d-%m-%Y'), 934, 'BSLLGU80A01L219W', 'Basile', 'Luigi', 'Strada Brigitta', 76645, 'Strada Brigitta', 'email', 'luigile@gmail.com', 'cellulare', '39388579691');
call BachecaElettronicadb.registra_utente_UCC ('morgara', 'e6bd6998', '5401321834836581', STR_TO_DATE('12-10-2023', '%d-%m-%Y'), 408, 'FRRMGN80A01D612S', 'Ferrara', 'Morgana', 'Rotonda Mauro', 99243, 'Rotonda Mauro', 'email', 'morgara@gmail.com', 'cellulare', '393056537');
call BachecaElettronicadb.registra_utente_UCC ('drrenna', '969b2a61', '6011468658733038', STR_TO_DATE('02-05-2023', '%d-%m-%Y'), 716, 'FRNRNZ80A01F205Z', 'Farina', 'Renzo', 'Contrada Parisi', 13957, 'Contrada Parisi', 'email', 'drrenna@gmail.com', 'cellulare', '393565983');
call BachecaElettronicadb.registra_utente_UCC ('sigarneo', '225629ab', '4916519429330685', STR_TO_DATE('07-07-2021', '%d-%m-%Y'), 777, 'CTTRBL80A01F205F', 'Cattaneo', 'Arcibaldo', 'Incrocio Manfredi', 38177, 'Incrocio Manfredi', 'email', 'sigarneo@gmail.com', 'cellulare', '39364260014');
call BachecaElettronicadb.registra_utente_UCC ('ceccolo', 'f49b4928', '4539487978229111', STR_TO_DATE('21-10-2022', '%d-%m-%Y'), 529, 'GLLCCC80A01F205E', 'Gallo', 'Cecco', 'Via Nunzia', 87718, 'Via Nunzia', 'email', 'ceccolo@gmail.com', 'cellulare', '393350701');
call BachecaElettronicadb.registra_utente_UCC ('ritano', '9821573c', '6011622223278198', STR_TO_DATE('22-01-2023', '%d-%m-%Y'), 251, 'MRNRTI80A01D612I', 'Marino', 'Rita', 'Piazza Cirino', 77485, 'Piazza Cirino', 'email', 'ritano@gmail.com', 'cellulare', '39353943997');
call BachecaElettronicadb.registra_utente_UCC ('ingediero', 'a46e76a9', '6011432312999591', STR_TO_DATE('16-02-2022', '%d-%m-%Y'), 769, 'RGGDPE80A01F205E', 'Ruggiero', 'Edipo', 'Via Rinaldi', 09835, 'Via Rinaldi', 'email', 'ingediero@gmail.com', 'cellulare', '393729111072');
call BachecaElettronicadb.registra_utente_UCC ('cleopana', '13d858a7', '4556593466737776', STR_TO_DATE('18-06-2022', '%d-%m-%Y'), 780, 'FNTCPT80A01F205D', 'Fontana', 'Cleopatra', 'Piazza Caruso', 51026, 'Piazza Caruso', 'email', 'cleopana@gmail.com', 'cellulare', '39309015535');
call BachecaElettronicadb.registra_utente_UCC ('raniri', '3f5771c4', '4929765166820462', STR_TO_DATE('11-08-2021', '%d-%m-%Y'), 247, 'NRERNR80A01D612O', 'Neri', 'Raniero', 'Incrocio Rizzo', 42689, 'Incrocio Rizzo', 'email', 'raniri@gmail.com', 'cellulare', '3936908124');
call BachecaElettronicadb.registra_utente_UCC ('ingnoadi', '725ea9e5', '6011078425048154', STR_TO_DATE('17-11-2023', '%d-%m-%Y'), 492, 'LMBNHO80A01L219O', 'Lombardi', 'Noah', 'Piazza Ferraro', 93111, 'Piazza Ferraro', 'email', 'ingnoadi@gmail.com', 'cellulare', '39349380576');
call BachecaElettronicadb.registra_utente_UCC ('dotteti', 'be0d9098', '5367071819797876', STR_TO_DATE('03-12-2021', '%d-%m-%Y'), 964, 'CNTVTE80A01D612L', 'Conti', 'Evita', 'Contrada Nabil', 81632, 'Contrada Nabil', 'email', 'dotteti@gmail.com', 'cellulare', '39379021927');
call BachecaElettronicadb.registra_utente_UCC ('oseaneri', '9d609d7a', '5356729972601564', STR_TO_DATE('23-08-2023', '%d-%m-%Y'), 661, 'NRESOE80A01L219H', 'Neri', 'Osea', 'Contrada Palmieri', 30857, 'Contrada Palmieri', 'email', 'oseaneri@gmail.com', 'cellulare', '3939250676');
call BachecaElettronicadb.registra_utente_UCC ('edilioni', '65547330', '6011191702853590', STR_TO_DATE('05-10-2022', '%d-%m-%Y'), 825, 'BLLDLE80A01L219G', 'Bellini', 'Edilio', 'Borgo Rinaldi', 59543, 'Borgo Rinaldi', 'email', 'edilioni@gmail.com', 'cellulare', '393043655');
call BachecaElettronicadb.registra_utente_UCC ('ingtreri', '51ed670f', '2221541454003528', STR_TO_DATE('24-11-2021', '%d-%m-%Y'), 890, 'NGRTVS80A01L219J', 'Negri', 'Trevis', 'Strada Claudia', 34349, 'Strada Claudia', 'email', 'ingtreri@gmail.com', 'cellulare', '393372790');
call BachecaElettronicadb.registra_utente_UCC ('sigrrdo', '3537126c', '5542682230750324', STR_TO_DATE('27-05-2023', '%d-%m-%Y'), 162, 'LMBVNN80A01F205J', 'Lombardo', 'Ivonne', 'Via Gallo', 86113, 'Via Gallo', 'email', 'sigrrdo@gmail.com', 'cellulare', '393342161');
call BachecaElettronicadb.registra_utente_UCC ('pablomlli', 'a70d38bd', '4532199437726309', STR_TO_DATE('10-07-2023', '%d-%m-%Y'), 730, 'MRLPBL80A01D612F', 'Morelli', 'Pablo', 'Incrocio Damico', 01699, 'Incrocio Damico', 'email', 'pablomlli@gmail.com', 'cellulare', '39325814748');
call BachecaElettronicadb.registra_utente_UCC ('drsiti', 'f07805ea', '2668905073038514', STR_TO_DATE('19-06-2021', '%d-%m-%Y'), 997, 'MRTSLL80A01H501S', 'Moretti', 'Sibilla', 'Strada Sanna', 58425, 'Strada Sanna', 'email', 'drsiti@gmail.com', 'cellulare', '39346220311');
call BachecaElettronicadb.registra_utente_UCC ('priamoro', '743517b4', '4532355734373217', STR_TO_DATE('22-10-2021', '%d-%m-%Y'), 898, 'RGGPRM80A01F205D', 'Ruggiero', 'Priamo', 'Rotonda Carlo', 78803, 'Rotonda Carlo', 'email', 'priamoro@gmail.com', 'cellulare', '393119220843');
call BachecaElettronicadb.registra_utente_UCC ('drconctti', '16486e1a', '2399019177468548', STR_TO_DATE('08-11-2023', '%d-%m-%Y'), 791, 'MRTCCT80A01D612P', 'Moretti', 'Concetta', 'Borgo De', 41788, 'Borgo De', 'email', 'drconctti@gmail.com', 'cellulare', '393046672');
call BachecaElettronicadb.registra_utente_UCC ('silvaas', '921883a1', '5460034289988991', STR_TO_DATE('19-11-2023', '%d-%m-%Y'), 403, 'PRSSVN80A01D612N', 'Piras', 'Silvano', 'Contrada Claudia', 01309, 'Contrada Claudia', 'email', 'silvaas@gmail.com', 'cellulare', '39353253650');
call BachecaElettronicadb.registra_utente_UCC ('concdi', '612c8459', '5107905705382613', STR_TO_DATE('26-02-2023', '%d-%m-%Y'), 712, 'BRNCCT80A01D612D', 'Bernardi', 'Concetta', 'Rotonda Galli', 52583, 'Rotonda Galli', 'email', 'concdi@gmail.com', 'cellulare', '3936036723');
call BachecaElettronicadb.registra_utente_UCC ('sigrti', '49bf2edc', '4539189036588', STR_TO_DATE('20-02-2021', '%d-%m-%Y'), 409, 'RSSJLN80A01L219S', 'Rossetti', 'Jelena', 'Incrocio Valdo', 48946, 'Incrocio Valdo', 'email', 'sigrti@gmail.com', 'cellulare', '3930353288');
call BachecaElettronicadb.registra_utente_UCC ('ruthnna', '0a3f0a4c', '5493775299103374', STR_TO_DATE('04-09-2022', '%d-%m-%Y'), 628, 'SNNRTH80A01F205W', 'Sanna', 'Ruth', 'Contrada Karim', 62783, 'Contrada Karim', 'email', 'ruthnna@gmail.com', 'cellulare', '3933351743');
call BachecaElettronicadb.registra_utente_UCC ('cassiali', '53b9e4d0', '2413809683952726', STR_TO_DATE('26-12-2021', '%d-%m-%Y'), 212, 'VTLCSP80A01H501Y', 'Vitali', 'Cassiopea', 'Via Rossi', 27161, 'Via Rossi', 'email', 'cassiali@gmail.com', 'cellulare', '393366309');
call BachecaElettronicadb.registra_utente_UCC ('donaeco', '2c7a11a4', '5274726134279361', STR_TO_DATE('09-05-2023', '%d-%m-%Y'), 791, 'GRCDTL80A01D612F', 'Greco', 'Donatella', 'Incrocio Costa', 53329, 'Incrocio Costa', 'email', 'donaeco@gmail.com', 'cellulare', '39359270433');
call BachecaElettronicadb.registra_utente_UCC ('dindoso', 'c992aaf8', '6011935433933067', STR_TO_DATE('15-02-2023', '%d-%m-%Y'), 533, 'RSSDND80A01D612E', 'Russo', 'Dindo', 'Strada Fiore', 42688, 'Strada Fiore', 'email', 'dindoso@gmail.com', 'cellulare', '3930128925');
call BachecaElettronicadb.registra_utente_UCC ('naomiini', '3bafe60e', '344884899131066', STR_TO_DATE('08-07-2021', '%d-%m-%Y'), 779, 'VLNNMA80A01H501I', 'Valentini', 'Naomi', 'Borgo Barbieri', 62018, 'Borgo Barbieri', 'email', 'naomiini@gmail.com', 'cellulare', '3933613043');
call BachecaElettronicadb.registra_utente_UCC ('dylano', 'ab5c72bb', '4556457218497578', STR_TO_DATE('24-10-2022', '%d-%m-%Y'), 454, 'BRNDLN80A01D612X', 'Bruno', 'Dylan', 'Rotonda Vitali', 25839, 'Rotonda Vitali', 'email', 'dylano@gmail.com', 'cellulare', '393315357');
call BachecaElettronicadb.registra_utente_UCC ('inggali', '4bc575ad', '6011098280768662', STR_TO_DATE('20-08-2021', '%d-%m-%Y'), 969, 'GLLGRL80A01D612V', 'Galli', 'Gabriele', 'Strada Selvaggia', 51844, 'Strada Selvaggia', 'email', 'inggali@gmail.com', 'cellulare', '39330716350');
call BachecaElettronicadb.registra_utente_UCC ('erminissi', '8f5f1738', '4556065143837550', STR_TO_DATE('01-04-2022', '%d-%m-%Y'), 587, 'GRSRMN80A01F205F', 'Grassi', 'Erminia', 'Strada Egidio', 80809, 'Strada Egidio', 'email', 'erminissi@gmail.com', 'cellulare', '3938852174');
call BachecaElettronicadb.registra_utente_UCC ('drjacana', 'e4b83b18', '5194058866265187', STR_TO_DATE('15-02-2021', '%d-%m-%Y'), 593, 'FNTJCK80A01L219S', 'Fontana', 'Jack', 'Piazza Sandro', 66884, 'Piazza Sandro', 'email', 'drjacana@gmail.com', 'cellulare', '3938068100');
call BachecaElettronicadb.registra_utente_UCC ('gerlanisi', '63ebc0b9', '5549607585137481', STR_TO_DATE('27-07-2021', '%d-%m-%Y'), 224, 'PRSGLN80A01L219J', 'Parisi', 'Gerlando', 'Incrocio Prisca', 40867, 'Incrocio Prisca', 'email', 'gerlanisi@gmail.com', 'cellulare', '393013317');
call BachecaElettronicadb.registra_utente_UCC ('arieri', '924901fb', '4532806291730686', STR_TO_DATE('23-06-2022', '%d-%m-%Y'), 677, 'SLVRLA80A01F205T', 'Silvestri', 'Ariel', 'Via Conte', 28757, 'Via Conte', 'email', 'arieri@gmail.com', 'cellulare', '3933336600');
call BachecaElettronicadb.registra_utente_UCC ('dottrotti', '340afe44', '4024007190934066', STR_TO_DATE('04-01-2024', '%d-%m-%Y'), 951, 'MRTRLN80A01H501T', 'Moretti', 'Rosalino', 'Via Vitali', 71846, 'Via Vitali', 'email', 'dottrotti@gmail.com', 'cellulare', '3930031689');
call BachecaElettronicadb.registra_utente_UCC ('ireneari', 'a78ee1d3', '4539464450796446', STR_TO_DATE('25-11-2021', '%d-%m-%Y'), 925, 'MNTRNI80A01H501A', 'Montanari', 'Irene', 'Contrada Carbone', 91052, 'Contrada Carbone', 'email', 'ireneari@gmail.com', 'cellulare', '3930835528');
call BachecaElettronicadb.registra_utente_UCC ('marusksi', 'a696e89b', '4716933452576852', STR_TO_DATE('26-05-2023', '%d-%m-%Y'), 353, 'GRSMSK80A01L219G', 'Grassi', 'Maruska', 'Piazza Olo', 77603, 'Piazza Olo', 'email', 'marusksi@gmail.com', 'cellulare', '393849375391');
call BachecaElettronicadb.registra_utente_UCC ('fiorla', 'ca04bd09', '4929686951678974', STR_TO_DATE('06-09-2021', '%d-%m-%Y'), 687, 'SLAFNT80A01F205H', 'Sala', 'Fiorentino', 'Via Antimo', 92362, 'Via Antimo', 'email', 'fiorla@gmail.com', 'cellulare', '393448180');
call BachecaElettronicadb.registra_utente_UCC ('oseagssi', '3effb3a4', '5217353340459131', STR_TO_DATE('01-02-2022', '%d-%m-%Y'), 351, 'GRSSOE80A01H501N', 'Grassi', 'Osea', 'Borgo Mariapia', 44245, 'Borgo Mariapia', 'email', 'oseagssi@gmail.com', 'cellulare', '393079097');
call BachecaElettronicadb.registra_utente_UCC ('dralni', '0a328b51', '342168722631795', STR_TO_DATE('19-12-2022', '%d-%m-%Y'), 445, 'GLNLSS80A01D612B', 'Giuliani', 'Alessio', 'Incrocio Mariapia', 54362, 'Incrocio Mariapia', 'email', 'dralni@gmail.com', 'cellulare', '3932158960');
call BachecaElettronicadb.registra_utente_UCC ('eustazo', '61a5e6c4', '342138288233013', STR_TO_DATE('10-06-2022', '%d-%m-%Y'), 253, 'RZZSCH80A01H501W', 'Rizzo', 'Eustachio', 'Piazza Erminia', 55249, 'Piazza Erminia', 'email', 'eustazo@gmail.com', 'cellulare', '39313065285');
call BachecaElettronicadb.registra_utente_UCC ('dottfano', '1daaeff3', '4024007193272597', STR_TO_DATE('23-10-2021', '%d-%m-%Y'), 918, 'GRDFBN80A01D612X', 'Giordano', 'Fabiano', 'Strada Costa', 42561, 'Strada Costa', 'email', 'dottfano@gmail.com', 'cellulare', '39399550836');
call BachecaElettronicadb.registra_utente_UCC ('zelidani', '690bc657', '4556350328230', STR_TO_DATE('11-01-2023', '%d-%m-%Y'), 444, 'CSTZLD80A01D612J', 'Costantini', 'Zelida', 'Borgo De', 48290, 'Borgo De', 'email', 'zelidani@gmail.com', 'cellulare', '393730060');
call BachecaElettronicadb.registra_utente_UCC ('ingmtti', 'ac48997d', '5368939783104478', STR_TO_DATE('26-04-2021', '%d-%m-%Y'), 558, 'MRTMZU80A01H501O', 'Moretti', 'Muzio', 'Rotonda Martino', 08539, 'Rotonda Martino', 'email', 'ingmtti@gmail.com', 'cellulare', '3932800491');


-- USCC USERS

call BachecaElettronicadb.registra_utente_USCC ('omarssi', 'cde3d4f2', 'GRSMRO80A01D612S', 'Grassi', 'Omar', 'Via Demis', 52004, 'Via Demis', 'email', 'omarssi@gmail.com', 'cellulare', '393315934');
call BachecaElettronicadb.registra_utente_USCC ('sersebti', 'f6c40a35', 'BNDSRS80A01D612E', 'Benedetti', 'Serse', 'Rotonda Ferrara', 30389, 'Rotonda Ferrara', 'email', 'sersebti@gmail.com', 'cellulare', '3930054873');
call BachecaElettronicadb.registra_utente_USCC ('ingscci', '91311afc', 'RCCSDR80A01L219L', 'Ricci', 'Sandro', 'Via De', 26245, 'Via De', 'email', 'ingscci@gmail.com', 'cellulare', '393350114');
call BachecaElettronicadb.registra_utente_USCC ('diamllo', '4dffd86f', 'GLLDNT80A01L219A', 'Gallo', 'Diamante', 'Via Rizzi', 28610, 'Via Rizzi', 'email', 'diamllo@gmail.com', 'cellulare', '39368957886');
call BachecaElettronicadb.registra_utente_USCC ('fabianti', 'de813072', 'BNDFBN80A01H501A', 'Benedetti', 'Fabiano', 'Contrada Neri', 84772, 'Contrada Neri', 'email', 'fabianti@gmail.com', 'cellulare', '3930648895');
call BachecaElettronicadb.registra_utente_USCC ('drpriaale', '492df93f', 'VTLPRM80A01F205H', 'Vitale', 'Priamo', 'Strada Silvestri', 19108, 'Strada Silvestri', 'email', 'drpriaale@gmail.com', 'cellulare', '3933755983');
call BachecaElettronicadb.registra_utente_USCC ('vinicara', 'af4a630f', 'FRRVNC80A01F205U', 'Ferrara', 'Vinicio', 'Incrocio Isira', 15733, 'Incrocio Isira', 'email', 'vinicara@gmail.com', 'cellulare', '39334344357');
call BachecaElettronicadb.registra_utente_USCC ('vinicito', '247196bf', 'SPSVNC80A01F205V', 'Esposito', 'Vinicio', 'Borgo Lombardi', 42233, 'Borgo Lombardi', 'email', 'vinicito@gmail.com', 'cellulare', '39393767546');
call BachecaElettronicadb.registra_utente_USCC ('donatela', '5a43275c', 'VLLDTL80A01F205S', 'Villa', 'Donatella', 'Borgo Damiana', 05189, 'Borgo Damiana', 'email', 'donatela@gmail.com', 'cellulare', '3930623412');
call BachecaElettronicadb.registra_utente_USCC ('inglucssi', 'da8a0e5a', 'RSSLCU80A01F205N', 'Rossi', 'Luce', 'Incrocio Rosalba', 94852, 'Incrocio Rosalba', 'email', 'inglucssi@gmail.com', 'cellulare', '39300455491');
call BachecaElettronicadb.registra_utente_USCC ('neriero', '564a724d', 'RGGNRE80A01D612U', 'Ruggiero', 'Neri', 'Piazza Lamberto', 44347, 'Piazza Lamberto', 'email', 'neriero@gmail.com', 'cellulare', '39353728663');
call BachecaElettronicadb.registra_utente_USCC ('ilarso', 'dadd41c1', 'GRSLRI80A01L219Z', 'Grasso', 'Ilario', 'Borgo Carmelo', 87568, 'Borgo Carmelo', 'email', 'ilarso@gmail.com', 'cellulare', '393329848');
call BachecaElettronicadb.registra_utente_USCC ('dottmeva', '83e02679', 'RVIMCD80A01H501E', 'Riva', 'Mercedes', 'Rotonda Greco', 92634, 'Rotonda Greco', 'email', 'dottmeva@gmail.com', 'cellulare', '393691960964');
call BachecaElettronicadb.registra_utente_USCC ('isabetti', '6a91ea6a', 'GTTSBL80A01H501N', 'Gatti', 'Isabel', 'Piazza Gatti', 33572, 'Piazza Gatti', 'email', 'isabetti@gmail.com', 'cellulare', '393101515');
call BachecaElettronicadb.registra_utente_USCC ('sigeeo', '1ac9d2f5', 'CTTTHN80A01D612B', 'Cattaneo', 'Ethan', 'Incrocio Cassiopea', 20847, 'Incrocio Cassiopea', 'email', 'sigeeo@gmail.com', 'cellulare', '393245286');
call BachecaElettronicadb.registra_utente_USCC ('baldaslli', 'add77af3', 'MRLBDS80A01F205E', 'Morelli', 'Baldassarre', 'Contrada Gatti', 55802, 'Contrada Gatti', 'email', 'baldaslli@gmail.com', 'cellulare', '3932187320');
call BachecaElettronicadb.registra_utente_USCC ('manuera', '823bfc82', 'FRRMNL80A01D612V', 'Ferrara', 'Manuele', 'Piazza Deborah', 39682, 'Piazza Deborah', 'email', 'manuera@gmail.com', 'cellulare', '393575678873');
call BachecaElettronicadb.registra_utente_USCC ('ingsatti', '642e7071', 'FRRSDR80A01H501Q', 'Ferretti', 'Sandro', 'Piazza Damico', 39208, 'Piazza Damico', 'email', 'ingsatti@gmail.com', 'cellulare', '39323230535');
call BachecaElettronicadb.registra_utente_USCC ('drradila', 'f08a0236', 'SLARDA80A01L219C', 'Sala', 'Radio', 'Rotonda Nick', 69223, 'Rotonda Nick', 'email', 'drradila@gmail.com', 'cellulare', '393008154');
call BachecaElettronicadb.registra_utente_USCC ('quartana', 'dcff1e06', 'FNTQRT80A01L219L', 'Fontana', 'Quarto', 'Contrada Monia', 56866, 'Contrada Monia', 'email', 'quartana@gmail.com', 'cellulare', '393085008');
call BachecaElettronicadb.registra_utente_USCC ('toscina', 'df1671d7', 'MSSTSC80A01F205U', 'Messina', 'Tosca', 'Rotonda Mirco', 95909, 'Rotonda Mirco', 'email', 'toscina@gmail.com', 'cellulare', '393356292');
call BachecaElettronicadb.registra_utente_USCC ('noemilo', 'd235171d', 'GLLNMO80A01L219D', 'Gallo', 'Noemi', 'Via Kris', 56039, 'Via Kris', 'email', 'noemilo@gmail.com', 'cellulare', '393380305');
call BachecaElettronicadb.registra_utente_USCC ('umbertri', '07567399', 'FRRMRT80A01F205Q', 'Ferrari', 'Umberto', 'Rotonda Rosaria', 20249, 'Rotonda Rosaria', 'email', 'umbertri@gmail.com', 'cellulare', '3939980453');
call BachecaElettronicadb.registra_utente_USCC ('matilini', '674e78ec', 'MRNMLD80A01F205N', 'Marini', 'Matilde', 'Via Cosetta', 43793, 'Via Cosetta', 'email', 'matilini@gmail.com', 'cellulare', '393067653');
call BachecaElettronicadb.registra_utente_USCC ('sarira', 'a910aaf8', 'GRRSRT80A01H501V', 'Guerra', 'Sarita', 'Via Cleopatra', 34736, 'Via Cleopatra', 'email', 'sarira@gmail.com', 'cellulare', '3934851189');
call BachecaElettronicadb.registra_utente_USCC ('pacifiari', '64125b37', 'FRRPFC80A01D612I', 'Ferrari', 'Pacifico', 'Rotonda Filomena', 06883, 'Rotonda Filomena', 'email', 'pacifiari@gmail.com', 'cellulare', '39364264177');
call BachecaElettronicadb.registra_utente_USCC ('drmonni', '18387f8e', 'GLNMNO80A01H501C', 'Giuliani', 'Monia', 'Contrada Amato', 80379, 'Contrada Amato', 'email', 'drmonni@gmail.com', 'cellulare', '393371390');
call BachecaElettronicadb.registra_utente_USCC ('dottezzo', '7a629923', 'RZZDVG80A01F205O', 'Rizzo', 'Edvige', 'Via Villa', 59022, 'Via Villa', 'email', 'dottezzo@gmail.com', 'cellulare', '393069231');
call BachecaElettronicadb.registra_utente_USCC ('ingsile', 'b444b8bf', 'GNTSRI80A01L219E', 'Gentile', 'Siro', 'Incrocio Folco', 23431, 'Incrocio Folco', 'email', 'ingsile@gmail.com', 'cellulare', '393487928');
call BachecaElettronicadb.registra_utente_USCC ('lunavni', '08758763', 'VLNLNU80A01D612G', 'Valentini', 'Luna', 'Piazza Marchetti', 31815, 'Piazza Marchetti', 'email', 'lunavni@gmail.com', 'cellulare', '39306942489');
call BachecaElettronicadb.registra_utente_USCC ('drnicoile', 'c201acb2', 'BSLNLT80A01D612Y', 'Basile', 'Nicoletta', 'Rotonda Gatti', 06366, 'Rotonda Gatti', 'email', 'drnicoile@gmail.com', 'cellulare', '3936462706');
call BachecaElettronicadb.registra_utente_USCC ('sigrari', '28b8f29a', 'FRRCPT80A01L219Q', 'Ferrari', 'Cleopatra', 'Rotonda Marina', 39773, 'Rotonda Marina', 'email', 'sigrari@gmail.com', 'cellulare', '39332186275');
call BachecaElettronicadb.registra_utente_USCC ('eusebdi', '9a4db7c2', 'BRNSBE80A01F205Y', 'Bernardi', 'Eusebio', 'Borgo Battaglia', 87306, 'Borgo Battaglia', 'email', 'eusebdi@gmail.com', 'cellulare', '393915815931');
call BachecaElettronicadb.registra_utente_USCC ('lucrezico', 'fac85bb1', 'DMCLRZ80A01H501E', 'Damico', 'Lucrezia', 'Via Furio', 98841, 'Via Furio', 'email', 'lucrezico@gmail.com', 'cellulare', '3937938153');
call BachecaElettronicadb.registra_utente_USCC ('sigodolla', '010ce736', 'VLLDNO80A01H501Y', 'Villa', 'Odone', 'Via Ricci', 54382, 'Via Ricci', 'email', 'sigodolla@gmail.com', 'cellulare', '39348912042');
call BachecaElettronicadb.registra_utente_USCC ('eldageco', '427e45b7', 'GRCLDE80A01D612Z', 'Greco', 'Elda', 'Contrada Vitale', 83414, 'Contrada Vitale', 'email', 'eldageco@gmail.com', 'cellulare', '393355170');
call BachecaElettronicadb.registra_utente_USCC ('criststa', '486d49b8', 'CSTCST80A01F205J', 'Costa', 'Cristyn', 'Contrada Ferraro', 42651, 'Contrada Ferraro', 'email', 'criststa@gmail.com', 'cellulare', '3930574581');
call BachecaElettronicadb.registra_utente_USCC ('emanudi', '5e0ebd5a', 'BRNMNL80A01L219I', 'Bernardi', 'Emanuel', 'Strada Giovanna', 80856, 'Strada Giovanna', 'email', 'emanudi@gmail.com', 'cellulare', '3934646498');
call BachecaElettronicadb.registra_utente_USCC ('inglinte', 'cfd5246c', 'CNTLNI80A01F205K', 'Conte', 'Lino', 'Strada Ricci', 14533, 'Strada Ricci', 'email', 'inglinte@gmail.com', 'cellulare', '393385037');
call BachecaElettronicadb.registra_utente_USCC ('artemiini', 'ccd7cd04', 'MNCRMD80A01D612O', 'Mancini', 'Artemide', 'Strada Bernardi', 19221, 'Strada Bernardi', 'email', 'artemiini@gmail.com', 'cellulare', '39318317746');
call BachecaElettronicadb.registra_utente_USCC ('giacsi', 'd48b0cf3', 'RSSGNT80A01D612X', 'Rossi', 'Giacinta', 'Contrada Testa', 95079, 'Contrada Testa', 'email', 'giacsi@gmail.com', 'cellulare', '3932278000');
call BachecaElettronicadb.registra_utente_USCC ('drardussi', 'bfaa8328', 'RSSRDN80A01F205O', 'Rossi', 'Arduino', 'Via Gentile', 43538, 'Via Gentile', 'email', 'drardussi@gmail.com', 'cellulare', '3937285038');
call BachecaElettronicadb.registra_utente_USCC ('ritasi', '069d7100', 'RSSRTI80A01L219F', 'Rossi', 'Rita', 'Rotonda Moreno', 52263, 'Rotonda Moreno', 'email', 'ritasi@gmail.com', 'cellulare', '393201022665');
call BachecaElettronicadb.registra_utente_USCC ('selvssi', '5a9ca47f', 'RSSSVG80A01F205L', 'Rossi', 'Selvaggia', 'Contrada Miriana', 29931, 'Contrada Miriana', 'email', 'selvssi@gmail.com', 'cellulare', '3932937325');
call BachecaElettronicadb.registra_utente_USCC ('emilino', '60886c3d', 'PGNMLE80A01L219D', 'Pagano', 'Emilia', 'Incrocio Rizzi', 10145, 'Incrocio Rizzi', 'email', 'emilino@gmail.com', 'cellulare', '393083090');
call BachecaElettronicadb.registra_utente_USCC ('dottci', '9168e39b', 'RCCSND80A01D612W', 'Ricci', 'Secondo', 'Rotonda Marini', 39246, 'Rotonda Marini', 'email', 'dottci@gmail.com', 'cellulare', '3930150667');
call BachecaElettronicadb.registra_utente_USCC ('domingbo', 'a4ff4b9a', 'PLMDNG80A01L219P', 'Palumbo', 'Domingo', 'Borgo Donatella', 04178, 'Borgo Donatella', 'email', 'domingbo@gmail.com', 'cellulare', '393367285');
call BachecaElettronicadb.registra_utente_USCC ('karimmti', '43e3312f', 'MNTKRM80A01L219D', 'Monti', 'Karim', 'Borgo Ferretti', 03120, 'Borgo Ferretti', 'email', 'karimmti@gmail.com', 'cellulare', '3932975600');
call BachecaElettronicadb.registra_utente_USCC ('danutno', 'e8c0a63f', 'GRDDNT80A01F205U', 'Giordano', 'Danuta', 'Incrocio Damico', 43733, 'Incrocio Damico', 'email', 'danutno@gmail.com', 'cellulare', '3936023775');

-- ADMINISTRATORS

INSERT INTO BachecaElettronicadb.Amministratore(Username, Password) VALUES ("amm1", md5("password"));
INSERT INTO BachecaElettronicadb.Amministratore(Username, Password) VALUES ("amm2", md5("password"));
INSERT INTO BachecaElettronicadb.Amministratore(Username, Password) VALUES ("amm3", md5("password"));


-- CATEGORY

call inserimentoNuovaCategoria('Immobili');
call inserimentoNuovaCategoria('Locali Commerciali');
call inserimentoNuovaCategoria('Motori');
call inserimentoNuovaCategoria('Auto');
call inserimentoNuovaCategoria('Moto');
call inserimentoNuovaCategoria('Accessori');
call inserimentoNuovaCategoria('Abbigliamento');
call inserimentoNuovaCategoria('Orologi e gioielli');
call inserimentoNuovaCategoria('Sport');
call inserimentoNuovaCategoria('Bici');
call inserimentoNuovaCategoria('Elettronica');
call inserimentoNuovaCategoria('Telefonia');
call inserimentoNuovaCategoria('Informatica computer');
call inserimentoNuovaCategoria('Videogames');
call inserimentoNuovaCategoria('Telecomunicazioni');
call inserimentoNuovaCategoria('Elettrodomestici');
call inserimentoNuovaCategoria('Fai da te');

-- ADS

call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 130, null, 'sigkreco', 'Videogames');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'sigkreco', 'Elettrodomestici');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 250, null, 'dottbo', 'Telefonia');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 200, null, 'dottbo', 'Bici');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 300, null, 'fioreeri', 'Fai da te');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 100, null, 'fioreeri', 'Moto');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 300, null, 'dottmeco', 'Telefonia');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 200, null, 'dottmeco', 'Accessori');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 130, null, 'gianatti', 'Moto');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 250, null, 'gianatti', 'Motori');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 200, null, 'zelidando', 'Sport');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 20, null, 'zelidando', 'Telefonia');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 50, null, 'marisri', 'Informatica computer');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 100, null, 'marisri', 'Auto');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 200, null, 'dotteli', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 250, null, 'dotteli', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 100, null, 'dottmnti', 'Bici');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 250, null, 'dottmnti', 'Informatica computer');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 350, null, 'shaino', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 200, null, 'shaino', 'Informatica computer');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 90, null, 'marceosa', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 300, null, 'marceosa', 'Informatica computer');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 100, null, 'marianco', 'Elettronica');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 130, null, 'marianco', 'Abbigliamento');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'karimmina', 'Motori');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 250, null, 'karimmina', 'Telecomunicazioni');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 130, null, 'sigprzo', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 400, null, 'sigprzo', 'Motori');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 90, null, 'drrusso', 'Sport');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 90, null, 'drrusso', 'Informatica computer');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 300, null, 'elgarosi', 'Elettronica');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 400, null, 'elgarosi', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 350, null, 'drtomssi', 'Moto');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 300, null, 'drtomssi', 'Telefonia');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 200, null, 'dottbri', 'Orologi e gioielli');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 90, null, 'dottbri', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 100, null, 'cirarizo', 'Elettronica');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 90, null, 'cirarizo', 'Telefonia');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 350, null, 'ingvitno', 'Sport');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 100, null, 'ingvitno', 'Sport');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 250, null, 'drgiulri', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 200, null, 'drgiulri', 'Locali Commerciali');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'demirra', 'Telefonia');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 200, null, 'demirra', 'Elettronica');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'ritamoti', 'Accessori');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 300, null, 'ritamoti', 'Moto');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'ingaina', 'Locali Commerciali');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 50, null, 'ingaina', 'Motori');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 400, null, 'concci', 'Telefonia');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 350, null, 'concci', 'Locali Commerciali');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 300, null, 'cirinoco', 'Informatica computer');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 400, null, 'cirinoco', 'Motori');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 100, null, 'dindocmbo', 'Orologi e gioielli');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 130, null, 'dindocmbo', 'Orologi e gioielli');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 200, null, 'odonebri', 'Videogames');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 50, null, 'odonebri', 'Telecomunicazioni');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 350, null, 'ferdndo', 'Sport');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 20, null, 'ferdndo', 'Sport');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 300, null, 'concetta', 'Elettrodomestici');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 130, null, 'concetta', 'Moto');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 250, null, 'guidocte', 'Moto');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 100, null, 'guidocte', 'Informatica computer');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'fulviino', 'Sport');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 300, null, 'fulviino', 'Accessori');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 250, null, 'lisalli', 'Informatica computer');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 130, null, 'lisalli', 'Elettronica');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 90, null, 'dottloara', 'Abbigliamento');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'dottloara', 'Accessori');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 130, null, 'flaviadi', 'Auto');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 50, null, 'flaviadi', 'Sport');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 300, null, 'bibialia', 'Bici');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 100, null, 'bibialia', 'Orologi e gioielli');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 90, null, 'karito', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 200, null, 'karito', 'Motori');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'ritadati', 'Videogames');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 20, null, 'ritadati', 'Informatica computer');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 20, null, 'drkayri', 'Abbigliamento');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 200, null, 'drkayri', 'Abbigliamento');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 400, null, 'ruthrici', 'Abbigliamento');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'ruthrici', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 50, null, 'samuesso', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'samuesso', 'Auto');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 20, null, 'dottmti', 'Videogames');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 90, null, 'dottmti', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'dottaini', 'Elettronica');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 100, null, 'dottaini', 'Videogames');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 90, null, 'sigmsta', 'Elettrodomestici');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 130, null, 'sigmsta', 'Elettrodomestici');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 350, null, 'dottari', 'Sport');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 400, null, 'dottari', 'Locali Commerciali');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 350, null, 'ingridelo', 'Telefonia');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 130, null, 'ingridelo', 'Telecomunicazioni');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 50, null, 'baldco', 'Elettronica');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 350, null, 'baldco', 'Motori');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'luigile', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 250, null, 'luigile', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 350, null, 'morgara', 'Bici');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 90, null, 'morgara', 'Auto');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 20, null, 'drrenna', 'Elettrodomestici');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 130, null, 'drrenna', 'Orologi e gioielli');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 90, null, 'sigarneo', 'Informatica computer');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 50, null, 'sigarneo', 'Elettrodomestici');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 200, null, 'ceccolo', 'Motori');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 50, null, 'ceccolo', 'Locali Commerciali');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 250, null, 'ritano', 'Abbigliamento');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 400, null, 'ritano', 'Bici');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 50, null, 'ingediero', 'Orologi e gioielli');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 20, null, 'ingediero', 'Orologi e gioielli');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 100, null, 'cleopana', 'Orologi e gioielli');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 100, null, 'cleopana', 'Fai da te');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 100, null, 'raniri', 'Fai da te');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'raniri', 'Elettronica');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 90, null, 'ingnoadi', 'Abbigliamento');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'ingnoadi', 'Accessori');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 90, null, 'dotteti', 'Videogames');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 250, null, 'dotteti', 'Accessori');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 300, null, 'oseaneri', 'Moto');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 100, null, 'oseaneri', 'Abbigliamento');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 350, null, 'edilioni', 'Auto');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 400, null, 'edilioni', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 90, null, 'ingtreri', 'Abbigliamento');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 350, null, 'ingtreri', 'Locali Commerciali');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 100, null, 'sigrrdo', 'Elettronica');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 90, null, 'sigrrdo', 'Bici');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 300, null, 'pablomlli', 'Locali Commerciali');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 130, null, 'pablomlli', 'Elettronica');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'drsiti', 'Fai da te');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 200, null, 'drsiti', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 250, null, 'priamoro', 'Abbigliamento');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'priamoro', 'Informatica computer');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 50, null, 'drconctti', 'Informatica computer');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 90, null, 'drconctti', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 50, null, 'silvaas', 'Bici');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 20, null, 'silvaas', 'Telecomunicazioni');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 20, null, 'concdi', 'Locali Commerciali');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 350, null, 'concdi', 'Locali Commerciali');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 130, null, 'sigrti', 'Telecomunicazioni');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 400, null, 'sigrti', 'Auto');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'ruthnna', 'Telecomunicazioni');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 100, null, 'ruthnna', 'Moto');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 400, null, 'cassiali', 'Fai da te');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 300, null, 'cassiali', 'Motori');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 100, null, 'donaeco', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'donaeco', 'Moto');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'dindoso', 'Fai da te');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 20, null, 'dindoso', 'Telecomunicazioni');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 130, null, 'naomiini', 'Elettronica');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 90, null, 'naomiini', 'Moto');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 90, null, 'dylano', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 300, null, 'dylano', 'Sport');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 200, null, 'inggali', 'Informatica computer');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 20, null, 'inggali', 'Elettrodomestici');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 300, null, 'erminissi', 'Accessori');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 50, null, 'erminissi', 'Auto');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'drjacana', 'Elettrodomestici');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 350, null, 'drjacana', 'Sport');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 20, null, 'gerlanisi', 'Locali Commerciali');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 90, null, 'gerlanisi', 'Motori');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 400, null, 'arieri', 'Informatica computer');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 100, null, 'arieri', 'Accessori');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 50, null, 'dottrotti', 'Telecomunicazioni');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 90, null, 'dottrotti', 'Videogames');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 300, null, 'ireneari', 'Accessori');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 400, null, 'ireneari', 'Auto');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 250, null, 'marusksi', 'Elettrodomestici');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 300, null, 'marusksi', 'Moto');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 350, null, 'fiorla', 'Abbigliamento');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 400, null, 'fiorla', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 250, null, 'oseagssi', 'Telefonia');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 20, null, 'oseagssi', 'Sport');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 300, null, 'dralni', 'Sport');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 20, null, 'dralni', 'Videogames');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 200, null, 'eustazo', 'Orologi e gioielli');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 50, null, 'eustazo', 'Abbigliamento');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 200, null, 'dottfano', 'Motori');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 250, null, 'dottfano', 'Telecomunicazioni');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 130, null, 'zelidani', 'Immobili');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 250, null, 'zelidani', 'Videogames');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'ingmtti', 'Informatica computer');
call BachecaElettronicadb.inserimentoNuovoAnnuncio('Descrizione: descrizione di default', 150, null, 'ingmtti', 'Locali Commerciali');

-- FOLLOWING


call BachecaElettronicadb.seguiAnnuncioUCC (2, 'sigkreco');
call BachecaElettronicadb.seguiAnnuncioUCC (1, 'dottbo');
call BachecaElettronicadb.seguiAnnuncioUCC (11, 'fioreeri');
call BachecaElettronicadb.seguiAnnuncioUCC (4, 'dottmeco');
call BachecaElettronicadb.seguiAnnuncioUCC (12, 'gianatti');
call BachecaElettronicadb.seguiAnnuncioUCC (5, 'zelidando');
call BachecaElettronicadb.seguiAnnuncioUCC (3, 'marisri');
call BachecaElettronicadb.seguiAnnuncioUCC (8, 'dotteli');
call BachecaElettronicadb.seguiAnnuncioUCC (13, 'dottmnti');
call BachecaElettronicadb.seguiAnnuncioUCC (1, 'shaino');
call BachecaElettronicadb.seguiAnnuncioUCC (13, 'marceosa');
call BachecaElettronicadb.seguiAnnuncioUCC (6, 'marianco');
call BachecaElettronicadb.seguiAnnuncioUCC (1, 'karimmina');
call BachecaElettronicadb.seguiAnnuncioUCC (6, 'sigprzo');
call BachecaElettronicadb.seguiAnnuncioUCC (26, 'drrusso');
call BachecaElettronicadb.seguiAnnuncioUCC (1, 'elgarosi');
call BachecaElettronicadb.seguiAnnuncioUCC (6, 'drtomssi');
call BachecaElettronicadb.seguiAnnuncioUCC (23, 'dottbri');
call BachecaElettronicadb.seguiAnnuncioUCC (15, 'cirarizo');
call BachecaElettronicadb.seguiAnnuncioUCC (37, 'ingvitno');
call BachecaElettronicadb.seguiAnnuncioUCC (9, 'drgiulri');
call BachecaElettronicadb.seguiAnnuncioUCC (39, 'demirra');
call BachecaElettronicadb.seguiAnnuncioUCC (30, 'ritamoti');
call BachecaElettronicadb.seguiAnnuncioUCC (4, 'ingaina');
call BachecaElettronicadb.seguiAnnuncioUCC (38, 'concci');
call BachecaElettronicadb.seguiAnnuncioUCC (47, 'cirinoco');
call BachecaElettronicadb.seguiAnnuncioUCC (31, 'dindocmbo');
call BachecaElettronicadb.seguiAnnuncioUCC (18, 'odonebri');
call BachecaElettronicadb.seguiAnnuncioUCC (1, 'ferdndo');
call BachecaElettronicadb.seguiAnnuncioUCC (37, 'concetta');
call BachecaElettronicadb.seguiAnnuncioUCC (22, 'guidocte');
call BachecaElettronicadb.seguiAnnuncioUCC (37, 'fulviino');
call BachecaElettronicadb.seguiAnnuncioUCC (36, 'lisalli');
call BachecaElettronicadb.seguiAnnuncioUCC (5, 'dottloara');
call BachecaElettronicadb.seguiAnnuncioUCC (3, 'flaviadi');
call BachecaElettronicadb.seguiAnnuncioUCC (12, 'bibialia');
call BachecaElettronicadb.seguiAnnuncioUCC (26, 'karito');
call BachecaElettronicadb.seguiAnnuncioUCC (59, 'drkayri');
call BachecaElettronicadb.seguiAnnuncioUCC (39, 'ruthrici');
call BachecaElettronicadb.seguiAnnuncioUCC (75, 'samuesso');
call BachecaElettronicadb.seguiAnnuncioUCC (14, 'dottmti');
call BachecaElettronicadb.seguiAnnuncioUCC (29, 'dottaini');
call BachecaElettronicadb.seguiAnnuncioUCC (78, 'sigmsta');
call BachecaElettronicadb.seguiAnnuncioUCC (11, 'dottari');
call BachecaElettronicadb.seguiAnnuncioUCC (10, 'ingridelo');
call BachecaElettronicadb.seguiAnnuncioUCC (86, 'baldco');
call BachecaElettronicadb.seguiAnnuncioUCC (40, 'luigile');
call BachecaElettronicadb.seguiAnnuncioUCC (82, 'morgara');
call BachecaElettronicadb.seguiAnnuncioUCC (44, 'drrenna');
call BachecaElettronicadb.seguiAnnuncioUCC (87, 'sigarneo');
call BachecaElettronicadb.seguiAnnuncioUCC (51, 'ceccolo');
call BachecaElettronicadb.seguiAnnuncioUCC (86, 'ritano');
call BachecaElettronicadb.seguiAnnuncioUCC (39, 'ingediero');
call BachecaElettronicadb.seguiAnnuncioUCC (54, 'cleopana');
call BachecaElettronicadb.seguiAnnuncioUCC (87, 'raniri');
call BachecaElettronicadb.seguiAnnuncioUCC (3, 'ingnoadi');
call BachecaElettronicadb.seguiAnnuncioUCC (88, 'dotteti');
call BachecaElettronicadb.seguiAnnuncioUCC (70, 'oseaneri');
call BachecaElettronicadb.seguiAnnuncioUCC (69, 'edilioni');
call BachecaElettronicadb.seguiAnnuncioUCC (28, 'ingtreri');
call BachecaElettronicadb.seguiAnnuncioUCC (65, 'sigrrdo');
call BachecaElettronicadb.seguiAnnuncioUCC (65, 'pablomlli');
call BachecaElettronicadb.seguiAnnuncioUCC (36, 'drsiti');
call BachecaElettronicadb.seguiAnnuncioUCC (127, 'priamoro');
call BachecaElettronicadb.seguiAnnuncioUCC (15, 'drconctti');
call BachecaElettronicadb.seguiAnnuncioUCC (96, 'silvaas');
call BachecaElettronicadb.seguiAnnuncioUCC (39, 'concdi');
call BachecaElettronicadb.seguiAnnuncioUCC (82, 'sigrti');
call BachecaElettronicadb.seguiAnnuncioUCC (48, 'ruthnna');
call BachecaElettronicadb.seguiAnnuncioUCC (115, 'cassiali');
call BachecaElettronicadb.seguiAnnuncioUCC (21, 'donaeco');
call BachecaElettronicadb.seguiAnnuncioUCC (87, 'dindoso');
call BachecaElettronicadb.seguiAnnuncioUCC (56, 'naomiini');
call BachecaElettronicadb.seguiAnnuncioUCC (57, 'dylano');
call BachecaElettronicadb.seguiAnnuncioUCC (70, 'inggali');
call BachecaElettronicadb.seguiAnnuncioUCC (109, 'erminissi');
call BachecaElettronicadb.seguiAnnuncioUCC (45, 'drjacana');
call BachecaElettronicadb.seguiAnnuncioUCC (147, 'gerlanisi');
call BachecaElettronicadb.seguiAnnuncioUCC (17, 'arieri');
call BachecaElettronicadb.seguiAnnuncioUCC (145, 'dottrotti');
call BachecaElettronicadb.seguiAnnuncioUCC (83, 'ireneari');
call BachecaElettronicadb.seguiAnnuncioUCC (109, 'marusksi');
call BachecaElettronicadb.seguiAnnuncioUCC (70, 'fiorla');
call BachecaElettronicadb.seguiAnnuncioUCC (12, 'oseagssi');
call BachecaElettronicadb.seguiAnnuncioUCC (117, 'dralni');
call BachecaElettronicadb.seguiAnnuncioUCC (62, 'eustazo');
call BachecaElettronicadb.seguiAnnuncioUCC (137, 'dottfano');
call BachecaElettronicadb.seguiAnnuncioUCC (167, 'zelidani');
call BachecaElettronicadb.seguiAnnuncioUCC (71, 'ingmtti');
call BachecaElettronicadb.seguiAnnuncioUSCC (125, 'omarssi');
call BachecaElettronicadb.seguiAnnuncioUSCC (1, 'sersebti');
call BachecaElettronicadb.seguiAnnuncioUSCC (115, 'ingscci');
call BachecaElettronicadb.seguiAnnuncioUSCC (118, 'diamllo');
call BachecaElettronicadb.seguiAnnuncioUSCC (179, 'fabianti');
call BachecaElettronicadb.seguiAnnuncioUSCC (109, 'drpriaale');
call BachecaElettronicadb.seguiAnnuncioUSCC (172, 'vinicara');
call BachecaElettronicadb.seguiAnnuncioUSCC (38, 'vinicito');
call BachecaElettronicadb.seguiAnnuncioUSCC (47, 'donatela');
call BachecaElettronicadb.seguiAnnuncioUSCC (120, 'inglucssi');
call BachecaElettronicadb.seguiAnnuncioUSCC (9, 'neriero');
call BachecaElettronicadb.seguiAnnuncioUSCC (114, 'ilarso');
call BachecaElettronicadb.seguiAnnuncioUSCC (27, 'dottmeva');
call BachecaElettronicadb.seguiAnnuncioUSCC (40, 'isabetti');
call BachecaElettronicadb.seguiAnnuncioUSCC (43, 'sigeeo');
call BachecaElettronicadb.seguiAnnuncioUSCC (9, 'baldaslli');
call BachecaElettronicadb.seguiAnnuncioUSCC (154, 'manuera');
call BachecaElettronicadb.seguiAnnuncioUSCC (141, 'ingsatti');
call BachecaElettronicadb.seguiAnnuncioUSCC (145, 'drradila');
call BachecaElettronicadb.seguiAnnuncioUSCC (72, 'quartana');
call BachecaElettronicadb.seguiAnnuncioUSCC (69, 'toscina');
call BachecaElettronicadb.seguiAnnuncioUSCC (131, 'noemilo');
call BachecaElettronicadb.seguiAnnuncioUSCC (28, 'umbertri');
call BachecaElettronicadb.seguiAnnuncioUSCC (28, 'matilini');
call BachecaElettronicadb.seguiAnnuncioUSCC (77, 'sarira');
call BachecaElettronicadb.seguiAnnuncioUSCC (33, 'pacifiari');
call BachecaElettronicadb.seguiAnnuncioUSCC (62, 'drmonni');
call BachecaElettronicadb.seguiAnnuncioUSCC (118, 'dottezzo');
call BachecaElettronicadb.seguiAnnuncioUSCC (101, 'ingsile');
call BachecaElettronicadb.seguiAnnuncioUSCC (108, 'lunavni');
call BachecaElettronicadb.seguiAnnuncioUSCC (155, 'drnicoile');
call BachecaElettronicadb.seguiAnnuncioUSCC (66, 'sigrari');
call BachecaElettronicadb.seguiAnnuncioUSCC (103, 'eusebdi');
call BachecaElettronicadb.seguiAnnuncioUSCC (110, 'lucrezico');
call BachecaElettronicadb.seguiAnnuncioUSCC (111, 'sigodolla');
call BachecaElettronicadb.seguiAnnuncioUSCC (126, 'eldageco');
call BachecaElettronicadb.seguiAnnuncioUSCC (34, 'criststa');
call BachecaElettronicadb.seguiAnnuncioUSCC (139, 'emanudi');
call BachecaElettronicadb.seguiAnnuncioUSCC (84, 'inglinte');
call BachecaElettronicadb.seguiAnnuncioUSCC (33, 'artemiini');
call BachecaElettronicadb.seguiAnnuncioUSCC (97, 'giacsi');
call BachecaElettronicadb.seguiAnnuncioUSCC (37, 'drardussi');
call BachecaElettronicadb.seguiAnnuncioUSCC (140, 'ritasi');
call BachecaElettronicadb.seguiAnnuncioUSCC (23, 'selvssi');
call BachecaElettronicadb.seguiAnnuncioUSCC (6, 'emilino');
call BachecaElettronicadb.seguiAnnuncioUSCC (67, 'dottci');
call BachecaElettronicadb.seguiAnnuncioUSCC (156, 'domingbo');
call BachecaElettronicadb.seguiAnnuncioUSCC (106, 'karimmti');
call BachecaElettronicadb.seguiAnnuncioUSCC (77, 'danutno');
