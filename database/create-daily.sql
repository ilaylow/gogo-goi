-- First clear the table
DELETE FROM public.dailykanji WHERE 1=1;

-- Insert in 5 words that the user got wrong recently (remove set of words they got right recently)
SELECT word, furigana, meaning
FROM (
  SELECT DISTINCT ON (word)
    k.word,
    k.furigana,
    k.meaning,
    ui.createtime
  FROM userinput ui
  INNER JOIN kanji k ON ui.word = k.word
  WHERE ui.iscorrect = false
  AND k.word NOT IN (
     SELECT word FROM public.userinput
     WHERE iscorrect = true
     ORDER BY createtime DESC
     LIMIT 100
  )
  ORDER BY word, ui.createtime DESC
) sub
ORDER BY createtime DESC
OFFSET 100
LIMIT 5;

-- Insert in 5 words that the user got right awhile ago
SELECT word, furigana, meaning
FROM (
  SELECT DISTINCT ON (word)
    k.word,
    k.furigana,
    k.meaning,
    ui.createtime
  FROM userinput ui
  INNER JOIN kanji k ON ui.word = k.word
  WHERE ui.iscorrect = true
  ORDER BY word, ui.createtime DESC
) sub
ORDER BY createtime DESC
OFFSET 100
LIMIT 5;

-- Insert in 5 words that the user got wrong awhile ago
SELECT word, furigana, meaning
FROM (
  SELECT DISTINCT ON (word)
    k.word,
    k.furigana,
    k.meaning,
    ui.createtime
  FROM userinput ui
  INNER JOIN kanji k ON ui.word = k.word
  WHERE ui.iscorrect = false
  ORDER BY word, ui.createtime DESC
) sub
ORDER BY createtime DESC
OFFSET 100
LIMIT 5;