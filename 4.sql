USE SportDatabase
GO
--3.1 INSERT
--a. Без указания списка полей
--INSERT INTO table_name VALUES (value1, value2, value3, ...);
--b. С указанием списка полей
--INSERT INTO table_name (column1, column2, column3, ...) VALUES (value1, value2,
--value3, ...);
--c. С чтением значения из другой таблицы
--INSERT INTO table2 (column_name(s)) SELECT column_name(s) FROM table1;
DELETE FROM [action]
DELETE FROM sportsman
DELETE FROM competition

INSERT INTO competition VALUES (1, N'Спартакиада', N'Ураева 6', 232332, 'Проведено')
INSERT INTO competition(competition_id, competition_name, prize_pool, [location],[status]) VALUES (3, N'Олимпиада имени Добрыни', 100000, N'Петрова 2', 'Проведено')
INSERT INTO competition(competition_id, competition_name, prize_pool, [location], [status]) VALUES (4, N'Олимпиада имени Никитича', 333333, N'Петрова 2', 'Проведено')
INSERT INTO competition VALUES (5, N'Спартакиада', N'Ураева 6', 100332, 'Проведено')
INSERT INTO competition(competition_id, competition_name, prize_pool, [location], [status]) VALUES (2, N'Олимпиада имени Ивана', 1000000, N'Петрова 2', 'Проведено')
INSERT INTO trainer(trainer_id, [name], surname) VALUES (1, N'Леонид', N'Рубцов')
INSERT INTO trainer(trainer_id, [name], surname) VALUES (2, N'Роман', N'Рубцов')
INSERT INTO [sportsman](sportsman_id, [rank], [name], trainer_id) VALUES (1, N'мастер', N'Олег Шалапаев', 1)
INSERT INTO [sportsman](sportsman_id, [rank], [name], trainer_id) VALUES (2, N'мастер', N'Егор Шалапаев', 1)
INSERT INTO [sportsman](sportsman_id, [rank], [name], trainer_id) VALUES (3, N'новичок', N'Роберт Шалапаев', 1)
INSERT INTO [action](result, start_of_preparation, end_of_preparation, competition_id, sportsman_id, action_id) VALUES (10, '2023-09-09', '2023-09-15', 1, 1, 1)
INSERT INTO [action](result, start_of_preparation, end_of_preparation, competition_id, sportsman_id, action_id) VALUES (6, '2024-09-09', '2024-09-15', 2, 1, 4)
INSERT INTO [action](result, start_of_preparation, end_of_preparation, competition_id, sportsman_id, action_id) VALUES (6, '2024-09-09', '2024-09-15', 5, 3, 3)
INSERT INTO judge(judge_id, [name]) SELECT trainer_id, [name] FROM trainer;
--3.2. DELETE
--a. Всех записей
--b. По условию
--DELETE FROM table_name WHERE condition;
--DELETE FROM trainer WHERE [name] = N'Леонид'
DELETE FROM judge
--3.3. UPDATE
--a. Всех записей
--UPDATE trainer
--SET experience = 5;
--b. По условию обновляя один атрибут
UPDATE trainer SET experience = 3
--c. По условию обновляя несколько атрибутов
UPDATE competition SET [location] = N'Кирова 11а', [status] = N'Проведено' WHERE [location] = N'Гончарова 10а'

--3.4. SELECT
--a. С набором извлекаемых атрибутов (SELECT atr1, atr2 FROM...)
SELECT competition_name, [location] FROM competition
--b. Со всеми атрибутами (SELECT * FROM...)
SELECT * FROM competition
--c. С условием по атрибуту (SELECT * FROM ... WHERE atr1 = value)
SELECT * FROM competition WHERE [competition_name] = N'Спартакиада'
--3.5. SELECT ORDER BY + TOP (LIMIT)
--a. С сортировкой по возрастанию ASC + ограничение вывода количества записей
SELECT TOP 1 *
FROM competition
ORDER BY prize_pool ASC;
--b. С сортировкой по убыванию DESC
SELECT TOP 1 *
FROM competition
ORDER BY prize_pool DESC;
--c. С сортировкой по двум атрибутам + ограничение вывода количества записей
SELECT TOP 1 *
FROM competition
ORDER BY prize_pool ASC, [status] DESC;
--d. С сортировкой по первому атрибуту, из списка извлекаемых
SELECT 
    competition_name, 
    [location], 
    prize_pool
FROM competition
ORDER BY competition_name;
--3.6. Работа с датами
--Необходимо, чтобы одна из таблиц содержала атрибут с типом DATETIME. Например,
--таблица авторов может содержать дату рождения автора.

--a. WHERE по дате
SELECT *
FROM [action]
WHERE [start_of_preparation] = '2023-09-09';
--b. WHERE дата в диапазоне
SELECT *
FROM [action]
WHERE start_of_preparation BETWEEN '2023-09-09' AND '2024-09-15';
--c. Извлечь из таблицы не всю дату, а только год. Например, год рождения автора.
SELECT result, YEAR(start_of_preparation) AS action_year
FROM [action];
--3.7. Функции агрегации
--a. Посчитать количество записей в таблице
SELECT COUNT(*) AS total_actions
FROM [action];
--b. Посчитать количество уникальных записей в таблице
SELECT COUNT(DISTINCT prize_pool) AS unique_prize_pool
FROM competition;
--c. Вывести уникальные значения столбца
SELECT DISTINCT prize_pool
FROM competition;
--d. Найти максимальное значение столбца
SELECT MAX(prize_pool) AS max_prize_pool
FROM competition;
--e. Найти минимальное значение столбца
SELECT MIN(prize_pool) AS min_prize_pool
FROM competition;
--f. Написать запрос COUNT() + GROUP BY
SELECT competition_name, COUNT(*) AS name_count
FROM competition
GROUP BY competition_name;

--3.8. SELECT GROUP BY + HAVING
--a. Написать 3 разных запроса с использованием GROUP BY + HAVING. Для
--каждого запроса написать комментарий с пояснением, какую информацию
--извлекает запрос. Запрос должен быть осмысленным, т.е. находить информацию,
--которую можно использовать.

--группирует соревнования по их названию и находит те, у которых сумма призовых фондов превышает 300000.
SELECT 
    competition_name, 
    SUM(prize_pool) AS total_prize_pool
FROM competition
GROUP BY competition_name
HAVING SUM(prize_pool) > 300000;

--группирует данные по спортсменам и находит тех, кто участвовал в более чем одном соревновании
SELECT 
    s.name AS sportsman_name, 
    COUNT(a.competition_id) AS competition_count
FROM sportsman s
JOIN [action] a ON s.sportsman_id = a.sportsman_id
GROUP BY s.name
HAVING COUNT(a.competition_id) > 1;

--находит тренеров, у которых средний результат их спортсменов больше 7
SELECT 
    t.name AS trainer_name, 
    AVG(a.result) AS average_result
FROM trainer t
JOIN sportsman s ON t.trainer_id = s.trainer_id
JOIN [action] a ON s.sportsman_id = a.sportsman_id
GROUP BY t.name
HAVING AVG(a.result) > 5;

--3.9. SELECT JOIN

--a. LEFT JOIN двух таблиц и WHERE по одному из атрибутов
SELECT * FROM [action];
SELECT * FROM competition;

SELECT 
    c.competition_name, 
    c.competition_id, 
    a.action_id, 
    s.name AS sportsman_name, 
    c.[location]
FROM competition c
LEFT JOIN [action] a ON c.competition_id = a.competition_id
LEFT JOIN sportsman s ON a.sportsman_id = s.sportsman_id
WHERE c.[location] = N'Ураева 6';
--b. RIGHT JOIN. Получить такую же выборку, как и в 3.9 a
SELECT 
    c.competition_name, 
    c.competition_id, 
    a.action_id, 
    s.name AS sportsman_name, 
    c.[location]
FROM competition c
RIGHT JOIN [action] a ON c.competition_id = a.competition_id
RIGHT JOIN sportsman s ON a.sportsman_id = s.sportsman_id
WHERE c.[location] = N'Ураева 6';
--c. LEFT JOIN трех таблиц + WHERE по атрибуту из каждой таблицы
SELECT s.name AS sportsman_name, c.competition_name, t.name AS trainer_name
FROM sportsman s
LEFT JOIN [action] a ON s.sportsman_id = a.sportsman_id
LEFT JOIN competition c ON a.competition_id = c.competition_id
LEFT JOIN trainer t ON s.trainer_id = t.trainer_id
WHERE s.[rank] = N'мастер'
  AND c.[status] = N'Проведено'
  AND t.name = N'Леонид';
  --d. INNER JOIN двух таблиц
SELECT c.competition_name, a.start_of_preparation, a.end_of_preparation
FROM competition c
INNER JOIN [action] a ON c.competition_id = a.competition_id;
--3.10. Подзапросы
--a. Написать запрос с условием WHERE IN (подзапрос)
SELECT competition_name, [location]
FROM competition
WHERE competition_id IN (
    SELECT competition_id
    FROM [action]
    WHERE sportsman_id IN (
        SELECT sportsman_id
        FROM sportsman
        WHERE [rank] = N'мастер'
    )
);
--b. Написать запрос SELECT atr1, atr2, (подзапрос) FROM ...
SELECT s.name AS sportsman_name, (
    SELECT COUNT(*)
    FROM [action] a
    WHERE a.sportsman_id = s.sportsman_id
) AS competition_count
FROM sportsman s;
--c. Написать запрос вида SELECT * FROM (подзапрос)
SELECT *
FROM (
    SELECT s.name AS sportsman_name, c.competition_name, c.prize_pool
    FROM sportsman s
    INNER JOIN [action] a ON s.sportsman_id = a.sportsman_id
    INNER JOIN competition c ON a.competition_id = c.competition_id
) AS subquery
WHERE prize_pool > 200000;
--d. Написать запрос вида SELECT * FROM table JOIN (подзапрос) ON …
SELECT s.name AS sportsman_name, t.name AS trainer_name, subquery.competition_name, subquery.prize_pool
FROM sportsman s
INNER JOIN trainer t ON s.trainer_id = t.trainer_id
INNER JOIN (
    SELECT a.sportsman_id, c.competition_name, c.prize_pool
    FROM [action] a
    INNER JOIN competition c ON a.competition_id = c.competition_id
    WHERE c.prize_pool > 300000
) AS subquery ON s.sportsman_id = subquery.sportsman_id;