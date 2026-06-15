/* Fn_Do_Scrub_Date_Value.sql
 *
 * Returns the input as a DATE when it is a genuine 'YYYY-MM-DD' calendar
 * date; otherwise NULL. Zero dates and almost-dates do not get through.
 *
 * Why it exists:
 *   Gatekeeper for everything date-shaped entering the system. The date
 *   display formatters all scrub through this first, so they only format
 *   values MySQL genuinely accepts as dates. DAYNAME() is the validity
 *   probe - it returns NULL for any invalid or zero date.
 *
 * Relationships:
 *   - Used by: the Fn_Do_Format_Date_* display functions and the nightly
 *     cleanup event
 *   - See also: Fn_Do_Convert_Date_Format_From_Display_To_Internal for
 *     parsing user-entered display dates
 *
 * Example:
 *   SELECT Fn_Do_Scrub_Date_Value('2024-03-13');  -- '2024-03-13'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Scrub_Date_Value`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Scrub_Date_Value`(v_Date VARCHAR(80)) RETURNS date
BEGIN

DECLARE v_Date_2 DATE DEFAULT NULL ;

IF (DAYNAME(v_Date) IS NULL) THEN
      RETURN NULL ;
END IF ;

SET v_Date_2 = IF((IFNULL(STR_TO_DATE(v_Date, '%Y-%m-%d'),'0000-00-00') = '0000-00-00'), NULL, CAST(v_Date AS DATE)) ;

RETURN IF((DAYNAME(v_Date_2) IS NULL), NULL, v_Date_2) ;

END
