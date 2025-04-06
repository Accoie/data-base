USE SportDatabase
GO
--3.1 INSERT
--a. ��� �������� ������ �����
--INSERT INTO table_name VALUES (value1, value2, value3, ...);
--b. � ��������� ������ �����
--INSERT INTO table_name (column1, column2, column3, ...) VALUES (value1, value2,
--value3, ...);
--c. � ������� �������� �� ������ �������
--INSERT INTO table2 (column_name(s)) SELECT column_name(s) FROM table1;
DELETE FROM [action]
DELETE FROM sportsman
DELETE FROM competition

INSERT INTO competition VALUES (1, N'�����������', N'������ 6', 232332, '���������')
INSERT INTO competition(competition_id, competition_name, prize_pool, [location],[status]) VALUES (3, N'��������� ����� �������', 100000, N'������� 2', '���������')
INSERT INTO competition(competition_id, competition_name, prize_pool, [location], [status]) VALUES (4, N'��������� ����� ��������', 333333, N'������� 2', '���������')
INSERT INTO competition VALUES (5, N'�����������', N'������ 6', 100332, '���������')
INSERT INTO competition(competition_id, competition_name, prize_pool, [location], [status]) VALUES (2, N'��������� ����� �����', 1000000, N'������� 2', '���������')
INSERT INTO trainer(trainer_id, [name], surname) VALUES (1, N'������', N'������')
INSERT INTO trainer(trainer_id, [name], surname) VALUES (2, N'�����', N'������')
INSERT INTO [sportsman](sportsman_id, [rank], [name], trainer_id) VALUES (1, N'������', N'���� ��������', 1)
INSERT INTO [sportsman](sportsman_id, [rank], [name], trainer_id) VALUES (2, N'������', N'���� ��������', 1)
INSERT INTO [sportsman](sportsman_id, [rank], [name], trainer_id) VALUES (3, N'�������', N'������ ��������', 1)
INSERT INTO [action](result, start_of_preparation, end_of_preparation, competition_id, sportsman_id, action_id) VALUES (10, '2023-09-09', '2023-09-15', 1, 1, 1)
INSERT INTO [action](result, start_of_preparation, end_of_preparation, competition_id, sportsman_id, action_id) VALUES (6, '2024-09-09', '2024-09-15', 2, 1, 4)
INSERT INTO [action](result, start_of_preparation, end_of_preparation, competition_id, sportsman_id, action_id) VALUES (6, '2024-09-09', '2024-09-15', 5, 3, 3)
INSERT INTO judge(judge_id, [name]) SELECT trainer_id, [name] FROM trainer;
--3.2. DELETE
--a. ���� �������
--b. �� �������
--DELETE FROM table_name WHERE condition;
--DELETE FROM trainer WHERE [name] = N'������'
DELETE FROM judge
--3.3. UPDATE
--a. ���� �������
--UPDATE trainer
--SET experience = 5;
--b. �� ������� �������� ���� �������
UPDATE trainer SET experience = 3
--c. �� ������� �������� ��������� ���������
UPDATE competition SET [location] = N'������ 11�', [status] = N'���������' WHERE [location] = N'��������� 10�'

--3.4. SELECT
--a. � ������� ����������� ��������� (SELECT atr1, atr2 FROM...)
SELECT competition_name, [location] FROM competition
--b. �� ����� ���������� (SELECT * FROM...)
SELECT * FROM competition
--c. � �������� �� �������� (SELECT * FROM ... WHERE atr1 = value)
SELECT * FROM competition WHERE [competition_name] = N'�����������'
--3.5. SELECT ORDER BY + TOP (LIMIT)
--a. � ����������� �� ����������� ASC + ����������� ������ ���������� �������
SELECT TOP 1 *
FROM competition
ORDER BY prize_pool ASC;
--b. � ����������� �� �������� DESC
SELECT TOP 1 *
FROM competition
ORDER BY prize_pool DESC;
--c. � ����������� �� ���� ��������� + ����������� ������ ���������� �������
SELECT TOP 1 *
FROM competition
ORDER BY prize_pool ASC, [status] DESC;
--d. � ����������� �� ������� ��������, �� ������ �����������
SELECT 
    competition_name, 
    [location], 
    prize_pool
FROM competition
ORDER BY competition_name;
--3.6. ������ � ������
--����������, ����� ���� �� ������ ��������� ������� � ����� DATETIME. ��������,
--������� ������� ����� ��������� ���� �������� ������.

--a. WHERE �� ����
SELECT *
FROM [action]
WHERE [start_of_preparation] = '2023-09-09';
--b. WHERE ���� � ���������
SELECT *
FROM [action]
WHERE start_of_preparation BETWEEN '2023-09-09' AND '2024-09-15';
--c. ������� �� ������� �� ��� ����, � ������ ���. ��������, ��� �������� ������.
SELECT result, YEAR(start_of_preparation) AS action_year
FROM [action];
--3.7. ������� ���������
--a. ��������� ���������� ������� � �������
SELECT COUNT(*) AS total_actions
FROM [action];
--b. ��������� ���������� ���������� ������� � �������
SELECT COUNT(DISTINCT prize_pool) AS unique_prize_pool
FROM competition;
--c. ������� ���������� �������� �������
SELECT DISTINCT prize_pool
FROM competition;
--d. ����� ������������ �������� �������
SELECT MAX(prize_pool) AS max_prize_pool
FROM competition;
--e. ����� ����������� �������� �������
SELECT MIN(prize_pool) AS min_prize_pool
FROM competition;
--f. �������� ������ COUNT() + GROUP BY
SELECT competition_name, COUNT(*) AS name_count
FROM competition
GROUP BY competition_name;

--3.8. SELECT GROUP BY + HAVING
--a. �������� 3 ������ ������� � �������������� GROUP BY + HAVING. ���
--������� ������� �������� ����������� � ����������, ����� ����������
--��������� ������. ������ ������ ���� �����������, �.�. �������� ����������,
--������� ����� ������������.

--���������� ������������ �� �� �������� � ������� ��, � ������� ����� �������� ������ ��������� 300000.
SELECT 
    competition_name, 
    SUM(prize_pool) AS total_prize_pool
FROM competition
GROUP BY competition_name
HAVING SUM(prize_pool) > 300000;

--���������� ������ �� ����������� � ������� ���, ��� ���������� � ����� ��� ����� ������������
SELECT 
    s.name AS sportsman_name, 
    COUNT(a.competition_id) AS competition_count
FROM sportsman s
JOIN [action] a ON s.sportsman_id = a.sportsman_id
GROUP BY s.name
HAVING COUNT(a.competition_id) > 1;

--������� ��������, � ������� ������� ��������� �� ����������� ������ 7
SELECT 
    t.name AS trainer_name, 
    AVG(a.result) AS average_result
FROM trainer t
JOIN sportsman s ON t.trainer_id = s.trainer_id
JOIN [action] a ON s.sportsman_id = a.sportsman_id
GROUP BY t.name
HAVING AVG(a.result) > 5;

--3.9. SELECT JOIN

--a. LEFT JOIN ���� ������ � WHERE �� ������ �� ���������
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
WHERE c.[location] = N'������ 6';
--b. RIGHT JOIN. �������� ����� �� �������, ��� � � 3.9 a
SELECT 
    c.competition_name, 
    c.competition_id, 
    a.action_id, 
    s.name AS sportsman_name, 
    c.[location]
FROM competition c
RIGHT JOIN [action] a ON c.competition_id = a.competition_id
RIGHT JOIN sportsman s ON a.sportsman_id = s.sportsman_id
WHERE c.[location] = N'������ 6';
--c. LEFT JOIN ���� ������ + WHERE �� �������� �� ������ �������
SELECT s.name AS sportsman_name, c.competition_name, t.name AS trainer_name
FROM sportsman s
LEFT JOIN [action] a ON s.sportsman_id = a.sportsman_id
LEFT JOIN competition c ON a.competition_id = c.competition_id
LEFT JOIN trainer t ON s.trainer_id = t.trainer_id
WHERE s.[rank] = N'������'
  AND c.[status] = N'���������'
  AND t.name = N'������';
  --d. INNER JOIN ���� ������
SELECT c.competition_name, a.start_of_preparation, a.end_of_preparation
FROM competition c
INNER JOIN [action] a ON c.competition_id = a.competition_id;
--3.10. ����������
--a. �������� ������ � �������� WHERE IN (���������)
SELECT competition_name, [location]
FROM competition
WHERE competition_id IN (
    SELECT competition_id
    FROM [action]
    WHERE sportsman_id IN (
        SELECT sportsman_id
        FROM sportsman
        WHERE [rank] = N'������'
    )
);
--b. �������� ������ SELECT atr1, atr2, (���������) FROM ...
SELECT s.name AS sportsman_name, (
    SELECT COUNT(*)
    FROM [action] a
    WHERE a.sportsman_id = s.sportsman_id
) AS competition_count
FROM sportsman s;
--c. �������� ������ ���� SELECT * FROM (���������)
SELECT *
FROM (
    SELECT s.name AS sportsman_name, c.competition_name, c.prize_pool
    FROM sportsman s
    INNER JOIN [action] a ON s.sportsman_id = a.sportsman_id
    INNER JOIN competition c ON a.competition_id = c.competition_id
) AS subquery
WHERE prize_pool > 200000;
--d. �������� ������ ���� SELECT * FROM table JOIN (���������) ON �
SELECT s.name AS sportsman_name, t.name AS trainer_name, subquery.competition_name, subquery.prize_pool
FROM sportsman s
INNER JOIN trainer t ON s.trainer_id = t.trainer_id
INNER JOIN (
    SELECT a.sportsman_id, c.competition_name, c.prize_pool
    FROM [action] a
    INNER JOIN competition c ON a.competition_id = c.competition_id
    WHERE c.prize_pool > 300000
) AS subquery ON s.sportsman_id = subquery.sportsman_id;