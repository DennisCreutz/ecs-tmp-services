CREATE TABLE `tmp` (
                       `userId` VARCHAR(255) NOT NULL,
                       `serviceId` VARCHAR(255) NOT NULL,
                       `created` TIMESTAMP NOT NULL,
                       `isMarkedForDeletion` BOOLEAN NOT NULL DEFAULT false,
                       `id` INT NOT NULL AUTO_INCREMENT,
                       PRIMARY KEY (`id`)
);
