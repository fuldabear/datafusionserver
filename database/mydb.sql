-- MySQL dump 10.13  Distrib 5.1.41, for debian-linux-gnu (i486)
--
-- Host: localhost    Database: mydb
-- ------------------------------------------------------
-- Server version	5.1.41-3ubuntu12.6

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `detailFunctionSession`
--

DROP TABLE IF EXISTS `detailFunctionSession`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `detailFunctionSession` (
  `iddetailFunctionSession` int(11) NOT NULL AUTO_INCREMENT,
  `idfunction` int(11) DEFAULT NULL,
  `idsession` int(11) DEFAULT NULL,
  `write` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`iddetailFunctionSession`),
  KEY `fkidsessionFunction` (`idsession`),
  KEY `fkidfunctionSession` (`idfunction`),
  CONSTRAINT `fkidfunctionSession` FOREIGN KEY (`idfunction`) REFERENCES `function` (`idfunction`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fkidsessionFunction` FOREIGN KEY (`idsession`) REFERENCES `session` (`idsession`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detailFunctionSession`
--

LOCK TABLES `detailFunctionSession` WRITE;
/*!40000 ALTER TABLE `detailFunctionSession` DISABLE KEYS */;
/*!40000 ALTER TABLE `detailFunctionSession` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detailFunctionTag`
--

DROP TABLE IF EXISTS `detailFunctionTag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `detailFunctionTag` (
  `iddetailFunctionTag` int(11) NOT NULL AUTO_INCREMENT,
  `idfunction` int(11) DEFAULT NULL,
  `idtag` int(11) DEFAULT NULL,
  PRIMARY KEY (`iddetailFunctionTag`),
  KEY `fkfunctionTag` (`idfunction`),
  KEY `fktagFunction` (`idtag`),
  CONSTRAINT `fkfunctionTag` FOREIGN KEY (`idfunction`) REFERENCES `function` (`idfunction`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fktagFunction` FOREIGN KEY (`idtag`) REFERENCES `tag` (`idtag`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detailFunctionTag`
--

LOCK TABLES `detailFunctionTag` WRITE;
/*!40000 ALTER TABLE `detailFunctionTag` DISABLE KEYS */;
/*!40000 ALTER TABLE `detailFunctionTag` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detailFunctionVariable`
--

DROP TABLE IF EXISTS `detailFunctionVariable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `detailFunctionVariable` (
  `iddetailFunctionVariable` int(11) NOT NULL AUTO_INCREMENT,
  `idfunction` int(11) DEFAULT NULL,
  `idvariable` int(11) DEFAULT NULL,
  `type` varchar(45) DEFAULT NULL,
  `defaultValue` blob,
  PRIMARY KEY (`iddetailFunctionVariable`),
  KEY `fkfunctionVariable` (`idfunction`),
  KEY `fkvariableFunction` (`idvariable`),
  CONSTRAINT `fkfunctionVariable` FOREIGN KEY (`idfunction`) REFERENCES `function` (`idfunction`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fkvariableFunction` FOREIGN KEY (`idvariable`) REFERENCES `variable` (`idvariable`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detailFunctionVariable`
--

LOCK TABLES `detailFunctionVariable` WRITE;
/*!40000 ALTER TABLE `detailFunctionVariable` DISABLE KEYS */;
/*!40000 ALTER TABLE `detailFunctionVariable` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detailVariableSession`
--

DROP TABLE IF EXISTS `detailVariableSession`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `detailVariableSession` (
  `iddetailVariableSession` int(11) NOT NULL AUTO_INCREMENT,
  `idvariable` int(11) DEFAULT NULL,
  `idsession` int(11) DEFAULT NULL,
  `rw` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`iddetailVariableSession`),
  KEY `fkidsessionVariable` (`idsession`),
  KEY `fkidvariableSession` (`idvariable`),
  CONSTRAINT `fkidsessionVariable` FOREIGN KEY (`idsession`) REFERENCES `session` (`idsession`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fkidvariableSession` FOREIGN KEY (`idvariable`) REFERENCES `variable` (`idvariable`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detailVariableSession`
--

LOCK TABLES `detailVariableSession` WRITE;
/*!40000 ALTER TABLE `detailVariableSession` DISABLE KEYS */;
INSERT INTO `detailVariableSession` VALUES (1,1,20,1);
/*!40000 ALTER TABLE `detailVariableSession` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detailVariableTag`
--

DROP TABLE IF EXISTS `detailVariableTag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `detailVariableTag` (
  `iddetailVariableTag` int(11) NOT NULL AUTO_INCREMENT,
  `idvariable` int(11) DEFAULT NULL,
  `idtag` int(11) DEFAULT NULL,
  PRIMARY KEY (`iddetailVariableTag`),
  KEY `fkidvariableTag` (`idvariable`),
  KEY `fkidtagVariable` (`idtag`),
  CONSTRAINT `fkidtagVariable` FOREIGN KEY (`idtag`) REFERENCES `tag` (`idtag`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fkidvariableTag` FOREIGN KEY (`idvariable`) REFERENCES `variable` (`idvariable`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detailVariableTag`
--

LOCK TABLES `detailVariableTag` WRITE;
/*!40000 ALTER TABLE `detailVariableTag` DISABLE KEYS */;
/*!40000 ALTER TABLE `detailVariableTag` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `function`
--

DROP TABLE IF EXISTS `function`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `function` (
  `idfunction` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) DEFAULT NULL,
  `description` blob,
  `language` varchar(45) DEFAULT NULL,
  `function` blob,
  PRIMARY KEY (`idfunction`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `function`
--

LOCK TABLES `function` WRITE;
/*!40000 ALTER TABLE `function` DISABLE KEYS */;
/*!40000 ALTER TABLE `function` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `session`
--

DROP TABLE IF EXISTS `session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `session` (
  `idsession` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) DEFAULT NULL COMMENT 'session name, the login name for the group or user',
  `description` varchar(45) DEFAULT NULL COMMENT 'about the session',
  `password` varchar(45) DEFAULT NULL COMMENT 'for group sessions only',
  `expiration` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idsession`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `session`
--

LOCK TABLES `session` WRITE;
/*!40000 ALTER TABLE `session` DISABLE KEYS */;
INSERT INTO `session` VALUES (20,'david','developer user','brennan','0'),(26,'tester','This should be the best session the world has','connor','1293253200');
/*!40000 ALTER TABLE `session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tag`
--

DROP TABLE IF EXISTS `tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag` (
  `idtag` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idtag`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tag`
--

LOCK TABLES `tag` WRITE;
/*!40000 ALTER TABLE `tag` DISABLE KEYS */;
/*!40000 ALTER TABLE `tag` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `variable`
--

DROP TABLE IF EXISTS `variable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `variable` (
  `idvariable` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) DEFAULT NULL,
  `value` blob COMMENT 'This need to support arrays etc',
  `lastUpdated` varchar(45) DEFAULT NULL,
  `description` blob,
  `units` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idvariable`),
  UNIQUE KEY `idvariable_UNIQUE` (`idvariable`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `variable`
--

LOCK TABLES `variable` WRITE;
/*!40000 ALTER TABLE `variable` DISABLE KEYS */;
INSERT INTO `variable` VALUES (1,'bb','2',NULL,NULL,NULL),(2,'b','47',NULL,NULL,NULL),(3,'c','89',NULL,NULL,NULL),(4,'[d,e,f]','[9,76,45]',NULL,NULL,NULL),(5,'d','9','1286539045',NULL,NULL),(6,'e','76','1286539045',NULL,NULL),(7,'f','45','1286539045',NULL,NULL),(8,'x','1','1286773542',NULL,NULL),(9,'y','2','1286773542',NULL,NULL),(10,'z','3','1286773542',NULL,NULL),(11,'t','1','1286779268',NULL,NULL),(12,'h','2','1286779268',NULL,NULL),(13,'j','3','1286779268',NULL,NULL);
/*!40000 ALTER TABLE `variable` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2010-10-11  9:40:02
