# Projekt SQL

Autor: Barbora Tomšů

## Zadání

Cílem projektu bylo vytvořit dvě výsledné tabulky a pomocí SQL odpovědět na pět výzkumných otázek o mzdách, cenách potravin a HDP.

## Použité zdrojové tabulky

- czechia_payroll
- czechia_payroll_industry_branch
- czechia_price
- czechia_price_category
- countries
- economies

## Vytvořené tabulky

### t_barbora_tomsu_project_SQL_primary_final

Obsahuje průměrné mzdy podle odvětví a průměrné ceny potravin za společné období let 2006–2018.

### t_barbora_tomsu_project_SQL_secondary_final

Obsahuje údaje o HDP, GINI koeficientu a počtu obyvatel evropských států za stejné období.

## Odpovědi na výzkumné otázky

### 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

Ve většině odvětví mzdy rostly. V některých letech ale došlo i k jejich poklesu.

### 2. Kolik bylo možné koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období?

V roce 2006 bylo možné za průměrnou mzdu koupit přibližně:

- 1 312 kg chleba
- 1 465 l mléka

V roce 2018 bylo možné koupit přibližně:

- 1 365 kg chleba
- 1 669 l mléka

V roce 2018 bylo tedy možné za průměrnou mzdu koupit více chleba i mléka než v roce 2006.

### 3. Která kategorie potravin zdražovala nejpomaleji?

Nejpomaleji zdražoval cukr krystal. Jeho průměrná meziroční změna ceny byla -1,92 %.

### 4. Existuje rok, kdy ceny potravin rostly výrazně rychleji než mzdy?

Takový rok se v dostupných datech nepotvrdil. Největší rozdíl byl v roce 2013, kdy ceny rostly rychleji než mzdy o 6,65 procentního bodu.

### 5. Má výška HDP vliv na změny mezd a cen potravin?

Z dostupných dat není vidět, že by vyšší růst HDP vždy znamenal vyšší růst mezd nebo cen potravin ve stejném ani v následujícím roce.

## Poznámky

- Obě výsledné tabulky obsahují data za roky 2006–2018.
- U některých států chybí hodnoty GINI koeficientu, proto se zobrazují jako `NULL`.
- Zdrojová data nebyla upravována. Všechny výpočty byly provedeny pomocí SQL dotazů.
