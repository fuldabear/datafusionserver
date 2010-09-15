SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP SCHEMA IF EXISTS `mydb` ;
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`variable`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`variable` ;

CREATE  TABLE IF NOT EXISTS `mydb`.`variable` (
  `idvariable` INT NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(45) NULL ,
  `value` BLOB NULL COMMENT 'This need to support arrays etc' ,
  `lastUpdated` VARCHAR(45) NULL ,
  `description` BLOB NULL ,
  `units` VARCHAR(45) NULL ,
  PRIMARY KEY (`idvariable`) )
ENGINE = InnoDB;

CREATE UNIQUE INDEX `idvariable_UNIQUE` ON `mydb`.`variable` (`idvariable` ASC) ;


-- -----------------------------------------------------
-- Table `mydb`.`tag`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`tag` ;

CREATE  TABLE IF NOT EXISTS `mydb`.`tag` (
  `idtag` INT NOT NULL ,
  `name` VARCHAR(45) NULL ,
  PRIMARY KEY (`idtag`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`detailVariableTag`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`detailVariableTag` ;

CREATE  TABLE IF NOT EXISTS `mydb`.`detailVariableTag` (
  `iddetailVariableTag` INT NOT NULL ,
  `idvariable` INT NULL ,
  `idtag` INT NULL ,
  PRIMARY KEY (`iddetailVariableTag`) ,
  CONSTRAINT `fkidvariableTag`
    FOREIGN KEY (`idvariable` )
    REFERENCES `mydb`.`variable` (`idvariable` )
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fkidtagVariable`
    FOREIGN KEY (`idtag` )
    REFERENCES `mydb`.`tag` (`idtag` )
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fkidvariableTag` ON `mydb`.`detailVariableTag` (`idvariable` ASC) ;

CREATE INDEX `fkidtagVariable` ON `mydb`.`detailVariableTag` (`idtag` ASC) ;


-- -----------------------------------------------------
-- Table `mydb`.`function`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`function` ;

CREATE  TABLE IF NOT EXISTS `mydb`.`function` (
  `idfunction` INT NOT NULL ,
  `name` VARCHAR(45) NULL ,
  `description` BLOB NULL ,
  `language` VARCHAR(45) NULL ,
  `function` BLOB NULL ,
  PRIMARY KEY (`idfunction`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`detailFunctionVariable`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`detailFunctionVariable` ;

CREATE  TABLE IF NOT EXISTS `mydb`.`detailFunctionVariable` (
  `iddetailFunctionVariable` INT NOT NULL ,
  `idfunction` INT NULL ,
  `idvariable` INT NULL ,
  `type` VARCHAR(45) NULL ,
  `defaultValue` BLOB NULL ,
  PRIMARY KEY (`iddetailFunctionVariable`) ,
  CONSTRAINT `fkfunctionVariable`
    FOREIGN KEY (`idfunction` )
    REFERENCES `mydb`.`function` (`idfunction` )
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fkvariableFunction`
    FOREIGN KEY (`idvariable` )
    REFERENCES `mydb`.`variable` (`idvariable` )
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fkfunctionVariable` ON `mydb`.`detailFunctionVariable` (`idfunction` ASC) ;

CREATE INDEX `fkvariableFunction` ON `mydb`.`detailFunctionVariable` (`idvariable` ASC) ;


-- -----------------------------------------------------
-- Table `mydb`.`session`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`session` ;

CREATE  TABLE IF NOT EXISTS `mydb`.`session` (
  `idsession` INT NOT NULL ,
  `name` VARCHAR(45) NULL COMMENT 'session name, the login name for the group or user' ,
  `description` VARCHAR(45) NULL COMMENT 'about the session' ,
  `password` VARCHAR(45) NULL COMMENT 'for group sessions only' ,
  `type` VARCHAR(45) NULL COMMENT 'group, user, global' ,
  `expiration` VARCHAR(45) NULL ,
  PRIMARY KEY (`idsession`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`detailVariableSession`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`detailVariableSession` ;

CREATE  TABLE IF NOT EXISTS `mydb`.`detailVariableSession` (
  `iddetailVariableSession` INT NOT NULL ,
  `idvariable` INT NULL ,
  `idsession` INT NULL ,
  `write` TINYINT(1)  NULL ,
  PRIMARY KEY (`iddetailVariableSession`) ,
  CONSTRAINT `fkidsessionVariable`
    FOREIGN KEY (`idsession` )
    REFERENCES `mydb`.`session` (`idsession` )
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fkidvariableSession`
    FOREIGN KEY (`idvariable` )
    REFERENCES `mydb`.`variable` (`idvariable` )
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fkidsessionVariable` ON `mydb`.`detailVariableSession` (`idsession` ASC) ;

CREATE INDEX `fkidvariableSession` ON `mydb`.`detailVariableSession` (`idvariable` ASC) ;


-- -----------------------------------------------------
-- Table `mydb`.`detailFunctionSession`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`detailFunctionSession` ;

CREATE  TABLE IF NOT EXISTS `mydb`.`detailFunctionSession` (
  `iddetailFunctionSession` INT NOT NULL ,
  `idfunction` INT NULL ,
  `idsession` INT NULL ,
  `write` TINYINT(1)  NULL ,
  PRIMARY KEY (`iddetailFunctionSession`) ,
  CONSTRAINT `fkidsessionFunction`
    FOREIGN KEY (`idsession` )
    REFERENCES `mydb`.`session` (`idsession` )
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fkidfunctionSession`
    FOREIGN KEY (`idfunction` )
    REFERENCES `mydb`.`function` (`idfunction` )
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fkidsessionFunction` ON `mydb`.`detailFunctionSession` (`idsession` ASC) ;

CREATE INDEX `fkidfunctionSession` ON `mydb`.`detailFunctionSession` (`idfunction` ASC) ;


-- -----------------------------------------------------
-- Table `mydb`.`detailFunctionTag`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`detailFunctionTag` ;

CREATE  TABLE IF NOT EXISTS `mydb`.`detailFunctionTag` (
  `iddetailFunctionTag` INT NOT NULL ,
  `idfunction` INT NULL ,
  `idtag` INT NULL ,
  PRIMARY KEY (`iddetailFunctionTag`) ,
  CONSTRAINT `fkfunctionTag`
    FOREIGN KEY (`idfunction` )
    REFERENCES `mydb`.`function` (`idfunction` )
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fktagFunction`
    FOREIGN KEY (`idtag` )
    REFERENCES `mydb`.`tag` (`idtag` )
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fkfunctionTag` ON `mydb`.`detailFunctionTag` (`idfunction` ASC) ;

CREATE INDEX `fktagFunction` ON `mydb`.`detailFunctionTag` (`idtag` ASC) ;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

