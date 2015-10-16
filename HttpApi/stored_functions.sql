USE `stream_center`;
DROP function IF EXISTS `addNewCustomURL`;

DELIMITER $$
USE `stream_center`$$
#Created by Olivier Boucher
CREATE FUNCTION `addNewCustomURL` (url TEXT)
RETURNS VARCHAR(5)
BEGIN

DECLARE has_error TINYINT DEFAULT 0;
DECLARE acode VARCHAR(5);
DECLARE lid INT;

DECLARE CONTINUE HANDLER FOR 1062 SET has_error = 1;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET acode = NULL;

SELECT custom_urls.code INTO acode FROM custom_urls WHERE custom_urls.url = url;

IF acode IS NULL THEN
	retry:
	REPEAT
		BEGIN
			SET has_error = 0;
			SET lid = LAST_INSERT_ID();
			SET acode =  LEFT(UUID(), 5);
			INSERT INTO custom_urls(url, generated_date, code) VALUES (url, NOW(), acode);

			IF has_error = 0 THEN
				LEAVE retry;
			END IF;

		END;
	UNTIL FALSE END REPEAT;
END IF;

RETURN acode;

END
$$

DELIMITER ;

