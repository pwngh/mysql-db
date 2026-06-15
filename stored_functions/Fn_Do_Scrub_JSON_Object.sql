/* Fn_Do_Scrub_JSON_Object.sql
 *
 * Validates a JSON object held as text and returns it serialized back from
 * the JSON type, or NULL when it is invalid or trivially empty ('{}', '[]',
 * or under 20 characters).
 *
 * Why it exists:
 *   The JSON-args API functions pass their result through this as a final
 *   gate, so callers receive either a well-formed, normalized JSON document
 *   or NULL - never a half-built string that parses on some clients and not
 *   others. Round-tripping through the JSON type is what does the
 *   normalizing.
 *
 * Example:
 *   SELECT Fn_Do_Scrub_JSON_Object('{"v_User_Account_Id": "1000000001"}');
 */

DROP FUNCTION IF EXISTS `Fn_Do_Scrub_JSON_Object`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Scrub_JSON_Object`(v_Json_Object_Text TEXT) RETURNS text CHARSET utf8mb4
BEGIN

DECLARE v_Json_Object JSON DEFAULT NULL ;


IF (IFNULL(v_Json_Object_Text,'') = '') THEN
      RETURN NULL;
END IF;


IF (IFNULL(v_Json_Object_Text,'') = '{}') THEN
      RETURN NULL;
END IF;


IF (IFNULL(v_Json_Object_Text,'') = '[]') THEN
      RETURN NULL;
END IF;


IF (CHAR_LENGTH(v_Json_Object_Text) < 20) THEN
      RETURN NULL;
END IF;


IF (IFNULL(JSON_VALID(v_Json_Object_Text),'0') != '1') THEN
      RETURN NULL;
END IF;



SET v_Json_Object = CAST(v_Json_Object_Text AS JSON) ;


IF (IFNULL(JSON_VALID(v_Json_Object),'0') != '1') THEN
      RETURN NULL;
END IF;


IF (IFNULL(JSON_VALID(CAST(v_Json_Object AS CHAR)),'0') != '1') THEN
      RETURN NULL;
END IF;



RETURN CAST(v_Json_Object AS CHAR) ;


END