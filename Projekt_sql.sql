-- Projekt SQL
-- Barbora Tomsu


-- Vytvoření primární tabulky s průměrnými mzdami a cenami potravin

CREATE TABLE t_barbora_tomsu_project_SQL_primary_final AS

SELECT
    wages.payroll_year,
    wages.industry_branch,
    wages.average_wage,
    prices.food_category_code,
    prices.food_category,
    prices.price_value,
    prices.price_unit,
    prices.average_price
FROM
(
    SELECT
        cp.payroll_year,
        cpib.name AS industry_branch,
        AVG(cp.value) AS average_wage
    FROM czechia_payroll cp
    JOIN czechia_payroll_industry_branch cpib
        ON cp.industry_branch_code = cpib.code
    WHERE cp.value_type_code = 5958
        AND cp.unit_code = 200
        AND cp.calculation_code = 200
        AND cp.payroll_year BETWEEN 2006 AND 2018
        AND cp.value IS NOT NULL
    GROUP BY
        cp.payroll_year,
        cpib.name
) wages

JOIN
(
    SELECT
        EXTRACT(YEAR FROM cp.date_from) AS price_year,
        cpc.code AS food_category_code,
        cpc.name AS food_category,
        cpc.price_value,
        cpc.price_unit,
        AVG(cp.value) AS average_price
    FROM czechia_price cp
    JOIN czechia_price_category cpc
        ON cp.category_code = cpc.code
    GROUP BY
        EXTRACT(YEAR FROM cp.date_from),
        cpc.code,
        cpc.name,
        cpc.price_value,
        cpc.price_unit
) prices
    ON wages.payroll_year = prices.price_year;


-- Vytvoření sekundární tabulky s ekonomickými údaji evropských států

CREATE TABLE t_barbora_tomsu_project_SQL_secondary_final AS

SELECT
    c.country,
    e.year,
    e.gdp,
    e.gini,
    e.population

FROM countries c

JOIN economies e
    ON c.country = e.country

WHERE c.continent = 'Europe'
    AND e.year BETWEEN 2006 AND 2018;


-- Výzkumná otázka č. 1

-- Přehled vývoje mezd podle odvětví

SELECT
    payroll_year,
    industry_branch,
    average_wage,
    previous_wage,
    CASE
        WHEN previous_wage IS NULL THEN 'Nelze porovnat'
        WHEN average_wage > previous_wage THEN 'Růst'
        WHEN average_wage < previous_wage THEN 'Pokles'
        ELSE 'Beze změny'
    END AS wage_development
FROM (
    SELECT
        payroll_year,
        industry_branch,
        average_wage,
        LAG(average_wage) OVER (
            PARTITION BY industry_branch
            ORDER BY payroll_year
        ) AS previous_wage
    FROM (
        SELECT DISTINCT
            payroll_year,
            industry_branch,
            average_wage
        FROM t_barbora_tomsu_project_SQL_primary_final
    ) wages
) wage_comparison
ORDER BY
    industry_branch,
    payroll_year;

-- Přehled odvětví a let, kdy došlo k poklesu mezd

SELECT
    payroll_year,
    industry_branch,
    average_wage,
    previous_wage
FROM (
    SELECT
        payroll_year,
        industry_branch,
        average_wage,
        LAG(average_wage) OVER (
            PARTITION BY industry_branch
            ORDER BY payroll_year
        ) AS previous_wage
    FROM (
        SELECT DISTINCT
            payroll_year,
            industry_branch,
            average_wage
        FROM t_barbora_tomsu_project_SQL_primary_final
    ) wages
) wage_comparison
WHERE average_wage < previous_wage
ORDER BY
    industry_branch,
    payroll_year;


-- Výzkumná otázka č. 2

-- Kupní síla pro chléb a mléko v letech 2006 a 2018

SELECT
    payroll_year,
    food_category,
    ROUND(AVG(average_wage)::numeric, 2) AS average_wage,
    ROUND(average_price::numeric, 2) AS average_price,
    price_unit,
    ROUND(
        (AVG(average_wage) / average_price)::numeric,
        2
    ) AS purchasable_amount
FROM t_barbora_tomsu_project_SQL_primary_final
WHERE payroll_year IN (2006, 2018)
    AND food_category IN (
        'Chléb konzumní kmínový',
        'Mléko polotučné pasterované'
    )
GROUP BY
    payroll_year,
    food_category,
    average_price,
    price_unit
ORDER BY
    food_category,
    payroll_year;


-- Výzkumná otázka č. 3

-- Průměrný meziroční růst cen jednotlivých potravin

SELECT
    food_category,
    ROUND(AVG(price_growth_percent)::numeric, 2) AS average_price_growth_percent
FROM (
    SELECT
        payroll_year,
        food_category,
        average_price,
        LAG(average_price) OVER (
            PARTITION BY food_category
            ORDER BY payroll_year
        ) AS previous_price,
        (
            (average_price - LAG(average_price) OVER (
                PARTITION BY food_category
                ORDER BY payroll_year
            ))
            / LAG(average_price) OVER (
                PARTITION BY food_category
                ORDER BY payroll_year
            )
            * 100
        ) AS price_growth_percent
    FROM (
        SELECT DISTINCT
            payroll_year,
            food_category,
            average_price
        FROM t_barbora_tomsu_project_SQL_primary_final
    ) prices
) price_comparison
WHERE previous_price IS NOT NULL
GROUP BY food_category
ORDER BY average_price_growth_percent;


-- Výzkumná otázka č. 4

-- Porovnání meziročního růstu mezd a cen potravin

WITH yearly_wages AS (
    SELECT
        payroll_year,
        AVG(average_wage) AS average_wage
    FROM (
        SELECT DISTINCT
            payroll_year,
            industry_branch,
            average_wage
        FROM t_barbora_tomsu_project_SQL_primary_final
    ) wages
    GROUP BY payroll_year
),
yearly_prices AS (
    SELECT
        payroll_year,
        AVG(average_price) AS average_price
    FROM (
        SELECT DISTINCT
            payroll_year,
            food_category,
            average_price
        FROM t_barbora_tomsu_project_SQL_primary_final
    ) prices
    GROUP BY payroll_year
),
yearly_growth AS (
    SELECT
        w.payroll_year,
        (w.average_wage / LAG(w.average_wage) OVER (
            ORDER BY w.payroll_year
        ) - 1) * 100 AS wage_growth,
        (p.average_price / LAG(p.average_price) OVER (
            ORDER BY p.payroll_year
        ) - 1) * 100 AS price_growth
    FROM yearly_wages w
    JOIN yearly_prices p
        ON w.payroll_year = p.payroll_year
)
SELECT
    payroll_year,
    ROUND(wage_growth::numeric, 2) AS wage_growth,
    ROUND(price_growth::numeric, 2) AS price_growth,
    ROUND((price_growth - wage_growth)::numeric, 2) AS difference
FROM yearly_growth
ORDER BY payroll_year;


-- Výzkumná otázka č. 5

-- Porovnání růstu HDP s růstem mezd a cen ve stejném a následujícím roce

WITH yearly_wages AS (
    SELECT
        payroll_year,
        AVG(average_wage) AS average_wage
    FROM (
        SELECT DISTINCT
            payroll_year,
            industry_branch,
            average_wage
        FROM t_barbora_tomsu_project_SQL_primary_final
    ) wages
    GROUP BY payroll_year
),
yearly_prices AS (
    SELECT
        payroll_year,
        AVG(average_price) AS average_price
    FROM (
        SELECT DISTINCT
            payroll_year,
            food_category,
            average_price
        FROM t_barbora_tomsu_project_SQL_primary_final
    ) prices
    GROUP BY payroll_year
),
yearly_growth AS (
    SELECT
        s.year,
        (s.gdp / LAG(s.gdp) OVER (ORDER BY s.year) - 1) * 100 AS gdp_growth,
        (w.average_wage / LAG(w.average_wage) OVER (
            ORDER BY w.payroll_year
        ) - 1) * 100 AS wage_growth,
        (p.average_price / LAG(p.average_price) OVER (
            ORDER BY p.payroll_year
        ) - 1) * 100 AS price_growth
    FROM t_barbora_tomsu_project_SQL_secondary_final s
    JOIN yearly_wages w
        ON s.year = w.payroll_year
    JOIN yearly_prices p
        ON s.year = p.payroll_year
    WHERE s.country = 'Czech Republic'
)
SELECT
    year,
    ROUND(gdp_growth::numeric, 2) AS gdp_growth,
    ROUND(wage_growth::numeric, 2) AS wage_growth_same_year,
    ROUND(price_growth::numeric, 2) AS price_growth_same_year,
    ROUND(LEAD(wage_growth) OVER (ORDER BY year)::numeric, 2)
        AS wage_growth_next_year,
    ROUND(LEAD(price_growth) OVER (ORDER BY year)::numeric, 2)
        AS price_growth_next_year
FROM yearly_growth
ORDER BY year;