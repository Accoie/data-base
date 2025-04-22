USE [University]

--1 Добавить внешние ключи.
ALTER TABLE student 
ADD 
	CONSTRAINT FK_student_id_group FOREIGN KEY (id_group) REFERENCES [group](id_group)

ALTER TABLE lesson
ADD 
	CONSTRAINT FK_lesson_id_teacher FOREIGN KEY (id_teacher) REFERENCES teacher(id_teacher),
	CONSTRAINT FK_lesson_id_subject FOREIGN KEY (id_subject) REFERENCES [subject](id_subject),
	CONSTRAINT FK_lesson_id_group FOREIGN KEY (id_group) REFERENCES [group](id_group)

ALTER TABLE mark
ADD 
	CONSTRAINT FK_mark_student_id_student FOREIGN KEY (id_student) REFERENCES [student](id_student),
	CONSTRAINT FK_mark_lesson_id_lesson FOREIGN KEY (id_lesson) REFERENCES [lesson](id_lesson)

GO
--2 Выдать оценки студентов по информатике если они обучаются данному
--предмету. Оформить выдачу данных с использованием view.
DROP VIEW IF EXISTS dbo.marks;
GO
CREATE VIEW dbo.marks AS
SELECT 
    m.mark, 
    s.name, 
    s.phone, 
    s.id_group
FROM 
    dbo.mark m
JOIN 
    dbo.student s ON s.id_student = m.id_student
JOIN 
    dbo.lesson l ON l.id_lesson = m.id_lesson
JOIN 
    dbo.[subject] sub ON sub.id_subject = l.id_subject AND sub.name = N'Информатика';

GO
--3 Дать информацию о должниках с указанием фамилии студента и названия
--предмета. Должниками считаются студенты, не имеющие оценки по предмету,
--который ведется в группе. Оформить в виде процедуры, на входе
--идентификатор группы.

--having
CREATE OR ALTER PROCEDURE dbo.GetDebtorsByGroup
    @group_id INT
AS
BEGIN
    WITH StudentMarks AS (
    SELECT 
        s.id_student,
        s.name AS student_name,
        sub.id_subject,
        sub.name AS subject_name,
        COUNT(m.id_mark) OVER (PARTITION BY s.id_student, sub.id_subject) AS marks_count
    FROM student s
    JOIN [group] g ON s.id_group = g.id_group AND g.id_group = @group_id
    JOIN lesson l ON l.id_group = g.id_group
    JOIN subject sub ON sub.id_subject = l.id_subject
    LEFT JOIN mark m ON m.id_student = s.id_student AND m.id_lesson = l.id_lesson
)
SELECT 
    student_name,
    subject_name
FROM (
    SELECT * FROM StudentMarks
) AS FilteredMarks
WHERE marks_count = 0
GROUP BY student_name, subject_name;

END;

EXEC GetDebtorsByGroup 3;
GO

--4 Дать среднюю оценку студентов по каждому предмету для тех предметов, по
--которым занимается не менее 35 студентов.
WITH StudentsMarks AS (
SELECT DISTINCT
	s.name AS student_name, 
	sub.name AS subject_name,
	AVG(m.mark) OVER (PARTITION BY s.name, sub.name) AS student_mark
FROM student s 
	JOIN lesson l ON l.id_group = s.id_group
	JOIN subject sub ON l.id_subject = sub.id_subject
	JOIN mark m ON m.id_lesson = l.id_lesson AND m.id_student = s.id_student
)
SELECT student_name, subject_name, student_mark 
FROM (
	SELECT 
		student_name, 
		subject_name, 
		student_mark, 
		COUNT(student_name) OVER (PARTITION BY subject_name) AS count_student FROM StudentsMarks
	) AS CountStudents
WHERE count_student > 35
ORDER BY student_name

--5 Дать оценки студентов специальности ВМ по всем проводимым предметам с
--указанием группы, фамилии, предмета, даты. При отсутствии оценки заполнить
--значениями поля оценки.

SELECT g.name AS name_group, s.name AS name_student, sub.name AS name_subject, l.date, 
COALESCE(m.mark, 0) AS mark FROM lesson l
JOIN student s ON s.id_group = l.id_group
LEFT JOIN mark m ON m.id_lesson = l.id_lesson AND m.id_student = s.id_student
JOIN subject sub ON sub.id_subject = l.id_subject
JOIN [group] g ON g.id_group = l.id_group
WHERE g.name = 'ВМ'
ORDER BY name_student, name_subject, date

--6 Всем студентам специальности ПС, получившим оценки меньшие 5 по предмету
--БД до 12.05, повысить эти оценки на 1 балл.
UPDATE mark SET mark.mark += 1 WHERE mark.id_mark IN (
	SELECT id_mark FROM mark m
	JOIN lesson l ON l.id_lesson = m.id_lesson AND l.date <= '2019-05-12'
	JOIN student s ON m.id_student = s.id_student
	JOIN [group] g ON g.id_group = s.id_group AND g.name = 'ПС'
	JOIN subject sub ON sub.id_subject = l.id_subject AND sub.name = 'БД'
WHERE m.mark < 5)

--7 Добавить необходимые индексы.
CREATE UNIQUE INDEX UI_group_name ON [group](name) INCLUDE (id_group);
CREATE UNIQUE INDEX UI_subject_name ON [subject](name) INCLUDE (id_subject);

CREATE INDEX IX_student_id_group ON student(id_group)

CREATE INDEX IX_mark_id_lesson ON mark(id_lesson)
CREATE INDEX IX_mark_id_student ON mark(id_student)

CREATE INDEX IX_lesson_id_group ON lesson(id_group)
CREATE INDEX IX_lesson_id_subject ON lesson(id_subject)
