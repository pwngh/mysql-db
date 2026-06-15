/* Fn_Do_Titlecase_Text.sql
 *
 * Title-cases free-form text the way a person would: words get capitals,
 * small words stay lowercase, acronyms and US state abbreviations go
 * uppercase, and Mc/Mac surnames get their second capital.
 *
 * What this covers beyond simple capitalization:
 *   - Word-level fixups: small words ('of', 'the'), acronyms (LLC, USA),
 *     state codes (TX, NY), Mc/Mac names, 'PO Box'
 *   - Normalizes curly quotes/dashes and common HTML entities to plain text
 *
 * Why it exists:
 *   Names and addresses arrive in ALL CAPS or all lowercase from imports
 *   and user entry. Fixing case in the DB layer applies the cleanup for
 *   every consumer, and the (long) exception lists live in one routine
 *   instead of being copied around.
 *
 * Notes:
 *   - Returns '' (not NULL) for NULL/empty input - safe to CONCAT.
 *   - The exception lists are US-centric by design.
 *
 * Example:
 *   SELECT Fn_Do_Titlecase_Text('JOHN MCDONALD of dallas tx');  -- 'John McDonald of Dallas TX'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Titlecase_Text`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Titlecase_Text`(The_Text TEXT) RETURNS text CHARSET utf8mb4
BEGIN

DECLARE v_The_Text TEXT DEFAULT NULL ;
DECLARE v_Character VARCHAR(80) ;
DECLARE v_Index INT DEFAULT 1 ;
DECLARE v_Character_Found INT DEFAULT 1 ;
DECLARE v_Punctuation CHAR(17) DEFAULT ' .!,:;-_~{}[]()\'"' ;
DECLARE v_Space CHAR(0) DEFAULT ' ' ;
DECLARE v_Word_Beginning VARCHAR(80) DEFAULT '' ;
DECLARE v_First_Word INT DEFAULT 1 ;

SET v_The_Text = TRIM(The_Text) ; -- trim and truncate our string input
SET v_The_Text = LOWER(v_The_Text) ; -- set it to all lowercase

IF ((The_Text IS NULL) OR (The_Text = '') OR (v_The_Text IS NULL) OR (v_The_Text = '')) THEN
    RETURN '';
ELSE

 -- first loop will capitalize the first character of each word in the string
WHILE v_Index <= LENGTH( v_The_Text ) DO
  BEGIN
    SET v_Character = SUBSTRING( v_The_Text, v_Index, 1 ) ;

    IF (LOCATE( v_Character, v_Punctuation ) > 0) OR (LOCATE( v_Character, v_Space ) > 0) THEN -- uppercase a-z character that follows a punctuation character
      SET v_Character_Found = 1 ;
    ELSEIF v_Character_Found=1 THEN
      BEGIN
        IF (v_Character >= 'a') AND (v_Character <= 'z') THEN -- uppercase the first character if it is a-z
          BEGIN
            SET v_The_Text = CONCAT(LEFT(v_The_Text,v_Index-1),UCASE(v_Character),SUBSTRING(v_The_Text,v_Index+1)) ;
            SET v_Character_Found = 0 ;
          END;
        ELSEIF (v_Character >= '0') AND (v_Character <= '9') THEN
          SET v_Character_Found = 0 ;
        END IF;
      END;
    END IF;
    SET v_Index = v_Index+1 ; -- move to the next character in the string
  END;
END WHILE;

SET v_Index = 1 ; -- reset the index before looping over the string for a second time

 -- second loop applies word-level special cases (first word, Mc/Mac surnames, last word)
WHILE v_Index <= LENGTH( v_The_Text ) DO
  BEGIN
    SET v_Character = SUBSTRING( v_The_Text, v_Index, 1 ) ;

    -- process the first word in the string
    IF (v_Character = ' ') THEN -- if the current character is a space, we should have a full word stored in v_Word_Beginning
      IF (v_First_Word = 1) THEN -- if we haven't already processed the first word, do so now

        -- if this word is a state abbreviation, then make it all uppercase
        IF (v_Word_Beginning IN ('Al','Ak','As','Az','Ar','Ca','Co','Ct','De','Dc','Fm','Fl','GA','Gu','Hi','Id','Il','In','Ia','Ks','Ky','La','Me','Mh','Md','Ma','Mi','Mn','Ms','Mo','Mt','Ne','Nv','Nh','Nj','Nm','Ny','Nc','Nd','Mp','Oh','Ok','Or','Pw','Pa','Pr','Ri','Sc','Sd','Tn','Tx','Ut','Vt','Vi','Va','Wa','Wv','Wi','Wy','Ae','Aa','Ap')) THEN
          SET v_The_Text = CONCAT(LEFT(v_The_Text,v_Index-3),UCASE(v_Word_Beginning),SUBSTRING(v_The_Text,v_Index)) ;
        END IF;

        -- if this word is an acronym, then make it all uppercase
        IF (v_Word_Beginning IN ('Ii','Iv','Pc')) THEN
          SET v_The_Text = CONCAT(LEFT(v_The_Text,v_Index-3),UCASE(v_Word_Beginning),SUBSTRING(v_The_Text,v_Index)) ;
        END IF;
        IF (v_Word_Beginning IN ('Iii','Llc','Usa','Usd')) THEN
          SET v_The_Text = CONCAT(LEFT(v_The_Text,v_Index-4),UCASE(v_Word_Beginning),SUBSTRING(v_The_Text,v_Index)) ;
        END IF;

        SET v_First_Word = 0 ; -- update v_First_Word after processing the first word
      END IF;

      SET v_Word_Beginning = "" ;  -- empty v_Word_Beginning, will be used to store the next word
    ELSE
      SET v_Word_Beginning = CONCAT(v_Word_Beginning, v_Character) ;
    END IF;

    -- if this is a multi-character string, uppercase the first character following the match
    IF (v_Word_Beginning IN ('Mc','Mac')) THEN
      SET v_The_Text = CONCAT(LEFT(v_The_Text,v_Index),UCASE(SUBSTRING(v_The_Text, v_Index+1, 1)),SUBSTRING(v_The_Text,v_Index+2)) ;
    END IF;

    -- process the last word in the string
    IF (v_Index+1 > LENGTH(v_The_Text)) OR ((v_Index+2 > LENGTH(v_The_Text)) AND (LOCATE(SUBSTRING(v_The_Text, v_Index+1, 1), v_Punctuation) > 0)) THEN

      -- if this is a small word, and not the first word in the string, then make it all lowercase
      IF (v_Word_Beginning IN ('A')) THEN
        SET v_The_Text = CONCAT(LEFT(v_The_Text,v_Index-1),LOWER(v_Word_Beginning),SUBSTRING(v_The_Text,v_Index+1)) ;
      END IF;
      IF (v_Word_Beginning IN ('An','At','By','If','In','Is','It','Of','On','Or','To')) THEN
        SET v_The_Text = CONCAT(LEFT(v_The_Text,v_Index-2),LOWER(v_Word_Beginning),SUBSTRING(v_The_Text,v_Index+1)) ;
      END IF;
      IF (v_Word_Beginning IN ('And','But','For','Had','Nor','Off','Out','The','Was')) THEN
        SET v_The_Text = CONCAT(LEFT(v_The_Text,v_Index-3),LOWER(v_Word_Beginning),SUBSTRING(v_The_Text,v_Index+1)) ;
      END IF;
      IF (v_Word_Beginning IN ('Else','From','Into','Over','Then','When','With')) THEN
        SET v_The_Text = CONCAT(LEFT(v_The_Text,v_Index-4),LOWER(v_Word_Beginning),SUBSTRING(v_The_Text,v_Index+1)) ;
      END IF;

      -- if this word is a state abbreviation, then make it all uppercase
      IF (v_Word_Beginning IN ('Al','Ak','As','Az','Ar','Ca','Co','Ct','De','Dc','Fm','Fl','GA','Gu','Hi','Id','Il','In','Ia','Ks','Ky','La','Me','Mh','Md','Ma','Mi','Mn','Ms','Mo','Mt','Ne','Nv','Nh','Nj','Nm','Ny','Nc','Nd','Mp','Oh','Ok','Or','Pw','Pa','Pr','Ri','Sc','Sd','Tn','Tx','Ut','Vt','Vi','Va','Wa','Wv','Wi','Wy','Ae','Aa','Ap')) THEN
          SET v_The_Text = CONCAT(LEFT(v_The_Text,v_Index-2),UCASE(v_Word_Beginning),SUBSTRING(v_The_Text,v_Index+1)) ;
      END IF;

      -- if this word is an acronym, then make it all uppercase
      IF (v_Word_Beginning IN ('Ii','Iv','Pc')) THEN
        SET v_The_Text = CONCAT(LEFT(v_The_Text,v_Index-2),UCASE(v_Word_Beginning),SUBSTRING(v_The_Text,v_Index+1)) ;
      END IF;
      IF (v_Word_Beginning IN ('Iii','Llc','Usa','Usd')) THEN
        SET v_The_Text = CONCAT(LEFT(v_The_Text,v_Index-3),UCASE(v_Word_Beginning),SUBSTRING(v_The_Text,v_Index+1)) ;
      END IF;
    END IF;

    SET v_Index = v_Index+1 ; -- move to the next character in the string to begin the next iteration

  END;
END WHILE;

-- replace UTF-8 fancy double-quotes, single-quotes, en dashes, and em dashes with their plain text version
SET v_The_Text = REPLACE(v_The_Text, 0xE28098, '\'') ;
SET v_The_Text = REPLACE(v_The_Text, 0xE28099, '\'') ;
SET v_The_Text = REPLACE(v_The_Text, 0xE2809C, '"') ;
SET v_The_Text = REPLACE(v_The_Text, 0xE2809D, '"') ;
SET v_The_Text = REPLACE(v_The_Text, 0xE28093, '-') ;
SET v_The_Text = REPLACE(v_The_Text, 0xE28094, '--') ;
SET v_The_Text = REPLACE(v_The_Text, 0xE280A6, '...') ;

-- replace html entities with their plain text version
SET v_The_Text = REPLACE(v_The_Text, '&amp;', '&') ;
SET v_The_Text = REPLACE(v_The_Text, '&#32;', ' ') ;
SET v_The_Text = REPLACE(v_The_Text, '&#33;', '!') ;
SET v_The_Text = REPLACE(v_The_Text, '&#34;', '"') ;
SET v_The_Text = REPLACE(v_The_Text, '&#35;', '#') ;
SET v_The_Text = REPLACE(v_The_Text, '&#36;', '$') ;
SET v_The_Text = REPLACE(v_The_Text, '&#37;', '%') ;
SET v_The_Text = REPLACE(v_The_Text, '&#39;', '\'') ;
SET v_The_Text = REPLACE(v_The_Text, '&#40;', '(') ;
SET v_The_Text = REPLACE(v_The_Text, '&#41;', ')') ;
SET v_The_Text = REPLACE(v_The_Text, '&#42;', '*') ;
SET v_The_Text = REPLACE(v_The_Text, '&#43;', '+') ;
SET v_The_Text = REPLACE(v_The_Text, '&#44;', ',') ;
SET v_The_Text = REPLACE(v_The_Text, '&#45;', '-') ;
SET v_The_Text = REPLACE(v_The_Text, '&#46;', '.') ;

-- 'special exceptions'
SET v_The_Text = REPLACE(v_The_Text, 'P.O. Box', 'PO Box') ;
SET v_The_Text = REPLACE(v_The_Text, 'Po Box', 'PO Box') ;

-- 'compound word suffixes' that we always want to be lowercase
SET v_The_Text = REPLACE(v_The_Text, 'an\'T', 'an\'t') ;
SET v_The_Text = REPLACE(v_The_Text, 'on\'T', 'on\'t') ;
SET v_The_Text = REPLACE(v_The_Text, 'idn\'T', 'idn\'t') ;
SET v_The_Text = REPLACE(v_The_Text, 'ouldn\'T', 'ouldn\'t') ;
SET v_The_Text = REPLACE(v_The_Text, 'ren\'T', 'ren\'t') ;
SET v_The_Text = REPLACE(v_The_Text, 'ven\'T', 'ven\'t') ;
SET v_The_Text = REPLACE(v_The_Text, 'isn\'T', 'isn\'t') ;

-- "small words" that we always want to be lowercase
SET v_The_Text = REPLACE(v_The_Text, ' A ', ' a ') ;
SET v_The_Text = REPLACE(v_The_Text, ' An ', ' an ') ;
SET v_The_Text = REPLACE(v_The_Text, ' And ', ' and ') ;
SET v_The_Text = REPLACE(v_The_Text, ' At ', ' at ') ;
SET v_The_Text = REPLACE(v_The_Text, ' But ', ' but ') ;
SET v_The_Text = REPLACE(v_The_Text, ' By ', ' by ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Else ', ' else ') ;
SET v_The_Text = REPLACE(v_The_Text, ' For ', ' for ') ;
SET v_The_Text = REPLACE(v_The_Text, ' From ', ' from ') ;
SET v_The_Text = REPLACE(v_The_Text, ' If ', ' if ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Had ', ' had ') ;
SET v_The_Text = REPLACE(v_The_Text, ' In ', ' in ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Into ', ' into ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Is ', ' is ') ;
SET v_The_Text = REPLACE(v_The_Text, ' It ', ' it ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Nor ', ' nor ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Of ', ' of ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Off ', ' off ') ;
SET v_The_Text = REPLACE(v_The_Text, ' On ', ' on ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Or ', ' or ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Out ', ' out ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Over ', ' over ') ;
SET v_The_Text = REPLACE(v_The_Text, ' The ', ' the ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Then ', ' then ') ;
SET v_The_Text = REPLACE(v_The_Text, ' To ', ' to ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Was ', ' was ') ;
SET v_The_Text = REPLACE(v_The_Text, ' When ', ' when ') ;
SET v_The_Text = REPLACE(v_The_Text, ' With ', ' with ') ;

-- "acronyms" that we always want to be uppercase if it is used as an individual "word"
SET v_The_Text = REPLACE(v_The_Text, ' Ii ', ' II ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Iii ', ' III ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Iv ', ' IV ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Isd ', ' ISD ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Llc ', ' LLC ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Pc ', ' PC ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Usa ', ' USA ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Usd ', ' USD ') ;

-- US state abbreviations that we always want to be uppercase
SET v_The_Text = REPLACE(v_The_Text, ' Al ', ' AL ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Ak ', ' AK ') ;
SET v_The_Text = REPLACE(v_The_Text, ' As ', ' AS ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Az ', ' AZ ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Ar ', ' AR ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Ca ', ' CA ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Co ', ' CO ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Ct ', ' CT ') ;
SET v_The_Text = REPLACE(v_The_Text, ' De ', ' DE ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Dc ', ' DC ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Fm ', ' FM ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Fl ', ' FL ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Ga ', ' GA ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Gu ', ' GU ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Hi ', ' HI ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Id ', ' ID ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Il ', ' IL ') ;
SET v_The_Text = REPLACE(v_The_Text, ' In ', ' IN ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Ia ', ' IA ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Ks ', ' KS ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Ky ', ' KY ') ;
SET v_The_Text = REPLACE(v_The_Text, ' La ', ' LA ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Me ', ' ME ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Mh ', ' MH ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Md ', ' MD ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Ma ', ' MA ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Mi ', ' MI ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Ms ', ' MS ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Mo ', ' MO ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Mt ', ' MT ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Ne ', ' NE ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Nv ', ' NV ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Nh ', ' NH ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Nj ', ' NJ ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Nm ', ' NM ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Ny ', ' NY ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Nc ', ' NC ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Nd ', ' ND ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Mp ', ' MP ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Oh ', ' OH ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Ok ', ' OK ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Or ', ' OR ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Pw ', ' PW ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Pa ', ' PA ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Pr ', ' PR ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Ri ', ' RI ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Sc ', ' SC ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Sd ', ' SD ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Tn ', ' TN ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Tx ', ' TX ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Ut ', ' UT ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Vt ', ' VT ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Vi ', ' VI ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Va ', ' VA ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Wa ', ' WA ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Wv ', ' WV ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Wi ', ' WI ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Wy ', ' WY ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Ae ', ' AE ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Aa ', ' AA ') ;
SET v_The_Text = REPLACE(v_The_Text, ' Ap ', ' AP ') ;

RETURN v_The_Text;

END IF; -- 'Invalid or Missing Parameter Value for The_Text'

END