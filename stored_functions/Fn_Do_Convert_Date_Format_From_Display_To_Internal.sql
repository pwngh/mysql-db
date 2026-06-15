/* Fn_Do_Convert_Date_Format_From_Display_To_Internal.sql
 *
 * Best-effort parser for user-entered dates: takes M-D-Y input with dash,
 * slash, dot, space, or comma delimiters - 2-digit years and trailing time
 * portions tolerated - and returns 'YYYY-MM-DD', or NULL when nothing
 * parseable is left.
 *
 * Why it exists:
 *   The inbound mirror of the date display formatters. Display formats are
 *   for humans; queries and storage want the internal form. Doing the
 *   conversion here keeps "which date strings do we accept" defined once,
 *   in the same layer that defines how dates are shown.
 *
 * Notes:
 *   - Assumes US month-day-year ordering for delimited input.
 *   - Values already in 'YYYY-MM-DD[ time]' form pass straight through.
 *   - Returns NULL rather than guessing when parsing fails.
 *
 * See also: Fn_Do_Scrub_Date_Value, the strict gate for already-internal
 *   dates.
 *
 * Example:
 *   SELECT Fn_Do_Convert_Date_Format_From_Display_To_Internal('3/13/24');  -- '2024-03-13'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Convert_Date_Format_From_Display_To_Internal`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Convert_Date_Format_From_Display_To_Internal`(v_Date VARCHAR(20)) RETURNS varchar(30) CHARSET utf8mb4
BEGIN

DECLARE v_Date_2 INT DEFAULT NULL ; -- used for attempting a 2-digit year conversion

SET v_Date = (SELECT Fn_Do_Remove_Duplicate_Spaces_From_Text(v_Date)) ; -- remove any starting or ending spaces and any duplicate spaces

IF ((CHAR_LENGTH(v_Date) >= 8) AND (LOCATE('-', v_Date) = 5)) THEN -- we may have a properly formatted date or date/time (first occurrence of a dash is at position 5)
      IF (DAYNAME(CAST(CAST(v_Date AS DATE) AS CHAR)) IS NOT NULL) THEN -- if we were passed a valid date
            RETURN CAST(CAST(v_Date AS DATE) AS CHAR) ; -- return the valid date now, else we simply continue
      END IF;
END IF;


SET v_Date = TRIM(v_Date) ; -- remove any starting or ending spaces

IF (IFNULL(v_Date,'') = '') THEN -- if we don't have anything to work with
    RETURN NULL ; -- return null
END IF;


SET v_Date = (CASE WHEN ((CHAR_LENGTH(v_Date) > 10) AND (SUBSTRING(v_Date, 11, 1) = ' ')) -- if we have a 10-digit date with a time, and with date and time delimited by a space
                   THEN TRIM(LEFT(v_Date, 10)) -- remove the time portion

                   WHEN ((CHAR_LENGTH(v_Date) > 9) AND (SUBSTRING(v_Date, 10, 1) = ' ')) -- if we have a 9-digit date with a time, and with date and time delimited by a space
                   THEN TRIM(LEFT(v_Date, 9)) -- remove the time portion

                   WHEN ((CHAR_LENGTH(v_Date) > 8) AND (SUBSTRING(v_Date, 9, 1) = ' ')) -- if we have a 8-digit date with a time, and with date and time delimited by a space
                   THEN TRIM(LEFT(v_Date, 8)) -- remove the time portion

                   WHEN ((CHAR_LENGTH(v_Date) > 7) AND (SUBSTRING(v_Date, 8, 1) = ' ')) -- if we have a 7-digit date with a time, and with date and time delimited by a space
                   THEN TRIM(LEFT(v_Date, 7)) -- remove the time portion

                   WHEN ((CHAR_LENGTH(v_Date) > 6) AND (SUBSTRING(v_Date, 7, 1) = ' ')) -- if we have a 6-digit date with a time, and with date and time delimited by a space
                   THEN TRIM(LEFT(v_Date, 6)) -- remove the time portion

                   ELSE v_Date END) ;


-- convert all likely day, month, year delimiters to dashes
SET v_Date = REPLACE(
             REPLACE(
             REPLACE(
             REPLACE(
                     TRIM(LEFT(TRIM(v_Date), 10)) , -- we know a valid date cannot contain more than 10 characters
             ' ', '-') ,
             '.', '-') ,
             '/', '-') ,
             ',', '-') ;


-- if any multiple dashes convert to single dashes
SET v_Date = REPLACE(
             REPLACE(
             REPLACE(
                     TRIM(v_Date) ,
             '--', '-') ,
             '--', '-') ,
             '--', '-') ;


SET v_Date = TRIM(v_Date) ; -- remove any starting or ending spaces


-- if we have a 2-digit year we try a 2-digit year converter
IF ((CHAR_LENGTH(v_Date) >= 6) AND (CHAR_LENGTH(v_Date) <= 8)) AND (SUBSTRING(v_Date, (CHAR_LENGTH(v_Date) - 2), 1) = '-') THEN

      SET v_Date_2 = CAST(CAST(STR_TO_DATE(v_Date,'%m-%d-%y') AS DATE) AS CHAR) ; -- we try to convert with a 2-digit year

      IF (DAYNAME(CAST(CAST(v_Date_2 AS DATE) AS CHAR)) IS NOT NULL) THEN -- if we generated a valid date
            RETURN CAST(CAST(v_Date_2 AS DATE) AS CHAR) ; -- return the valid date
      END IF;

END IF;


SET v_Date = CAST(CAST(STR_TO_DATE(v_Date,'%m-%d-%Y') AS DATE) AS CHAR) ;


IF (DAYNAME(CAST(CAST(v_Date AS DATE) AS CHAR)) IS NOT NULL) THEN -- if we generated a valid date
      RETURN CAST(CAST(v_Date AS DATE) AS CHAR) ; -- return the valid date
END IF;


RETURN NULL ; -- if we get here we did not generate a valid date, so return a null value


END