-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema BachecaElettronicadb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema BachecaElettronicadb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `BachecaElettronicadb` ;
USE `BachecaElettronicadb` ;

-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`StoricoConversazione`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`StoricoConversazione` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`StoricoConversazione` (
  `ID` INT AUTO_INCREMENT NOT NULL,
  PRIMARY KEY (`ID`))
ENGINE = InnoDB AUTO_INCREMENT=1;

CREATE UNIQUE INDEX `ID_UNIQUE` ON `BachecaElettronicadb`.`StoricoConversazione` (`ID` ASC) VISIBLE;


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
  `IndirizzoDiFatturazione` VARCHAR(20) NULL,
  `TipoRecapitoPreferito` VARCHAR(20) NOT NULL,
  `RecapitoPreferito` VARCHAR(40) NOT NULL,
  PRIMARY KEY (`CF`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `CF_UNIQUE` ON `BachecaElettronicadb`.`InformazioneAnagrafica` (`CF` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`UCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`UCC` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`UCC` (
  `Username` VARCHAR(45) NOT NULL,
  `Password` VARCHAR(45) NOT NULL,
  `NumeroCarta` INT NOT NULL,
  `CognomeIntestatario` VARCHAR(20) NOT NULL,
  `NomeIntestatario` VARCHAR(20) NOT NULL,
  `DataScadenza` DATE NOT NULL,
  `CVC` INT NOT NULL,
  `StoricoConversazione_ID` INT NOT NULL,
  `CF_Anagrafico` VARCHAR(16) NOT NULL,
  PRIMARY KEY (`Username`),
  CONSTRAINT `fk_UCC_StoricoConversazione1`
    FOREIGN KEY (`StoricoConversazione_ID`)
    REFERENCES `BachecaElettronicadb`.`StoricoConversazione` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_UCC_InformazioneAnagrafica1`
    FOREIGN KEY (`CF_Anagrafico`)
    REFERENCES `BachecaElettronicadb`.`InformazioneAnagrafica` (`CF`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `Username_UNIQUE` ON `BachecaElettronicadb`.`UCC` (`Username` ASC) VISIBLE;

CREATE INDEX `fk_UCC_StoricoConversazione1_idx` ON `BachecaElettronicadb`.`UCC` (`StoricoConversazione_ID` ASC) VISIBLE;

CREATE INDEX `fk_UCC_InformazioneAnagrafica1_idx` ON `BachecaElettronicadb`.`UCC` (`CF_Anagrafico` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Categoria`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Categoria` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Categoria` (
  `Nome` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`Nome`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `Nome_UNIQUE` ON `BachecaElettronicadb`.`Categoria` (`Nome` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Annuncio`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Annuncio` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Annuncio` (
  `Codice` INT AUTO_INCREMENT NOT NULL,
  `Stato` VARCHAR(7) NOT NULL,
  `Descrizione` VARCHAR(100) NOT NULL,
  `Importo` INT NULL,
  `Foto` VARCHAR(45) BINARY NULL,
  `UCC_Username` VARCHAR(45) NOT NULL,
  `Categoria_Nome` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`Codice`),
  CONSTRAINT `fk_Annuncio_UCC`
    FOREIGN KEY (`UCC_Username`)
    REFERENCES `BachecaElettronicadb`.`UCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Annuncio_Categoria1`
    FOREIGN KEY (`Categoria_Nome`)
    REFERENCES `BachecaElettronicadb`.`Categoria` (`Nome`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB AUTO_INCREMENT=1;

CREATE UNIQUE INDEX `Codice_UNIQUE` ON `BachecaElettronicadb`.`Annuncio` (`Codice` ASC) VISIBLE;

CREATE INDEX `fk_Annuncio_UCC_idx` ON `BachecaElettronicadb`.`Annuncio` (`UCC_Username` ASC) VISIBLE;

CREATE INDEX `fk_Annuncio_Categoria1_idx` ON `BachecaElettronicadb`.`Annuncio` (`Categoria_Nome` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Nota`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Nota` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Nota` (
  `ID` INT AUTO_INCREMENT NOT NULL,
  `Testo` VARCHAR(45) NOT NULL,
  `Annuncio_Codice` INT NOT NULL,
  PRIMARY KEY (`ID`, `Annuncio_Codice`),
  CONSTRAINT `fk_Nota_Annuncio1`
    FOREIGN KEY (`Annuncio_Codice`)
    REFERENCES `BachecaElettronicadb`.`Annuncio` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB AUTO_INCREMENT=1;

CREATE INDEX `fk_Nota_Annuncio1_idx` ON `BachecaElettronicadb`.`Nota` (`Annuncio_Codice` ASC) VISIBLE;

CREATE UNIQUE INDEX `Annuncio_Codice_UNIQUE` ON `BachecaElettronicadb`.`Nota` (`Annuncio_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Commento`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Commento` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Commento` (
  `ID` INT AUTO_INCREMENT NOT NULL,
  `Testo` VARCHAR(45) NOT NULL,
  `Annuncio_Codice` INT NOT NULL,
  PRIMARY KEY (`ID`, `Annuncio_Codice`),
  CONSTRAINT `fk_Commento_Annuncio1`
    FOREIGN KEY (`Annuncio_Codice`)
    REFERENCES `BachecaElettronicadb`.`Annuncio` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB AUTO_INCREMENT=1;

CREATE INDEX `fk_Commento_Annuncio1_idx` ON `BachecaElettronicadb`.`Commento` (`Annuncio_Codice` ASC) VISIBLE;

CREATE UNIQUE INDEX `Annuncio_Codice_UNIQUE` ON `BachecaElettronicadb`.`Commento` (`Annuncio_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Report`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Report` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Report` (
  `UCC_Username` VARCHAR(45) NOT NULL,
  `ImportoTotale` INT NOT NULL,
  `NumeroCarta` INT NOT NULL,
  `CognomeIntestatarioCC` VARCHAR(20) NOT NULL,
  `NomeIntestatarioCC` VARCHAR(20) NOT NULL,
  `Data` DATETIME NOT NULL,
  PRIMARY KEY (`UCC_Username`),
  CONSTRAINT `fk_Report_UCC1`
    FOREIGN KEY (`UCC_Username`)
    REFERENCES `BachecaElettronicadb`.`UCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Report_UCC1_idx` ON `BachecaElettronicadb`.`Report` (`UCC_Username` ASC) VISIBLE;

CREATE UNIQUE INDEX `UCC_Username_UNIQUE` ON `BachecaElettronicadb`.`Report` (`UCC_Username` ASC) VISIBLE;


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
  CONSTRAINT `fk_USCC_StoricoConversazione1`
    FOREIGN KEY (`StoricoConversazione_ID`)
    REFERENCES `BachecaElettronicadb`.`StoricoConversazione` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_USCC_InformazioneAnagrafica1`
    FOREIGN KEY (`CF_Anagrafico`)
    REFERENCES `BachecaElettronicadb`.`InformazioneAnagrafica` (`CF`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `Username_UNIQUE` ON `BachecaElettronicadb`.`USCC` (`Username` ASC) VISIBLE;

CREATE INDEX `fk_USCC_StoricoConversazione1_idx` ON `BachecaElettronicadb`.`USCC` (`StoricoConversazione_ID` ASC) VISIBLE;

CREATE INDEX `fk_USCC_InformazioneAnagrafica1_idx` ON `BachecaElettronicadb`.`USCC` (`CF_Anagrafico` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Conversazione`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Conversazione` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Conversazione` (
  `Codice` INT AUTO_INCREMENT NOT NULL,
  PRIMARY KEY (`Codice`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `Codice_UNIQUE` ON `BachecaElettronicadb`.`Conversazione` (`Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Messaggio`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Messaggio` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Messaggio` (
  `ID` INT AUTO_INCREMENT NOT NULL,
  `Data` DATETIME NOT NULL,
  `Conversazione_Codice` INT NOT NULL,
  `Testo` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`ID`, `Conversazione_Codice`),
  CONSTRAINT `fk_Messaggio_Conversazione1`
    FOREIGN KEY (`Conversazione_Codice`)
    REFERENCES `BachecaElettronicadb`.`Conversazione` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Messaggio_Conversazione1_idx` ON `BachecaElettronicadb`.`Messaggio` (`Conversazione_Codice` ASC) VISIBLE;

CREATE UNIQUE INDEX `Conversazione_Codice_UNIQUE` ON `BachecaElettronicadb`.`Messaggio` (`Conversazione_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`RecapitoNonPreferito`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`RecapitoNonPreferito` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`RecapitoNonPreferito` (
  `Recapito` VARCHAR(40) NOT NULL,
  `Tipo` VARCHAR(20) NOT NULL,
  `InformazioneAnagrafica_CF` VARCHAR(16) NOT NULL,
  PRIMARY KEY (`InformazioneAnagrafica_CF`, `Recapito`),
  CONSTRAINT `fk_RecapitoNonPreferito_InformazioneAnagrafica1`
    FOREIGN KEY (`InformazioneAnagrafica_CF`)
    REFERENCES `BachecaElettronicadb`.`InformazioneAnagrafica` (`CF`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_RecapitoNonPreferito_InformazioneAnagrafica1_idx` ON `BachecaElettronicadb`.`RecapitoNonPreferito` (`InformazioneAnagrafica_CF` ASC) VISIBLE;

CREATE UNIQUE INDEX `InformazioneAnagrafica_CF_UNIQUE` ON `BachecaElettronicadb`.`RecapitoNonPreferito` (`InformazioneAnagrafica_CF` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Seguito-UCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Seguito-UCC` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Seguito-UCC` (
  `UCC_Username` VARCHAR(45) NOT NULL,
  `Annuncio_Codice` INT NOT NULL,
  PRIMARY KEY (`UCC_Username`, `Annuncio_Codice`),
  CONSTRAINT `fk_Seguito-UCC_UCC1`
    FOREIGN KEY (`UCC_Username`)
    REFERENCES `BachecaElettronicadb`.`UCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Seguito-UCC_Annuncio1`
    FOREIGN KEY (`Annuncio_Codice`)
    REFERENCES `BachecaElettronicadb`.`Annuncio` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Seguito-UCC_UCC1_idx` ON `BachecaElettronicadb`.`Seguito-UCC` (`UCC_Username` ASC) VISIBLE;

CREATE INDEX `fk_Seguito-UCC_Annuncio1_idx` ON `BachecaElettronicadb`.`Seguito-UCC` (`Annuncio_Codice` ASC) VISIBLE;

CREATE UNIQUE INDEX `UCC_Username_UNIQUE` ON `BachecaElettronicadb`.`Seguito-UCC` (`UCC_Username` ASC) VISIBLE;

CREATE UNIQUE INDEX `Annuncio_Codice_UNIQUE` ON `BachecaElettronicadb`.`Seguito-UCC` (`Annuncio_Codice` ASC) VISIBLE;


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
    REFERENCES `BachecaElettronicadb`.`Annuncio` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Seguito-USCC_USCC1`
    FOREIGN KEY (`USCC_Username`)
    REFERENCES `BachecaElettronicadb`.`USCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Seguito-USCC_Annuncio1_idx` ON `BachecaElettronicadb`.`Seguito-USCC` (`Annuncio_Codice` ASC) VISIBLE;

CREATE INDEX `fk_Seguito-USCC_USCC1_idx` ON `BachecaElettronicadb`.`Seguito-USCC` (`USCC_Username` ASC) VISIBLE;

CREATE UNIQUE INDEX `Annuncio_Codice_UNIQUE` ON `BachecaElettronicadb`.`Seguito-USCC` (`Annuncio_Codice` ASC) VISIBLE;

CREATE UNIQUE INDEX `USCC_Username_UNIQUE` ON `BachecaElettronicadb`.`Seguito-USCC` (`USCC_Username` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Partecipa-USCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Partecipa-USCC` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Partecipa-USCC` (
  `Conversazione_Codice` INT NOT NULL,
  `USCC_Username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Conversazione_Codice`),
  CONSTRAINT `fk_Partecipa-USCC_Conversazione1`
    FOREIGN KEY (`Conversazione_Codice`)
    REFERENCES `BachecaElettronicadb`.`Conversazione` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Partecipa-USCC_USCC1`
    FOREIGN KEY (`USCC_Username`)
    REFERENCES `BachecaElettronicadb`.`USCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Partecipa-USCC_Conversazione1_idx` ON `BachecaElettronicadb`.`Partecipa-USCC` (`Conversazione_Codice` ASC) VISIBLE;

CREATE INDEX `fk_Partecipa-USCC_USCC1_idx` ON `BachecaElettronicadb`.`Partecipa-USCC` (`USCC_Username` ASC) VISIBLE;

CREATE UNIQUE INDEX `Conversazione_Codice_UNIQUE` ON `BachecaElettronicadb`.`Partecipa-USCC` (`Conversazione_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Modificato-UCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Modificato-UCC` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Modificato-UCC` (
  `InformazioneAnagrafica_CF` VARCHAR(16) NOT NULL,
  `UCC_Username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`InformazioneAnagrafica_CF`),
  CONSTRAINT `fk_Modificato-UCC_UCC1`
    FOREIGN KEY (`UCC_Username`)
    REFERENCES `BachecaElettronicadb`.`UCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Modificato-UCC_InformazioneAnagrafica1`
    FOREIGN KEY (`InformazioneAnagrafica_CF`)
    REFERENCES `BachecaElettronicadb`.`InformazioneAnagrafica` (`CF`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Modificato-UCC_UCC1_idx` ON `BachecaElettronicadb`.`Modificato-UCC` (`UCC_Username` ASC) VISIBLE;

CREATE INDEX `fk_Modificato-UCC_InformazioneAnagrafica1_idx` ON `BachecaElettronicadb`.`Modificato-UCC` (`InformazioneAnagrafica_CF` ASC) VISIBLE;

CREATE UNIQUE INDEX `InformazioneAnagrafica_CF_UNIQUE` ON `BachecaElettronicadb`.`Modificato-UCC` (`InformazioneAnagrafica_CF` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Modificato-USCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Modificato-USCC` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Modificato-USCC` (
  `InformazioneAnagrafica_CF` VARCHAR(16) NOT NULL,
  `USCC_Username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`InformazioneAnagrafica_CF`),
  CONSTRAINT `fk_Modificato-USCC_USCC1`
    FOREIGN KEY (`USCC_Username`)
    REFERENCES `BachecaElettronicadb`.`USCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Modificato-USCC_InformazioneAnagrafica1`
    FOREIGN KEY (`InformazioneAnagrafica_CF`)
    REFERENCES `BachecaElettronicadb`.`InformazioneAnagrafica` (`CF`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Modificato-USCC_USCC1_idx` ON `BachecaElettronicadb`.`Modificato-USCC` (`USCC_Username` ASC) VISIBLE;

CREATE INDEX `fk_Modificato-USCC_InformazioneAnagrafica1_idx` ON `BachecaElettronicadb`.`Modificato-USCC` (`InformazioneAnagrafica_CF` ASC) VISIBLE;

CREATE UNIQUE INDEX `InformazioneAnagrafica_CF_UNIQUE` ON `BachecaElettronicadb`.`Modificato-USCC` (`InformazioneAnagrafica_CF` ASC) VISIBLE;


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
    REFERENCES `BachecaElettronicadb`.`StoricoConversazione` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_ConversazioneCodice_StoricoConversazione1_idx` ON `BachecaElettronicadb`.`ConversazioneCodice` (`StoricoConversazione_ID` ASC) VISIBLE;

CREATE UNIQUE INDEX `StoricoConversazione_ID_UNIQUE` ON `BachecaElettronicadb`.`ConversazioneCodice` (`StoricoConversazione_ID` ASC) VISIBLE;

CREATE UNIQUE INDEX `CodiceConv_UNIQUE` ON `BachecaElettronicadb`.`ConversazioneCodice` (`CodiceConv` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Tracciato`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Tracciato` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Tracciato` (
  `Conversazione_Codice` INT NOT NULL,
  `StoricoConversazione_ID` INT NOT NULL,
  PRIMARY KEY (`Conversazione_Codice`, `StoricoConversazione_ID`),
  CONSTRAINT `fk_Tracciato_StoricoConversazione1`
    FOREIGN KEY (`StoricoConversazione_ID`)
    REFERENCES `BachecaElettronicadb`.`StoricoConversazione` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Tracciato_Conversazione1`
    FOREIGN KEY (`Conversazione_Codice`)
    REFERENCES `BachecaElettronicadb`.`Conversazione` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Tracciato_StoricoConversazione1_idx` ON `BachecaElettronicadb`.`Tracciato` (`StoricoConversazione_ID` ASC) VISIBLE;

CREATE UNIQUE INDEX `StoricoConversazione_ID_UNIQUE` ON `BachecaElettronicadb`.`Tracciato` (`StoricoConversazione_ID` ASC) VISIBLE;

CREATE INDEX `fk_Tracciato_Conversazione1_idx` ON `BachecaElettronicadb`.`Tracciato` (`Conversazione_Codice` ASC) VISIBLE;

CREATE UNIQUE INDEX `Conversazione_Codice_UNIQUE` ON `BachecaElettronicadb`.`Tracciato` (`Conversazione_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `BachecaElettronicadb`.`Partecipa-UCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BachecaElettronicadb`.`Partecipa-UCC` ;

CREATE TABLE IF NOT EXISTS `BachecaElettronicadb`.`Partecipa-UCC` (
  `Conversazione_Codice` INT NOT NULL,
  `UCC_Username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Conversazione_Codice`, `UCC_Username`),
  CONSTRAINT `fk_Partecipa-UCC_Conversazione1`
    FOREIGN KEY (`Conversazione_Codice`)
    REFERENCES `BachecaElettronicadb`.`Conversazione` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Partecipa-UCC_UCC1`
    FOREIGN KEY (`UCC_Username`)
    REFERENCES `BachecaElettronicadb`.`UCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Partecipa-UCC_Conversazione1_idx` ON `BachecaElettronicadb`.`Partecipa-UCC` (`Conversazione_Codice` ASC) VISIBLE;

CREATE UNIQUE INDEX `Conversazione_Codice_UNIQUE` ON `BachecaElettronicadb`.`Partecipa-UCC` (`Conversazione_Codice` ASC) VISIBLE;

CREATE INDEX `fk_Partecipa-UCC_UCC1_idx` ON `BachecaElettronicadb`.`Partecipa-UCC` (`UCC_Username` ASC) VISIBLE;

CREATE UNIQUE INDEX `UCC_Username_UNIQUE` ON `BachecaElettronicadb`.`Partecipa-UCC` (`UCC_Username` ASC) VISIBLE;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


-- Registrazione di un utente UCC-------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.registra_utente_UCC ;
CREATE PROCEDURE BachecaElettronicadb.registra_utente_UCC (IN username VARCHAR(45), IN password VARCHAR(45), IN numeroCarta INT, IN cognomeIntestatario VARCHAR(20), IN nomeIntestatario VARCHAR(20), IN dataScadenza DATE, IN cvc INT, IN cf_anagrafico VARCHAR(16), IN cognome VARCHAR(20), IN nome VARCHAR(20), IN indirizzoDiResidenza VARCHAR(20), IN cap INT, IN indirizzoDiFatturazione VARCHAR(20), IN tipoRecapitoPreferito VARCHAR(20), IN recapitoPreferito VARCHAR(40), IN tipoRecapitoNonPreferito VARCHAR(20), IN recapitoNonPreferito VARCHAR(40))
BEGIN
	declare idStorico INT;
	if ((SELECT count(Username) FROM BachecaElettronicadb.UCC WHERE Username=username)=0) then
		
		call BachecaElettronicadb.inserisci_Storico(idStorico);
		call BachecaElettronicadb.inserimentoInfoAnagrafiche(cf_anagrafico, cognome, nome, indirizzoDiResidenza, cap, indirizzoDiFatturazione, tipoRecapitoPreferito, recapitoPreferito);
		call BachecaElettronicadb.inserisci_RecapitoNonPreferito(tipoRecapitoNonPreferito, recapitoNonPreferito, cf_anagrafico);		
		
		INSERT INTO BachecaElettronicadb.UCC (Username, Password, NumeroCarta, CognomeIntestatario, NomeIntestatario, DataScadenza, CVC, StoricoConversazione_ID, CF_Anagrafico)
		VALUES(username, password, numeroCarta, cognomeIntestatario, nomeIntestatario, dataScadenza, cvc, idStorico, cf_anagrafico);
	end if;
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
		if tipo is not null AND recapito is not null AND cf_anagrafico is not null then
			INSERT INTO BachecaElettronicadb.RecapitoNonPreferito (Recapito, Tipo, InformazioneAnagrafica_CF) VALUES(recapito, tipo, cf_anagrafico);
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

	if ((SELECT count(Username) FROM BachecaElettronicadb.USCC WHERE BachecaElettronicadb.USCC.Username=username)=0) then
		call BachecaElettronicadb.inserisci_Storico(idStorico);
		call BachecaElettronicadb.inserimentoInfoAnagrafiche(cf_anagrafico, cognome, nome, indirizzoDiResidenza, cap, indirizzoDiFatturazione, tipoRecapitoPreferito, recapitoPreferito);
		call BachecaElettronicadb.inserisci_RecapitoNonPreferito(tipoRecapitoNonPreferito, recapitoNonPreferito, cf_anagrafico);		

		
		INSERT INTO BachecaElettronicadb.USCC (Username, Password, StoricoConversazione_ID, CF_Anagrafico) 
		VALUES(username, password, idStorico, cf_anagrafico);
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento delle Informazioni Anagrafiche ------------------------ 
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.inserimentoInfoAnagrafiche ;
CREATE PROCEDURE BachecaElettronicadb.inserimentoInfoAnagrafiche (IN cf VARCHAR(16), IN cognome VARCHAR(20), IN nome VARCHAR(20), IN indirizzoDiResidenza VARCHAR(20), IN cap INT, IN indirizzoDiFatturazione VARCHAR(20), IN tipoRecapitoPreferito VARCHAR(20), IN recapitoPreferito VARCHAR(40))
BEGIN
	if ((SELECT count(CF) FROM BachecaElettronicadb.InformazioneAnagrafica WHERE CF=cf)=0) then
		IF indirizzoDiFatturazione IS NOT NULL THEN
			INSERT INTO InformazioneAnagrafica (CF, Cognome, Nome, IndirizzoDiResidenza, CAP, IndirizzoDiFatturazione, tipoRecapitoPreferito, RecapitoPreferito) 
			VALUES(cf, cognome, nome, indirizzoDiResidenza, cap, indirizzoDiFatturazione, tipoRecapitoPreferito, recapitoPreferito);
		ELSE
			INSERT INTO InformazioneAnagrafica (CF, Cognome, Nome, IndirizzoDiResidenza, CAP, tipoRecapitoPreferito, RecapitoPreferito) 
			VALUES(cf, cognome, nome, indirizzoDiResidenza, cap, tipoRecapitoPreferito, recapitoPreferito);
		END IF;
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Modifica delle Informazioni Anagrafiche ---------------------------
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
	if ((SELECT(count(Username)) FROM BachecaElettronicadb.UCC WHERE BachecaElettronicadb.UCC.Username=ucc_username) = 1) then
		if ((SELECT(count(Nome)) FROM BachecaElettronicadb.Categoria WHERE BachecaElettronicadb.Categoria.Nome=categoria_nome) = 1) then
			
			IF foto IS NULL THEN
				INSERT INTO BachecaElettronicadb.Annuncio (Codice, Stato, Descrizione, Importo, UCC_Username, Categoria_Nome) VALUES(NULL, 'Attivo', descrizione, importo, ucc_username, categoria_nome);
			ELSE
				INSERT INTO BachecaElettronicadb.Annuncio (Codice, Stato, Descrizione, Importo, Foto, UCC_Username, Categoria_Nome) VALUES(NULL, 'Attivo', descrizione, importo, foto, ucc_username, categoria_nome);
			END IF;
			
			
		end if;
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Inserimento di una foto in annuncio ------------------------------- Impostare un livello di isolamento per evitare repeatible read - Evento: avverti utenti che seguono l'annuncio
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.inserimentoFotoAnnuncio ;
CREATE PROCEDURE BachecaElettronicadb.inserimentoFotoAnnuncio (IN codice INT, IN foto BINARY)
BEGIN
	if ((SELECT(count(codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=codice AND BachecaElettronicadb.Annuncio.Stato='Attivo')=1 AND foto IS NOT NULL) then
		UPDATE BachecaElettronicadb.Annuncio
		SET Foto=foto
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

-- Inserimento commento ---------------------------------------------- Evento: avverti utenti che seguono l'annuncio
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.inserimentoCommento ;
CREATE PROCEDURE BachecaElettronicadb.inserimentoCommento (IN testo VARCHAR(45), IN annuncio_codice INT)
BEGIN
	if ((SELECT(count(Annuncio_Codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=annuncio_codice AND BachecaElettronicadb.Annuncio.Stato='Attivo') = 1 AND testo IS NOT NULL) then
		INSERT INTO BachecaElettronicadb.Commento (Testo, Annuncio_Codice) VALUES(testo, annuncio_codice);
	end if;
END//
DELIMITER ;
-- -------------------------------------------------------------------

-- Visualizzazione commento ------------------------------------------ Impostare un livello di isolamento
DELIMITER //
DROP PROCEDURE IF EXISTS BachecaElettronicadb.visualizzaCommento ;
CREATE PROCEDURE BachecaElettronicadb.visualizzaCommento (IN annuncio_codice INT)
BEGIN
	if ((SELECT(count(Annuncio_Codice)) FROM BachecaElettronicadb.Annuncio WHERE BachecaElettronicadb.Annuncio.Codice=annuncio_codice AND BachecaElettronicadb.Annuncio.Stato='Attivo') = 1) then
		SELECT Testo, Annuncio_codice AS "Codice dell'annuncio"
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
	
	if ((SELECT count(Username) FROM BachecaElettronicadb.USCC WHERE Username=uscc_username)=1 AND testo IS NOT NULL) then

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
	
	if ((SELECT count(Username) FROM BachecaElettronicadb.UCC WHERE Username=ucc_username)=1 AND testo IS NOT NULL) then

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
	
	if ((SELECT count(Username) FROM BachecaElettronicadb.UCC WHERE Username=ucc_username_1)=1 AND testo IS NOT NULL) then

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
	
		/*CREATE TEMPORARY TABLE `BachecaElettronicadb`.`ViewMessaggio` (
		`testo` VARCHAR(100) NOT NULL, 
		`data` DATETIME NOT NULL);*/	
	
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

-- Visualizzazione degli Annunci seguiti ---------------------- Impostare un livello di isolamento
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

-- Visualizzazione degli Annunci seguiti ----------------------------- Impostare un livello di isolamento
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
	declare numeroCarta, codice_annuncio INT;
	declare importo INT DEFAULT 0;
	declare cognome, nome VARCHAR(20);
	declare loop_import INT DEFAULT 0;
	declare sum_import CURSOR FOR SELECT Codice FROM BachecaElettronica.Annuncio WHERE UCC_Username=ucc_username and Stato='Venduto';
	declare continue handler for not found set loop_import=1;
	
	if ((SELECT(count(Username)) FROM BachecaElettronicadb.UCC WHERE Username=ucc_username) = 1) then
		SELECT NumeroCarta INTO numeroCarta FROM BachecaElettronicadb.UCC WHERE Username=ucc_username;
		SELECT CognomeIntestatario INTO cognome FROM BachecaElettronicadb.UCC WHERE Username=ucc_username;
		SELECT NomeIntestatario INTO nome FROM BachecaElettronicadb.UCC WHERE Username=ucc_username;
		
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
	
		INSERT INTO BachecaElettronicadb.Report (UCC_Username, ImportoTotale, NumeroCarta, CognomeIntestatarioCC, NomeIntestatarioCC, Data)
		VALUES(ucc_username, importo, numeroCarta, cognome, nome, now());
	end if;
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


