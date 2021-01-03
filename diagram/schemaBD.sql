-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema bacheca-elettronica
-- -----------------------------------------------------

CREATE SCHEMA IF NOT EXISTS `bacheca-elettronica` DEFAULT CHARACTER SET utf8 ;
USE `bacheca-elettronica` ;

-- -----------------------------------------------------
-- Table `bacheca-elettronica`.`UCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bacheca-elettronica`.`UCC` ;

CREATE TABLE IF NOT EXISTS `bacheca-elettronica`.`UCC` (
  `Username` VARCHAR(45) NOT NULL,
  `Password` VARCHAR(45) NOT NULL,
  `Numero Carta` INT NOT NULL,
  `Cognome intestatario` VARCHAR(20) NOT NULL,
  `Nome intestatario` VARCHAR(20) NOT NULL,
  `Data scadenza` DATE NOT NULL,
  `CVC` INT NOT NULL,
  PRIMARY KEY (`Username`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `Username_UNIQUE` ON `bacheca-elettronica`.`UCC` (`Username` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `bacheca-elettronica`.`Categoria`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bacheca-elettronica`.`Categoria` ;

CREATE TABLE IF NOT EXISTS `bacheca-elettronica`.`Categoria` (
  `Nome` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`Nome`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `Nome_UNIQUE` ON `bacheca-elettronica`.`Categoria` (`Nome` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `bacheca-elettronica`.`Annuncio`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bacheca-elettronica`.`Annuncio` ;

CREATE TABLE IF NOT EXISTS `bacheca-elettronica`.`Annuncio` (
  `Codice` INT NOT NULL,
  `Stato` VARCHAR(7) NOT NULL DEFAULT 'Attivo',
  `Descrizione` VARCHAR(100) NOT NULL,
  `Importo` INT NULL,
  `Foto` VARCHAR(45) BINARY NULL,
  `Venditore` VARCHAR(45) NOT NULL,
  `UCC_Username` VARCHAR(45) NOT NULL,
  `Categoria_Nome` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`Codice`),
  CONSTRAINT `fk_Annuncio_UCC`
    FOREIGN KEY (`UCC_Username`)
    REFERENCES `bacheca-elettronica`.`UCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Annuncio_Categoria1`
    FOREIGN KEY (`Categoria_Nome`)
    REFERENCES `bacheca-elettronica`.`Categoria` (`Nome`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `Codice_UNIQUE` ON `bacheca-elettronica`.`Annuncio` (`Codice` ASC) VISIBLE;

CREATE INDEX `fk_Annuncio_UCC_idx` ON `bacheca-elettronica`.`Annuncio` (`UCC_Username` ASC) VISIBLE;

CREATE INDEX `fk_Annuncio_Categoria1_idx` ON `bacheca-elettronica`.`Annuncio` (`Categoria_Nome` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `bacheca-elettronica`.`Nota`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bacheca-elettronica`.`Nota` ;

CREATE TABLE IF NOT EXISTS `bacheca-elettronica`.`Nota` (
  `ID` INT NOT NULL,
  `Testo` VARCHAR(45) NOT NULL,
  `Annuncio_Codice` INT NOT NULL,
  PRIMARY KEY (`ID`, `Annuncio_Codice`),
  CONSTRAINT `fk_Nota_Annuncio1`
    FOREIGN KEY (`Annuncio_Codice`)
    REFERENCES `bacheca-elettronica`.`Annuncio` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Nota_Annuncio1_idx` ON `bacheca-elettronica`.`Nota` (`Annuncio_Codice` ASC) VISIBLE;

CREATE UNIQUE INDEX `Annuncio_Codice_UNIQUE` ON `bacheca-elettronica`.`Nota` (`Annuncio_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `bacheca-elettronica`.`Commento`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bacheca-elettronica`.`Commento` ;

CREATE TABLE IF NOT EXISTS `bacheca-elettronica`.`Commento` (
  `ID` INT NOT NULL,
  `Testo` VARCHAR(45) NOT NULL,
  `Annuncio_Codice` INT NOT NULL,
  PRIMARY KEY (`ID`, `Annuncio_Codice`),
  CONSTRAINT `fk_Commento_Annuncio1`
    FOREIGN KEY (`Annuncio_Codice`)
    REFERENCES `bacheca-elettronica`.`Annuncio` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Commento_Annuncio1_idx` ON `bacheca-elettronica`.`Commento` (`Annuncio_Codice` ASC) VISIBLE;

CREATE UNIQUE INDEX `Annuncio_Codice_UNIQUE` ON `bacheca-elettronica`.`Commento` (`Annuncio_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `bacheca-elettronica`.`Report`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bacheca-elettronica`.`Report` ;

CREATE TABLE IF NOT EXISTS `bacheca-elettronica`.`Report` (
  `Codice` INT NOT NULL,
  PRIMARY KEY (`Codice`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `Codice_UNIQUE` ON `bacheca-elettronica`.`Report` (`Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `bacheca-elettronica`.`USCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bacheca-elettronica`.`USCC` ;

CREATE TABLE IF NOT EXISTS `bacheca-elettronica`.`USCC` (
  `Username` VARCHAR(45) NOT NULL,
  `Password` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Username`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `Username_UNIQUE` ON `bacheca-elettronica`.`USCC` (`Username` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `bacheca-elettronica`.`Conversazione`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bacheca-elettronica`.`Conversazione` ;

CREATE TABLE IF NOT EXISTS `bacheca-elettronica`.`Conversazione` (
  `Codice` INT NOT NULL,
  `Storico conversazioni` INT NULL DEFAULT NULL,
  `UCC_Username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Codice`),
  CONSTRAINT `fk_Conversazione_UCC1`
    FOREIGN KEY (`UCC_Username`)
    REFERENCES `bacheca-elettronica`.`UCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `Codice_UNIQUE` ON `bacheca-elettronica`.`Conversazione` (`Codice` ASC) VISIBLE;

CREATE INDEX `fk_Conversazione_UCC1_idx` ON `bacheca-elettronica`.`Conversazione` (`UCC_Username` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `bacheca-elettronica`.`Messaggio`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bacheca-elettronica`.`Messaggio` ;

CREATE TABLE IF NOT EXISTS `bacheca-elettronica`.`Messaggio` (
  `Username-r` VARCHAR(45) NOT NULL,
  `Username-s` VARCHAR(45) NOT NULL,
  `Data` DATE NOT NULL,
  `Conversazione_Codice` INT NOT NULL,
  PRIMARY KEY (`Username-r`, `Username-s`, `Conversazione_Codice`),
  CONSTRAINT `fk_Messaggio_Conversazione1`
    FOREIGN KEY (`Conversazione_Codice`)
    REFERENCES `bacheca-elettronica`.`Conversazione` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `Username-r_UNIQUE` ON `bacheca-elettronica`.`Messaggio` (`Username-r` ASC) VISIBLE;

CREATE UNIQUE INDEX `Username-s_UNIQUE` ON `bacheca-elettronica`.`Messaggio` (`Username-s` ASC) VISIBLE;

CREATE INDEX `fk_Messaggio_Conversazione1_idx` ON `bacheca-elettronica`.`Messaggio` (`Conversazione_Codice` ASC) VISIBLE;

CREATE UNIQUE INDEX `Conversazione_Codice_UNIQUE` ON `bacheca-elettronica`.`Messaggio` (`Conversazione_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `bacheca-elettronica`.`Informazione Anagrafica`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bacheca-elettronica`.`Informazione Anagrafica` ;

CREATE TABLE IF NOT EXISTS `bacheca-elettronica`.`Informazione Anagrafica` (
  `CF` VARCHAR(16) NOT NULL,
  `Cognome` VARCHAR(20) NOT NULL,
  `Nome` VARCHAR(20) NOT NULL,
  `Indirizzo di residenza` VARCHAR(20) NOT NULL,
  `CAP` INT NOT NULL,
  `Indirizzo di fatturazione` VARCHAR(20) NULL,
  `Tipo Recapito preferito` VARCHAR(20) NOT NULL,
  `Recapito preferito` VARCHAR(40) NOT NULL,
  PRIMARY KEY (`CF`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `CF_UNIQUE` ON `bacheca-elettronica`.`Informazione Anagrafica` (`CF` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `bacheca-elettronica`.`Recapito non preferito`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bacheca-elettronica`.`Recapito non preferito` ;

CREATE TABLE IF NOT EXISTS `bacheca-elettronica`.`Recapito non preferito` (
  `Recapito` VARCHAR(40) NOT NULL,
  `Tipo` VARCHAR(20) NOT NULL,
  `Informazione Anagrafica_CF` VARCHAR(16) NOT NULL,
  PRIMARY KEY (`Recapito`, `Informazione Anagrafica_CF`),
  CONSTRAINT `fk_Recapito non preferito_Informazione Anagrafica1`
    FOREIGN KEY (`Informazione Anagrafica_CF`)
    REFERENCES `bacheca-elettronica`.`Informazione Anagrafica` (`CF`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Recapito non preferito_Informazione Anagrafica1_idx` ON `bacheca-elettronica`.`Recapito non preferito` (`Informazione Anagrafica_CF` ASC) VISIBLE;

CREATE UNIQUE INDEX `Informazione Anagrafica_CF_UNIQUE` ON `bacheca-elettronica`.`Recapito non preferito` (`Informazione Anagrafica_CF` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `bacheca-elettronica`.`Seguito-UCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bacheca-elettronica`.`Seguito-UCC` ;

CREATE TABLE IF NOT EXISTS `bacheca-elettronica`.`Seguito-UCC` (
  `UCC_Username` VARCHAR(45) NOT NULL,
  `Annuncio_Codice` INT NOT NULL,
  PRIMARY KEY (`UCC_Username`, `Annuncio_Codice`),
  CONSTRAINT `fk_Seguito-UCC_UCC1`
    FOREIGN KEY (`UCC_Username`)
    REFERENCES `bacheca-elettronica`.`UCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Seguito-UCC_Annuncio1`
    FOREIGN KEY (`Annuncio_Codice`)
    REFERENCES `bacheca-elettronica`.`Annuncio` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Seguito-UCC_UCC1_idx` ON `bacheca-elettronica`.`Seguito-UCC` (`UCC_Username` ASC) VISIBLE;

CREATE INDEX `fk_Seguito-UCC_Annuncio1_idx` ON `bacheca-elettronica`.`Seguito-UCC` (`Annuncio_Codice` ASC) VISIBLE;

CREATE UNIQUE INDEX `UCC_Username_UNIQUE` ON `bacheca-elettronica`.`Seguito-UCC` (`UCC_Username` ASC) VISIBLE;

CREATE UNIQUE INDEX `Annuncio_Codice_UNIQUE` ON `bacheca-elettronica`.`Seguito-UCC` (`Annuncio_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `bacheca-elettronica`.`Seguito-USCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bacheca-elettronica`.`Seguito-USCC` ;

CREATE TABLE IF NOT EXISTS `bacheca-elettronica`.`Seguito-USCC` (
  `Annuncio_Codice` INT NOT NULL,
  `USCC_Username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Annuncio_Codice`, `USCC_Username`),
  CONSTRAINT `fk_Seguito-USCC_Annuncio1`
    FOREIGN KEY (`Annuncio_Codice`)
    REFERENCES `bacheca-elettronica`.`Annuncio` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Seguito-USCC_USCC1`
    FOREIGN KEY (`USCC_Username`)
    REFERENCES `bacheca-elettronica`.`USCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Seguito-USCC_Annuncio1_idx` ON `bacheca-elettronica`.`Seguito-USCC` (`Annuncio_Codice` ASC) VISIBLE;

CREATE INDEX `fk_Seguito-USCC_USCC1_idx` ON `bacheca-elettronica`.`Seguito-USCC` (`USCC_Username` ASC) VISIBLE;

CREATE UNIQUE INDEX `Annuncio_Codice_UNIQUE` ON `bacheca-elettronica`.`Seguito-USCC` (`Annuncio_Codice` ASC) VISIBLE;

CREATE UNIQUE INDEX `USCC_Username_UNIQUE` ON `bacheca-elettronica`.`Seguito-USCC` (`USCC_Username` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `bacheca-elettronica`.`Riguarda`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bacheca-elettronica`.`Riguarda` ;

CREATE TABLE IF NOT EXISTS `bacheca-elettronica`.`Riguarda` (
  `Report_Codice` INT NOT NULL,
  `UCC_Username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Report_Codice`),
  CONSTRAINT `fk_Riguarda_Report1`
    FOREIGN KEY (`Report_Codice`)
    REFERENCES `bacheca-elettronica`.`Report` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Riguarda_UCC1`
    FOREIGN KEY (`UCC_Username`)
    REFERENCES `bacheca-elettronica`.`UCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Riguarda_Report1_idx` ON `bacheca-elettronica`.`Riguarda` (`Report_Codice` ASC) VISIBLE;

CREATE INDEX `fk_Riguarda_UCC1_idx` ON `bacheca-elettronica`.`Riguarda` (`UCC_Username` ASC) VISIBLE;

CREATE UNIQUE INDEX `Report_Codice_UNIQUE` ON `bacheca-elettronica`.`Riguarda` (`Report_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `bacheca-elettronica`.`Partecipa-UCC-UCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bacheca-elettronica`.`Partecipa-UCC-UCC` ;

CREATE TABLE IF NOT EXISTS `bacheca-elettronica`.`Partecipa-UCC-UCC` (
  `Conversazione_Codice` INT NOT NULL,
  `UCC_Username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Conversazione_Codice`),
  CONSTRAINT `fk_Partecipa-UCC-UCC_Conversazione1`
    FOREIGN KEY (`Conversazione_Codice`)
    REFERENCES `bacheca-elettronica`.`Conversazione` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Partecipa-UCC-UCC_UCC1`
    FOREIGN KEY (`UCC_Username`)
    REFERENCES `bacheca-elettronica`.`UCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Partecipa-UCC-UCC_Conversazione1_idx` ON `bacheca-elettronica`.`Partecipa-UCC-UCC` (`Conversazione_Codice` ASC) VISIBLE;

CREATE INDEX `fk_Partecipa-UCC-UCC_UCC1_idx` ON `bacheca-elettronica`.`Partecipa-UCC-UCC` (`UCC_Username` ASC) VISIBLE;

CREATE UNIQUE INDEX `Conversazione_Codice_UNIQUE` ON `bacheca-elettronica`.`Partecipa-UCC-UCC` (`Conversazione_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `bacheca-elettronica`.`Partecipa-USCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bacheca-elettronica`.`Partecipa-USCC` ;

CREATE TABLE IF NOT EXISTS `bacheca-elettronica`.`Partecipa-USCC` (
  `Conversazione_Codice` INT NOT NULL,
  `USCC_Username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Conversazione_Codice`),
  CONSTRAINT `fk_Partecipa-USCC_Conversazione1`
    FOREIGN KEY (`Conversazione_Codice`)
    REFERENCES `bacheca-elettronica`.`Conversazione` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Partecipa-USCC_USCC1`
    FOREIGN KEY (`USCC_Username`)
    REFERENCES `bacheca-elettronica`.`USCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Partecipa-USCC_Conversazione1_idx` ON `bacheca-elettronica`.`Partecipa-USCC` (`Conversazione_Codice` ASC) VISIBLE;

CREATE INDEX `fk_Partecipa-USCC_USCC1_idx` ON `bacheca-elettronica`.`Partecipa-USCC` (`USCC_Username` ASC) VISIBLE;

CREATE UNIQUE INDEX `Conversazione_Codice_UNIQUE` ON `bacheca-elettronica`.`Partecipa-USCC` (`Conversazione_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `bacheca-elettronica`.`Modificato-UCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bacheca-elettronica`.`Modificato-UCC` ;

CREATE TABLE IF NOT EXISTS `bacheca-elettronica`.`Modificato-UCC` (
  `Informazione Anagrafica_CF` VARCHAR(16) NOT NULL,
  `UCC_Username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Informazione Anagrafica_CF`),
  CONSTRAINT `fk_Modificato-UCC_Informazione Anagrafica1`
    FOREIGN KEY (`Informazione Anagrafica_CF`)
    REFERENCES `bacheca-elettronica`.`Informazione Anagrafica` (`CF`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Modificato-UCC_UCC1`
    FOREIGN KEY (`UCC_Username`)
    REFERENCES `bacheca-elettronica`.`UCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Modificato-UCC_Informazione Anagrafica1_idx` ON `bacheca-elettronica`.`Modificato-UCC` (`Informazione Anagrafica_CF` ASC) VISIBLE;

CREATE INDEX `fk_Modificato-UCC_UCC1_idx` ON `bacheca-elettronica`.`Modificato-UCC` (`UCC_Username` ASC) VISIBLE;

CREATE UNIQUE INDEX `Informazione Anagrafica_CF_UNIQUE` ON `bacheca-elettronica`.`Modificato-UCC` (`Informazione Anagrafica_CF` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `bacheca-elettronica`.`Modificato-USCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bacheca-elettronica`.`Modificato-USCC` ;

CREATE TABLE IF NOT EXISTS `bacheca-elettronica`.`Modificato-USCC` (
  `Informazione Anagrafica_CF` VARCHAR(16) NOT NULL,
  `USCC_Username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Informazione Anagrafica_CF`),
  CONSTRAINT `fk_Modificato-USCC_Informazione Anagrafica1`
    FOREIGN KEY (`Informazione Anagrafica_CF`)
    REFERENCES `bacheca-elettronica`.`Informazione Anagrafica` (`CF`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Modificato-USCC_USCC1`
    FOREIGN KEY (`USCC_Username`)
    REFERENCES `bacheca-elettronica`.`USCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Modificato-USCC_Informazione Anagrafica1_idx` ON `bacheca-elettronica`.`Modificato-USCC` (`Informazione Anagrafica_CF` ASC) VISIBLE;

CREATE INDEX `fk_Modificato-USCC_USCC1_idx` ON `bacheca-elettronica`.`Modificato-USCC` (`USCC_Username` ASC) VISIBLE;

CREATE UNIQUE INDEX `Informazione Anagrafica_CF_UNIQUE` ON `bacheca-elettronica`.`Modificato-USCC` (`Informazione Anagrafica_CF` ASC) VISIBLE;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
