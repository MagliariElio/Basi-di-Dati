-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema BachecaElettronicadb
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `BachecaElettronicadb` ;

-- -----------------------------------------------------
-- Schema BachecaElettronicadb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `BachecaElettronicadb` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `BachecaElettronicadb` ;

-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Amministratore`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Amministratore` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Amministratore` (
  `Username` VARCHAR(45) NOT NULL,
  `Password` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Username`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE UNIQUE INDEX `Username_UNIQUE` ON `BachecaElettronicadb`.`Amministratore` (`Username` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Categoria`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Categoria` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Categoria` (
  `Nome` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`Nome`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE UNIQUE INDEX `Nome_UNIQUE` ON `BachecaElettronicadb`.`Categoria` (`Nome` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`InformazioneAnagrafica`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`InformazioneAnagrafica` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`InformazioneAnagrafica` (
  `CF` VARCHAR(16) NOT NULL,
  `Cognome` VARCHAR(20) NOT NULL,
  `Nome` VARCHAR(20) NOT NULL,
  `IndirizzoDiResidenza` VARCHAR(20) NOT NULL,
  `CAP` INT NOT NULL,
  `IndirizzoDiFatturazione` VARCHAR(20) NULL DEFAULT NULL,
  `TipoRecapitoPreferito` ENUM('email', 'cellulare', 'social', 'sms') NOT NULL,
  `RecapitoPreferito` VARCHAR(40) NOT NULL,
  PRIMARY KEY (`CF`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE UNIQUE INDEX `CF_UNIQUE` ON `BachecaElettronicadb`.`InformazioneAnagrafica` (`CF` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`StoricoConversazione`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`StoricoConversazione` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`StoricoConversazione` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`ID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE UNIQUE INDEX `ID_UNIQUE` ON `BachecaElettronicadb`.`StoricoConversazione` (`ID` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`UCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`UCC` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`UCC` (
  `Username` VARCHAR(45) NOT NULL,
  `Password` VARCHAR(45) NOT NULL,
  `NumeroCarta` VARCHAR(16) NOT NULL,
  `DataScadenza` DATE NOT NULL,
  `CVC` INT NOT NULL,
  `StoricoConversazione_ID` INT NOT NULL,
  `CF_Anagrafico` VARCHAR(16) NOT NULL,
  PRIMARY KEY (`Username`),
  CONSTRAINT `fk_UCC_InformazioneAnagrafica1`
    FOREIGN KEY (`CF_Anagrafico`)
    REFERENCES `BachecaElettronicadb`.`InformazioneAnagrafica` (`CF`),
  CONSTRAINT `fk_UCC_StoricoConversazione1`
    FOREIGN KEY (`StoricoConversazione_ID`)
    REFERENCES `BachecaElettronicadb`.`StoricoConversazione` (`ID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE UNIQUE INDEX `Username_UNIQUE` ON `BachecaElettronicadb`.`UCC` (`Username` ASC) VISIBLE;

CREATE INDEX `fk_UCC_StoricoConversazione1_idx` ON `BachecaElettronicadb`.`UCC` (`StoricoConversazione_ID` ASC) VISIBLE;

CREATE INDEX `fk_UCC_InformazioneAnagrafica1_idx` ON `BachecaElettronicadb`.`UCC` (`CF_Anagrafico` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Annuncio`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Annuncio` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Annuncio` (
  `Codice` INT NOT NULL AUTO_INCREMENT,
  `Stato` ENUM('Attivo', 'Venduto', 'Rimosso') NOT NULL,
  `Descrizione` VARCHAR(100) NOT NULL,
  `Importo` INT NOT NULL,
  `Foto` VARCHAR(9) NULL DEFAULT NULL,
  `Report_calcolato` TINYINT NOT NULL DEFAULT '0',
  `UCC_Username` VARCHAR(45) NOT NULL,
  `Categoria_Nome` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`Codice`),
  CONSTRAINT `fk_Annuncio_Categoria1`
    FOREIGN KEY (`Categoria_Nome`)
    REFERENCES `BachecaElettronicadb`.`Categoria` (`Nome`),
  CONSTRAINT `fk_Annuncio_UCC`
    FOREIGN KEY (`UCC_Username`)
    REFERENCES `BachecaElettronicadb`.`UCC` (`Username`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE UNIQUE INDEX `Codice_UNIQUE` ON `BachecaElettronicadb`.`Annuncio` (`Codice` ASC) VISIBLE;

CREATE INDEX `fk_Annuncio_UCC_idx` ON `BachecaElettronicadb`.`Annuncio` (`UCC_Username` ASC) VISIBLE;

CREATE INDEX `fk_Annuncio_Categoria1_idx` ON `BachecaElettronicadb`.`Annuncio` (`Categoria_Nome` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Commento`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Commento` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Commento` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `Testo` VARCHAR(45) NOT NULL,
  `Annuncio_Codice` INT NOT NULL,
  PRIMARY KEY (`ID`, `Annuncio_Codice`),
  CONSTRAINT `fk_Commento_Annuncio1`
    FOREIGN KEY (`Annuncio_Codice`)
    REFERENCES `BachecaElettronicadb`.`Annuncio` (`Codice`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE UNIQUE INDEX `Annuncio_Codice_UNIQUE` ON `BachecaElettronicadb`.`Commento` (`Annuncio_Codice` ASC) VISIBLE;

CREATE INDEX `fk_Commento_Annuncio1_idx` ON `BachecaElettronicadb`.`Commento` (`Annuncio_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`USCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`USCC` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`USCC` (
  `Username` VARCHAR(45) NOT NULL,
  `Password` VARCHAR(45) NOT NULL,
  `StoricoConversazione_ID` INT NOT NULL,
  `CF_Anagrafico` VARCHAR(16) NOT NULL,
  PRIMARY KEY (`Username`),
  CONSTRAINT `fk_USCC_InformazioneAnagrafica1`
    FOREIGN KEY (`CF_Anagrafico`)
    REFERENCES `BachecaElettronicadb`.`InformazioneAnagrafica` (`CF`),
  CONSTRAINT `fk_USCC_StoricoConversazione1`
    FOREIGN KEY (`StoricoConversazione_ID`)
    REFERENCES `BachecaElettronicadb`.`StoricoConversazione` (`ID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE UNIQUE INDEX `Username_UNIQUE` ON `BachecaElettronicadb`.`USCC` (`Username` ASC) VISIBLE;

CREATE INDEX `fk_USCC_StoricoConversazione1_idx` ON `BachecaElettronicadb`.`USCC` (`StoricoConversazione_ID` ASC) VISIBLE;

CREATE INDEX `fk_USCC_InformazioneAnagrafica1_idx` ON `BachecaElettronicadb`.`USCC` (`CF_Anagrafico` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Conversazione`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Conversazione` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Conversazione` (
  `Codice` INT NOT NULL AUTO_INCREMENT,
  `UCC_Username_1` VARCHAR(45) NOT NULL,
  `UCC_Username_2` VARCHAR(45) NULL DEFAULT NULL,
  `USCC_Username` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`Codice`),
  CONSTRAINT `fk_Conversazione_UCC1`
    FOREIGN KEY (`UCC_Username_1`)
    REFERENCES `BachecaElettronicadb`.`UCC` (`Username`),
  CONSTRAINT `fk_Conversazione_UCC2`
    FOREIGN KEY (`UCC_Username_2`)
    REFERENCES `BachecaElettronicadb`.`UCC` (`Username`),
  CONSTRAINT `fk_Conversazione_USCC1`
    FOREIGN KEY (`USCC_Username`)
    REFERENCES `BachecaElettronicadb`.`USCC` (`Username`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE UNIQUE INDEX `Codice_UNIQUE` ON `BachecaElettronicadb`.`Conversazione` (`Codice` ASC) VISIBLE;

CREATE INDEX `fk_Conversazione_UCC1_idx` ON `BachecaElettronicadb`.`Conversazione` (`UCC_Username_1` ASC) VISIBLE;

CREATE INDEX `fk_Conversazione_USCC1_idx` ON `BachecaElettronicadb`.`Conversazione` (`USCC_Username` ASC) VISIBLE;

CREATE INDEX `fk_Conversazione_UCC2_idx` ON `BachecaElettronicadb`.`Conversazione` (`UCC_Username_2` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`ConversazioneCodice`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`ConversazioneCodice` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`ConversazioneCodice` (
  `CodiceConv` INT NOT NULL,
  `StoricoConversazione_ID` INT NOT NULL,
  PRIMARY KEY (`StoricoConversazione_ID`, `CodiceConv`),
  CONSTRAINT `fk_ConversazioneCodice_StoricoConversazione1`
    FOREIGN KEY (`StoricoConversazione_ID`)
    REFERENCES `BachecaElettronicadb`.`StoricoConversazione` (`ID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_ConversazioneCodice_StoricoConversazione1_idx` ON `BachecaElettronicadb`.`ConversazioneCodice` (`StoricoConversazione_ID` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Messaggio`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Messaggio` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Messaggio` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `Data` DATETIME NOT NULL,
  `Conversazione_Codice` INT NOT NULL,
  `Testo` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`ID`, `Conversazione_Codice`),
  CONSTRAINT `fk_Messaggio_Conversazione1`
    FOREIGN KEY (`Conversazione_Codice`)
    REFERENCES `BachecaElettronicadb`.`Conversazione` (`Codice`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_Messaggio_Conversazione1_idx` ON `BachecaElettronicadb`.`Messaggio` (`Conversazione_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Nota`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Nota` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Nota` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `Testo` VARCHAR(45) NOT NULL,
  `Annuncio_Codice` INT NOT NULL,
  PRIMARY KEY (`ID`, `Annuncio_Codice`),
  CONSTRAINT `fk_Nota_Annuncio1`
    FOREIGN KEY (`Annuncio_Codice`)
    REFERENCES `BachecaElettronicadb`.`Annuncio` (`Codice`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE UNIQUE INDEX `Annuncio_Codice_UNIQUE` ON `BachecaElettronicadb`.`Nota` (`Annuncio_Codice` ASC) VISIBLE;

CREATE INDEX `fk_Nota_Annuncio1_idx` ON `BachecaElettronicadb`.`Nota` (`Annuncio_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Notifica`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Notifica` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Notifica` (
  `Codice_Notifica` INT NOT NULL AUTO_INCREMENT,
  `Codice` INT NOT NULL,
  `Tipo_Notifica` VARCHAR(45) NOT NULL,
  `Username_Utente` VARCHAR(45) NOT NULL,
  `Data` DATETIME NOT NULL,
  `Messaggio` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Codice_Notifica`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE UNIQUE INDEX `Codice_Notifica_UNIQUE` ON `BachecaElettronicadb`.`Notifica` (`Codice_Notifica` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`RecapitoNonPreferito`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`RecapitoNonPreferito` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`RecapitoNonPreferito` (
  `Recapito` VARCHAR(40) NOT NULL,
  `Tipo` ENUM('email', 'cellulare', 'social', 'sms') NOT NULL,
  `InformazioneAnagrafica_CF` VARCHAR(16) NOT NULL,
  PRIMARY KEY (`InformazioneAnagrafica_CF`, `Recapito`),
  CONSTRAINT `fk_RecapitoNonPreferito_InformazioneAnagrafica1`
    FOREIGN KEY (`InformazioneAnagrafica_CF`)
    REFERENCES `BachecaElettronicadb`.`InformazioneAnagrafica` (`CF`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_RecapitoNonPreferito_InformazioneAnagrafica1_idx` ON `BachecaElettronicadb`.`RecapitoNonPreferito` (`InformazioneAnagrafica_CF` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Report`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Report` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Report` (
  `Codice` INT NOT NULL AUTO_INCREMENT,
  `UCC_Username` VARCHAR(45) NOT NULL,
  `ImportoTotale` INT NOT NULL,
  `NumeroAnnunci` INT NOT NULL,
  `NumeroCarta` VARCHAR(16) NOT NULL,
  `Data` DATE NOT NULL,
  `Amministratore_Username` VARCHAR(45) NOT NULL,
  `Riscosso_Amministratore` TINYINT NOT NULL DEFAULT '0',
  `Importo_Amministratore` INT NOT NULL DEFAULT '0',
  `Importo_UCC` INT NOT NULL DEFAULT '0',
  PRIMARY KEY (`Codice`),
  CONSTRAINT `fk_Report_UCC1`
    FOREIGN KEY (`UCC_Username`)
    REFERENCES `BachecaElettronicadb`.`UCC` (`Username`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE UNIQUE INDEX `Codice_UNIQUE` ON `BachecaElettronicadb`.`Report` (`Codice` ASC) VISIBLE;

CREATE INDEX `fk_Report_UCC1_idx` ON `BachecaElettronicadb`.`Report` (`UCC_Username` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Seguito-UCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Seguito-UCC` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Seguito-UCC` (
  `Annuncio_Codice` INT NOT NULL,
  `UCC_Username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Annuncio_Codice`, `UCC_Username`),
  CONSTRAINT `fk_Seguito-UCC_Annuncio1`
    FOREIGN KEY (`Annuncio_Codice`)
    REFERENCES `BachecaElettronicadb`.`Annuncio` (`Codice`),
  CONSTRAINT `fk_Seguito-UCC_UCC1`
    FOREIGN KEY (`UCC_Username`)
    REFERENCES `BachecaElettronicadb`.`UCC` (`Username`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_Seguito-UCC_UCC1_idx` ON `BachecaElettronicadb`.`Seguito-UCC` (`UCC_Username` ASC) VISIBLE;

CREATE INDEX `fk_Seguito-UCC_Annuncio1_idx` ON `BachecaElettronicadb`.`Seguito-UCC` (`Annuncio_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Seguito-USCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Seguito-USCC` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Seguito-USCC` (
  `Annuncio_Codice` INT NOT NULL,
  `USCC_Username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Annuncio_Codice`, `USCC_Username`),
  CONSTRAINT `fk_Seguito-USCC_Annuncio1`
    FOREIGN KEY (`Annuncio_Codice`)
    REFERENCES `BachecaElettronicadb`.`Annuncio` (`Codice`),
  CONSTRAINT `fk_Seguito-USCC_USCC1`
    FOREIGN KEY (`USCC_Username`)
    REFERENCES `BachecaElettronicadb`.`USCC` (`Username`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_Seguito-USCC_Annuncio1_idx` ON `BachecaElettronicadb`.`Seguito-USCC` (`Annuncio_Codice` ASC) VISIBLE;

CREATE INDEX `fk_Seguito-USCC_USCC1_idx` ON `BachecaElettronicadb`.`Seguito-USCC` (`USCC_Username` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Tracciato`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Tracciato` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Tracciato` (
  `Conversazione_Codice` INT NOT NULL,
  `StoricoConversazione_ID` INT NOT NULL,
  PRIMARY KEY (`Conversazione_Codice`, `StoricoConversazione_ID`),
  CONSTRAINT `fk_Tracciato_Conversazione1`
    FOREIGN KEY (`Conversazione_Codice`)
    REFERENCES `BachecaElettronicadb`.`Conversazione` (`Codice`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_Tracciato_StoricoConversazione1`
    FOREIGN KEY (`StoricoConversazione_ID`)
    REFERENCES `BachecaElettronicadb`.`StoricoConversazione` (`ID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_Tracciato_StoricoConversazione1_idx` ON `BachecaElettronicadb`.`Tracciato` (`StoricoConversazione_ID` ASC) VISIBLE;

CREATE INDEX `fk_Tracciato_Conversazione1_idx` ON `BachecaElettronicadb`.`Tracciato` (`Conversazione_Codice` ASC) VISIBLE;


-- Stored Procedure

-- Registrazione di un utente UCC-------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.registra_utente_UCC ;
CREATE PROCEDURE BachecaElettronicadb.registra_utente_UCC (IN username VARCHAR(45), IN password VARCHAR(45), IN numeroCarta VARCHAR(16), IN dataScadenza DATE, IN cvc INT, IN cf_anagrafico VARCHAR(16), IN cognome VARCHAR(20), IN nome VARCHAR(20), IN indirizzoDiResidenza VARCHAR(20), IN cap INT, IN indirizzoDiFatturazione VARCHAR(20), IN tipoRecapitoPreferito VARCHAR(20), IN recapitoPreferito VARCHAR(40), IN tipoRecapitoNonPreferito VARCHAR(20), IN recapitoNonPreferito VARCHAR(40))
BEGIN
	declare idStorico INT;
		
	call BachecaElettronicadb.inserisci_Storico(idStorico);
	call BachecaElettronicadb.inserimentoInfoAnagrafiche(cf_anagrafico, cognome, nome, indirizzoDiResidenza, cap, indirizzoDiFatturazione, tipoRecapitoPreferito, recapitoPreferito);
	call BachecaElettronicadb.modifica_RecapitoNonPreferito(tipoRecapitoNonPreferito, recapitoNonPreferito, cf_anagrafico, null);		
	
	INSERT INTO BachecaElettronicadb.UCC (Username, Password, NumeroCarta, DataScadenza, CVC, StoricoConversazione_ID, CF_Anagrafico)
	VALUES(username, md5(password), numeroCarta, dataScadenza, cvc, idStorico, cf_anagrafico);
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento di uno Storico Conversazioni --------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.inserisci_Storico ;
CREATE PROCEDURE BachecaElettronicadb.inserisci_Storico (OUT id INT)
BEGIN
	declare exit handler for sqlexception 
	begin 
		ROLLBACK; -- rollback any changes made in the transaction 
		RESIGNAL; -- raise again the sql exceptionto the caller
	end;
	
	/*NOTA
	 * Ho scelto questo livello perchè voglio che non ci siano letture 
	 * sporche sul valore dell'ID in caso concorrenza su questa procedura.
	 * Il trucco è quello di usare il lock preso dalla write, che verrà restituito al commit. 
	 */
	
	SET transaction isolation level read committed;
	start transaction;
		INSERT INTO BachecaElettronicadb.StoricoConversazione (ID) VALUES(NULL);
		SET id = LAST_INSERT_ID();
	commit;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento o Rimozione Recapito non preferito -------------------- 

DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.modifica_RecapitoNonPreferito ;
CREATE PROCEDURE BachecaElettronicadb.modifica_RecapitoNonPreferito (IN tipo VARCHAR(20), IN recapito VARCHAR(40), IN cf_anagrafico VARCHAR(16), IN rimuovi INT)
BEGIN

	if (not exists (SELECT CF FROM BachecaElettronicadb.InformazioneAnagrafica WHERE BachecaElettronicadb.InformazioneAnagrafica.CF = cf_anagrafico))  then
		signal sqlstate '45004' set message_text = "Tax code not found";
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
	
	declare exit handler for sqlexception 
	begin 
		ROLLBACK; -- rollback any changes made in the transaction 
		RESIGNAL; -- raise again the sql exceptionto the caller
	end; 
	
	/*NOTA
	 * Ho scelto questo livello per evitare letture inconsistenti sugli stessi dati
	 */
	
	SET transaction read only;	
	SET transaction isolation level repeatable read;
	start transaction;
	
		if (not exists (SELECT CF FROM BachecaElettronicadb.InformazioneAnagrafica WHERE BachecaElettronicadb.InformazioneAnagrafica.CF = cf_anagrafico)) then
			signal sqlstate '45004' set message_text = 'Tax code not found';
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
	
	commit;
		
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Registrazione di un utente USCC -----------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.registra_utente_USCC ;
CREATE PROCEDURE BachecaElettronicadb.registra_utente_USCC (IN username VARCHAR(45), IN password VARCHAR(45), IN cf_anagrafico VARCHAR(16), IN cognome VARCHAR(20), IN nome VARCHAR(20), IN indirizzoDiResidenza VARCHAR(20), IN cap INT, IN indirizzoDiFatturazione VARCHAR(20), IN tipoRecapitoPreferito VARCHAR(20), IN recapitoPreferito VARCHAR(40), IN tipoRecapitoNonPreferito VARCHAR(20), IN recapitoNonPreferito VARCHAR(40))
BEGIN
	declare idStorico INT;
	
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

-- Visualizzazione nuove notifiche -----------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizza_notifiche ;
CREATE PROCEDURE BachecaElettronicadb.visualizza_notifiche (IN username VARCHAR(45))
BEGIN
	
	declare exit handler for sqlexception 
	begin 
		ROLLBACK; -- rollback any changes made in the transaction 
		RESIGNAL; -- raise again the sql exceptionto the caller
	end; 
	
	/*NOTA
	 * Ho scelto questo livello per evitare le letture sporche
	 */
	
	SET transaction isolation level read committed;
	start transaction;
	
		/*NOTA
		 * Questa stored procedure è utilizzata per mostrare all'utente, che lo ha chiamato, 
		 * le sue nuove notifiche. Applica un concetto simile ad una coda di messaggi
		 * dove è possibile fare un'estrazione dei messaggi richiesti ed infine eliminarli per non 
		 * essere visualizzati di nuovo. È correlata ai trigger precedentemente descritti.
		 */
		
		-- Mostra le nuove notifiche rimaste in coda 
		SELECT Codice, Tipo_Notifica, Data, Messaggio
		FROM BachecaElettronicadb.Notifica
		WHERE BachecaElettronicadb.Notifica.Username_Utente = username
		ORDER BY Data ASC;
		
		-- Elimina le notifiche visualizzate
		DELETE FROM BachecaElettronicadb.Notifica
		WHERE BachecaElettronicadb.Notifica.Username_Utente = username;
		
	commit;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Modifica delle Informazioni Anagrafiche ---------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.modificaInfoAnagrafiche ;
CREATE PROCEDURE BachecaElettronicadb.modificaInfoAnagrafiche (IN cf VARCHAR(16), IN cognome VARCHAR(20), IN nome VARCHAR(20), IN indirizzoDiResidenza VARCHAR(20), IN cap INT, IN indirizzoDiFatturazione VARCHAR(20), IN tipoRecapitoPreferito VARCHAR(20), IN recapitoPreferito VARCHAR(40))
BEGIN
			
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

-- Visualizzazione delle Informazioni Anagrafiche -------------------- 
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaInfoAnagrafiche ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaInfoAnagrafiche (IN cf VARCHAR(16), IN check_owner INT, IN username VARCHAR(45))
BEGIN
	
	declare exit handler for sqlexception 
	begin 
		ROLLBACK; -- rollback any changes made in the transaction 
		RESIGNAL; -- raise again the sql exceptionto the caller
	end; 
	
	/*NOTA
	 * Ho scelto questo livello per evitare le letture sporche
	 */
	
	SET transaction read only;
	SET transaction isolation level read committed;
	start transaction;
		
		if ((check_owner IS NOT NULL) AND (username IS NOT NULL)) then
			IF (not exists (SELECT Username FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.CF_Anagrafico = cf AND BachecaElettronicadb.UCC.Username = username)) then
				if (not exists (SELECT Username FROM BachecaElettronicadb.USCC WHERE BachecaElettronicadb.USCC.CF_Anagrafico = cf AND BachecaElettronicadb.USCC.Username = username)) then	
					signal sqlstate '45009' set message_text = 'The Tax code is not yours';
				end if;
			end IF;
		end if;
		
		SELECT CF AS 'Codice Fiscale', Cognome, Nome, IndirizzoDiResidenza AS 'Indirizzo di Residenza', CAP, IndirizzoDiFatturazione AS 'Indirizzo di Fatturazione', tipoRecapitoPreferito AS 'Tipo Recapito', RecapitoPreferito AS 'Recapito Preferito'
		FROM BachecaElettronicadb.InformazioneAnagrafica
		WHERE BachecaElettronicadb.InformazioneAnagrafica.CF = cf;
		
	commit;

END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento di una nuova categoria --------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.inserimentoNuovaCategoria ;
CREATE PROCEDURE BachecaElettronicadb.inserimentoNuovaCategoria (IN nome VARCHAR(20))
BEGIN
	
	INSERT INTO BachecaElettronicadb.Categoria (Nome) VALUES(nome);

END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione categoria -----------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaCategoria ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaCategoria ()
BEGIN
	declare exit handler for sqlexception 
	begin 
		ROLLBACK; -- rollback any changes made in the transaction 
		RESIGNAL; -- raise again the sql exceptionto the caller
	end; 
	
	/*NOTA
	 * Ho scelto questo livello per evitare le letture sporche 
	 * in caso di inserimento di una nuova categoria ma non andato a buon fine
	 */
	
	SET transaction read only;
	SET transaction isolation level read committed;
	start transaction;
	
		SELECT Nome
		FROM BachecaElettronicadb.Categoria;
	
	commit;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento di un nuovo annuncio ----------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.inserimentoNuovoAnnuncio ;
CREATE PROCEDURE BachecaElettronicadb.inserimentoNuovoAnnuncio (IN descrizione VARCHAR(100), IN importo INT, IN foto VARCHAR(9), IN ucc_username VARCHAR(45), IN categoria_nome VARCHAR(20))
BEGIN
	
	if (foto IS NULL) then
		INSERT INTO BachecaElettronicadb.Annuncio (Codice, Stato, Descrizione, Importo, UCC_Username, Categoria_Nome) VALUES(NULL, 'Attivo', descrizione, importo, ucc_username, categoria_nome);
	else
		INSERT INTO BachecaElettronicadb.Annuncio (Codice, Stato, Descrizione, Importo, Foto, UCC_Username, Categoria_Nome) VALUES(NULL, 'Attivo', descrizione, importo, 'Presente', ucc_username, categoria_nome);
	end if;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento o Rimozione di una foto in annuncio -------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.modificaFotoAnnuncio ;
CREATE PROCEDURE BachecaElettronicadb.modificaFotoAnnuncio (IN codice INT, IN username VARCHAR(45), IN foto VARCHAR(9))
BEGIN
	declare exit handler for sqlexception 
	begin 
		ROLLBACK; -- rollback any changes made in the transaction 
		RESIGNAL; -- raise again the sql exceptionto the caller
	end; 
	
	/*NOTA
	 * Ho scelto questo livello per evitare le letture inconsistenti
	 * e per restituire il lock al commit
	 */
	
	SET transaction isolation level repeatable read;
	start transaction;
	
		if (not exists (SELECT Codice FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice = codice)) then
			signal sqlstate '45006' set  message_text = 'Ad not found';
		end if;	
		
		if (not exists (SELECT Codice FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice = codice AND BachecaElettronicadb.Annuncio.UCC_Username = username)) then
			signal sqlstate '45008' set  message_text = 'You are not the owner of the ad';
		end if;
		
		if (not exists (SELECT Codice FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice = codice AND BachecaElettronicadb.Annuncio.Stato = 'Attivo')) then
			signal sqlstate '45007' set  message_text = 'Ad not active now';
		end if;
		
		if (foto is not NULL) then
			UPDATE BachecaElettronicadb.Annuncio
			SET BachecaElettronicadb.Annuncio.Foto = 'Presente'
			WHERE BachecaElettronicadb.Annuncio.Codice = codice;
		else
			UPDATE BachecaElettronicadb.Annuncio
			SET BachecaElettronicadb.Annuncio.Foto = NULL
			WHERE BachecaElettronicadb.Annuncio.Codice = codice;
		end if;
	commit;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizza annuncio -----------------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaAnnuncio ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaAnnuncio (IN annuncio_codice INT, IN username VARCHAR(45), IN check_owner INT)
BEGIN
	declare exit handler for sqlexception 
	begin 
		ROLLBACK; -- rollback any changes made in the transaction 
		RESIGNAL; -- raise again the sql exceptionto the caller
	end; 
	
	/*NOTA
	 * Ho scelto questo livello per evitare le letture inconsistenti sullo stesso dato
	 */
	
	SET transaction read only;
	SET transaction isolation level repeatable read;
	start transaction;
	
		if ((username IS NOT NULL) AND not exists (SELECT Username FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username=username)) then
			signal sqlstate '45000' set message_text = 'User not found';
		end if;
		
		if ((annuncio_codice IS NOT NULL) AND not exists (SELECT Codice FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=annuncio_codice)) then
			signal sqlstate '45006' set message_text = 'Ad not found';
		end if;
		
		if ((check_owner = 1) AND (username IS NOT NULL) AND (annuncio_codice IS NOT NULL)) then
			IF (not exists (SELECT Codice FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=annuncio_codice AND BachecaElettronicadb.Annuncio.UCC_Username=username)) then
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
		
	commit;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento o Rimozione commento ----------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.modificaCommento ;
CREATE PROCEDURE BachecaElettronicadb.modificaCommento (IN testo VARCHAR(45), IN annuncio_codice INT, IN ID_rimozione_commento INT)
BEGIN
		
	if (ID_rimozione_commento is null) then	
		INSERT INTO BachecaElettronicadb.Commento (Testo, Annuncio_Codice) VALUES(testo, annuncio_codice);
	else
		DELETE FROM BachecaElettronicadb.Commento
		WHERE BachecaElettronicadb.Commento.ID = ID_rimozione_commento;
	end if;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione commento ------------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaCommento ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaCommento (IN annuncio_codice INT)
BEGIN
	declare exit handler for sqlexception 
	begin 
		ROLLBACK; -- rollback any changes made in the transaction 
		RESIGNAL; -- raise again the sql exceptionto the caller
	end; 
	
	/*NOTA
	 * Ho scelto questo livello per evitare le letture sporche
	 * in caso di inserimento di un nuovo commento ma ancora non committato
	 */
	
	SET transaction read only;
	SET transaction isolation level read committed;
	start transaction;
		
		if (not exists (SELECT Codice FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=annuncio_codice AND BachecaElettronicadb.Annuncio.Stato='Attivo')) then
			 signal sqlstate '45007' set message_text = 'Ad not active now';
		end if;
		
		SELECT ID, Testo, Annuncio_codice AS "Codice dell'annuncio"
		FROM BachecaElettronicadb.Commento
		WHERE BachecaElettronicadb.Commento.Annuncio_Codice = annuncio_codice;
		
	commit;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento Conversazione -----------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.inserimentoConversazione ;
CREATE PROCEDURE BachecaElettronicadb.inserimentoConversazione (OUT id_conversazione INT, IN ucc_username_1 VARCHAR(45), ucc_username_2 VARCHAR(45), IN uscc_username VARCHAR(45))
BEGIN
	declare exit handler for sqlexception 
	begin 
		ROLLBACK; -- rollback any changes made in the transaction 
		RESIGNAL; -- raise again the sql exceptionto the caller
	end; 
	
	/*NOTA
	 * Ho scelto questo livello per evitare concorrenza sull'ID, usando il lock
	 * ottenuto dal write che sarà poi rilasciato al commit.
	 */
	
	SET transaction isolation level read committed;
	start transaction;
		
		INSERT INTO BachecaElettronicadb.Conversazione (Codice, UCC_Username_1, UCC_Username_2, USCC_Username) VALUES(NULL, ucc_username_1, ucc_username_2, uscc_username);
		SET id_conversazione = LAST_INSERT_ID();
		
	commit;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Seleziona Storico UCC per la stored procedure ---------------------
DELIMITER //
DROP FUNCTION IF EXISTS BachecaElettronicadb.seleziona_Storico_UCC ;
CREATE FUNCTION BachecaElettronicadb.seleziona_Storico_UCC (username VARCHAR(45)) RETURNS INT DETERMINISTIC
BEGIN
	declare storico_id_ucc INT;
	
	-- Prende il codice dello storico dell'utente 
	SELECT StoricoConversazione_ID INTO storico_id_ucc
	FROM BachecaElettronicadb.UCC
	WHERE BachecaElettronicadb.UCC.Username = username;
	
	RETURN storico_id_ucc;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Seleziona Storico USCC per la stored procedure --------------------
DELIMITER //
DROP FUNCTION IF EXISTS BachecaElettronicadb.seleziona_Storico_USCC ;
CREATE FUNCTION BachecaElettronicadb.seleziona_Storico_USCC (username VARCHAR(45)) RETURNS INT DETERMINISTIC
BEGIN
	
	declare storico_id_uscc INT;
	
	-- Prende il codice dello storico dell'utente 
	SELECT StoricoConversazione_ID INTO storico_id_uscc
	FROM BachecaElettronicadb.USCC
	WHERE BachecaElettronicadb.USCC.Username = username;
	
	RETURN storico_id_uscc;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Tracciamento Conversazioni ----------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.traccia_Conversazione ;
CREATE PROCEDURE BachecaElettronicadb.traccia_Conversazione (IN conversazione_codice INT, IN sender_ucc_username VARCHAR(45), IN receiver_ucc_username VARCHAR(45), IN receiver_uscc_username VARCHAR(45))
BEGIN
	
	declare storico_id_ucc, storico_id_uscc INT;
	
	if ((sender_ucc_username is not null) and (receiver_uscc_username is not null)) then	
		SET storico_id_ucc = seleziona_Storico_UCC(sender_ucc_username);
		SET storico_id_uscc = seleziona_Storico_USCC(receiver_uscc_username);
		
		INSERT INTO BachecaElettronicadb.Tracciato (Conversazione_Codice, StoricoConversazione_ID) VALUES(conversazione_codice, storico_id_ucc);	-- traccia lo storico di UCC
		INSERT INTO BachecaElettronicadb.Tracciato (Conversazione_Codice, StoricoConversazione_ID) VALUES(conversazione_codice, storico_id_uscc);	-- traccia lo storico di USCC
		INSERT INTO BachecaElettronicadb.ConversazioneCodice (CodiceConv, StoricoConversazione_ID) VALUES(conversazione_codice, storico_id_ucc); 	-- inserisce il nuovo codice della conversazione nello storico di UCC
		INSERT INTO BachecaElettronicadb.ConversazioneCodice (CodiceConv, StoricoConversazione_ID) VALUES(conversazione_codice, storico_id_uscc); 	-- inserisce il nuovo codice della conversazione nello storico di USCC
	
	elseif ((sender_ucc_username is not null) and (receiver_ucc_username is not null)) then	
		SET storico_id_ucc = seleziona_Storico_UCC(sender_ucc_username);
		SET storico_id_uscc = seleziona_Storico_UCC(receiver_ucc_username);
		
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

-- Controlla il tipo di utente ---------------------------------------
DELIMITER //
DROP FUNCTION IF EXISTS BachecaElettronicadb.controlla_utente ;
CREATE FUNCTION BachecaElettronicadb.controlla_utente (username VARCHAR(45)) RETURNS VARCHAR(4) DETERMINISTIC
BEGIN
	
	if (exists (SELECT Username FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username = username)) then
		RETURN 'UCC';
		
	elseif (exists (SELECT Username FROM BachecaElettronicadb.USCC WHERE BachecaElettronicadb.USCC.Username = username)) then	
		RETURN 'USCC';
		
	else
		signal sqlstate '45000' set message_text = 'User not found';		-- utente non trovato nel database
	end if;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Invio messaggio da parte utente -----------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.invioMessaggio ;
CREATE PROCEDURE BachecaElettronicadb.invioMessaggio (IN sender_username VARCHAR(45), IN receiver_username VARCHAR(45), IN testo VARCHAR(100))
BEGIN
	declare conversazione_codice INT DEFAULT NULL;
	declare type_user_sender VARCHAR(4);
	declare type_user_receiver VARCHAR(4);
	declare sender_is_ucc, sender_is_uscc, receiver_is_ucc, receiver_is_uscc INT;
	
	declare exit handler for sqlexception 
	BEGIN 
		rollback; -- rollback any changes made in the transaction 
		resignal; -- raise again the sql exceptionto the caller
	END; 
	
	/*NOTA
	 * Ho scelto questo livello per evitare letture
	 * inconsistenti sull'utente nel database, vista la necessita di fare
	 * più di una lettura sullo stesso dato
	 */
	
	SET transaction isolation level repeatable read;
	start transaction;
		
		if (sender_username = receiver_username) then
			signal sqlstate '45010' set message_text = 'Error parameters';
		end if;
		
		SET sender_is_ucc = 0;
		SET sender_is_uscc = 0;
		SET receiver_is_ucc = 0;
		SET receiver_is_uscc = 0;
	
		SET type_user_sender = controlla_utente(sender_username);			-- Restituisce la natura dell'utente che invia il messaggio
		SET type_user_receiver = controlla_utente(receiver_username);		-- Restituisce la natura dell'utente che riceve il messaggio

		-- Seleziona gli username dei due utenti 
		if (type_user_sender = 'UCC') then
			SET sender_is_ucc = 1;
			
			SELECT Username INTO sender_username
			FROM BachecaElettronicadb.UCC 
			WHERE BachecaElettronicadb.UCC.Username = sender_username;
		else
			SET sender_is_uscc = 1;
			
			SELECT Username INTO sender_username
			FROM BachecaElettronicadb.USCC 
			WHERE BachecaElettronicadb.USCC.Username = sender_username;
		end if;
			
		if (type_user_receiver = 'UCC') then
			SET receiver_is_ucc = 1;
			
			SELECT Username INTO receiver_username
			FROM BachecaElettronicadb.UCC 
			WHERE BachecaElettronicadb.UCC.Username = receiver_username;
		else
			SET receiver_is_uscc = 1;
			
			SELECT Username INTO receiver_username
			FROM BachecaElettronicadb.USCC 
			WHERE BachecaElettronicadb.USCC.Username = receiver_username;
		end if;
			
		if ((sender_is_uscc = 1) AND (receiver_is_uscc = 1)) then
			signal sqlstate '45013' set message_text = 'You cannot write to another USCC user';
		end if;	
		
		commit; -- Inserisco un commit onde evitare un dead lock con le altre query e per non ottenere l'errore: Error 1568 (25001)
		SET conversazione_codice = controllo_conversazione(NULL, sender_username, receiver_username);  -- cerca il codice della conversazione 
		
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
		
		/* NOTA
		 * Non è presente la condizione (sender_is_uscc = 1) and (receiver_is_uscc = 1))
		 * perchè non è possibile che due utenti USCC si scrivano
		 */
		
		if (conversazione_codice is not null) then
			INSERT INTO BachecaElettronicadb.Messaggio (Data, Conversazione_Codice, Testo)		-- conversazione esistente, allora inserisco il messaggio
			VALUES (now(), conversazione_codice, testo);
		end if;
		
	commit;
		
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Controllo Privacy e Ricerca conversazione -------------------------
DELIMITER //
DROP FUNCTION IF EXISTS BachecaElettronicadb.controllo_conversazione ;
CREATE FUNCTION BachecaElettronicadb.controllo_conversazione (id_conversation_check INT, sender_username VARCHAR(45), receiver_username VARCHAR(45)) RETURNS INT DETERMINISTIC
BEGIN
	declare conversazione_codice_controllo INT DEFAULT NULL;
		
	-- Ricerca del codice della conversazione, basando la ricerca sulla combinazione degli username
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
	
	RETURN conversazione_codice_controllo;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizza messaggio ----------------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaMessaggio ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaMessaggio (IN id_conversation INT, sender_username VARCHAR(45), IN receiver_username VARCHAR(45))
BEGIN
	declare conversazione_codice INT DEFAULT NULL;
	declare exit handler for sqlexception 
	begin 
		ROLLBACK; -- rollback any changes made in the transaction 
		RESIGNAL; -- raise again the sql exceptionto the caller
	end; 
	
	/*NOTA
	 * Ho scelto questo livello per evitare letture sporche
	 */
	
	SET transaction read only;
	SET transaction isolation level read committed;
	start transaction;
	
		-- sender_username è l'username dell'utente che sta chiamando la stored procedure
		-- receiver_username è l'username dell'utente con cui sender_username ha avuto una conversazione
		
		-- l'utente ha passato un codice di conversazione, probabilmente visualizzando lo storico 
		if(id_conversation is not null) then
			SET conversazione_codice = controllo_conversazione(id_conversation, sender_username, receiver_username);
			IF (conversazione_codice = -1) then
				signal sqlstate '45012' set message_text = 'You are not authorized to access this conversation';
			end IF;
		end if;
		
		if(id_conversation is null) then
			SET conversazione_codice = controllo_conversazione(NULL, sender_username, receiver_username);
		end if;
		
		if(conversazione_codice = -1) then 			-- errore, conversazione non trovata quindi inesistente
			signal sqlstate '45011' set message_text = 'Conversation not found'; 
		else
			SELECT Testo, Data
			FROM BachecaElettronicadb.Messaggio
			WHERE BachecaElettronicadb.Messaggio.Conversazione_Codice = conversazione_codice
			ORDER BY Data ASC;
		end if;
		
	commit;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione Storico UCC ---------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaStorico_UCC ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaStorico_UCC (IN ucc_username VARCHAR(45))
BEGIN
	declare idStorico INT;
	declare exit handler for sqlexception 
	begin 
		ROLLBACK; -- rollback any changes made in the transaction 
		RESIGNAL; -- raise again the sql exceptionto the caller
	end; 
	
	/*NOTA
	 * Ho scelto questo livello per evitare letture sporche
	 */
	
	SET transaction read only;
	SET transaction isolation level read committed;
	start transaction;
		
		-- Trova il codice dello storico creato nel momento della registrazione 
		SELECT StoricoConversazione_ID INTO idStorico FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username = ucc_username;
		
		-- Stampa tutte le conversazioni dell'utente con il relativo partecipante 
		SELECT Codice, UCC_Username_2 AS 'Username utente UCC', USCC_Username AS 'Username utente USCC'
		FROM BachecaElettronicadb.Conversazione
		WHERE BachecaElettronicadb.Conversazione.Codice in (SELECT CodiceConv
															FROM BachecaElettronicadb.ConversazioneCodice
															WHERE BachecaElettronicadb.ConversazioneCodice.StoricoConversazione_ID = idStorico);
	commit;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione Storico USCC --------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaStorico_USCC ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaStorico_USCC (IN uscc_username VARCHAR(45))
BEGIN
	declare idStorico INT;
	declare exit handler for sqlexception 
	begin 
		ROLLBACK; -- rollback any changes made in the transaction 
		RESIGNAL; -- raise again the sql exceptionto the caller
	end; 
	
	/*NOTA
	 * Ho scelto questo livello per evitare letture sporche
	 */
	
	SET transaction read only;
	SET transaction isolation level read committed;
	start transaction;
		
		-- Trova il codice dello storico creato nel momento della registrazione 
		SELECT StoricoConversazione_ID INTO idStorico FROM BachecaElettronicadb.USCC WHERE BachecaElettronicadb.USCC.Username = uscc_username;
		
		-- Stampa tutte le conversazioni dell'utente con il relativo partecipante 
		SELECT Codice, UCC_Username_1 AS 'Username utente UCC', UCC_Username_2 AS 'Username utente UCC'
		FROM BachecaElettronicadb.Conversazione
		WHERE BachecaElettronicadb.Conversazione.Codice in (SELECT CodiceConv
															FROM BachecaElettronicadb.ConversazioneCodice
															WHERE BachecaElettronicadb.ConversazioneCodice.StoricoConversazione_ID = idStorico);
	commit;
															
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Seguire un annuncio -----------------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.segui_Annuncio ;
CREATE PROCEDURE BachecaElettronicadb.segui_Annuncio (IN codice_annuncio INT, IN username VARCHAR(45))
BEGIN
	declare exit handler for sqlexception 
	begin 
		ROLLBACK; -- rollback any changes made in the transaction 
		RESIGNAL; -- raise again the sql exceptionto the caller
	end; 
	
	/*NOTA
	 * Ho scelto questo livello per evitare letture sporche
	 */
	
	SET transaction isolation level read committed;
	start transaction;
		
		/* NOTA
		 * L'idea è: Verifica che l'utente sia un UCC, altrimenti controlla se è un USCC.
		 * Se non fosse nè UCC e nè USCC allora l'utente non esiste
		 */	
	
		if (not exists (SELECT Username FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username = username)) then
			IF (not exists (SELECT Username FROM BachecaElettronicadb.USCC WHERE BachecaElettronicadb.USCC.Username = username)) THEN
				signal sqlstate '45000' set message_text = 'User not found';
			ELSE
				INSERT INTO BachecaElettronicadb.`Seguito-USCC`(USCC_Username, Annuncio_Codice) VALUES(username, codice_annuncio);
			end IF;
		else	
			INSERT INTO BachecaElettronicadb.`Seguito-UCC`(UCC_Username, Annuncio_Codice) VALUES(username, codice_annuncio);
		end if;
	
	commit;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione degli Annunci seguiti -----------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizza_Annunci_Seguiti ;
CREATE PROCEDURE BachecaElettronicadb.visualizza_Annunci_Seguiti (IN username VARCHAR(45))
BEGIN
	declare exit handler for sqlexception 
	begin 
		ROLLBACK; -- rollback any changes made in the transaction 
		RESIGNAL; -- raise again the sql exceptionto the caller
	end; 
	
	/*NOTA
	 * Ho scelto questo livello per evitare letture sporche
	 */
	
	SET transaction read only;
	SET transaction isolation level read committed;
	start transaction;
	
		/* NOTA
		 * L'idea è: Verifica che l'utente sia un UCC, altrimenti controlla se è un USCC.
		 * Se non fosse nè UCC e nè USCC allora l'utente non esiste
		 */	
		
		if (not exists (SELECT Username FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username = username)) then
			IF (not exists (SELECT Username FROM BachecaElettronicadb.USCC WHERE BachecaElettronicadb.USCC.Username = username)) THEN
				signal sqlstate '45000' set message_text = 'User not found';
			ELSE
				SELECT annuncio.Codice, annuncio.Stato, annuncio.UCC_Username AS 'Proprietario'
				FROM BachecaElettronicadb.`Seguito-USCC` AS seguiti JOIN BachecaElettronicadb.Annuncio AS annuncio ON seguiti.Annuncio_Codice = annuncio.Codice
				WHERE seguiti.USCC_Username = username;
			end IF;
		else
			SELECT annuncio.Codice, annuncio.Stato, annuncio.UCC_Username AS 'Proprietario'
			FROM BachecaElettronicadb.`Seguito-UCC` AS seguiti JOIN BachecaElettronicadb.Annuncio AS annuncio ON seguiti.Annuncio_Codice = annuncio.Codice
			WHERE seguiti.UCC_Username = username;
		end if;
		
	commit;

END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento o Rimozione nota in un Annuncio -----------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.modificaNota ;
CREATE PROCEDURE BachecaElettronicadb.modificaNota (IN testo VARCHAR(45), IN annuncio_codice INT, IN ID_rimozione_nota INT, IN username VARCHAR(45))
BEGIN
	declare exit handler for sqlexception 
	begin 
		ROLLBACK; -- rollback any changes made in the transaction 
		RESIGNAL; -- raise again the sql exceptionto the caller
	end; 
	
	/*NOTA
	 * Ho scelto questo livello per evitare letture sporche
	 */
	
	SET transaction isolation level read committed;
	start transaction;
	
	-- possibile implementazione trigger che controlla se una nuova nota inserita sia riferita ad un annuncio attivo
	
		if (not exists (SELECT Codice FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice = annuncio_codice and BachecaElettronicadb.Annuncio.UCC_Username = username)) then
			signal sqlstate '45008' set message_text = 'You are not the owner of the ad';
		end if;
	
		if (not exists (SELECT Codice FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice = annuncio_codice and BachecaElettronicadb.Annuncio.Stato = 'Attivo')) then
			signal sqlstate '45007' set message_text = 'Ad not active now';
		end if;
		
		if (ID_rimozione_nota is null) then
			INSERT INTO BachecaElettronicadb.Nota (ID, Testo, Annuncio_Codice) VALUES(NULL, testo, annuncio_codice);
		else 
			DELETE FROM BachecaElettronicadb.Nota
			WHERE BachecaElettronicadb.Nota.ID = ID_rimozione_nota;
		end if;
		
	commit;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizza nota ---------------------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaNota ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaNota (IN annuncio_Codice INT)
BEGIN
	declare exit handler for sqlexception 
	begin 
		ROLLBACK; -- rollback any changes made in the transaction 
		RESIGNAL; -- raise again the sql exceptionto the caller
	end; 
	
	/*NOTA
	 * Ho scelto questo livello per evitare letture sporche
	 */
	
	SET transaction read only;
	SET transaction isolation level read committed;
	start transaction;
	
		if (not exists (SELECT Codice FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice = annuncio_Codice and BachecaElettronicadb.Annuncio.Stato = 'Attivo')) then
			signal sqlstate '45007' set message_text = 'Ad not active now';
		end if;
		
		SELECT ID, Testo, Annuncio_Codice AS "Codice dell'annuncio"
		FROM BachecaElettronicadb.Nota
		WHERE BachecaElettronicadb.Nota.Annuncio_Codice = annuncio_Codice;
	
	commit;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Rimozione di un Annuncio ------------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.rimuoviAnnuncio ;
CREATE PROCEDURE BachecaElettronicadb.rimuoviAnnuncio (IN codice_annuncio INT, IN ucc_username VARCHAR(45))
BEGIN
	
	/*NOTA
	 * Non ho impostato nessun livello di isolamento perchè
	 * non c'è concorrenza sulla singolo annuncio, ovvero
	 * solo un solo utente può modificare il suo annuncio.
	 */
	
	-- Controlla che il paramentro sia corretto con la regola aziendale impostata 
	if (not exists (SELECT Codice FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=codice_annuncio and BachecaElettronicadb.Annuncio.Stato = 'Attivo' and BachecaElettronicadb.Annuncio.UCC_Username = ucc_username)) then
		signal sqlstate '45006' set message_text = 'Ad not found';
	end if;
			
	UPDATE BachecaElettronicadb.Annuncio
	SET BachecaElettronicadb.Annuncio.Stato = 'Rimosso'
	WHERE BachecaElettronicadb.Annuncio.Codice = codice_annuncio AND BachecaElettronicadb.Annuncio.Stato = 'Attivo' and BachecaElettronicadb.Annuncio.UCC_Username = ucc_username;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Annuncio Venduto --------------------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.vendutoAnnuncio ;
CREATE PROCEDURE BachecaElettronicadb.vendutoAnnuncio (IN codice_annuncio INT, IN ucc_username VARCHAR(45))
BEGIN
	
	/*NOTA
	 * Non ho impostato nessun livello di isolamento perchè
	 * non c'è concorrenza sulla singolo annuncio, ovvero
	 * solo un solo utente può modificare il suo annuncio.
	 */
	
	-- Controlla che il paramentro sia corretto con la regola aziendale impostata 
	if (not exists (SELECT Codice FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=codice_annuncio and BachecaElettronicadb.Annuncio.Stato = 'Attivo' and BachecaElettronicadb.Annuncio.UCC_Username = ucc_username)) then
		signal sqlstate '45006' set message_text = 'Ad not found';
	end if;
	
	UPDATE BachecaElettronicadb.Annuncio
	SET BachecaElettronicadb.Annuncio.Stato = 'Venduto'
	WHERE BachecaElettronicadb.Annuncio.Codice = codice_annuncio AND BachecaElettronicadb.Annuncio.Stato = 'Attivo' and BachecaElettronicadb.Annuncio.UCC_Username = ucc_username;

END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Generazione di un nuovo report ------------------------------------
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
	
	declare exit handler for sqlexception 
	begin 
		ROLLBACK; -- rollback any changes made in the transaction 
		RESIGNAL; -- raise again the sql exceptionto the caller
	end; 
	
	/*NOTA
	 * Ho scelto questo livello per evitare letture inconsistenti
	 * leggendo l'utente più di una volta  
	 */
	
	SET transaction isolation level repeatable read;
	start transaction;
	
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
	
		if (not exists (SELECT Username FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username = ucc_username)) then
			signal sqlstate '45000' set message_text = 'User not found';
		end if;
		
		if (not exists (SELECT Codice FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.UCC_Username = ucc_username and BachecaElettronicadb.Annuncio.Stato = 'Venduto')) then
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
			
	commit;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Riscossione di un report Amministratore ---------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.riscossione_report ;
CREATE PROCEDURE BachecaElettronicadb.riscossione_report (IN codice_report INT, IN ucc_username VARCHAR(45), IN amministratore_username VARCHAR(45))
BEGIN
	declare importo INT;
	declare exit handler for sqlexception 
	begin 
		ROLLBACK; -- rollback any changes made in the transaction 
		RESIGNAL; -- raise again the sql exceptionto the caller
	end; 
	
	/*NOTA
	 * Ho scelto questo livello per evitare letture inconsistenti con il report
	 */
	
	SET transaction isolation level repeatable read;
	start transaction;
	
		if (not exists (SELECT Username FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username = ucc_username)) then
			signal sqlstate '45000' set message_text = 'User not found';
		end if;
		
		if (not exists (SELECT Codice FROM BachecaElettronicadb.Report WHERE BachecaElettronicadb.Report.Codice = codice_report and BachecaElettronicadb.Report.UCC_Username = ucc_username)) then
			signal sqlstate '45015' set message_text = 'Report not found';
		end if;
		
		if (exists (SELECT Codice FROM BachecaElettronicadb.Report WHERE BachecaElettronicadb.Report.Codice = codice_report and BachecaElettronicadb.Report.Riscosso_Amministratore = true)) then
			signal sqlstate '45016' set message_text = 'Report already collected';
		end if;
		
		-- Solo l'amministratore che ha generato il report può riscuotere
		if (not exists (SELECT Codice FROM BachecaElettronicadb.Report WHERE BachecaElettronicadb.Report.Codice = codice_report and BachecaElettronicadb.Report.Amministratore_Username = amministratore_username)) then
			signal sqlstate '45017' set message_text = 'You are not the owner of the report';
		end if;
		
		SELECT ImportoTotale INTO importo
		FROM BachecaElettronicadb.Report 
		WHERE BachecaElettronicadb.Report.Codice = codice_report;
		
		UPDATE BachecaElettronicadb.Report
		SET BachecaElettronicadb.Report.Riscosso_Amministratore = true
		WHERE BachecaElettronicadb.Report.Codice = codice_report;
	
	commit;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione report --------------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizza_report ;
CREATE PROCEDURE BachecaElettronicadb.visualizza_report (IN codice_report INT, IN ucc_username VARCHAR(45))
BEGIN
	declare exit handler for sqlexception 
	begin 
		ROLLBACK; -- rollback any changes made in the transaction 
		RESIGNAL; -- raise again the sql exceptionto the caller
	end; 
	
	/*NOTA
	 * Ho scelto questo livello per evitare letture sporche
	 */
	
	SET transaction read only;
	SET transaction isolation level read committed;
	start transaction;
	
		if (not exists (SELECT Username FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username = ucc_username)) then
			signal sqlstate '45000' set message_text = 'User not found';
		end if;
		
		if (codice_report is null) then
			SELECT Codice, UCC_Username, ImportoTotale, NumeroAnnunci, NumeroCarta, Importo_UCC, Amministratore_Username, Riscosso_Amministratore, Importo_Amministratore
			FROM BachecaElettronicadb.Report
			WHERE BachecaElettronicadb.Report.UCC_Username = ucc_username;
		else
			SELECT Codice, UCC_Username, ImportoTotale, NumeroAnnunci, NumeroCarta, Importo_UCC, Amministratore_Username, Riscosso_Amministratore, Importo_Amministratore
			FROM BachecaElettronicadb.Report
			WHERE BachecaElettronicadb.Report.Codice = codice_report and BachecaElettronicadb.Report.UCC_Username = ucc_username;
		end if;
		
	commit;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione informazioni utente -------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizza_Info_Utente ;
CREATE PROCEDURE BachecaElettronicadb.visualizza_Info_Utente (IN username VARCHAR(45))
BEGIN
	declare exit handler for sqlexception 
	begin 
		ROLLBACK; -- rollback any changes made in the transaction 
		RESIGNAL; -- raise again the sql exceptionto the caller
	end; 
	
	/*NOTA
	 * Ho scelto questo livello per evitare letture sporche
	 */
	
	SET transaction read only;
	SET transaction isolation level read committed;
	start transaction;
	
		/* Nota
		 * L'idea è: Verifica che l'utente sia un UCC, altrimenti controlla se è un USCC.
		 * Se non sarà nè UCC e nè USCC allora l'utente non esiste.
		 */	
		
		if (not exists (SELECT Username FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username=username)) then
			IF (not exists (SELECT Username FROM BachecaElettronicadb.USCC WHERE BachecaElettronicadb.USCC.Username=username)) THEN
				signal sqlstate '45000' set message_text = 'User not found';
			ELSE
				SELECT Username, Password, CF_Anagrafico AS 'Codice Fiscale'
				FROM BachecaElettronicadb.USCC
				WHERE BachecaElettronicadb.USCC.Username = username;
			end IF;
		else
			SELECT Username, Password, NumeroCarta AS 'Numero Carta', DataScadenza AS 'Scadenza', CVC, CF_Anagrafico AS 'Codice Fiscale'
			FROM BachecaElettronicadb.UCC
			WHERE BachecaElettronicadb.UCC.Username = username;
		end if;
		
	commit;
	
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Login -------------------------------------------------------------
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

-- Trigger

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

-- Controlla Annuncio in Seguito USCC --------------------------------

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


SET SQL_MODE = '';
DROP USER IF EXISTS UCC;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'UCC' IDENTIFIED BY 'uccpassword';

SET SQL_MODE = '';
DROP USER IF EXISTS USCC;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'USCC' IDENTIFIED BY 'usccpassword';

SET SQL_MODE = '';
DROP USER IF EXISTS Amministratore;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'Amministratore' IDENTIFIED BY 'amministratorepassword';

SET SQL_MODE = '';
DROP USER IF EXISTS login;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'login' IDENTIFIED BY 'loginpassword';



GRANT EXECUTE ON procedure `BachecaElettronicadb`.`inserimentoNuovoAnnuncio` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizzaAnnuncio` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizzaCategoria` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`rimuoviAnnuncio` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`vendutoAnnuncio` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizzaInfoAnagrafiche` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizza_Info_Utente` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`modificaInfoAnagrafiche` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`modificaFotoAnnuncio` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`modificaCommento` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizzaCommento` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`modificaNota` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizzaNota` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`modifica_RecapitoNonPreferito` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizza_contatti` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`invioMessaggio` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizzaMessaggio` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizzaStorico_UCC` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`segui_Annuncio` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizza_Annunci_Seguiti` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizza_report` TO `UCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizza_notifiche` TO `UCC`;


GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizzaAnnuncio` TO `USCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizzaCategoria` TO `USCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizzaInfoAnagrafiche` TO `USCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizza_Info_Utente` TO `USCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`modificaInfoAnagrafiche` TO `USCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`modificaCommento` TO `USCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizzaCommento` TO `USCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizzaNota` TO `USCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`modifica_RecapitoNonPreferito` TO `USCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizza_contatti` TO `USCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`invioMessaggio` TO `USCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizzaMessaggio` TO `USCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizzaStorico_USCC` TO `USCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`segui_Annuncio` TO `USCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizza_Annunci_Seguiti` TO `USCC`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizza_notifiche` TO `USCC`;


GRANT EXECUTE ON procedure `BachecaElettronicadb`.`inserimentoNuovaCategoria` TO `Amministratore`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizzaCategoria` TO `Amministratore`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizzaAnnuncio` TO `Amministratore`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`genera_report` TO `Amministratore`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`riscossione_report` TO `Amministratore`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`visualizza_report` TO `Amministratore`;


GRANT EXECUTE ON procedure `BachecaElettronicadb`.`login` TO `login`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`registra_utente_UCC` TO `login`;
GRANT EXECUTE ON procedure `BachecaElettronicadb`.`registra_utente_USCC` TO `login`;


-- Alcune entry che ho generato per il database facendo webscaping su un generatore di fake identity


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


call BachecaElettronicadb.segui_Annuncio (2, 'sigkreco');
call BachecaElettronicadb.segui_Annuncio (1, 'dottbo');
call BachecaElettronicadb.segui_Annuncio (11, 'fioreeri');
call BachecaElettronicadb.segui_Annuncio (4, 'dottmeco');
call BachecaElettronicadb.segui_Annuncio (12, 'gianatti');
call BachecaElettronicadb.segui_Annuncio (5, 'zelidando');
call BachecaElettronicadb.segui_Annuncio (3, 'marisri');
call BachecaElettronicadb.segui_Annuncio (8, 'dotteli');
call BachecaElettronicadb.segui_Annuncio (13, 'dottmnti');
call BachecaElettronicadb.segui_Annuncio (1, 'shaino');
call BachecaElettronicadb.segui_Annuncio (13, 'marceosa');
call BachecaElettronicadb.segui_Annuncio (6, 'marianco');
call BachecaElettronicadb.segui_Annuncio (1, 'karimmina');
call BachecaElettronicadb.segui_Annuncio (6, 'sigprzo');
call BachecaElettronicadb.segui_Annuncio (26, 'drrusso');
call BachecaElettronicadb.segui_Annuncio (1, 'elgarosi');
call BachecaElettronicadb.segui_Annuncio (6, 'drtomssi');
call BachecaElettronicadb.segui_Annuncio (23, 'dottbri');
call BachecaElettronicadb.segui_Annuncio (15, 'cirarizo');
call BachecaElettronicadb.segui_Annuncio (37, 'ingvitno');
call BachecaElettronicadb.segui_Annuncio (9, 'drgiulri');
call BachecaElettronicadb.segui_Annuncio (39, 'demirra');
call BachecaElettronicadb.segui_Annuncio (30, 'ritamoti');
call BachecaElettronicadb.segui_Annuncio (4, 'ingaina');
call BachecaElettronicadb.segui_Annuncio (38, 'concci');
call BachecaElettronicadb.segui_Annuncio (47, 'cirinoco');
call BachecaElettronicadb.segui_Annuncio (31, 'dindocmbo');
call BachecaElettronicadb.segui_Annuncio (18, 'odonebri');
call BachecaElettronicadb.segui_Annuncio (1, 'ferdndo');
call BachecaElettronicadb.segui_Annuncio (37, 'concetta');
call BachecaElettronicadb.segui_Annuncio (22, 'guidocte');
call BachecaElettronicadb.segui_Annuncio (37, 'fulviino');
call BachecaElettronicadb.segui_Annuncio (36, 'lisalli');
call BachecaElettronicadb.segui_Annuncio (5, 'dottloara');
call BachecaElettronicadb.segui_Annuncio (3, 'flaviadi');
call BachecaElettronicadb.segui_Annuncio (12, 'bibialia');
call BachecaElettronicadb.segui_Annuncio (26, 'karito');
call BachecaElettronicadb.segui_Annuncio (59, 'drkayri');
call BachecaElettronicadb.segui_Annuncio (39, 'ruthrici');
call BachecaElettronicadb.segui_Annuncio (75, 'samuesso');
call BachecaElettronicadb.segui_Annuncio (14, 'dottmti');
call BachecaElettronicadb.segui_Annuncio (29, 'dottaini');
call BachecaElettronicadb.segui_Annuncio (78, 'sigmsta');
call BachecaElettronicadb.segui_Annuncio (11, 'dottari');
call BachecaElettronicadb.segui_Annuncio (10, 'ingridelo');
call BachecaElettronicadb.segui_Annuncio (86, 'baldco');
call BachecaElettronicadb.segui_Annuncio (40, 'luigile');
call BachecaElettronicadb.segui_Annuncio (82, 'morgara');
call BachecaElettronicadb.segui_Annuncio (44, 'drrenna');
call BachecaElettronicadb.segui_Annuncio (87, 'sigarneo');
call BachecaElettronicadb.segui_Annuncio (51, 'ceccolo');
call BachecaElettronicadb.segui_Annuncio (86, 'ritano');
call BachecaElettronicadb.segui_Annuncio (39, 'ingediero');
call BachecaElettronicadb.segui_Annuncio (54, 'cleopana');
call BachecaElettronicadb.segui_Annuncio (87, 'raniri');
call BachecaElettronicadb.segui_Annuncio (3, 'ingnoadi');
call BachecaElettronicadb.segui_Annuncio (88, 'dotteti');
call BachecaElettronicadb.segui_Annuncio (70, 'oseaneri');
call BachecaElettronicadb.segui_Annuncio (69, 'edilioni');
call BachecaElettronicadb.segui_Annuncio (28, 'ingtreri');
call BachecaElettronicadb.segui_Annuncio (65, 'sigrrdo');
call BachecaElettronicadb.segui_Annuncio (65, 'pablomlli');
call BachecaElettronicadb.segui_Annuncio (36, 'drsiti');
call BachecaElettronicadb.segui_Annuncio (127, 'priamoro');
call BachecaElettronicadb.segui_Annuncio (15, 'drconctti');
call BachecaElettronicadb.segui_Annuncio (96, 'silvaas');
call BachecaElettronicadb.segui_Annuncio (39, 'concdi');
call BachecaElettronicadb.segui_Annuncio (82, 'sigrti');
call BachecaElettronicadb.segui_Annuncio (48, 'ruthnna');
call BachecaElettronicadb.segui_Annuncio (115, 'cassiali');
call BachecaElettronicadb.segui_Annuncio (21, 'donaeco');
call BachecaElettronicadb.segui_Annuncio (87, 'dindoso');
call BachecaElettronicadb.segui_Annuncio (56, 'naomiini');
call BachecaElettronicadb.segui_Annuncio (57, 'dylano');
call BachecaElettronicadb.segui_Annuncio (70, 'inggali');
call BachecaElettronicadb.segui_Annuncio (109, 'erminissi');
call BachecaElettronicadb.segui_Annuncio (45, 'drjacana');
call BachecaElettronicadb.segui_Annuncio (147, 'gerlanisi');
call BachecaElettronicadb.segui_Annuncio (17, 'arieri');
call BachecaElettronicadb.segui_Annuncio (145, 'dottrotti');
call BachecaElettronicadb.segui_Annuncio (83, 'ireneari');
call BachecaElettronicadb.segui_Annuncio (109, 'marusksi');
call BachecaElettronicadb.segui_Annuncio (70, 'fiorla');
call BachecaElettronicadb.segui_Annuncio (12, 'oseagssi');
call BachecaElettronicadb.segui_Annuncio (117, 'dralni');
call BachecaElettronicadb.segui_Annuncio (62, 'eustazo');
call BachecaElettronicadb.segui_Annuncio (137, 'dottfano');
call BachecaElettronicadb.segui_Annuncio (167, 'zelidani');
call BachecaElettronicadb.segui_Annuncio (71, 'ingmtti');
call BachecaElettronicadb.segui_Annuncio (125, 'omarssi');
call BachecaElettronicadb.segui_Annuncio (1, 'sersebti');
call BachecaElettronicadb.segui_Annuncio (115, 'ingscci');
call BachecaElettronicadb.segui_Annuncio (118, 'diamllo');
call BachecaElettronicadb.segui_Annuncio (179, 'fabianti');
call BachecaElettronicadb.segui_Annuncio (109, 'drpriaale');
call BachecaElettronicadb.segui_Annuncio (172, 'vinicara');
call BachecaElettronicadb.segui_Annuncio (38, 'vinicito');
call BachecaElettronicadb.segui_Annuncio (47, 'donatela');
call BachecaElettronicadb.segui_Annuncio (120, 'inglucssi');
call BachecaElettronicadb.segui_Annuncio (9, 'neriero');
call BachecaElettronicadb.segui_Annuncio (114, 'ilarso');
call BachecaElettronicadb.segui_Annuncio (27, 'dottmeva');
call BachecaElettronicadb.segui_Annuncio (40, 'isabetti');
call BachecaElettronicadb.segui_Annuncio (43, 'sigeeo');
call BachecaElettronicadb.segui_Annuncio (9, 'baldaslli');
call BachecaElettronicadb.segui_Annuncio (154, 'manuera');
call BachecaElettronicadb.segui_Annuncio (141, 'ingsatti');
call BachecaElettronicadb.segui_Annuncio (145, 'drradila');
call BachecaElettronicadb.segui_Annuncio (72, 'quartana');
call BachecaElettronicadb.segui_Annuncio (69, 'toscina');
call BachecaElettronicadb.segui_Annuncio (131, 'noemilo');
call BachecaElettronicadb.segui_Annuncio (28, 'umbertri');
call BachecaElettronicadb.segui_Annuncio (28, 'matilini');
call BachecaElettronicadb.segui_Annuncio (77, 'sarira');
call BachecaElettronicadb.segui_Annuncio (33, 'pacifiari');
call BachecaElettronicadb.segui_Annuncio (62, 'drmonni');
call BachecaElettronicadb.segui_Annuncio (118, 'dottezzo');
call BachecaElettronicadb.segui_Annuncio (101, 'ingsile');
call BachecaElettronicadb.segui_Annuncio (108, 'lunavni');
call BachecaElettronicadb.segui_Annuncio (155, 'drnicoile');
call BachecaElettronicadb.segui_Annuncio (66, 'sigrari');
call BachecaElettronicadb.segui_Annuncio (103, 'eusebdi');
call BachecaElettronicadb.segui_Annuncio (110, 'lucrezico');
call BachecaElettronicadb.segui_Annuncio (111, 'sigodolla');
call BachecaElettronicadb.segui_Annuncio (126, 'eldageco');
call BachecaElettronicadb.segui_Annuncio (34, 'criststa');
call BachecaElettronicadb.segui_Annuncio (139, 'emanudi');
call BachecaElettronicadb.segui_Annuncio (84, 'inglinte');
call BachecaElettronicadb.segui_Annuncio (33, 'artemiini');
call BachecaElettronicadb.segui_Annuncio (97, 'giacsi');
call BachecaElettronicadb.segui_Annuncio (37, 'drardussi');
call BachecaElettronicadb.segui_Annuncio (140, 'ritasi');
call BachecaElettronicadb.segui_Annuncio (23, 'selvssi');
call BachecaElettronicadb.segui_Annuncio (6, 'emilino');
call BachecaElettronicadb.segui_Annuncio (67, 'dottci');
call BachecaElettronicadb.segui_Annuncio (156, 'domingbo');
call BachecaElettronicadb.segui_Annuncio (106, 'karimmti');
call BachecaElettronicadb.segui_Annuncio (77, 'danutno');


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
