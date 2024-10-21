WITH cte AS ( -- Criando uma CTE para calcular indicadores chave para filtrar a consulta com base nos filtros estabelecidos
    SELECT -- Fazendo o SELECT com as informacoes que serao calculadas
		AVG(fis.SalesAmount - fis.TotalProductCost) AS avg_profit, -- Calculando a media do lucro
		MIN(fis.SalesAmount - fis.TotalProductCost) AS min_profit, -- Calculando o lucro minimo
		MAX(fis.SalesAmount - fis.TotalProductCost) AS max_profit -- Calculando o lucro maximo
    FROM -- Definindo as tabelas em que serao extraidos os dados e feitos os JOINs
		FactInternetSales fis -- Definindo a tabela de onde serao extraidos os dados
	INNER JOIN DimCustomer dc ON fis.CustomerKey = dc.CustomerKey -- Fazendo o JOIN com uma tabela intermediaria
		INNER JOIN DimGeography dg ON dc.GeographyKey = dg.GeographyKey -- Fazendo o JOIN com a tabela final para extrair o pais
    WHERE -- Definindo os filtros que serao aplicados na consulta (Lembrando que os filtros tem que estar de acordo com a consulta realizada posteriormente, ou nao, caso seja definido dessa forma pelas regras de negocio)
		YEAR(fis.OrderDate) = 2013 AND -- Filtrando a consulta de acordo o ano
		dg.EnglishCountryRegionName = 'United States' -- Filtrando a consulta de acordo o pais
)

SELECT TOP (100000) -- Selecionando os 100.000 primeiros resultados, independentemente da qtd. retornada, podendo ser maior ou menor
	fis.SalesOrderNumber AS 'order_number', -- Selecionando o numero do pedido
    fis.OrderDate AS 'order_date', -- Selecionando a data do pedido
    dpc.EnglishProductCategoryName AS 'category', -- Selecionando a categoria do produto
    fis.CustomerKey AS 'customer_id', -- Selecionando o codigo do cliente
    dc.FirstName + ' ' + dc.LastName AS 'name', -- Criando e selecionando o nome do cliente
    REPLACE(REPLACE(dc.Gender, 'M','Male'), 'F', 'Female') AS 'gender', -- Fazendo substituicoes nos valores de genero e selecionando o genero
    dg.EnglishCountryRegionName AS 'country', -- Selecionando o pais
    fis.OrderQuantity AS 'order_quantity', -- Selecionando a quantidade do pedido
    fis.SalesAmount AS 'sales_amount', -- Selecionando o valor do pedido
    fis.TotalProductCost AS 'total_product_cost', -- Selecionando o custo do produto
    fis.SalesAmount - fis.TotalProductCost AS 'sales_profit' -- Calculando o lucro e selecionando o lucro
FROM -- Definindo as tabelas em que serao extraidos os dados e feitos os JOINs, e adicionando o CTE tambem
	cte, -- Acessando as informacoes da CTE criada acima
	FactInternetSales fis -- Definindo a tabela de onde serao extraidos os dados
INNER JOIN DimProduct dp ON fis.ProductKey = dp.ProductKey -- Fazendo o JOIN com uma tabela intermediaria
	INNER JOIN DimProductSubcategory dps ON dp.ProductSubcategoryKey = dps.ProductSubcategoryKey -- Fazendo o JOIN com uma tabela intermediaria
		INNER JOIN DimProductCategory dpc ON dps.ProductCategoryKey = dpc.ProductCategoryKey -- Fazendo o JOIN com a tabela final para extrair a categoria do produto
INNER JOIN DimCustomer dc ON fis.CustomerKey = dc.CustomerKey -- Fazendo o JOIN com uma tabela intermediaria
	INNER JOIN DimGeography dg ON dc.GeographyKey = dg.GeographyKey -- Fazendo o JOIN com a tabela final para extrair o pais
WHERE -- Definindo os filtros que serao aplicados na consulta
	YEAR(fis.OrderDate) = 2013 AND -- Filtrando a consulta de acordo o ano
	(fis.SalesAmount - fis.TotalProductCost) > cte.avg_profit AND -- Filtrando a consulta de acordo com os valores acima da media
	dg.EnglishCountryRegionName = 'United States'; -- Filtrando a consulta de acordo o pais

-- Detalhe que todas as tabelas receberam alias (apelidos) para diminuir o codigo e facilitar sua compreensao, como FactInternetSales virou apenas as iniciais fis