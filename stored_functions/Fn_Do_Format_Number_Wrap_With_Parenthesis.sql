/* Fn_Do_Format_Number_Wrap_With_Parenthesis.sql
 *
 * Wraps a value in parentheses for accounting-style negative display.
 * Empty or NULL input returns NULL.
 *
 * Why it exists:
 *   Financial views show negatives as '(1,234.50)' rather than with a minus
 *   sign. The wrap is its own small step so it can be applied after any of
 *   the currency formatters, only when the caller knows the value is
 *   negative - the input is not validated or parsed as numeric.
 *
 * Example:
 *   SELECT Fn_Do_Format_Number_Wrap_With_Parenthesis('1,234.50');  -- '(1,234.50)'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Format_Number_Wrap_With_Parenthesis`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Format_Number_Wrap_With_Parenthesis`(v_Number VARCHAR(80)) RETURNS varchar(80) CHARSET utf8mb4
BEGIN

IF (IFNULL(v_Number,'') = '') THEN
      RETURN NULL ;
END IF;

RETURN CONCAT('(', v_Number, ')') ;

END
