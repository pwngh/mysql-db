/* Fn_Do_Scrub_Decimal_Money_Value.sql
 *
 * Extracts a money amount from a string: digits, at most one leading minus,
 * at most one decimal point. Returns a DECIMAL(8,2), or NULL when there is
 * nothing numeric to extract.
 *
 * Why it exists:
 *   The stricter sibling of Fn_Do_Scrub_Decimal_Value, for places where the
 *   result has to be one well-formed amount. Stray '-' or '.' characters
 *   later in the string are dropped rather than allowed to scramble the
 *   value, and empty input yields NULL instead of a fake 0.00.
 *
 * Used by: Fn_Do_Format_Number_To_Currency_Display and its _Short variant.
 *
 * Example:
 *   SELECT Fn_Do_Scrub_Decimal_Money_Value('$1,234.5');  -- '1234.50'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Scrub_Decimal_Money_Value`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Scrub_Decimal_Money_Value`(v_String_Source VARCHAR(20)) RETURNS varchar(20) CHARSET utf8mb4
BEGIN


DECLARE v_String_Result VARCHAR(20) DEFAULT '' ;
DECLARE v_Pos SMALLINT UNSIGNED DEFAULT '1' ;
DECLARE v_Len SMALLINT UNSIGNED DEFAULT CHAR_LENGTH(v_String_Source) ;

DECLARE v_Negative_Cnt SMALLINT UNSIGNED DEFAULT '0' ; -- allow at most one negative sign per value, and only in position 1
DECLARE v_Decimal_Cnt SMALLINT UNSIGNED DEFAULT '0' ; -- allow at most one decimal point per value


IF(IFNULL(v_String_Source,'') = '') THEN
      RETURN NULL ;
END IF;


WHILE (v_Pos <= v_Len) DO

      IF ((v_Negative_Cnt > 0) OR (v_Pos > 1))  AND (v_Decimal_Cnt > 0) THEN

            SET v_Negative_Cnt = (v_Negative_Cnt + IF((SUBSTRING(v_String_Source, v_Pos, 1) = '-'), 1, 0)) ;
            SET v_Decimal_Cnt = (v_Decimal_Cnt + IF((SUBSTRING(v_String_Source, v_Pos, 1) = '.'), 1, 0)) ;
            SET v_String_Result = CONCAT(v_String_Result, IF((SUBSTRING(v_String_Source, v_Pos, 1) IN ('0','1','2','3','4','5','6','7','8','9')), SUBSTRING(v_String_Source, v_Pos, 1), '')) ;

      ELSEIF ((v_Negative_Cnt > 0) OR (v_Pos > 1)) THEN

            SET v_Negative_Cnt = (v_Negative_Cnt + IF((SUBSTRING(v_String_Source, v_Pos, 1) = '-'), 1, 0)) ;
            SET v_Decimal_Cnt = (v_Decimal_Cnt + IF((SUBSTRING(v_String_Source, v_Pos, 1) = '.'), 1, 0)) ;
            SET v_String_Result = CONCAT(v_String_Result, IF((SUBSTRING(v_String_Source, v_Pos, 1) IN ('.','0','1','2','3','4','5','6','7','8','9')), SUBSTRING(v_String_Source, v_Pos, 1), '')) ;

      ELSEIF (v_Decimal_Cnt > 0) THEN

            SET v_Negative_Cnt = (v_Negative_Cnt + IF((SUBSTRING(v_String_Source, v_Pos, 1) = '-'), 1, 0)) ;
            SET v_Decimal_Cnt = (v_Decimal_Cnt + IF((SUBSTRING(v_String_Source, v_Pos, 1) = '.'), 1, 0)) ;
            SET v_String_Result = CONCAT(v_String_Result, IF((SUBSTRING(v_String_Source, v_Pos, 1) IN ('-','0','1','2','3','4','5','6','7','8','9')), SUBSTRING(v_String_Source, v_Pos, 1), '')) ;

      ELSE

            SET v_Negative_Cnt = (v_Negative_Cnt + IF((SUBSTRING(v_String_Source, v_Pos, 1) = '-'), 1, 0)) ;
            SET v_Decimal_Cnt = (v_Decimal_Cnt + IF((SUBSTRING(v_String_Source, v_Pos, 1) = '.'), 1, 0)) ;
            SET v_String_Result = CONCAT(v_String_Result, IF((SUBSTRING(v_String_Source, v_Pos, 1) IN ('-','.','0','1','2','3','4','5','6','7','8','9')), SUBSTRING(v_String_Source, v_Pos, 1), '')) ;

      END IF;


      SET v_Pos = v_Pos + 1 ;


END WHILE;


IF(IFNULL(v_String_Result,'') = '') THEN
      RETURN NULL ;
END IF;


IF(IFNULL(REPLACE(REPLACE(v_String_Result,'-',''),'.',''),'') = '') THEN
      RETURN NULL ;
END IF;



RETURN CAST(v_String_Result AS DECIMAL(8,2)) ;



END