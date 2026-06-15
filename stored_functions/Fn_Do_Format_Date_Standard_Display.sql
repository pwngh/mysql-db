/* Fn_Do_Format_Date_Standard_Display.sql
 *
 * Formats a date as the uppercase 'DD-MON-YY' display form: '2024-03-13'
 * becomes '13-MAR-24'. NULL when the input is not a valid date.
 *
 * Why it exists:
 *   One of the standard display formats the DB layer guarantees: every
 *   consumer asking for the compact date gets the same string. Input is
 *   scrubbed through Fn_Do_Scrub_Date_Value first, so only real dates are
 *   formatted.
 *
 * See also: Fn_Do_Format_Date_Standard_Display_To_Hour when the hour
 *   matters too.
 *
 * Example:
 *   SELECT Fn_Do_Format_Date_Standard_Display('2024-03-13');  -- '13-MAR-24'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Format_Date_Standard_Display`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Format_Date_Standard_Display`(v_Date VARCHAR(80)) RETURNS varchar(80) CHARSET utf8mb4
BEGIN

SET v_Date = (SELECT Fn_Do_Scrub_Date_Value(v_Date)) ;

IF (DAYNAME(v_Date) IS NULL) THEN
      RETURN NULL ;
END IF;

RETURN UPPER(DATE_FORMAT(CAST(v_Date AS DATE), '%e-%b-%y')) ;

END
