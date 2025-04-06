--1 Добавить внешние ключи.
ALTER TABLE room ADD CONSTRAINT fk_room_hotel 
    FOREIGN KEY (id_hotel) REFERENCES hotel(id_hotel);

ALTER TABLE room ADD CONSTRAINT fk_room_category 
    FOREIGN KEY (id_room_category) REFERENCES room_category(id_room_category);
    
ALTER TABLE booking ADD CONSTRAINT fk_booking_client 
    FOREIGN KEY (id_client) REFERENCES client(id_client);
    
ALTER TABLE room_in_booking ADD CONSTRAINT fk_room_booking_booking 
    FOREIGN KEY (id_booking) REFERENCES booking(id_booking);
    
ALTER TABLE room_in_booking ADD CONSTRAINT fk_room_booking_room 
    FOREIGN KEY (id_room) REFERENCES room(id_room);
--2 Выдать информацию о клиентах гостиницы “Космос”, проживающих в номерах
--категории “Люкс” на 1 апреля 2019г.
SELECT * FROM client c
JOIN booking b ON b.id_client = c.id_client
JOIN room_in_booking rib ON rib.id_booking = b.id_booking AND rib.checkin_date <= '2019-04-01' 
AND rib.checkout_date > '2019-04-01'
JOIN room r ON rib.id_room = r.id_room
JOIN room_category rc ON rc.id_room_category = r.id_room_category
JOIN hotel h ON r.id_hotel = h.id_hotel
WHERE 
h.name = N'Космос'
AND rc.name = N'Люкс' 
--3 Дать список свободных номеров всех гостиниц на 22 апреля.
SELECT 
    h.name AS hotel_name,
    r.number,
    rc.name AS category_name,
    rc.square
FROM room r
INNER JOIN hotel h ON r.id_hotel = h.id_hotel
INNER JOIN room_category rc ON r.id_room_category = rc.id_room_category
WHERE r.id_room NOT IN (
    SELECT rib.id_room
    FROM room_in_booking rib
    WHERE 
        rib.checkin_date < '2023-04-23' AND
        rib.checkout_date > '2023-04-22'
);
--4 Дать количество проживающих в гостинице “Космос” на 23 марта по каждой
--категории номеров
SELECT 
rc.name AS category_name,
COUNT(DISTINCT c.id_client) AS count_living FROM client c
JOIN booking b ON c.id_client = b.id_client
JOIN room_in_booking rib ON b.id_booking = rib.id_booking
JOIN room r ON r.id_room = rib.id_room
JOIN hotel h ON h.id_hotel = r.id_hotel
JOIN room_category rc ON rc.id_room_category = r.id_room_category
WHERE h.name = N'Космос' AND rib.checkin_date <= '2019-03-23' 
AND rib.checkout_date > '2019-03-23'
GROUP BY rc.name;
--5 Дать список последних проживавших клиентов по всем комнатам гостиницы
--“Космос”, выехавшим в апреле с указанием даты выезда.
WITH RoomLastAprilCheckout AS (
    SELECT 
        r.id_room,
        r.number,
        rib.checkout_date,
        c.id_client,
        c.name AS client_name,
        c.phone,
        ROW_NUMBER() OVER (
            PARTITION BY r.id_room 
            ORDER BY rib.checkout_date DESC
        ) AS row_num
    FROM room r
    JOIN hotel h ON r.id_hotel = h.id_hotel
    JOIN room_in_booking rib ON r.id_room = rib.id_room
    JOIN booking b ON rib.id_booking = b.id_booking
    JOIN client c ON b.id_client = c.id_client
    WHERE h.name = N'Космос'
      AND rib.checkout_date >= '2019-04-01' 
      AND rib.checkout_date < '2019-05-01'
)
SELECT 
    id_room,
    number,
    client_name,
    phone,
    checkout_date
FROM RoomLastAprilCheckout
WHERE row_num = 1
ORDER BY id_room;
--6 Продлить на 2 дня дату проживания в гостинице “Космос” всем клиентам
--комнат категории “Бизнес”, которые заселились 10 мая.
--UPDATE rib SET rib.checkout_date = DATEADD(day, 2, rib.checkout_date)
--FROM room_in_booking AS rib
--JOIN booking b ON rib.id_booking = b.id_booking
--JOIN room r ON rib.id_room = r.id_room
--JOIN hotel h ON r.id_hotel = h.id_hotel
--JOIN room_category rc ON rc.id_room_category = r.id_room_category
--WHERE
	--h.name = N'Космос' AND
	--rc.name = N'Бизнес' AND rib.checkin_date = '2019-05-10'
SELECT rib.checkout_date 
FROM room_in_booking AS rib
JOIN booking b ON rib.id_booking = b.id_booking
JOIN room r ON rib.id_room = r.id_room
JOIN hotel h ON r.id_hotel = h.id_hotel
JOIN room_category rc ON rc.id_room_category = r.id_room_category
WHERE
	h.name = N'Космос' AND
	rc.name = N'Бизнес' AND rib.checkin_date = '2019-05-10'
--7 Найти все "пересекающиеся" варианты проживания. Правильное состояние: не
--может быть забронирован один номер на одну дату несколько раз, т.к. нельзя
--заселиться нескольким клиентам в один номер. Записи в таблице
--room_in_booking с id_room_in_booking = 5 и 2154 являются примером
--неправильного состояния, которые необходимо найти. Результирующий кортеж
--выборки должен содержать информацию о двух конфликтующих номерах.
SELECT a.*, b.* 
FROM room_in_booking a
JOIN room_in_booking b
ON a.id_room = b.id_room AND a.checkin_date < b.checkout_date AND a.checkout_date >= b.checkout_date AND a.id_room_in_booking != b.id_room_in_booking
--8 Создать бронирование в транзакции.
BEGIN TRANSACTION;
BEGIN TRY

    DECLARE @client_number NVARCHAR(25) = '+79161234567'
	DECLARE @client_name NVARCHAR(50) = 'Петров Сергей Петрович'
	DECLARE @checkin_date DATE = '2019-07-13'
	DECLARE @checkout_date DATE = '2019-07-19'
	DECLARE @room_id INT = 71
	DECLARE @client_id INT;

	IF NOT EXISTS(SELECT id_client FROM client WHERE phone = @client_number)
	BEGIN
		INSERT INTO client(name, phone)
		VALUES (@client_name, @client_number);
		SET @client_id = SCOPE_IDENTITY();
	END
	ELSE
	BEGIN
		SET @client_id = (SELECT id_client FROM client WHERE phone = @client_number);
	END

	DECLARE @booking_id INT;

	INSERT INTO booking(id_client, booking_date) VALUES (@client_id, @checkin_date)
	SET @booking_id = SCOPE_IDENTITY();

	IF NOT EXISTS(
	SELECT id_room_in_booking FROM room_in_booking rib WHERE rib.id_room = @room_id
	AND rib.checkout_date > @checkin_date AND rib.checkout_date >= @checkout_date
	)
	BEGIN
		INSERT INTO room_in_booking(id_booking, checkin_date, checkout_date, id_room) VALUES (@booking_id, @checkin_date, @checkout_date, @room_id)
	END
	ELSE
	BEGIN
		RAISERROR('Один или несколько номеров уже заняты на указанные даты', 16, 1);
	END

	COMMIT TRANSACTION;
    
    SELECT 'Бронирование успешно создано. Номер брони: ' + CAST(@booking_id AS VARCHAR);
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
    
    -- Возвращаем сообщение об ошибке
    SELECT 'Ошибка при создании бронирования: ' + ERROR_MESSAGE() AS ErrorMessage;
END CATCH


-- проверка на правильность запроса
SELECT rib.id_room_in_booking FROM room_in_booking rib JOIN booking b ON b.id_booking = rib.id_booking
JOIN client c
ON c.id_client = b.id_client
WHERE
c.name = 'Петров Сергей Петрович'

--9 Добавить необходимые индексы для всех таблиц.
CREATE INDEX IX_booking_date ON [booking] (booking_date)

CREATE INDEX IX_client_name ON [client] (name)
CREATE UNIQUE INDEX IX_client_phone ON [client] (phone)

CREATE INDEX IX_hotel_name ON [hotel] (name)

CREATE INDEX IX_room_number ON [room] (number)
CREATE INDEX IX_room_price ON [room] (price)

CREATE INDEX IX_room_category_name ON [room_category] (name)
CREATE INDEX IX_room_category_name_square ON [room_category] ([square])

CREATE INDEX IX_room_in_booking_checkin_date ON [room_in_booking] (checkin_date)
CREATE INDEX IX_room_in_booking_checkout_date ON [room_in_booking](checkout_date)