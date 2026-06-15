/* Fn_Do_Scrub_Decimal_Value.sql
 *
 * Strips everything but digits, '-' and '.' from a string and returns what
 * remains as a DECIMAL(9,3). '$1,234.5 USD' comes back as 1234.500.
 *
 * Why it exists:
 *   General-purpose numeric scrub for values that arrive dressed up with
 *   currency symbols, separators, or units. Walking the string and keeping
 *   the numeric characters beats CAST, which gives up at the first
 *   non-numeric character.
 *
 * Notes:
 *   - Returns 0.000 (not NULL) when nothing numeric is found, even for NULL
 *     input. Callers that must distinguish "no value" should use
 *     Fn_Do_Scrub_Decimal_Money_Value, which also enforces a single minus
 *     sign and decimal point.
 *
 * Example:
 *   SELECT Fn_Do_Scrub_Decimal_Value('$1,234.5 USD');  -- '1234.500'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Scrub_Decimal_Value`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Scrub_Decimal_Value`(v_String_Source VARCHAR(20)) RETURNS varchar(20) CHARSET utf8mb4
BEGIN

DECLARE v_String_Result VARCHAR(20) DEFAULT '' ;
DECLARE v_Pos SMALLINT DEFAULT '1' ;
DECLARE v_Len SMALLINT DEFAULT CHAR_LENGTH(v_String_Source) ;

WHILE (v_Pos <= v_Len) DO

      SET v_String_Result = CONCAT(v_String_Result, IF((SUBSTRING(v_String_Source, v_Pos, 1) IN ('-','.','0','1','2','3','4','5','6','7','8','9')), SUBSTRING(v_String_Source, v_Pos, 1), '')) ;

      SET v_Pos = v_Pos + 1 ;

END WHILE;


RETURN CAST(v_String_Result AS DECIMAL(9,3)) ;


END
