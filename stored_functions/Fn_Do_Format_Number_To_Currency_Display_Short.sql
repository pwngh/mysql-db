/* Fn_Do_Format_Number_To_Currency_Display_Short.sql
 *
 * Formats a numeric value as whole-dollar US currency: '1234.5' becomes
 * '$1,235' (rounded). NULL when no numeric value can be extracted.
 *
 * Why it exists:
 *   Summary rows and dashboards drop the cents; keeping that variant as a
 *   named format in the DB layer beats ad-hoc ROUND/CONCAT in each query.
 *   Same money scrub as the full version, so both accept the same loose
 *   input.
 *
 * See also: Fn_Do_Format_Number_To_Currency_Display (with cents).
 *
 * Example:
 *   SELECT Fn_Do_Format_Number_To_Currency_Display_Short('1234.5');  -- '$1,235'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Format_Number_To_Currency_Display_Short`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Format_Number_To_Currency_Display_Short`(v_Number VARCHAR(80)) RETURNS varchar(80) CHARSET utf8mb4
BEGIN

SET v_Number = (SELECT Fn_Do_Scrub_Decimal_Money_Value(v_Number)) ;

IF (IFNULL(v_Number,'') = '') THEN
      RETURN NULL ;
END IF;

RETURN CONCAT('$', FORMAT(CAST(v_Number AS DECIMAL(8,2)),0)) ;

END
