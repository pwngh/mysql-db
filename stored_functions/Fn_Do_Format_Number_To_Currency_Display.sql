/* Fn_Do_Format_Number_To_Currency_Display.sql
 *
 * Formats a numeric value as US currency with cents: '1234.5' becomes
 * '$1,234.50'. NULL when no numeric value can be extracted.
 *
 * Why it exists:
 *   Currency rendering is a display rule, and display rules live in the DB
 *   layer so every consumer prints the same string. Input is scrubbed
 *   through Fn_Do_Scrub_Decimal_Money_Value first, so '$1,234.5' and
 *   '1234.5' format identically.
 *
 * See also: Fn_Do_Format_Number_To_Currency_Display_Short for whole-dollar
 *   output, Fn_Do_Format_Number_Wrap_With_Parenthesis for accounting-style
 *   negatives.
 *
 * Example:
 *   SELECT Fn_Do_Format_Number_To_Currency_Display('1234.5');  -- '$1,234.50'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Format_Number_To_Currency_Display`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Format_Number_To_Currency_Display`(v_Number VARCHAR(80)) RETURNS varchar(80) CHARSET utf8mb4
BEGIN

SET v_Number = (SELECT Fn_Do_Scrub_Decimal_Money_Value(v_Number)) ;

IF (IFNULL(v_Number,'') = '') THEN
      RETURN NULL ;
END IF;

RETURN CONCAT('$', FORMAT(CAST(v_Number AS DECIMAL(8,2)),2)) ;

END
