/* Fn_Do_Format_DateTime_Time_Zone_Prefix_Display_To_Min.sql
 *
 * Renders a stored UTC datetime for display in a target zone, with a label
 * in front and the zone abbreviation behind:
 * 'Updated: Mar 13, 2024, 2:33 pm (CDT)'.
 *
 * Why it exists:
 *   Datetimes are stored in UTC and converted only at display time. This is
 *   the display-side workhorse for that rule: label, zone conversion, short
 *   format, and DST-aware abbreviation in one call, so 'Updated:' lines look
 *   the same on every page.
 *
 * Input / Output:
 *   - v_Prefix: label prepended verbatim (NULL treated as '')
 *   - v_DateTime: UTC datetime, scrubbed via Fn_Do_Scrub_DateTime_Value
 *   - v_Time_Zone: target zone or alias; defaults to America/Chicago
 *   - Returns the display string, or NULL for an invalid datetime
 *
 * Notes:
 *   - Same hardcoded US-zone abbreviation CASE as the As-of builders; other
 *     valid zones show their full name.
 *
 * Example:
 *   SELECT Fn_Do_Format_DateTime_Time_Zone_Prefix_Display_To_Min('Updated: ', '2024-03-13 19:33:19', 'CT');  -- 'Updated: Mar 13, 2024, 2:33 pm (CDT)'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Format_DateTime_Time_Zone_Prefix_Display_To_Min`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Format_DateTime_Time_Zone_Prefix_Display_To_Min`(v_Prefix VARCHAR(20), v_DateTime VARCHAR(80), v_Time_Zone VARCHAR(80)) RETURNS varchar(80) CHARSET utf8mb4
BEGIN

DECLARE v_UTC_Offset INT UNSIGNED DEFAULT '0' ;

SET v_DateTime = (SELECT Fn_Do_Scrub_DateTime_Value(v_DateTime)) ;

IF (DAYNAME(v_DateTime) IS NULL) THEN
 RETURN NULL ;
END IF;

SET v_Time_Zone = IFNULL((Fn_Do_Scrub_Time_Zone_Value(v_Time_Zone)),'America/Chicago') ;

SET v_UTC_Offset = ABS(TIMESTAMPDIFF(HOUR, CONVERT_TZ(UTC_TIMESTAMP, 'UTC', v_Time_Zone), UTC_TIMESTAMP)) ;


RETURN CONCAT((IFNULL(v_Prefix,'')) ,
              -- ------------------------------
              (SELECT Fn_Do_Format_DateTime_Standard_Display_Short_To_Min(CONVERT_TZ(v_DateTime, 'UTC', v_Time_Zone))) ,
              -- ------------------------------
              (CASE WHEN (IFNULL(v_Time_Zone,'') = 'America/New_York')
                     AND (v_UTC_Offset = 5) -- 5 hour difference
                    THEN ' (EST)' -- Eastern Standard Time
                    -- ------------------------------
                    WHEN (IFNULL(v_Time_Zone,'') = 'America/New_York')
                     AND (v_UTC_Offset = 4) -- 4 hour difference
                    THEN ' (EDT)' -- Eastern Daylight Time
                    -- ------------------------------
                    -- ------------------------------
                    WHEN (IFNULL(v_Time_Zone,'') = 'America/Chicago')
                     AND (v_UTC_Offset = 6) -- 6 hour difference
                    THEN ' (CST)' -- Central Standard Time
                    -- ------------------------------
                    WHEN (IFNULL(v_Time_Zone,'') = 'America/Chicago')
                     AND (v_UTC_Offset = 5) -- 5 hour difference
                    THEN ' (CDT)' -- Central Daylight Time
                    -- ------------------------------
                    -- ------------------------------
                    WHEN (IFNULL(v_Time_Zone,'') = 'America/Denver')
                     AND (v_UTC_Offset = 7) -- 7 hour difference
                    THEN ' (MST)' -- Mountain Standard Time
                    -- ------------------------------
                    WHEN (IFNULL(v_Time_Zone,'') = 'America/Denver')
                     AND (v_UTC_Offset = 6) -- 6 hour difference
                    THEN ' (MDT)' -- Mountain Daylight Time
                    -- ------------------------------
                    -- ------------------------------
                    WHEN (IFNULL(v_Time_Zone,'') = 'America/Phoenix') -- Phoenix timezone is always on Mountain Standard Time
                    THEN ' (MST)' -- Mountain Standard Time
                    -- ------------------------------
                    -- ------------------------------
                    WHEN (IFNULL(v_Time_Zone,'') = 'America/Los_Angeles')
                     AND (v_UTC_Offset = 8) -- 8 hour difference
                    THEN ' (PST)' -- Pacific Standard Time
                    -- ------------------------------
                    WHEN (IFNULL(v_Time_Zone,'') = 'America/Los_Angeles')
                     AND (v_UTC_Offset = 7) -- 7 hour difference
                    THEN ' (PDT)' -- Pacific Daylight Time
                    -- ------------------------------
                    -- ------------------------------
                    ELSE CONCAT(' (',v_Time_Zone, ')') END)) ;


END