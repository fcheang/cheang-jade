CREATE TABLE  `jade`.`standardholiday` (
  `name` varchar(50) NOT NULL,
  `isObserved` tinyint(1) default NULL,
  `startDate` datetime default NULL,
  `endDate` datetime default NULL,
  PRIMARY KEY  (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE  `jade`.`location` (
  `name` varchar(45) NOT NULL,
  PRIMARY KEY  (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE  `jade`.`employee` (
  `employeeSeq` int(10) unsigned NOT NULL auto_increment,
  `lastName` varchar(45) NOT NULL,
  `middleName` varchar(45) default '',
  `firstName` varchar(45) NOT NULL,
  `title` varchar(45) default '',
  PRIMARY KEY  (`employeeSeq`),
  UNIQUE KEY `Index_2` (`lastName`,`firstName`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

CREATE TABLE  `jade`.`employeeview` (
  `employeeViewSeq` int(10) unsigned NOT NULL auto_increment,
  `viewName` varchar(200) NOT NULL,
  PRIMARY KEY  (`employeeViewSeq`),
  UNIQUE KEY `Index_2` (`viewName`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

CREATE TABLE  `jade`.`role` (
  `name` varchar(45) NOT NULL,
  PRIMARY KEY  (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

CREATE TABLE  `jade`.`user` (
  `userId` varchar(45) NOT NULL,
  `password` varchar(45) NOT NULL,
  `role` varchar(45) NOT NULL,
  `employeeViewSeq` int(10) unsigned default NULL,
  `description` varchar(200),
  `assignedTo` varchar(45),
  PRIMARY KEY  (`userId`),
  KEY `FK_user_1` (`role`),
  KEY `FK_user_2` (`employeeViewSeq`),
  CONSTRAINT `FK_user_1` FOREIGN KEY (`role`) REFERENCES `role` (`name`),
  CONSTRAINT `FK_user_2` FOREIGN KEY (`employeeViewSeq`) REFERENCES `employeeview` (`employeeViewSeq`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE  `jade`.`viewmapping` (
  `employeeViewSeq` int(10) unsigned NOT NULL,
  `employeeSeq` int(10) unsigned NOT NULL,
  `location` varchar(45) NOT NULL,
  PRIMARY KEY  (`employeeViewSeq`,`employeeSeq`, `location`),
  KEY `FK_viewMapping_2` (`employeeSeq`),
  CONSTRAINT `FK_viewMapping_1` FOREIGN KEY (`employeeViewSeq`) REFERENCES `employeeview` (`employeeViewSeq`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_viewMapping_2` FOREIGN KEY (`employeeSeq`) REFERENCES `employee` (`employeeSeq`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_viewMapping_3` FOREIGN KEY (`location`) REFERENCES `location` (`name`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE  `jade`.`timesheet` (
  `employeeSeq` int(10) unsigned NOT NULL auto_increment,
  `location` varchar(45) NOT NULL,
  `date` datetime NOT NULL,
  `worked` decimal(10,2) NOT NULL default '0',
  `overtime` decimal(10,2) NOT NULL default '0',
  `vacation` decimal(10,2) NOT NULL default '0',
  `sick` decimal(10,2) NOT NULL default '0',
  `floating` decimal(10,2) NOT NULL default '0',
  `holiday` decimal(10,2) NOT NULL default '0',
  `other` decimal(10,2) NOT NULL default '0',
  `comments` varchar(200) default NULL,
  `createdBy` varchar(45) NOT NULL,
  PRIMARY KEY  (`employeeSeq`,`location`,`date`),
  KEY `FK_timesheet_2` (`location`),
  KEY `FK_timesheet_4` (`createdBy`),
  CONSTRAINT `FK_timesheet_1` FOREIGN KEY (`employeeSeq`) REFERENCES `employee` (`employeeSeq`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_timesheet_2` FOREIGN KEY (`location`) REFERENCES `location` (`name`),
  CONSTRAINT `FK_timesheet_4` FOREIGN KEY (`createdBy`) REFERENCES `user` (`userId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;