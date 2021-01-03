-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `bacheca-elettronica` DEFAULT CHARACTER SET utf8 ;
USE `bacheca-elettronica` ;

-- -----------------------------------------------------
-- Table `mydb`.`UCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`UCC` ;

CREATE TABLE IF NOT EXISTS `mydb`.`UCC` (
  `Username` VARCHAR(45) NOT NULL,
  `Password` VARCHAR(45) NOT NULL,
  `Numero Carta` INT NOT NULL,
  `Cognome intestatario` VARCHAR(20) NOT NULL,
  `Nome intestatario` VARCHAR(20) NOT NULL,
  `Data scadenza` DATE NOT NULL,
  `CVC` INT NOT NULL,
  PRIMARY KEY (`Username`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `Username_UNIQUE` ON `mydb`.`UCC` (`Username` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`Categoria`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Categoria` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Categoria` (
  `Nome` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`Nome`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `Nome_UNIQUE` ON `mydb`.`Categoria` (`Nome` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`Annuncio`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Annuncio` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Annuncio` (
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
    REFERENCES `mydb`.`UCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Annuncio_Categoria1`
    FOREIGN KEY (`Categoria_Nome`)
    REFERENCES `mydb`.`Categoria` (`Nome`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `Codice_UNIQUE` ON `mydb`.`Annuncio` (`Codice` ASC) VISIBLE;

CREATE INDEX `fk_Annuncio_UCC_idx` ON `mydb`.`Annuncio` (`UCC_Username` ASC) VISIBLE;

CREATE INDEX `fk_Annuncio_Categoria1_idx` ON `mydb`.`Annuncio` (`Categoria_Nome` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`Nota`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Nota` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Nota` (
  `ID` INT NOT NULL,
  `Testo` VARCHAR(45) NOT NULL,
  `Annuncio_Codice` INT NOT NULL,
  PRIMARY KEY (`ID`, `Annuncio_Codice`),
  CONSTRAINT `fk_Nota_Annuncio1`
    FOREIGN KEY (`Annuncio_Codice`)
    REFERENCES `mydb`.`Annuncio` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Nota_Annuncio1_idx` ON `mydb`.`Nota` (`Annuncio_Codice` ASC) VISIBLE;

CREATE UNIQUE INDEX `Annuncio_Codice_UNIQUE` ON `mydb`.`Nota` (`Annuncio_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`Commento`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Commento` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Commento` (
  `ID` INT NOT NULL,
  `Testo` VARCHAR(45) NOT NULL,
  `Annuncio_Codice` INT NOT NULL,
  PRIMARY KEY (`ID`, `Annuncio_Codice`),
  CONSTRAINT `fk_Commento_Annuncio1`
    FOREIGN KEY (`Annuncio_Codice`)
    REFERENCES `mydb`.`Annuncio` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Commento_Annuncio1_idx` ON `mydb`.`Commento` (`Annuncio_Codice` ASC) VISIBLE;

CREATE UNIQUE INDEX `Annuncio_Codice_UNIQUE` ON `mydb`.`Commento` (`Annuncio_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`Report`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Report` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Report` (
  `Codice` INT NOT NULL,
  PRIMARY KEY (`Codice`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `Codice_UNIQUE` ON `mydb`.`Report` (`Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`USCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`USCC` ;

CREATE TABLE IF NOT EXISTS `mydb`.`USCC` (
  `Username` VARCHAR(45) NOT NULL,
  `Password` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Username`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `Username_UNIQUE` ON `mydb`.`USCC` (`Username` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`Conversazione`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Conversazione` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Conversazione` (
  `Codice` INT NOT NULL,
  `Storico conversazioni` INT NULL DEFAULT NULL,
  `UCC_Username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Codice`),
  CONSTRAINT `fk_Conversazione_UCC1`
    FOREIGN KEY (`UCC_Username`)
    REFERENCES `mydb`.`UCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `Codice_UNIQUE` ON `mydb`.`Conversazione` (`Codice` ASC) VISIBLE;

CREATE INDEX `fk_Conversazione_UCC1_idx` ON `mydb`.`Conversazione` (`UCC_Username` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`Messaggio`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Messaggio` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Messaggio` (
  `Username-r` VARCHAR(45) NOT NULL,
  `Username-s` VARCHAR(45) NOT NULL,
  `Data` DATE NOT NULL,
  `Conversazione_Codice` INT NOT NULL,
  PRIMARY KEY (`Username-r`, `Username-s`, `Conversazione_Codice`),
  CONSTRAINT `fk_Messaggio_Conversazione1`
    FOREIGN KEY (`Conversazione_Codice`)
    REFERENCES `mydb`.`Conversazione` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `Username-r_UNIQUE` ON `mydb`.`Messaggio` (`Username-r` ASC) VISIBLE;

CREATE UNIQUE INDEX `Username-s_UNIQUE` ON `mydb`.`Messaggio` (`Username-s` ASC) VISIBLE;

CREATE INDEX `fk_Messaggio_Conversazione1_idx` ON `mydb`.`Messaggio` (`Conversazione_Codice` ASC) VISIBLE;

CREATE UNIQUE INDEX `Conversazione_Codice_UNIQUE` ON `mydb`.`Messaggio` (`Conversazione_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`Informazione Anagrafica`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Informazione Anagrafica` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Informazione Anagrafica` (
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

CREATE UNIQUE INDEX `CF_UNIQUE` ON `mydb`.`Informazione Anagrafica` (`CF` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`Recapito non preferito`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Recapito non preferito` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Recapito non preferito` (
  `Recapito` VARCHAR(40) NOT NULL,
  `Tipo` VARCHAR(20) NOT NULL,
  `Informazione Anagrafica_CF` VARCHAR(16) NOT NULL,
  PRIMARY KEY (`Recapito`, `Informazione Anagrafica_CF`),
  CONSTRAINT `fk_Recapito non preferito_Informazione Anagrafica1`
    FOREIGN KEY (`Informazione Anagrafica_CF`)
    REFERENCES `mydb`.`Informazione Anagrafica` (`CF`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Recapito non preferito_Informazione Anagrafica1_idx` ON `mydb`.`Recapito non preferito` (`Informazione Anagrafica_CF` ASC) VISIBLE;

CREATE UNIQUE INDEX `Informazione Anagrafica_CF_UNIQUE` ON `mydb`.`Recapito non preferito` (`Informazione Anagrafica_CF` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`Seguito-UCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Seguito-UCC` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Seguito-UCC` (
  `UCC_Username` VARCHAR(45) NOT NULL,
  `Annuncio_Codice` INT NOT NULL,
  PRIMARY KEY (`UCC_Username`, `Annuncio_Codice`),
  CONSTRAINT `fk_Seguito-UCC_UCC1`
    FOREIGN KEY (`UCC_Username`)
    REFERENCES `mydb`.`UCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Seguito-UCC_Annuncio1`
    FOREIGN KEY (`Annuncio_Codice`)
    REFERENCES `mydb`.`Annuncio` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Seguito-UCC_UCC1_idx` ON `mydb`.`Seguito-UCC` (`UCC_Username` ASC) VISIBLE;

CREATE INDEX `fk_Seguito-UCC_Annuncio1_idx` ON `mydb`.`Seguito-UCC` (`Annuncio_Codice` ASC) VISIBLE;

CREATE UNIQUE INDEX `UCC_Username_UNIQUE` ON `mydb`.`Seguito-UCC` (`UCC_Username` ASC) VISIBLE;

CREATE UNIQUE INDEX `Annuncio_Codice_UNIQUE` ON `mydb`.`Seguito-UCC` (`Annuncio_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`Seguito-USCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Seguito-USCC` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Seguito-USCC` (
  `Annuncio_Codice` INT NOT NULL,
  `USCC_Username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Annuncio_Codice`, `USCC_Username`),
  CONSTRAINT `fk_Seguito-USCC_Annuncio1`
    FOREIGN KEY (`Annuncio_Codice`)
    REFERENCES `mydb`.`Annuncio` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Seguito-USCC_USCC1`
    FOREIGN KEY (`USCC_Username`)
    REFERENCES `mydb`.`USCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Seguito-USCC_Annuncio1_idx` ON `mydb`.`Seguito-USCC` (`Annuncio_Codice` ASC) VISIBLE;

CREATE INDEX `fk_Seguito-USCC_USCC1_idx` ON `mydb`.`Seguito-USCC` (`USCC_Username` ASC) VISIBLE;

CREATE UNIQUE INDEX `Annuncio_Codice_UNIQUE` ON `mydb`.`Seguito-USCC` (`Annuncio_Codice` ASC) VISIBLE;

CREATE UNIQUE INDEX `USCC_Username_UNIQUE` ON `mydb`.`Seguito-USCC` (`USCC_Username` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`Riguarda`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Riguarda` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Riguarda` (
  `Report_Codice` INT NOT NULL,
  `UCC_Username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Report_Codice`),
  CONSTRAINT `fk_Riguarda_Report1`
    FOREIGN KEY (`Report_Codice`)
    REFERENCES `mydb`.`Report` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Riguarda_UCC1`
    FOREIGN KEY (`UCC_Username`)
    REFERENCES `mydb`.`UCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Riguarda_Report1_idx` ON `mydb`.`Riguarda` (`Report_Codice` ASC) VISIBLE;

CREATE INDEX `fk_Riguarda_UCC1_idx` ON `mydb`.`Riguarda` (`UCC_Username` ASC) VISIBLE;

CREATE UNIQUE INDEX `Report_Codice_UNIQUE` ON `mydb`.`Riguarda` (`Report_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`Partecipa-UCC-UCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Partecipa-UCC-UCC` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Partecipa-UCC-UCC` (
  `Conversazione_Codice` INT NOT NULL,
  `UCC_Username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Conversazione_Codice`),
  CONSTRAINT `fk_Partecipa-UCC-UCC_Conversazione1`
    FOREIGN KEY (`Conversazione_Codice`)
    REFERENCES `mydb`.`Conversazione` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Partecipa-UCC-UCC_UCC1`
    FOREIGN KEY (`UCC_Username`)
    REFERENCES `mydb`.`UCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Partecipa-UCC-UCC_Conversazione1_idx` ON `mydb`.`Partecipa-UCC-UCC` (`Conversazione_Codice` ASC) VISIBLE;

CREATE INDEX `fk_Partecipa-UCC-UCC_UCC1_idx` ON `mydb`.`Partecipa-UCC-UCC` (`UCC_Username` ASC) VISIBLE;

CREATE UNIQUE INDEX `Conversazione_Codice_UNIQUE` ON `mydb`.`Partecipa-UCC-UCC` (`Conversazione_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`Partecipa-USCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Partecipa-USCC` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Partecipa-USCC` (
  `Conversazione_Codice` INT NOT NULL,
  `USCC_Username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Conversazione_Codice`),
  CONSTRAINT `fk_Partecipa-USCC_Conversazione1`
    FOREIGN KEY (`Conversazione_Codice`)
    REFERENCES `mydb`.`Conversazione` (`Codice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Partecipa-USCC_USCC1`
    FOREIGN KEY (`USCC_Username`)
    REFERENCES `mydb`.`USCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Partecipa-USCC_Conversazione1_idx` ON `mydb`.`Partecipa-USCC` (`Conversazione_Codice` ASC) VISIBLE;

CREATE INDEX `fk_Partecipa-USCC_USCC1_idx` ON `mydb`.`Partecipa-USCC` (`USCC_Username` ASC) VISIBLE;

CREATE UNIQUE INDEX `Conversazione_Codice_UNIQUE` ON `mydb`.`Partecipa-USCC` (`Conversazione_Codice` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`Modificato-UCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Modificato-UCC` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Modificato-UCC` (
  `Informazione Anagrafica_CF` VARCHAR(16) NOT NULL,
  `UCC_Username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Informazione Anagrafica_CF`),
  CONSTRAINT `fk_Modificato-UCC_Informazione Anagrafica1`
    FOREIGN KEY (`Informazione Anagrafica_CF`)
    REFERENCES `mydb`.`Informazione Anagrafica` (`CF`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Modificato-UCC_UCC1`
    FOREIGN KEY (`UCC_Username`)
    REFERENCES `mydb`.`UCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Modificato-UCC_Informazione Anagrafica1_idx` ON `mydb`.`Modificato-UCC` (`Informazione Anagrafica_CF` ASC) VISIBLE;

CREATE INDEX `fk_Modificato-UCC_UCC1_idx` ON `mydb`.`Modificato-UCC` (`UCC_Username` ASC) VISIBLE;

CREATE UNIQUE INDEX `Informazione Anagrafica_CF_UNIQUE` ON `mydb`.`Modificato-UCC` (`Informazione Anagrafica_CF` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`Modificato-USCC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Modificato-USCC` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Modificato-USCC` (
  `Informazione Anagrafica_CF` VARCHAR(16) NOT NULL,
  `USCC_Username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Informazione Anagrafica_CF`),
  CONSTRAINT `fk_Modificato-USCC_Informazione Anagrafica1`
    FOREIGN KEY (`Informazione Anagrafica_CF`)
    REFERENCES `mydb`.`Informazione Anagrafica` (`CF`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Modificato-USCC_USCC1`
    FOREIGN KEY (`USCC_Username`)
    REFERENCES `mydb`.`USCC` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Modificato-USCC_Informazione Anagrafica1_idx` ON `mydb`.`Modificato-USCC` (`Informazione Anagrafica_CF` ASC) VISIBLE;

CREATE INDEX `fk_Modificato-USCC_USCC1_idx` ON `mydb`.`Modificato-USCC` (`USCC_Username` ASC) VISIBLE;

CREATE UNIQUE INDEX `Informazione Anagrafica_CF_UNIQUE` ON `mydb`.`Modificato-USCC` (`Informazione Anagrafica_CF` ASC) VISIBLE;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
