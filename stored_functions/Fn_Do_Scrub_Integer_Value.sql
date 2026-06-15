/* Fn_Do_Scrub_Integer_Value.sql
 *
 * Strips everything but digits and '-' from a string and returns the result
 * as an integer - SIGNED when a minus sign survived, UNSIGNED otherwise.
 *
 * Why it exists:
 *   Counterpart to Fn_Do_Scrub_Decimal_Value for whole numbers: pulls a
 *   usable integer out of formatted input ('$1,234 USD') instead of letting
 *   CAST give up at the first non-digit.
 *
 * Notes:
 *   - Returns 0 (not NULL) when the input has no digits, even for NULL input.
 *   - Not range-checked. ID values go through Fn_Do_Scrub_Data_Id_Value or
 *     Fn_Do_Scrub_Ref_Id_Value instead, which reject rather than repair.
 *
 * Example:
 *   SELECT Fn_Do_Scrub_Integer_Value('$1,234 USD');  -- '1234'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Scrub_Integer_Value`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Scrub_Integer_Value`(v_String_Source VARCHAR(20)) RETURNS varchar(20) CHARSET utf8mb4
BEGIN

DECLARE v_String_Result VARCHAR(20) DEFAULT '' ;
DECLARE v_Pos SMALLINT DEFAULT '1' ;
DECLARE v_Len SMALLINT DEFAULT CHAR_LENGTH(v_String_Source) ;

WHILE (v_Pos <= v_Len) DO

      SET v_String_Result = CONCAT(v_String_Result, IF((SUBSTRING(v_String_Source, v_Pos, 1) IN ('-','0','1','2','3','4','5','6','7','8','9')), SUBSTRING(v_String_Source, v_Pos, 1), '')) ;

      SET v_Pos = v_Pos + 1 ;

END WHILE;


IF (INSTR(v_String_Result, '-') > 0) THEN
      RETURN CAST(v_String_Result AS SIGNED) ;
ELSE
      RETURN CAST(v_String_Result AS UNSIGNED) ;
END IF;


END
