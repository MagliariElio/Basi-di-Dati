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



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
