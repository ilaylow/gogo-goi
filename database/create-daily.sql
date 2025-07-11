-- First clear the table
DELETE FROM public.dailykanji WHERE 1=1;

-- Insert in 5 words that the user got wrong recently
INSERT INTO public.dailykanji (word)
SELECT word FROM public.userinput
WHERE iscorrect=false
ORDER BY createtime DESC
LIMIT 5;

-- Insert in 5 words that the user got right awhile ago
INSERT INTO public.dailykanji (word)
SELECT word from public.userinput
WHERE iscorrect=true
ORDER BY createtime DESC
LIMIT 5 OFFSET 100;

-- Insert in 5 words that the user got wrong awhile ago
INSERT INTO public.dailykanji (word)
SELECT word from public.userinput
WHERE iscorrect=false
ORDER BY createtime DESC
LIMIT 5 OFFSET 100;