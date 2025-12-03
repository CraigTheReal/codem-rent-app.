

CREATE TABLE IF NOT EXISTS `line_rentals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(50) NOT NULL,
  `vehicleModel` varchar(50) NOT NULL,
  `plate` varchar(10) NOT NULL,
  `rentalFee` int(11) NOT NULL DEFAULT 0,
  `costPerInterval` int(11) NOT NULL DEFAULT 0,
  `totalCost` int(11) NOT NULL DEFAULT 0,
  `startedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `endedAt` timestamp NULL DEFAULT NULL,
  `tripDuration` int(11) NOT NULL DEFAULT 0,
  `isActive` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`),
  KEY `isActive` (`isActive`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

