/* Fn_Do_As_Of_Display_String_Value.sql
 *
 * Builds the 'As of: Tue, 2-9-2021, 3:07 pm (CST)' header line used at the
 * top of reports and queue pages, rendered in the requested time zone.
 *
 * Why it exists:
 *   Report timestamps are rendered in the DB layer so every consumer - web
 *   pages, exports, ops queries - shows the identical string. The zone
 *   abbreviation (CST vs CDT, etc.) is derived from the zone's current UTC
 *   offset, which keeps the string DST-correct without storing any DST
 *   rules here.
 *
 * Notes:
 *   - Zone input goes through Fn_Do_Scrub_Time_Zone_Value (aliases accepted,
 *     default America/Chicago).
 *   - The abbreviation CASE covers the common US zones; other valid zones
 *     are shown by their full name. A zone CONVERT_TZ does not recognize
 *     makes the whole result NULL.
 *
 * See also: Fn_Do_As_Of_Display_String_Value_Min for the compact format.
 *
 * Example:
 *   SELECT Fn_Do_As_Of_Display_String_Value('CST');  -- 'As of: Tue, 2-9-2021, 3:07 pm (CST)'
 */

DROP FUNCTION IF EXISTS `Fn_Do_As_Of_Display_String_Value`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_As_Of_Display_String_Value`(v_Time_Zone VARCHAR(80)) RETURNS varchar(80) CHARSET utf8mb4
BEGIN


DECLARE v_UTC_Offset INT UNSIGNED DEFAULT '0' ;


SET v_Time_Zone = IFNULL((Fn_Do_Scrub_Time_Zone_Value(v_Time_Zone)),'America/Chicago') ;


SET v_UTC_Offset = ABS(TIMESTAMPDIFF(HOUR, CONVERT_TZ(UTC_TIMESTAMP, 'UTC', v_Time_Zone), UTC_TIMESTAMP)) ;


RETURN CONCAT('As of: ' ,
              -- ------------------------------
              (SELECT Fn_Do_Format_DateTime_Standard_Display_To_Min(CONVERT_TZ(UTC_TIMESTAMP, 'UTC', v_Time_Zone))) ,
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