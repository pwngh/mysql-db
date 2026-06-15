/* Fn_Do_Scrub_Ref_Id_Value.sql
 *
 * Validates a reference-table record ID: digits only, inside the reference
 * auto-increment range (10001-4294967295). Anything else returns NULL.
 *
 * Why it exists:
 *   Reference/lookup IDs start much lower (10001+) than data IDs
 *   (1000000001+), so small lookup IDs that the data-ID scrub rejects are
 *   accepted here. Both scrubs share the same 4294967295 ceiling, so the
 *   separation is one-directional: a data-range ID also passes this check,
 *   but a low ref ID does not pass the data-ID check. Like its sibling, it
 *   rejects bad input outright rather than trusting CAST's wrap/truncate
 *   behavior.
 *
 * See also: Fn_Do_Scrub_Data_Id_Value (data-table range, 1000000001+).
 *
 * Example:
 *   SELECT Fn_Do_Scrub_Ref_Id_Value('202100');  -- '202100'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Scrub_Ref_Id_Value`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Scrub_Ref_Id_Value`(v_ID_Val VARCHAR(20)) RETURNS varchar(20) CHARSET utf8mb4
BEGIN

DECLARE v_Min_Id_Value INT UNSIGNED DEFAULT '10001' ;
DECLARE v_Max_Id_Value INT UNSIGNED DEFAULT '4294967295' ;

DECLARE v_ID_Val_Unsigned BIGINT UNSIGNED DEFAULT NULL ;

IF ((v_ID_Val IS NULL) OR (TRIM(v_ID_Val) = '')) THEN
      RETURN NULL ;
END IF;

IF (TRIM(v_ID_Val) NOT REGEXP '^[0-9]{1,10}$') THEN -- digits only; rejects signs, decimals, and values too long to be in range (no silent CAST wrap/truncation)
      RETURN NULL ;
END IF;

SET v_ID_Val_Unsigned = CAST(TRIM(v_ID_Val) AS UNSIGNED) ;

IF (v_ID_Val_Unsigned NOT BETWEEN v_Min_Id_Value AND v_Max_Id_Value) THEN
      RETURN NULL ;
END IF;

RETURN CAST(v_ID_Val_Unsigned AS CHAR) ;

END
