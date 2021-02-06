-- ------------------------------------
USE `BachecaElettronicadb`
-- ------------------------------------

-- Avviso Nota Inserita ----------------------------------------------

DELIMITER //
DROP TRIGGER IF EXISTS BachecaElettronicadb.warn_new_note ;
CREATE DEFINER = CURRENT_USER TRIGGER BachecaElettronicadb.warn_new_note AFTER INSERT ON BachecaElettronicadb.Nota FOR EACH ROW
BEGIN
	declare username VARCHAR(45);
	declare loop_username INT DEFAULT 0;
	
	declare cur_username_ucc_user CURSOR FOR SELECT seguiti.UCC_Username FROM BachecaElettronicadb.Nota AS nota JOIN BachecaElettronicadb.`Seguito-UCC` AS seguiti ON nota.Annuncio_Codice = seguiti.Annuncio_Codice;
	declare cur_username_uscc_user CURSOR FOR SELECT seguiti.USCC_Username FROM BachecaElettronicadb.Nota AS nota JOIN BachecaElettronicadb.`Seguito-USCC` AS seguiti ON nota.Annuncio_Codice = seguiti.Annuncio_Codice;
	declare CONTINUE HANDLER FOR NOT FOUND SET loop_username = 1;
	
	
	/*NOTA
	 * L'idea del trigger è di soddisfare la regola aziendale di avvisare ogni utente
	 * che segue l'annuncio di una nuova nota. Viene eseguito un ciclo in modo da permettere
	 * di inserire per ogni utente il suo messaggio e sarà poi alla stored procedure la responsabilità
	 * di gestire i dati. Ho applicato una sorta di pattern GRASP in modo da avere che ogni utente 
	 * ha il suo messaggio e non un unico messaggio dove è condiviso per tutti, quindi da avere un low
	 * coupling tra gli utenti (ogni row contentente il messaggio dipende solo dall'utente indirizzato)
	 */
	
	-- Seleziona tutti gli utenti che seguono l'annuncio e inserisce una nuova entry in modo da notificare l'evento
	OPEN cur_username_ucc_user;
	insert_new_ucc_warning:   LOOP
							  FETCH cur_username_ucc_user INTO username;
							  
							  IF loop_username = 1 THEN
							  	LEAVE insert_new_ucc_warning;
							  end IF;
							  
							  INSERT INTO BachecaElettronicadb.Notifica(Codice, Tipo_Notifica, Username_Utente, Data, Messaggio)
							  VALUES (NEW.ID, 'Nota Annuncio', username, now(), 'Nuovo Inserimento'); 
				 
	end LOOP insert_new_ucc_warning;
	CLOSE cur_username_ucc_user;

	SET loop_username = 0;
	SET username = NULL;
	
	OPEN cur_username_uscc_user;
	insert_new_uscc_warning:  LOOP
							  FETCH cur_username_uscc_user INTO username;
							  
							  IF loop_username = 1 THEN
							  	LEAVE insert_new_uscc_warning;
							  end IF;
							  
							  INSERT INTO BachecaElettronicadb.Notifica(Codice, Tipo_Notifica, Username_Utente, Data, Messaggio)
							  VALUES (NEW.ID, 'Nota Annuncio', username, now(), 'Nuovo Inserimento'); 
				 
	end LOOP insert_new_uscc_warning;
	CLOSE cur_username_uscc_user;

	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Avviso Nota Eliminata ----------------------------------------------

DELIMITER //
DROP TRIGGER IF EXISTS BachecaElettronicadb.warn_note_deleted ;
CREATE DEFINER = CURRENT_USER TRIGGER BachecaElettronicadb.warn_note_deleted AFTER DELETE ON BachecaElettronicadb.Nota FOR EACH ROW
BEGIN
	declare username VARCHAR(45);
	declare loop_username INT DEFAULT 0;
	
	declare cur_username_ucc_user CURSOR FOR SELECT seguiti.UCC_Username FROM BachecaElettronicadb.Nota AS nota JOIN BachecaElettronicadb.`Seguito-UCC` AS seguiti ON nota.Annuncio_Codice = seguiti.Annuncio_Codice;
	declare cur_username_uscc_user CURSOR FOR SELECT seguiti.USCC_Username FROM BachecaElettronicadb.Nota AS nota JOIN BachecaElettronicadb.`Seguito-USCC` AS seguiti ON nota.Annuncio_Codice = seguiti.Annuncio_Codice;
	declare CONTINUE HANDLER FOR NOT FOUND SET loop_username = 1;
	
	
	/*NOTA
	 * L'idea del trigger è di soddisfare la regola aziendale di avvisare ogni utente
	 * che segue l'annuncio di una nota eliminata. Viene eseguito un ciclo in modo da permettere
	 * di inserire per ogni utente il suo messaggio e sarà poi alla stored procedure la responsabilità
	 * di gestire i dati. Ho applicato una sorta di pattern GRASP in modo da avere che ogni utente 
	 * ha il suo messaggio e non un unico messaggio dove è condiviso per tutti, quindi da avere un low
	 * coupling tra gli utenti (ogni row contentente il messaggio dipende solo dall'utente indirizzato)
	 */
	
	-- Seleziona tutti gli utenti che seguono l'annuncio e inserisce una nuova entry in modo da notificare l'evento
	OPEN cur_username_ucc_user;
	insert_new_ucc_warning:   LOOP
							  FETCH cur_username_ucc_user INTO username;
							  
							  IF loop_username = 1 THEN
							  	LEAVE insert_new_ucc_warning;
							  end IF;
							  
							  INSERT INTO BachecaElettronicadb.Notifica(Codice, Tipo_Notifica, Username_Utente, Data, Messaggio)
							  VALUES (OLD.ID, 'Nota Annuncio', username, now(), 'Nota Eliminata'); 
			 
	end LOOP insert_new_ucc_warning;
	CLOSE cur_username_ucc_user;

	SET loop_username = 0;
	SET username = NULL;
	
	OPEN cur_username_uscc_user;
	insert_new_uscc_warning:  LOOP
							  FETCH cur_username_uscc_user INTO username;
							  
							  IF loop_username = 1 THEN
							  	LEAVE insert_new_uscc_warning;
							  end IF;
							  
							  INSERT INTO BachecaElettronicadb.Notifica(Codice, Tipo_Notifica, Username_Utente, Data, Messaggio)
							  VALUES (OLD.ID, 'Nota Annuncio', username, now(), 'Nota Eliminata');
			 
	end LOOP insert_new_uscc_warning;
	CLOSE cur_username_uscc_user;

	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Avviso Commento Inserito ------------------------------------------

DELIMITER //
DROP TRIGGER IF EXISTS BachecaElettronicadb.warn_new_comment ;
CREATE DEFINER = CURRENT_USER TRIGGER BachecaElettronicadb.warn_new_comment AFTER INSERT ON BachecaElettronicadb.Commento FOR EACH ROW
BEGIN
	declare username VARCHAR(45);
	declare loop_username INT DEFAULT 0;
	
	declare cur_username_ucc_user CURSOR FOR SELECT seguiti.UCC_Username FROM BachecaElettronicadb.Commento AS commento JOIN BachecaElettronicadb.`Seguito-UCC` AS seguiti ON commento.Annuncio_Codice = seguiti.Annuncio_Codice;
	declare cur_username_uscc_user CURSOR FOR SELECT seguiti.USCC_Username FROM BachecaElettronicadb.Commento AS commento JOIN BachecaElettronicadb.`Seguito-USCC` AS seguiti ON commento.Annuncio_Codice = seguiti.Annuncio_Codice;
	declare CONTINUE HANDLER FOR NOT FOUND SET loop_username = 1;
	
	
	/*NOTA
	 * L'idea del trigger è di soddisfare la regola aziendale di avvisare ogni utente
	 * che segue l'annuncio di un nuovo commento. Viene eseguito un ciclo in modo da permettere
	 * di inserire per ogni utente il suo messaggio e sarà poi alla stored procedure la responsabilità
	 * di gestire i dati. Ho applicato una sorta di pattern GRASP in modo da avere che ogni utente 
	 * ha il suo messaggio e non un unico messaggio dove è condiviso per tutti, quindi da avere un low
	 * coupling tra gli utenti (ogni row contentente il messaggio dipende solo dall'utente indirizzato)
	 */
	
	-- Seleziona tutti gli utenti che seguono l'annuncio e inserisce una nuova entry in modo da notificare l'evento
	OPEN cur_username_ucc_user;
	insert_new_ucc_warning:  LOOP
						  FETCH cur_username_ucc_user INTO username;
						  
						  IF loop_username = 1 THEN
						  	LEAVE insert_new_ucc_warning;
						  end IF;
						  
						  INSERT INTO BachecaElettronicadb.Notifica(Codice, Tipo_Notifica, Username_Utente, Data, Messaggio)
						  VALUES (NEW.ID, 'Commento Annuncio', username, now(), 'Nuovo Commento'); 
			 
	end LOOP insert_new_ucc_warning;
	CLOSE cur_username_ucc_user;

	SET loop_username = 0;
	SET username = NULL;
	
	OPEN cur_username_uscc_user;
	insert_new_uscc_warning: LOOP
						  FETCH cur_username_uscc_user INTO username;
						  
						  IF loop_username = 1 THEN
						  	LEAVE insert_new_uscc_warning;
						  end IF;
						  
						  INSERT INTO BachecaElettronicadb.Notifica(Codice, Tipo_Notifica, Username_Utente, Data, Messaggio)
						  VALUES (NEW.ID, 'Commento Annuncio', username, now(), 'Nuovo Commento'); 
			 
	end LOOP insert_new_uscc_warning;
	CLOSE cur_username_uscc_user;

	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Avviso Commento Inserito ------------------------------------------

DELIMITER //
DROP TRIGGER IF EXISTS BachecaElettronicadb.warn_comment_deleted ;
CREATE DEFINER = CURRENT_USER TRIGGER BachecaElettronicadb.warn_comment_deleted AFTER DELETE ON BachecaElettronicadb.Commento FOR EACH ROW
BEGIN
	declare username VARCHAR(45);
	declare loop_username INT DEFAULT 0;
	
	declare cur_username_ucc_user CURSOR FOR SELECT seguiti.UCC_Username FROM BachecaElettronicadb.Commento AS commento JOIN BachecaElettronicadb.`Seguito-UCC` AS seguiti ON commento.Annuncio_Codice = seguiti.Annuncio_Codice;
	declare cur_username_uscc_user CURSOR FOR SELECT seguiti.USCC_Username FROM BachecaElettronicadb.Commento AS commento JOIN BachecaElettronicadb.`Seguito-USCC` AS seguiti ON commento.Annuncio_Codice = seguiti.Annuncio_Codice;
	declare CONTINUE HANDLER FOR NOT FOUND SET loop_username = 1;
	
	
	/*NOTA
	 * L'idea del trigger è di soddisfare la regola aziendale di avvisare ogni utente
	 * che segue l'annuncio che è stato eliminato il commento. Viene eseguito un ciclo in modo da permettere
	 * di inserire per ogni utente il suo messaggio e sarà poi alla stored procedure la responsabilità
	 * di gestire i dati. Ho applicato una sorta di pattern GRASP in modo da avere che ogni utente 
	 * ha il suo messaggio e non un unico messaggio dove è condiviso per tutti, quindi da avere un low
	 * coupling tra gli utenti (ogni row contentente il messaggio dipende solo dall'utente indirizzato)
	 */
	
	-- Seleziona tutti gli utenti che seguono l'annuncio e inserisce una nuova entry in modo da notificare l'evento
	OPEN cur_username_ucc_user;
	insert_new_ucc_warning:  LOOP
						  FETCH cur_username_ucc_user INTO username;
						  
						  IF loop_username = 1 THEN
						  	LEAVE insert_new_ucc_warning;
						  end IF;
						  
						  INSERT INTO BachecaElettronicadb.Notifica(Codice, Tipo_Notifica, Username_Utente, Data, Messaggio)
						  VALUES (OLD.ID, 'Commento Annuncio', username, now(), 'Commento Eliminato'); 
			 
	end LOOP insert_new_ucc_warning;
	CLOSE cur_username_ucc_user;

	SET loop_username = 0;
	SET username = NULL;
	
	OPEN cur_username_uscc_user;
	insert_new_uscc_warning: LOOP
						  FETCH cur_username_uscc_user INTO username;
						  
						  IF loop_username = 1 THEN
						  	LEAVE insert_new_uscc_warning;
						  end IF;
						  
						  INSERT INTO BachecaElettronicadb.Notifica(Codice, Tipo_Notifica, Username_Utente, Data, Messaggio)
						  VALUES (OLD.ID, 'Commento Annuncio', username, now(), 'Commento Eliminato'); 
			 
	end LOOP insert_new_uscc_warning;
	CLOSE cur_username_uscc_user;

	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Avviso Annuncio Modificato ----------------------------------------

DELIMITER //
DROP TRIGGER IF EXISTS BachecaElettronicadb.warn_ad_updated ;
CREATE DEFINER = CURRENT_USER TRIGGER BachecaElettronicadb.warn_ad_updated AFTER UPDATE ON BachecaElettronicadb.Annuncio FOR EACH ROW
BEGIN
	declare username VARCHAR(45) DEFAULT NULL;
	declare loop_username INT DEFAULT 0;
	
	declare cur_username_ucc_user CURSOR FOR SELECT seguiti.UCC_Username FROM BachecaElettronicadb.Annuncio AS annuncio JOIN BachecaElettronicadb.`Seguito-UCC` AS seguiti ON annuncio.Codice = seguiti.Annuncio_Codice;
	declare cur_username_uscc_user CURSOR FOR SELECT seguiti.USCC_Username FROM BachecaElettronicadb.Annuncio AS annuncio JOIN BachecaElettronicadb.`Seguito-USCC` AS seguiti ON annuncio.Codice = seguiti.Annuncio_Codice;
	declare CONTINUE HANDLER FOR NOT FOUND SET loop_username = 1;
	
	
	/*NOTA
	 * L'idea del trigger è di soddisfare la regola aziendale di avvisare ogni utente
	 * che segue l'annuncio che è stato modificato. Viene eseguito un ciclo in modo da permettere
	 * di inserire per ogni utente il suo messaggio e sarà poi alla stored procedure la responsabilità
	 * di gestire i dati. Ho applicato una sorta di pattern GRASP in modo da avere che ogni utente 
	 * ha il suo messaggio e non un unico messaggio dove è condiviso per tutti, quindi da avere un low
	 * coupling tra gli utenti (ogni row contentente il messaggio dipende solo dall'utente indirizzato)
	 */
		
	-- Seleziona tutti gli utenti che seguono l'annuncio e inserisce una nuova entry in modo da notificare l'evento
	OPEN cur_username_ucc_user;
	insert_new_ucc_warning: LOOP
							FETCH cur_username_ucc_user INTO username;
							  
							IF loop_username = 1 THEN
								LEAVE insert_new_ucc_warning;
							end IF;
						  
							INSERT INTO BachecaElettronicadb.Notifica(Codice, Tipo_Notifica, Username_Utente, Data, Messaggio)
							VALUES (NEW.Codice, 'Annuncio', username, now(), 'Annuncio Modificato'); 
				 
	end LOOP insert_new_ucc_warning;
	CLOSE cur_username_ucc_user;

	SET loop_username = 0;
	SET username = NULL;
	
	OPEN cur_username_uscc_user;
	insert_new_uscc_warning: LOOP
							 FETCH cur_username_uscc_user INTO username;
							  
							 IF loop_username = 1 THEN
							 	LEAVE insert_new_uscc_warning;
							 end IF;
							  
							 INSERT INTO BachecaElettronicadb.Notifica(Codice, Tipo_Notifica, Username_Utente, Data, Messaggio)
							 VALUES (NEW.Codice, 'Annuncio', username, now(), 'Annuncio Modificato'); 
	
	end LOOP insert_new_uscc_warning;
	CLOSE cur_username_uscc_user;

	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Controlla il Codice Fiscale ---------------------------------------

DELIMITER //
DROP TRIGGER IF EXISTS BachecaElettronicadb.check_tax_code ;
CREATE DEFINER = CURRENT_USER TRIGGER BachecaElettronicadb.check_tax_code BEFORE INSERT ON BachecaElettronicadb.InformazioneAnagrafica FOR EACH ROW
BEGIN
	
	-- Controlla che il formato del codice fiscale sia valido
	if (NEW.CF not regexp'^[A-Z]{6}[0-9]{2}[A-Z][0-9]{2}[A-Z][0-9]{3}[A-Z]$') then
		signal sqlstate '45019' set message_text = 'Incorrect Tax Code';
	end if;

END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Controlla Commento Inserimento ------------------------------------

DELIMITER //
DROP TRIGGER IF EXISTS BachecaElettronicadb.check_commento_insert ;
CREATE DEFINER = CURRENT_USER TRIGGER BachecaElettronicadb.check_commento_insert BEFORE INSERT ON BachecaElettronicadb.Commento FOR EACH ROW
BEGIN
	-- Controlla che l'annuncio sia attivo 
	if (not exists (SELECT Codice FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice = NEW.Annuncio_Codice AND BachecaElettronicadb.Annuncio.Stato='Attivo')) then
		signal sqlstate '45007' set message_text = 'Ad not active now';
	end if;

END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Controlla Commento Cancellazione ----------------------------------

DELIMITER //
DROP TRIGGER IF EXISTS BachecaElettronicadb.check_commento_delete ;
CREATE DEFINER = CURRENT_USER TRIGGER BachecaElettronicadb.check_commento_delete BEFORE DELETE ON BachecaElettronicadb.Commento FOR EACH ROW
BEGIN
	-- Controlla che l'annuncio sia attivo 
	if (not exists (SELECT Codice FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice = OLD.Annuncio_Codice AND BachecaElettronicadb.Annuncio.Stato='Attivo')) then
		signal sqlstate '45007' set message_text = 'Ad not active now';
	end if;

END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Controlla Annuncio in Seguito UCC ---------------------------------

DELIMITER //
DROP TRIGGER IF EXISTS BachecaElettronicadb.check_annuncio_seguito_ucc ;
CREATE DEFINER = CURRENT_USER TRIGGER BachecaElettronicadb.check_annuncio_seguito_ucc AFTER INSERT ON BachecaElettronicadb.`Seguito-UCC` FOR EACH ROW
BEGIN
	
	-- Controlla che l'annuncio esista e sia attivo 
	if (not exists (SELECT Codice FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice = NEW.Annuncio_Codice)) then
		signal sqlstate '45006' set message_text = 'Ad not found';
	end if;
	
	if (not exists (SELECT Codice FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice = NEW.Annuncio_Codice and BachecaElettronicadb.Annuncio.Stato = 'Attivo')) then
		signal sqlstate '45007' set message_text = 'Ad not active now';
	end if;

END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Controlla Annuncio in Seguito USCC ---------------------------------

DELIMITER //
DROP TRIGGER IF EXISTS BachecaElettronicadb.check_annuncio_seguito_uscc ;
CREATE DEFINER = CURRENT_USER TRIGGER BachecaElettronicadb.check_annuncio_seguito_uscc AFTER INSERT ON BachecaElettronicadb.`Seguito-USCC` FOR EACH ROW
BEGIN
	
	-- Controlla che l'annuncio esista e sia attivo 
	if (not exists (SELECT Codice FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice = NEW.Annuncio_Codice)) then
		signal sqlstate '45006' set message_text = 'Ad not found';
	end if;
	
	if (not exists (SELECT Codice FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice = NEW.Annuncio_Codice and BachecaElettronicadb.Annuncio.Stato = 'Attivo')) then
		signal sqlstate '45007' set message_text = 'Ad not active now';
	end if;

END//
DELIMITER ;
-- -------------------------------------------------------------------



