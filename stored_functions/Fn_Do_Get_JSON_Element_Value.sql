/* Fn_Do_Get_JSON_Element_Value.sql
 *
 * Pulls one element value out of a JSON object by key and returns it
 * unquoted, or NULL when the object is invalid, the key is absent, or the
 * value is empty/'null'.
 *
 * Why it exists:
 *   This is how the JSON-args API functions read their request arguments.
 *   It absorbs the sharp edges of raw JSON_EXTRACT so every caller gets the
 *   same forgiving contract instead of re-implementing it per argument.
 *
 * Input / Output:
 *   - v_JSON_Object_Text: the JSON object, as text
 *   - v_JSON_Element_Key: element key; the '$.' prefix is optional, and the
 *     key is matched as given, then lowercase, then uppercase
 *   - Returns the unquoted value, ready to hand to a scrub function
 *
 * Used by: Fn_Get_Page_Data (one call per expected argument).
 *
 * Example:
 *   SELECT Fn_Do_Get_JSON_Element_Value('{"v_User_Account_Id": "1000000001"}', 'v_User_Account_Id');  -- '1000000001'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Get_JSON_Element_Value`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Get_JSON_Element_Value`(v_JSON_Object_Text TEXT, v_JSON_Element_Key VARCHAR(80)) RETURNS varchar(15000) CHARSET utf8mb4
BEGIN

DECLARE v_JSON_Object JSON DEFAULT NULL ;
DECLARE v_JSON_Element_Value varchar(10000) DEFAULT NULL ;

IF (CHAR_LENGTH(v_JSON_Object_Text) > 10)
    AND (INSTR(v_JSON_Object_Text, '{') > 0)
    AND (INSTR(v_JSON_Object_Text, '}') > 0)
THEN
      SET v_JSON_Object = v_JSON_Object_Text ; -- convert from text to json
ELSE
      RETURN NULL ;
END IF;

IF (IFNULL(JSON_VALID(v_JSON_Object),'0') = '0') THEN -- required, must have a valid JSON structure
      RETURN NULL ;
END IF;

SET v_JSON_Element_Key = IF((LEFT(v_JSON_Element_Key,2) != '$.'), CONCAT('$.', v_JSON_Element_Key), v_JSON_Element_Key) ; -- element key must start with "$.", add it if not already there

IF (IFNULL(JSON_CONTAINS_PATH(v_JSON_Object, 'one', v_JSON_Element_Key),'0') = '1') THEN -- check for JSON key using original case
      SET v_JSON_Element_Value = JSON_UNQUOTE(JSON_EXTRACT(v_JSON_Object, v_JSON_Element_Key)) ;
      RETURN IF((IFNULL(LOWER(TRIM(v_JSON_Element_Value)),'') IN ('',' ','null')), NULL, v_JSON_Element_Value) ;
END IF;

IF (IFNULL(JSON_CONTAINS_PATH(v_JSON_Object, 'one', LOWER(v_JSON_Element_Key)),'0') = '1') THEN -- check for JSON key using lowercase
      SET v_JSON_Element_Value = JSON_UNQUOTE(JSON_EXTRACT(v_JSON_Object, LOWER(v_JSON_Element_Key))) ;
      RETURN IF((IFNULL(LOWER(TRIM(v_JSON_Element_Value)),'') IN ('',' ','null')), NULL, v_JSON_Element_Value) ;
END IF;

IF (IFNULL(JSON_CONTAINS_PATH(v_JSON_Object, 'one', UPPER(v_JSON_Element_Key)),'0') = '1') THEN -- check for JSON key using uppercase
      SET v_JSON_Element_Value = JSON_UNQUOTE(JSON_EXTRACT(v_JSON_Object, UPPER(v_JSON_Element_Key))) ;
      RETURN IF((IFNULL(LOWER(TRIM(v_JSON_Element_Value)),'') IN ('',' ','null')), NULL, v_JSON_Element_Value) ;
END IF;

RETURN NULL ;

END
