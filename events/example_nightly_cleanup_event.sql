/* example_nightly_cleanup_event.sql
 *
 * Example scheduled event: every night at 02:00 server time, delete
 * example_data_table rows older than 90 days.
 *
 * Why it exists:
 *   Retention enforcement belongs in the database alongside the data it
 *   prunes - no external cron job to drift out of sync. The cutoff is
 *   computed against the indexed Created_UTC_Date column, and even this
 *   internally-generated date runs through Fn_Do_Scrub_Date_Value, the same
 *   boundary check applied to external input.
 *
 * Notes:
 *   - Requires the event scheduler: SET GLOBAL event_scheduler = ON;
 *   - ON COMPLETION PRESERVE keeps the event defined after each run.
 */

DROP EVENT IF EXISTS `example_nightly_cleanup_event`;

CREATE DEFINER=`admin`@`%` EVENT `example_nightly_cleanup_event`
ON SCHEDULE EVERY 1 DAY
STARTS (TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY + INTERVAL 2 HOUR) -- runs nightly at 02:00 server time
ON COMPLETION PRESERVE
ENABLE
COMMENT 'Nightly cleanup: removes example_data_table records older than 90 days.'
DO
BEGIN

DELETE FROM `example_data_table`
WHERE Created_UTC_Date < (SELECT Fn_Do_Scrub_Date_Value(UTC_DATE() - INTERVAL 90 DAY)) ;

END
