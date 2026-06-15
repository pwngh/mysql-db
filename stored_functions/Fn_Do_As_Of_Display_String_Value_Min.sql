/* Fn_Do_As_Of_Display_String_Value_Min.sql
 *
 * Compact variant of Fn_Do_As_Of_Display_String_Value:
 * 'As of: Mar 13, 2024, 7:33 pm (CDT)'. Same zone handling, shorter date
 * format for tighter layouts.
 *
 * Why it exists:
 *   Same rationale as the long form - the "As of" stamp is built in the DB
 *   layer so every surface renders it identically. Only the date style
 *   differs ('Mon D, YYYY' instead of weekday plus numeric date).
 *
 * Notes:
 *   - Zone aliases and the America/Chicago default come from
 *     Fn_Do_Scrub_Time_Zone_Value; a zone CONVERT_TZ does not recognize
 *     makes the whole result NULL.
 *
 * Example:
 *   SELECT Fn_Do_As_Of_Display_String_Value_Min('CT');  -- 'As of: Mar 13, 2024, 7:33 pm (CDT)'
 */

DROP FUNCTION IF EXISTS `Fn_Do_As_Of_Display_String_Value_Min`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_As_Of_Display_String_Value_Min`(v_Time_Zone VARCHAR(80)) RETURNS varchar(80) CHARSET utf8mb4
BEGIN


DECLARE v_UTC_Offset INT UNSIGNED DEFAULT '0' ;


SET v_Time_Zone = IFNULL((Fn_Do_Scrub_Time_Zone_Value(v_Time_Zone)),'America/Chicago') ;


SET v_UTC_Offset = ABS(TIMESTAMPDIFF(HOUR, CONVERT_TZ(UTC_TIMESTAMP, 'UTC', v_Time_Zone), UTC_TIMESTAMP)) ;


RETURN CONCAT('As of: ' ,
              -- ------------------------------
              (SELECT Fn_Do_Format_DateTime_Standard_Display_Short_To_Min(CONVERT_TZ(UTC_TIMESTAMP, 'UTC', v_Time_Zone))) ,
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