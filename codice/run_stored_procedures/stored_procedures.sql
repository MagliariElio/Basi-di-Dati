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
	call BachecaElettronicadb.modifica_RecapitoNonPreferito(tipoRecapitoNonPreferito, recapitoNonPreferito, cf_anagrafico, null);		
	
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

-- Inserimento o Rimozione Recapito non preferito -------------------- 

DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.modifica_RecapitoNonPreferito ;
CREATE PROCEDURE BachecaElettronicadb.modifica_RecapitoNonPreferito (IN tipo VARCHAR(20), IN recapito VARCHAR(40), IN cf_anagrafico VARCHAR(16), IN rimuovi INT)
BEGIN
	
	if ((SELECT count(CF) FROM BachecaElettronicadb.InformazioneAnagrafica WHERE BachecaElettronicadb.InformazioneAnagrafica.CF=cf_anagrafico) <> 1)  then
		signal sqlstate '45004' set message_text = "Fiscal Code not found";
	end if;
	
	if(rimuovi is null) then
		INSERT INTO BachecaElettronicadb.RecapitoNonPreferito (Recapito, Tipo, InformazioneAnagrafica_CF) VALUES(recapito, tipo, cf_anagrafico);
	else
		DELETE FROM BachecaElettronicadb.RecapitoNonPreferito
		WHERE BachecaElettronicadb.RecapitoNonPreferito.InformazioneAnagrafica_CF = cf_anagrafico AND BachecaElettronicadb.RecapitoNonPreferito.Recapito = recapito AND BachecaElettronicadb.RecapitoNonPreferito.Tipo = tipo;
	end if;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione contatti ------------------------------------------ 

DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizza_contatti ;
CREATE PROCEDURE BachecaElettronicadb.visualizza_contatti (IN cf_anagrafico VARCHAR(16), IN preferito INT)
BEGIN
	
	if ((SELECT count(CF) FROM BachecaElettronicadb.InformazioneAnagrafica WHERE BachecaElettronicadb.InformazioneAnagrafica.CF=cf_anagrafico) <> 1)  then
		signal sqlstate '45004' set message_text = "Fiscal Code not found";
	end if;
	
	if (preferito is not null) then
		SELECT RecapitoPreferito AS 'Recapito', tipoRecapitoPreferito AS 'Tipo', CF AS 'Codice Fiscale'
		FROM BachecaElettronicadb.InformazioneAnagrafica
		WHERE BachecaElettronicadb.InformazioneAnagrafica.CF=cf_anagrafico;
	else 
		SELECT Recapito, Tipo, InformazioneAnagrafica_CF AS 'Codice Fiscale'
		FROM BachecaElettronicadb.RecapitoNonPreferito
		WHERE BachecaElettronicadb.RecapitoNonPreferito.InformazioneAnagrafica_CF=cf_anagrafico;
	end if;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Registrazione di un utente USCC -----------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.registra_utente_USCC ;
CREATE PROCEDURE BachecaElettronicadb.registra_utente_USCC (IN username VARCHAR(45), IN password VARCHAR(45), IN cf_anagrafico VARCHAR(16), IN cognome VARCHAR(20), IN nome VARCHAR(20), IN indirizzoDiResidenza VARCHAR(20), IN cap INT, IN indirizzoDiFatturazione VARCHAR(20), IN tipoRecapitoPreferito VARCHAR(20), IN recapitoPreferito VARCHAR(40), IN tipoRecapitoNonPreferito VARCHAR(20), IN recapitoNonPreferito VARCHAR(40))
BEGIN
	declare idStorico INT;
	
	if (SELECT count(Username) FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username=username) > 0 then
		signal sqlstate '45002' set message_text = "User was inserted as UCC";
	elseif (SELECT count(Username) FROM BachecaElettronicadb.USCC WHERE BachecaElettronicadb.USCC.Username=username) > 0 then
		signal sqlstate '45003' set message_text = "User was inserted as USCC";
	end if;
	
	call BachecaElettronicadb.inserisci_Storico(idStorico);
	call BachecaElettronicadb.inserimentoInfoAnagrafiche(cf_anagrafico, cognome, nome, indirizzoDiResidenza, cap, indirizzoDiFatturazione, tipoRecapitoPreferito, recapitoPreferito);
	call BachecaElettronicadb.modifica_RecapitoNonPreferito(tipoRecapitoNonPreferito, recapitoNonPreferito, cf_anagrafico, null);		

	
	INSERT INTO BachecaElettronicadb.USCC (Username, Password, StoricoConversazione_ID, CF_Anagrafico) 
	VALUES(username, md5(password), idStorico, cf_anagrafico);
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento delle Informazioni Anagrafiche ------------------------ 
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.inserimentoInfoAnagrafiche ;
CREATE PROCEDURE BachecaElettronicadb.inserimentoInfoAnagrafiche (IN cf VARCHAR(16), IN cognome VARCHAR(20), IN nome VARCHAR(20), IN indirizzoDiResidenza VARCHAR(20), IN cap INT, IN indirizzoDiFatturazione VARCHAR(20), IN tipoRecapitoPreferito VARCHAR(20), IN recapitoPreferito VARCHAR(40))
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
	if ((SELECT count(CF) FROM BachecaElettronicadb.InformazioneAnagrafica WHERE BachecaElettronicadb.InformazioneAnagrafica.CF = cf) <> 1) then
		signal sqlstate '45004' set message_text = 'Fiscal Code not found';
	end if;
	
	IF cognome IS NOT NULL THEN
		UPDATE BachecaElettronicadb.InformazioneAnagrafica SET BachecaElettronicadb.InformazioneAnagrafica.Cognome=cognome WHERE BachecaElettronicadb.InformazioneAnagrafica.CF=cf;
	END IF;
	IF nome IS NOT NULL THEN
		UPDATE BachecaElettronicadb.InformazioneAnagrafica SET BachecaElettronicadb.InformazioneAnagrafica.Nome=nome WHERE BachecaElettronicadb.InformazioneAnagrafica.CF=cf;
	END IF;
	IF indirizzoDiResidenza IS NOT NULL THEN
		UPDATE BachecaElettronicadb.InformazioneAnagrafica SET BachecaElettronicadb.InformazioneAnagrafica.IndirizzoDiResidenza=indirizzoDiResidenza WHERE BachecaElettronicadb.InformazioneAnagrafica.CF=cf;
	END IF;
	IF indirizzoDiFatturazione IS NOT NULL THEN
		UPDATE BachecaElettronicadb.InformazioneAnagrafica SET BachecaElettronicadb.InformazioneAnagrafica.IndirizzoDiFatturazione=indirizzoDiFatturazione WHERE BachecaElettronicadb.InformazioneAnagrafica.CF=cf;
	END IF;
	IF cap IS NOT NULL THEN
		UPDATE BachecaElettronicadb.InformazioneAnagrafica SET BachecaElettronicadb.InformazioneAnagrafica.CAP=cap, IndirizzoDiFatturazione=indirizzoDiFatturazione WHERE BachecaElettronicadb.InformazioneAnagrafica.CF=cf;
	END IF;
	IF ((tipoRecapitoPreferito IS NOT NULL) AND (recapitoPreferito IS NOT NULL)) THEN
		UPDATE BachecaElettronicadb.InformazioneAnagrafica SET BachecaElettronicadb.InformazioneAnagrafica.TipoRecapitoPreferito = tipoRecapitoPreferito WHERE BachecaElettronicadb.InformazioneAnagrafica.CF = cf;
		UPDATE BachecaElettronicadb.InformazioneAnagrafica SET BachecaElettronicadb.InformazioneAnagrafica.RecapitoPreferito = recapitoPreferito WHERE BachecaElettronicadb.InformazioneAnagrafica.CF = cf;
	END IF;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione delle Informazioni Anagrafiche ------------------------ 
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaInfoAnagrafiche ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaInfoAnagrafiche (IN cf VARCHAR(16), IN check_owner INT, IN username VARCHAR(45))
BEGIN
	
	if ((SELECT count(CF) FROM BachecaElettronicadb.InformazioneAnagrafica WHERE BachecaElettronicadb.InformazioneAnagrafica.CF=cf) <> 1) then
		signal sqlstate '45004' set message_text = 'Fiscal Code not found';
	end if;
	
	if ((check_owner IS NOT NULL) AND (username IS NOT NULL)) then
		IF ((SELECT(count(Username)) FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.CF_Anagrafico = cf AND BachecaElettronicadb.UCC.Username = username) <> 1) then
			if ((SELECT(count(Username)) FROM BachecaElettronicadb.USCC WHERE BachecaElettronicadb.USCC.CF_Anagrafico = cf AND BachecaElettronicadb.USCC.Username = username) <> 1) then	
				signal sqlstate '45009' set message_text = 'The fiscal code is not yours';
			end if;
		end IF;
	end if;
	
	SELECT CF AS 'Codice Fiscale', Cognome, Nome, IndirizzoDiResidenza AS 'Indirizzo di Residenza', CAP, IndirizzoDiFatturazione AS 'Indirizzo di Fatturazione', tipoRecapitoPreferito AS 'Tipo Recapito', RecapitoPreferito AS 'Recapito Preferito'
	FROM BachecaElettronicadb.InformazioneAnagrafica
	WHERE BachecaElettronicadb.InformazioneAnagrafica.CF = cf;

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
CREATE PROCEDURE BachecaElettronicadb.inserimentoNuovoAnnuncio (IN descrizione VARCHAR(100), IN importo INT, IN foto VARCHAR(9), IN ucc_username VARCHAR(45), IN categoria_nome VARCHAR(20))
BEGIN
	if ((SELECT(count(Username)) FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username=ucc_username) <> 1) then
		signal sqlstate '45000' set message_text = 'User not found';
	end if;
	if ((SELECT(count(Nome)) FROM BachecaElettronicadb.Categoria WHERE BachecaElettronicadb.Categoria.Nome=categoria_nome) <> 1) then
		signal sqlstate '45001' set message_text = 'Category not found';
	end if;
	
	IF (foto IS NULL) THEN
		INSERT INTO BachecaElettronicadb.Annuncio (Codice, Stato, Descrizione, Importo, UCC_Username, Categoria_Nome) VALUES(NULL, 'Attivo', descrizione, importo, ucc_username, categoria_nome);
	ELSE
		INSERT INTO BachecaElettronicadb.Annuncio (Codice, Stato, Descrizione, Importo, Foto, UCC_Username, Categoria_Nome) VALUES(NULL, 'Attivo', descrizione, importo, 'Presente', ucc_username, categoria_nome);
	END IF;
			
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento o Rimozione di una foto in annuncio ------------------- Impostare un livello di isolamento per evitare repeatible read - Evento: avverti utenti che seguono l'annuncio - Inserisci o rimuovi foto a seconda del parametro
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.modificaFotoAnnuncio ;
CREATE PROCEDURE BachecaElettronicadb.modificaFotoAnnuncio (IN codice INT, IN username VARCHAR(45), IN foto VARCHAR(9))
BEGIN
	if ((SELECT(count(codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=codice) <> 1) then
		signal sqlstate '45006' set  message_text = 'Ad not found';
	end if;	
	
	if ((SELECT(count(codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=codice AND BachecaElettronicadb.Annuncio.UCC_Username=username) <> 1) then
		signal sqlstate '45008' set  message_text = 'You are not the owner of the ad';
	end if;
	
	if ((SELECT(count(codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=codice AND BachecaElettronicadb.Annuncio.Stato='Attivo') <> 1) then
		signal sqlstate '45007' set  message_text = 'Ad not active now';
	end if;
	
	
	UPDATE BachecaElettronicadb.Annuncio
	SET Foto = foto
	WHERE Codice=codice;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizza annuncio -----------------------------------------------  Impostare un livello di isolamento
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaAnnuncio ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaAnnuncio (IN annuncio_codice INT, IN username VARCHAR(45), IN check_owner INT)
BEGIN
	if ((username IS NOT NULL) AND (SELECT(count(Username)) FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username=username) <> 1) then
		signal sqlstate '45000' set message_text = 'User not found';
	end if;

	if ((annuncio_codice IS NOT NULL) AND (SELECT(count(annuncio_codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=annuncio_codice) <> 1) then
		signal sqlstate '45006' set message_text = 'Ad not found';
	end if;
	
	if ((check_owner = 1) AND (username IS NOT NULL) AND (annuncio_codice IS NOT NULL)) then
		IF ((SELECT(count(Codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=annuncio_codice AND BachecaElettronicadb.Annuncio.UCC_Username=username) <> 1) then
			signal sqlstate '45008' set message_text = 'You are not the owner of the ad';
		end IF;
	end if;
	
	IF ((annuncio_codice IS NOT NULL) AND (username IS NOT NULL)) THEN
		SELECT Codice, Stato, Descrizione, Importo, Foto, UCC_Username AS 'Proprietario', Categoria_Nome AS 'Categoria'
		FROM BachecaElettronicadb.Annuncio
		WHERE BachecaElettronicadb.Annuncio.UCC_Username=username AND BachecaElettronicadb.Annuncio.Codice=annuncio_codice AND BachecaElettronicadb.Annuncio.Stato='Attivo';
	ELSEIF ((annuncio_codice IS NULL) AND (username IS NOT NULL)) THEN
		SELECT Codice, Stato, Descrizione, Importo, Foto, UCC_Username AS 'Proprietario', Categoria_Nome AS 'Categoria'
		FROM BachecaElettronicadb.Annuncio
		WHERE BachecaElettronicadb.Annuncio.UCC_Username=username AND BachecaElettronicadb.Annuncio.Stato='Attivo';
	ELSEIF ((annuncio_codice IS NOT NULL) AND (username IS NULL)) THEN
		SELECT Codice, Stato, Descrizione, Importo, Foto, UCC_Username AS 'Proprietario', Categoria_Nome AS 'Categoria'
		FROM BachecaElettronicadb.Annuncio
		WHERE BachecaElettronicadb.Annuncio.Codice=annuncio_codice AND BachecaElettronicadb.Annuncio.Stato='Attivo';
	ELSE
		SELECT Codice, Stato, Descrizione, Importo, Foto, UCC_Username AS 'Proprietario', Categoria_Nome AS 'Categoria'
		FROM BachecaElettronicadb.Annuncio 
		WHERE BachecaElettronicadb.Annuncio.Stato='Attivo';
	end IF;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento o Rimozione commento ---------------------------------- Evento: avverti utenti che seguono l'annuncio - Inserimento o Rimozione del commento a seconda del parametro
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.modificaCommento ;
CREATE PROCEDURE BachecaElettronicadb.modificaCommento (IN testo VARCHAR(45), IN annuncio_codice INT, IN ID_rimozione_commento INT)
BEGIN
	if ((SELECT(count(Annuncio_Codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=annuncio_codice AND BachecaElettronicadb.Annuncio.Stato='Attivo') <> 1) then
		signal sqlstate '45007' set message_text = 'Ad not active now';
	end if;
	
	if (ID_rimozione_commento is null) then	
		INSERT INTO BachecaElettronicadb.Commento (Testo, Annuncio_Codice) VALUES(testo, annuncio_codice);
	else
		DELETE FROM BachecaElettronicadb.Commento
		WHERE BachecaElettronicadb.Commento.ID = ID_rimozione_commento;
	end if;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione commento ------------------------------------------ Impostare un livello di isolamento
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaCommento ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaCommento (IN annuncio_codice INT)
BEGIN
	if ((SELECT(count(Annuncio_Codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=annuncio_codice AND BachecaElettronicadb.Annuncio.Stato='Attivo') <> 1) then
		 signal sqlstate '45007' set message_text = 'Ad not active now';
	end if;
	
	SELECT ID, Testo, Annuncio_codice AS "Codice dell'annuncio"
	FROM BachecaElettronicadb.Commento
	WHERE BachecaElettronicadb.Commento.Annuncio_Codice = annuncio_codice;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento Conversazione ----------------------------------------- Privilegi a nessuno
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.inserimentoConversazione ;
CREATE PROCEDURE BachecaElettronicadb.inserimentoConversazione (OUT id_conversazione INT, IN ucc_username_1 VARCHAR(45), ucc_username_2 VARCHAR(45), IN uscc_username VARCHAR(45))
BEGIN
	INSERT INTO BachecaElettronicadb.Conversazione (Codice, UCC_Username_1, UCC_Username_2, USCC_Username) VALUES(NULL, ucc_username_1, ucc_username_2, uscc_username);
	SET id_conversazione = LAST_INSERT_ID();
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Seleziona Storico UCC per la stored procedure --------------------- Impostare un livello di isolamento - Privilegi a nessuno
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.seleziona_Storico_UCC ;
CREATE PROCEDURE BachecaElettronicadb.seleziona_Storico_UCC (IN username VARCHAR(45), OUT storico_id_ucc INT)
BEGIN
	
	SELECT StoricoConversazione_ID INTO storico_id_ucc
	FROM BachecaElettronicadb.UCC
	WHERE BachecaElettronicadb.UCC.Username = username;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Seleziona Storico USCC per la stored procedure -------------------- Impostare un livello di isolamento - Privilegi a nessuno
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.seleziona_Storico_USCC ;
CREATE PROCEDURE BachecaElettronicadb.seleziona_Storico_USCC (IN username VARCHAR(45), OUT storico_id_uscc INT)
BEGIN
	
	SELECT StoricoConversazione_ID INTO storico_id_uscc
	FROM BachecaElettronicadb.USCC
	WHERE BachecaElettronicadb.USCC.Username = username;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Tracciamento Conversazioni ---------------------------------------- Privilegi a nessuno
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.traccia_Conversazione ;
CREATE PROCEDURE BachecaElettronicadb.traccia_Conversazione (IN conversazione_codice INT, IN sender_ucc_username VARCHAR(45), IN receiver_ucc_username VARCHAR(45), IN receiver_uscc_username VARCHAR(45))
BEGIN
	
	declare storico_id_ucc, storico_id_uscc INT;
	
	if ((sender_ucc_username is not null) and (receiver_uscc_username is not null)) then	
		call seleziona_Storico_UCC(sender_ucc_username, storico_id_ucc);
		call seleziona_Storico_USCC(receiver_uscc_username, storico_id_uscc);
		
		INSERT INTO BachecaElettronicadb.Tracciato (Conversazione_Codice, StoricoConversazione_ID) VALUES(conversazione_codice, storico_id_ucc);	-- traccia lo storico di UCC
		INSERT INTO BachecaElettronicadb.Tracciato (Conversazione_Codice, StoricoConversazione_ID) VALUES(conversazione_codice, storico_id_uscc);	-- traccia lo storico di USCC
		INSERT INTO BachecaElettronicadb.ConversazioneCodice (CodiceConv, StoricoConversazione_ID) VALUES(conversazione_codice, storico_id_ucc); 	-- inserisce il nuovo codice della conversazione nello storico di UCC
		INSERT INTO BachecaElettronicadb.ConversazioneCodice (CodiceConv, StoricoConversazione_ID) VALUES(conversazione_codice, storico_id_uscc); 	-- inserisce il nuovo codice della conversazione nello storico di USCC
	
	elseif ((sender_ucc_username is not null) and (receiver_ucc_username is not null)) then	
		call seleziona_Storico_UCC(sender_ucc_username, storico_id_ucc);
		call seleziona_Storico_UCC(receiver_ucc_username, storico_id_uscc);
		
		INSERT INTO BachecaElettronicadb.Tracciato (Conversazione_Codice, StoricoConversazione_ID) VALUES(conversazione_codice, storico_id_ucc);	-- traccia lo storico di UCC
		INSERT INTO BachecaElettronicadb.Tracciato (Conversazione_Codice, StoricoConversazione_ID) VALUES(conversazione_codice, storico_id_uscc);	-- traccia lo storico di UCC
		INSERT INTO BachecaElettronicadb.ConversazioneCodice (CodiceConv, StoricoConversazione_ID) VALUES(conversazione_codice, storico_id_ucc); 	-- inserisce il nuovo codice della conversazione nello storico di UCC
		INSERT INTO BachecaElettronicadb.ConversazioneCodice (CodiceConv, StoricoConversazione_ID) VALUES(conversazione_codice, storico_id_uscc); 	-- inserisce il nuovo codice della conversazione nello storico di UCC		
	else
		signal sqlstate '45010' set message_text = 'Error Parameters';
	end if;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Invio messaggio da parte utente ----------------------------------- Evento: arrivato un nuovo messaggio
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.invioMessaggio ;
CREATE PROCEDURE BachecaElettronicadb.invioMessaggio (IN sender_username VARCHAR(45), IN receiver_username VARCHAR(45), IN testo VARCHAR(100))
BEGIN
	declare conversazione_codice INT DEFAULT NULL;
	declare sender_is_ucc, sender_is_uscc, receiver_is_ucc, receiver_is_uscc INT;
	
	SET sender_is_ucc = 0;
	SET sender_is_uscc = 0;
	SET receiver_is_ucc = 0;
	SET receiver_is_uscc = 0;

	
	-- utente che invia il messaggio
	if ((SELECT count(Username) FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username = sender_username) = 1) then
		SELECT Username INTO sender_username
		FROM BachecaElettronicadb.UCC 
		WHERE BachecaElettronicadb.UCC.Username = sender_username;
		
		SET sender_is_ucc = 1;		-- l'utente che invia il messaggio è un UCC
		
	elseif ((SELECT count(Username) FROM BachecaElettronicadb.USCC WHERE BachecaElettronicadb.USCC.Username = sender_username) = 1) then
		SELECT Username INTO sender_username
		FROM BachecaElettronicadb.USCC 
		WHERE BachecaElettronicadb.USCC.Username = sender_username;
		
		SET sender_is_uscc = 1;		-- l'utente che invia il messaggio è un USCC
		
	else
		signal sqlstate '45000' set message_text = 'User not found';		-- utente non trovato nel database
	end if;
	
	-- utente che riceve il messaggio
	if ((SELECT count(Username) FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username = receiver_username) = 1) then
		SELECT Username INTO receiver_username
		FROM BachecaElettronicadb.UCC 
		WHERE BachecaElettronicadb.UCC.Username = receiver_username;
		
		SET receiver_is_ucc = 1;	-- l'utente che riceve il mesaggio è un UCC

	elseif ((SELECT count(Username) FROM BachecaElettronicadb.USCC WHERE BachecaElettronicadb.USCC.Username = receiver_username) = 1) then
		SELECT Username INTO receiver_username
		FROM BachecaElettronicadb.USCC 
		WHERE BachecaElettronicadb.USCC.Username = receiver_username;
		
		SET receiver_is_uscc = 1;	-- l'utente che riceve il messaggio è un USCC
		
	else
		signal sqlstate '45000' set message_text = 'User not found';		-- utente non trovato nel database 
	end if;
	
	if ((sender_is_uscc = 1) AND (receiver_is_uscc = 1)) then
		signal sqlstate '45013' set message_text = 'You cannot write to another USCC user';
	end if;	
	
	call controllo_conversazione(NULL, sender_username, receiver_username, conversazione_codice);  -- cerca il codice della conversazione 
	
	if(conversazione_codice = -1) then 			-- conversazione non trovata quindi inesistente, si inserisce una nuova
		-- traccia le conversazioni 
		if ((sender_is_ucc = 1) and (receiver_is_ucc = 1)) then
			call BachecaElettronicadb.inserimentoConversazione(conversazione_codice, sender_username, receiver_username, NULL);			-- nuova conversazione
			call traccia_Conversazione(conversazione_codice, sender_username, receiver_username, NULL);									-- inserisce tutti i vincoli
		elseif ((sender_is_ucc = 1) and (receiver_is_uscc = 1)) then
			call BachecaElettronicadb.inserimentoConversazione(conversazione_codice, sender_username, NULL, receiver_username);	
			call traccia_Conversazione(conversazione_codice, sender_username, NULL, receiver_username);
		else		-- (sender_is_uscc = 1) and (receiver_is_ucc = 1)
			call BachecaElettronicadb.inserimentoConversazione(conversazione_codice, receiver_username, NULL, sender_username);
			call traccia_Conversazione(conversazione_codice, receiver_username, NULL, sender_username);
		end if;
	end if;
	
	/* 							Nota
	 * Non è presente la condizione (sender_is_uscc = 1) and (receiver_is_uscc = 1))
	 * perchè non è possibile che due utenti USCC comunicano 
	 */
	
	if (conversazione_codice is not null) then
		INSERT INTO BachecaElettronicadb.Messaggio (Data, Conversazione_Codice, Testo)		-- conversazione esistente, allora inserisco il messaggio
		VALUES (now(), conversazione_codice, testo);
	end if;
		
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Controllo Privacy e Ricerca conversazione -------------------------- Impostare un livello di isolamento - privilegi a nessuno
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.controllo_conversazione ;
CREATE PROCEDURE BachecaElettronicadb.controllo_conversazione (IN id_conversation_check INT, sender_username VARCHAR(45), IN receiver_username VARCHAR(45), OUT conversazione_codice_controllo INT)
BEGIN
	
	SET conversazione_codice_controllo = NULL;
	
	-- ricerca del codice della conversazione, basando la ricerca sulla combinazione degli username   
	if (id_conversation_check is null) then
		SELECT Codice into conversazione_codice_controllo
		FROM BachecaElettronicadb.Conversazione
		WHERE BachecaElettronicadb.Conversazione.UCC_Username_1 = sender_username and BachecaElettronicadb.Conversazione.USCC_Username = receiver_username;
			
		if(conversazione_codice_controllo is null) then 
			SELECT Codice into conversazione_codice_controllo
			FROM BachecaElettronicadb.Conversazione
			WHERE BachecaElettronicadb.Conversazione.UCC_Username_1 = sender_username and BachecaElettronicadb.Conversazione.UCC_Username_2 = receiver_username;
		end if;
		if(conversazione_codice_controllo is null) then 
			SELECT Codice into conversazione_codice_controllo
			FROM BachecaElettronicadb.Conversazione
			WHERE BachecaElettronicadb.Conversazione.UCC_Username_1 = receiver_username and BachecaElettronicadb.Conversazione.UCC_Username_2 = sender_username;
		end if;
		if(conversazione_codice_controllo is null) then 
			SELECT Codice into conversazione_codice_controllo
			FROM BachecaElettronicadb.Conversazione
			WHERE BachecaElettronicadb.Conversazione.UCC_Username_1 = receiver_username and BachecaElettronicadb.Conversazione.USCC_Username = sender_username;
		end if;
		
		if(conversazione_codice_controllo is null) then 			-- errore, conversazione non trovata quindi inesistente
			SET conversazione_codice_controllo = -1;
		end if;
	end if;
		
	-- Controlla che gli utenti, con gli username passati, siano autorizzati ad accedere al codice di conversazione passato   
	if (id_conversation_check is not null) then	
		SELECT Codice into conversazione_codice_controllo
		FROM BachecaElettronicadb.Conversazione
		WHERE BachecaElettronicadb.Conversazione.Codice = id_conversation_check and BachecaElettronicadb.Conversazione.UCC_Username_1 = sender_username and BachecaElettronicadb.Conversazione.USCC_Username = receiver_username;
			
		if(conversazione_codice_controllo is null) then 
			SELECT Codice into conversazione_codice_controllo
			FROM BachecaElettronicadb.Conversazione
			WHERE BachecaElettronicadb.Conversazione.Codice = id_conversation_check and BachecaElettronicadb.Conversazione.UCC_Username_1 = sender_username and BachecaElettronicadb.Conversazione.UCC_Username_2 = receiver_username;
		end if;
		if(conversazione_codice_controllo is null) then 
			SELECT Codice into conversazione_codice_controllo
			FROM BachecaElettronicadb.Conversazione
			WHERE BachecaElettronicadb.Conversazione.Codice = id_conversation_check and BachecaElettronicadb.Conversazione.UCC_Username_1 = receiver_username and BachecaElettronicadb.Conversazione.UCC_Username_2 = sender_username;
		end if;
		if(conversazione_codice_controllo is null) then 
			SELECT Codice into conversazione_codice_controllo
			FROM BachecaElettronicadb.Conversazione
			WHERE BachecaElettronicadb.Conversazione.Codice = id_conversation_check and BachecaElettronicadb.Conversazione.UCC_Username_1 = receiver_username and BachecaElettronicadb.Conversazione.USCC_Username = sender_username;
		end if;
		
		if(conversazione_codice_controllo is null) then 			-- errore, conversazione non trovata quindi inesistente
			SET conversazione_codice_controllo = -1;
		end if;
	end if;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizza messaggio ---------------------------------------------- Impostare un livello di isolamento
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaMessaggio ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaMessaggio (IN id_conversation INT, sender_username VARCHAR(45), IN receiver_username VARCHAR(45))
BEGIN
	
	-- sender_username è l'username dell'utente che sta chiamando la stored procedure
	-- receiver_username è l'username dell'utente con cui sender_username ha avuto una conversazione
	
	declare conversazione_codice INT DEFAULT NULL;
	
	-- l'utente ha passato un codice di conversazione, probabilmente visualizzando lo storico 
	if(id_conversation is not null) then
		call controllo_conversazione(id_conversation, sender_username, receiver_username, conversazione_codice);
		IF (conversazione_codice = -1) then
			signal sqlstate '45012' set message_text = 'You are not authorized to access this conversation';
		end IF;
	end if;
	
	if(id_conversation is null) then
		call controllo_conversazione(NULL, sender_username, receiver_username, conversazione_codice);
	end if;
	
	if(conversazione_codice = -1) then 			-- errore, conversazione non trovata quindi inesistente
		signal sqlstate '45011' set message_text = 'Conversation not found'; 
	else
		SELECT Testo, Data
		FROM BachecaElettronicadb.Messaggio
		WHERE BachecaElettronicadb.Messaggio.Conversazione_Codice = conversazione_codice
		ORDER BY Data ASC;
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
	
	if ((SELECT(count(Username)) FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username = ucc_username) <> 1) then
		signal sqlstate '45000' set message_text = 'User not found';
	end if;
	
	-- Trova il codice dello storico creato nel momento della registrazione 
	SELECT StoricoConversazione_ID INTO idStorico FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username = ucc_username;
	
	-- Stampa tutte le conversazioni dell'utente con il relativo partecipante 
	SELECT Codice, UCC_Username_2 AS 'Username utente UCC', USCC_Username AS 'Username utente USCC'
	FROM BachecaElettronicadb.Conversazione
	WHERE BachecaElettronicadb.Conversazione.Codice in (SELECT CodiceConv
														FROM BachecaElettronicadb.ConversazioneCodice
														WHERE BachecaElettronicadb.ConversazioneCodice.StoricoConversazione_ID = idStorico);
		
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione Storico USCC -------------------------------------- Impostare un livello di isolamento
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaStorico_USCC ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaStorico_USCC (IN uscc_username VARCHAR(45))
BEGIN
	
	
	declare idStorico INT;
	
	if ((SELECT(count(Username)) FROM BachecaElettronicadb.USCC WHERE BachecaElettronicadb.USCC.Username = uscc_username) <> 1) then
		signal sqlstate '45000' set message_text = 'User not found';
	end if;
	
	-- Trova il codice dello storico creato nel momento della registrazione 
	SELECT StoricoConversazione_ID INTO idStorico FROM BachecaElettronicadb.USCC WHERE BachecaElettronicadb.USCC.Username = uscc_username;
	
	-- Stampa tutte le conversazioni dell'utente con il relativo partecipante 
	SELECT Codice, UCC_Username_1 AS 'Username utente UCC', UCC_Username_2 AS 'Username utente UCC'
	FROM BachecaElettronicadb.Conversazione
	WHERE BachecaElettronicadb.Conversazione.Codice in (SELECT CodiceConv
														FROM BachecaElettronicadb.ConversazioneCodice
														WHERE BachecaElettronicadb.ConversazioneCodice.StoricoConversazione_ID = idStorico);

END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Seguire un annuncio -----------------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.segui_Annuncio ;
CREATE PROCEDURE BachecaElettronicadb.segui_Annuncio (IN codice_annuncio INT, IN username VARCHAR(45))
BEGIN
	if ((SELECT(count(Codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice = codice_annuncio) = 0) then
		signal sqlstate '45006' set message_text = 'Ad not found';
	end if;
	
	if ((SELECT(count(Codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice = codice_annuncio and BachecaElettronicadb.Annuncio.Stato = 'Attivo') = 0) then
		signal sqlstate '45007' set message_text = 'Ad not active now';
	end if;
	
	if ((SELECT(count(Username)) FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username = username) <> 1) then
		IF ((SELECT(count(Username)) FROM BachecaElettronicadb.USCC WHERE BachecaElettronicadb.USCC.Username = username) <> 1) THEN
			signal sqlstate '45000' set message_text = 'User not found';
		ELSE
			INSERT INTO BachecaElettronicadb.`Seguito-USCC`(USCC_Username, Annuncio_Codice) VALUES(username, codice_annuncio);
		end IF;
	else	
		INSERT INTO BachecaElettronicadb.`Seguito-UCC`(UCC_Username, Annuncio_Codice) VALUES(username, codice_annuncio);
	end if;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione degli Annunci seguiti ----------------------------- Impostare un livello di isolamento
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizza_Annunci_Seguiti ;
CREATE PROCEDURE BachecaElettronicadb.visualizza_Annunci_Seguiti (IN username VARCHAR(45))
BEGIN
	
	/* Nota
	 * L'idea è: Verifica che l'utente sia un UCC, altrimenti controlla se è un USCC.
	 * Se non fosse nè UCC e nè USCC allora l'utente non esiste
	 */	
	
	if ((SELECT(count(Username)) FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username = username) <> 1) then
		IF ((SELECT(count(Username)) FROM BachecaElettronicadb.USCC WHERE BachecaElettronicadb.USCC.Username = username) <> 1) THEN
			signal sqlstate '45000' set message_text = 'User not found';
		ELSE
			SELECT annuncio.Codice, annuncio.Stato
			FROM BachecaElettronicadb.`Seguito-USCC` AS seguiti JOIN BachecaElettronicadb.Annuncio AS annuncio ON seguiti.Annuncio_Codice = annuncio.Codice
			WHERE seguiti.USCC_Username = username;
		end IF;
	else
		SELECT annuncio.Codice, annuncio.Stato
		FROM BachecaElettronicadb.`Seguito-UCC` AS seguiti JOIN BachecaElettronicadb.Annuncio AS annuncio ON seguiti.Annuncio_Codice = annuncio.Codice
		WHERE seguiti.UCC_Username = username;
	end if;

END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento o Rimozione nota in un Annuncio -----------------------	Attivare evento avverti utente che seguono l'annuncio
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.modificaNota ;
CREATE PROCEDURE BachecaElettronicadb.modificaNota (IN testo VARCHAR(45), IN annuncio_codice INT, IN ID_rimozione_nota INT, IN username VARCHAR(45))
BEGIN
	
	if ((SELECT(count(Codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=annuncio_codice and BachecaElettronicadb.Annuncio.Stato='Attivo') <> 1) then
		signal sqlstate '45007' set message_text = 'Ad not active now';
	end if;
	
	if ((SELECT(count(Codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=annuncio_codice and BachecaElettronicadb.Annuncio.UCC_Username=username) <> 1) then
		signal sqlstate '45008' set message_text = 'You are not the owner of the ad';
	end if;
	
	if (ID_rimozione_nota is null) then
		INSERT INTO BachecaElettronicadb.Nota (ID, Testo, Annuncio_Codice) VALUES(NULL, testo, annuncio_codice);
	else 
		DELETE FROM BachecaElettronicadb.Nota
		WHERE BachecaElettronicadb.Nota.ID = ID_rimozione_nota;
	end if;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizza nota --------------------------------------------------- Impostare un livello di isolamento
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaNota ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaNota (IN annuncio_Codice INT)
BEGIN
	if ((SELECT(count(Codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=annuncio_Codice and BachecaElettronicadb.Annuncio.Stato='Attivo') <> 1) then
		signal sqlstate '45007' set message_text = 'Ad not active now';
	end if;
	
	SELECT ID, Testo, Annuncio_Codice AS "Codice dell'annuncio"
	FROM BachecaElettronicadb.Nota
	WHERE BachecaElettronicadb.Nota.Annuncio_Codice = annuncio_Codice;
		
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Rimozione di un Annuncio ------------------------------------------	Attivare evento avverti utente che seguono l'annuncio - Attivare evento genera report
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.rimuoviAnnuncio ;
CREATE PROCEDURE BachecaElettronicadb.rimuoviAnnuncio (IN codice_annuncio INT)
BEGIN
	if ((SELECT(count(Codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=codice_annuncio) <> 1) then
		signal sqlstate '45006' set message_text = 'Ad not found';
	end if;
	
	if ((SELECT(count(Codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice = codice_annuncio and BachecaElettronicadb.Annuncio.Stato = 'Attivo') <> 1) then
		signal sqlstate '45007' set message_text = 'Ad not active now';
	end if;
	
	UPDATE BachecaElettronicadb.Annuncio
	SET BachecaElettronicadb.Annuncio.Stato = 'Rimosso'
	WHERE BachecaElettronicadb.Annuncio.Codice = codice_annuncio AND BachecaElettronicadb.Annuncio.Stato = 'Attivo';

END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Annuncio Venduto ------------------------------------------	Attivare evento avverti utente che seguono l'annuncio - Attivare evento genera report
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.vendutoAnnuncio ;
CREATE PROCEDURE BachecaElettronicadb.vendutoAnnuncio (IN codice_annuncio INT)
BEGIN
	if ((SELECT(count(Codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=codice_annuncio) <> 1) then
		signal sqlstate '45006' set message_text = 'Ad not found';
	end if;
	
	if ((SELECT(count(Codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice = codice_annuncio and BachecaElettronicadb.Annuncio.Stato = 'Attivo') <> 1) then
		signal sqlstate '45007' set message_text = 'Ad not active now';
	end if;
	
	UPDATE BachecaElettronicadb.Annuncio
	SET BachecaElettronicadb.Annuncio.Stato = 'Venduto'
	WHERE BachecaElettronicadb.Annuncio.Codice = codice_annuncio AND BachecaElettronicadb.Annuncio.Stato = 'Attivo';

END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Generazione di un nuovo report ------------------------------------ Controllare se bisogna attivare un evento per non calcolare ogni volta annunci già calcolati
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.genera_report ;
CREATE PROCEDURE BachecaElettronicadb.genera_report (IN ucc_username VARCHAR(45), IN amministratore_username VARCHAR(45))
BEGIN
	
	declare numeroCarta VARCHAR(16);
	declare codice_annuncio INT;
	declare numero_annunci INT DEFAULT 0;
	declare importo_totale INT DEFAULT 0;
	declare loop_amount INT DEFAULT 0;
	declare cur_id_annuncio CURSOR FOR SELECT Codice FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.UCC_Username = ucc_username and BachecaElettronicadb.Annuncio.Stato = 'Venduto';
	declare CONTINUE HANDLER FOR NOT FOUND SET loop_amount = 1;
	
	
	/*NOTA
	 * Ho scelto di implementare una stored procedure, rispetto ad un trigger, in quanto essi potevano garantire un uso delle risorse migliore, perché
	 * il calcolo viene effettuato a discrezione dell'amministratore.   
	 * Ovvero un trigger si sarebbe attivato ogni qualvolta che un annuncio venisse indicato come venduto, quindi per un elevato traffico nel
	 * sistema, questo portava una degradazione delle prestazioni e anche un inutile calcolo da fare immediatamente dal punto di vista delle specifiche.
	 */
	
	/*NOTA
	 * L'idea della stored procedure è: 
	 * Calcolare la somma degli importi di tutti gli annunci venduti non calcolati e la percentuale per l'amministratore che ha chiamanto la stored procedure
	 */
	
	-- begin 
		-- rollback;
		-- resignal;
	-- end;
	
	-- start transaction;
	
	if ((SELECT(count(Username)) FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username = ucc_username) <> 1) then
		signal sqlstate '45000' set message_text = "User not found";
	end if;
	
	if ((SELECT(count(Codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.UCC_Username = ucc_username and BachecaElettronicadb.Annuncio.Stato = 'Venduto') = 0) then
		signal sqlstate '45014' set message_text = 'This user has not sold any ads';
	end if;
	
	-- Cerca il numero di carta dell'utente
	SELECT BachecaElettronicadb.UCC.NumeroCarta INTO numeroCarta 
	FROM BachecaElettronicadb.UCC 
	WHERE BachecaElettronicadb.UCC.Username = ucc_username;
		
	-- Calcola l'importo totale degli annunci venduti ancora non riscossi 
	OPEN cur_id_annuncio;
	calculate_amount: LOOP
					  FETCH cur_id_annuncio INTO codice_annuncio;
					  
					  IF loop_amount = 1 THEN
					  	LEAVE calculate_amount;
					  end IF;
					  
					  -- calcola gli importi dei singoli annunci ancora non calcolati
					  SET numero_annunci = numero_annunci + 1;
					  SET importo_totale = importo_totale + (SELECT Importo 
					  										 FROM BachecaElettronicadb.Annuncio
					  										 WHERE BachecaElettronicadb.Annuncio.Codice = codice_annuncio AND BachecaElettronicadb.Annuncio.Report_calcolato = false);
					  
					  -- Imposta a true l'attributo in modo tale da non essere ricalcolato
					  UPDATE BachecaElettronicadb.Annuncio 
					  SET BachecaElettronicadb.Annuncio.Report_calcolato = true
					  WHERE BachecaElettronicadb.Annuncio.Codice = codice_annuncio;

	end LOOP calculate_amount;
	CLOSE cur_id_annuncio;

	INSERT INTO BachecaElettronicadb.Report (Codice, UCC_Username, ImportoTotale, NumeroAnnunci, NumeroCarta, Data, Amministratore_Username, Riscosso_Amministratore, Importo_Amministratore, Importo_UCC)
	VALUES(NULL, ucc_username, importo_totale, numero_annunci, numeroCarta, now(), amministratore_username, false, importo_totale*0.3, importo_totale*0.7);
		
	-- commit;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Riscossione di un report Amministratore --------------------------- Impostare un livello di isolamento 
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.riscossione_report ;
CREATE PROCEDURE BachecaElettronicadb.riscossione_report (IN codice_report INT, IN ucc_username VARCHAR(45), IN amministratore_username VARCHAR(45))
BEGIN
		declare importo INT;
		
		if ((SELECT(count(Username)) FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username = ucc_username) <> 1) then
			signal sqlstate '45000' set message_text = 'User not found';
		end if;
		
		if ((SELECT(count(Codice)) FROM BachecaElettronicadb.Report WHERE BachecaElettronicadb.Report.Codice = codice_report and BachecaElettronicadb.Report.UCC_Username = ucc_username) <> 1) then
			signal sqlstate '45015' set message_text = 'Report not found';
		end if;
		
		if ((SELECT(count(Codice)) FROM BachecaElettronicadb.Report WHERE BachecaElettronicadb.Report.Codice = codice_report and BachecaElettronicadb.Report.Riscosso_Amministratore = true) = 1) then
			signal sqlstate '45016' set message_text = 'Report already collected';
		end if;
		
		-- Solo l'amministratore che ha generato il report può riscuotere
		if ((SELECT(count(Codice)) FROM BachecaElettronicadb.Report WHERE BachecaElettronicadb.Report.Codice = codice_report and BachecaElettronicadb.Report.Amministratore_Username = amministratore_username) <> 1) then
			signal sqlstate '45017' set message_text = 'You are not the owner of the report';
		end if;
		
		SELECT ImportoTotale INTO importo
		FROM BachecaElettronicadb.Report 
		WHERE BachecaElettronicadb.Report.Codice = codice_report;
		
		UPDATE BachecaElettronicadb.Report
		SET BachecaElettronicadb.Report.Riscosso_Amministratore = true
		WHERE BachecaElettronicadb.Report.Codice = codice_report;
		
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione report ---------------------------------------------  Impostare un livello di isolamento
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizza_report ;
CREATE PROCEDURE BachecaElettronicadb.visualizza_report (IN codice_report INT, IN ucc_username VARCHAR(45))
BEGIN
		if ((SELECT(count(Username)) FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username = ucc_username) <> 1) then
			signal sqlstate '45000' set message_text = "User not found";
		end if;
		
		if ((codice_report is not null) and (SELECT(count(Codice)) FROM BachecaElettronicadb.Report WHERE BachecaElettronicadb.Report.Codice = codice_report and BachecaElettronicadb.Report.UCC_Username = ucc_username) <> 1) then
			signal sqlstate '45015' set message_text = 'Report not found';
		end if;
		
		if (codice_report is null) then
			SELECT UCC_Username, ImportoTotale, NumeroAnnunci, NumeroCarta, Importo_UCC, Amministratore_Username, Riscosso_Amministratore, Importo_Amministratore
			FROM BachecaElettronicadb.Report
			WHERE BachecaElettronicadb.Report.UCC_Username = ucc_username;
		else
			SELECT UCC_Username, ImportoTotale, NumeroAnnunci, NumeroCarta, Importo_UCC, Amministratore_Username, Riscosso_Amministratore, Importo_Amministratore
			FROM BachecaElettronicadb.Report
			WHERE BachecaElettronicadb.Report.Codice = codice_report and BachecaElettronicadb.Report.UCC_Username = ucc_username;
		end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione informazioni utente ------------------------------- Impostare un livello di isolamento
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizza_Info_Utente ;
CREATE PROCEDURE BachecaElettronicadb.visualizza_Info_Utente (IN username VARCHAR(45))
BEGIN
	
	/* Nota
	 * L'idea è: Verifica che l'utente sia un UCC, altrimenti controlla se è un USCC.
	 * Se non sarà nè UCC e nè USCC allora l'utente non esiste
	 */	
	
	if ((SELECT(count(Username)) FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username=username) <> 1) then
		IF ((SELECT(count(Username)) FROM BachecaElettronicadb.USCC WHERE BachecaElettronicadb.USCC.Username=username) <> 1) THEN
			signal sqlstate '45000' set message_text = 'User not found';
		ELSE
			SELECT Username, Password, CF_Anagrafico AS 'Codice Fiscale'
			FROM BachecaElettronicadb.USCC
			WHERE BachecaElettronicadb.USCC.Username=username;
		end IF;
	else
		SELECT Codice, Username, Password, NumeroCarta AS 'Numero Carta', DataScadenza AS 'Scadenza', CVC, CF_Anagrafico AS 'Codice Fiscale'
		FROM BachecaElettronicadb.UCC
		WHERE BachecaElettronicadb.UCC.Username = username;
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
