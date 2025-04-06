USE pharmacy;
GO
--1 �������� ������� �����.
ALTER TABLE dealer
ADD CONSTRAINT FK_dealer_company
FOREIGN KEY (id_company) REFERENCES company(id_company);
GO

ALTER TABLE production
ADD CONSTRAINT FK_production_company
FOREIGN KEY (id_company) REFERENCES company(id_company);
GO

ALTER TABLE production
ADD CONSTRAINT FK_production_medicine
FOREIGN KEY (id_medicine) REFERENCES medicine(id_medicine);
GO

ALTER TABLE [order]
ADD CONSTRAINT FK_order_production
FOREIGN KEY (id_production) REFERENCES production(id_production);
GO

ALTER TABLE [order]
ADD CONSTRAINT FK_order_dealer
FOREIGN KEY (id_dealer) REFERENCES dealer(id_dealer);
GO

ALTER TABLE [order]
ADD CONSTRAINT FK_order_pharmacy
FOREIGN KEY (id_pharmacy) REFERENCES pharmacy(id_pharmacy);
GO

--2 ������ ���������� �� ���� ������� ���������� ��������� �������� ������
--� ��������� �������� �����, ���, ������ �������.
SELECT
    p.name AS pharmacy_name,  
    o.date AS order_date,     
    o.quantity AS order_quantity  
FROM dbo.[order] o
JOIN dbo.production pr ON o.id_production = pr.id_production  
JOIN dbo.company c ON pr.id_company = c.id_company  
JOIN dbo.medicine m ON pr.id_medicine = m.id_medicine  
JOIN dbo.pharmacy p ON o.id_pharmacy = p.id_pharmacy  
WHERE
    m.name = N'��������'  
    AND c.name = N'�����'; 

-- 3 ���� ������ �������� �������� �������, �� ������� �� ���� ������� ������
-- �� 25 ������.
SELECT
    m.id_medicine,
    m.name AS medicine_name
FROM medicine m
JOIN production pr ON m.id_medicine = pr.id_medicine  
JOIN company c ON pr.id_company = c.id_company  
LEFT JOIN [order] o ON pr.id_production = o.id_production AND o.date < '2019-01-25'  
WHERE
    c.name = N'�����'  
    AND o.id_order IS NULL

--4 ���� ����������� � ������������ ����� �������� ������ �����, �������
--�������� �� ����� 120 �������.
SELECT
    c.id_company,
    c.name AS company_name,
	MIN(pr.rating) AS min_rating,
	MAX(pr.rating) AS max_rating
FROM
    company c
JOIN
    production pr ON c.id_company = pr.id_company  
JOIN
    [order] o ON pr.id_production = o.id_production 
GROUP BY
    c.id_company, c.name  
HAVING
    COUNT(o.id_order) >= 120;  

--5 ���� ������ ��������� ������ ����� �� ���� ������� �������� �AstraZeneca�.
--���� � ������ ��� �������, � �������� ������ ���������� NULL.
SELECT
    d.id_dealer,
    d.name AS dealer_name,
    COALESCE(p.name, 'NULL') AS pharmacy_name  
FROM dealer d
JOIN company c ON d.id_company = c.id_company  
LEFT JOIN (
    SELECT DISTINCT o.id_dealer, p.name
    FROM [order] o
    LEFT JOIN pharmacy p ON o.id_pharmacy = p.id_pharmacy
) p ON d.id_dealer = p.id_dealer
 
ORDER BY d.id_dealer;

--6 ��������� �� 20% ��������� ���� ��������, ���� ��� ��������� 3000, �
--������������ ������� �� ����� 7 ����.
	UPDATE
    production
SET
    price = price * 0.8  
WHERE
    price > 3000  
    AND id_medicine IN (
        SELECT
            id_medicine
        FROM
            medicine
        WHERE
            cure_duration <= 7  
    );
	--�����������
--7 �������� ����������� �������.
CREATE INDEX IX_order_id_production ON [order] (id_production);
CREATE INDEX IX_order_id_dealer ON [order] (id_dealer);
CREATE INDEX IX_order_id_pharmacy ON [order] (id_pharmacy);
CREATE INDEX IX_order_date ON [order] (date);
--����������� ����� �������
CREATE INDEX IX_production_id_company ON production (id_company);
CREATE INDEX IX_production_id_medicine ON production (id_medicine);
CREATE INDEX IX_production_rating ON production (rating);
CREATE INDEX IX_production_price ON production (price);

CREATE INDEX IX_medicine_name ON medicine (name);
CREATE INDEX IX_medicine_cure_duration ON medicine (cure_duration);

CREATE INDEX IX_company_name ON company (name);

CREATE INDEX IX_dealer_id_company ON dealer (id_company);

CREATE INDEX IX_pharmacy_name ON pharmacy (name);