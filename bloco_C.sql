Faturamento total por estado do cliente
********************************************************************************/
-- Pergunta: Quanto cada estado de cliente faturou no total?
SELECT
c."customer_state" AS estado_cliente,
CAST(SUM(pg."payment_value") AS numeric(18,2)) AS faturamento_total
FROM "Pedidos" p
JOIN "Pagamentos" pg ON p."pedido_id" = pg."order_id"
JOIN "Clientes" c ON p."cliente_id" = c."customer_id"
GROUP BY c."customer_state"
ORDER BY faturamento_total DESC;
/********************************************************************************
2) Top 10 vendedores por faturamento
********************************************************************************/
-- Pergunta: Quem são os 10 vendedores com maior faturamento?
SELECT
it."seller_id",
CAST(SUM(pg."payment_value") AS numeric(18,2)) AS faturamento_total
FROM "Itens" it
JOIN "Pagamentos" pg ON it."order_id" = pg."order_id"
GROUP BY it."seller_id"
ORDER BY faturamento_total DESC
LIMIT 10;

/********************************************************************************
3) Ticket médio por categoria de produto
********************************************************************************/
-- Pergunta: Qual o ticket médio (média do pagamento) por categoria de produto?
SELECT
pr."product_category_name",
ROUND(AVG(pg."payment_value")::numeric, 2) AS ticket_medio
FROM "Itens" it
JOIN "Produtos" pr ON it."product_id" = pr."product_id"
JOIN "Pagamentos" pg ON it."order_id" = pg."order_id"
GROUP BY pr."product_category_name"
ORDER BY ticket_medio DESC;

/********************************************************************************
4) Vendedores com nota média de avaliação abaixo de 3
********************************************************************************/
-- Pergunta: Quais vendedores têm média de avaliação inferior a 3?
SELECT
it."seller_id",
AVG(a."review_score") AS nota_media
FROM "Itens" it
JOIN "Avaliacoes" a ON it."order_id" = a."order_id"
GROUP BY it."seller_id"
HAVING AVG(a."review_score") < 3
ORDER BY nota_media ASC;

/********************************************************************************
5) Quantidade de pedidos por forma de pagamento
********************************************************************************/
-- Pergunta: Quantos pedidos foram pagos por cada tipo de pagamento?
SELECT
pg."payment_type",
COUNT(DISTINCT pg."order_id") AS quantidade_pedidos
FROM "Pagamentos" pg
GROUP BY pg."payment_type"
ORDER BY quantidade_pedidos DESC;

/********************************************************************************
6) Peso médio dos produtos por categoria
********************************************************************************/
-- Pergunta: Qual o peso médio dos produtos em cada categoria?
SELECT
pr."product_category_name",
ROUND(AVG(pr."product_weight_g")::numeric, 2) AS peso_medio
FROM "Produtos" pr
GROUP BY pr."product_category_name"
ORDER BY peso_medio DESC;

/********************************************************************************
7) Número médio de parcelas por categoria de produto
********************************************************************************/
-- Pergunta: Em média, quantas parcelas os pedidos de cada categoria usam?
SELECT
pr."product_category_name",
ROUND(AVG(pg."payment_installments")::numeric, 2) AS numero_medio_parcelas
FROM "Itens" it
JOIN "Produtos" pr ON it."product_id" = pr."product_id"
JOIN "Pagamentos" pg ON it."order_id" = pg."order_id"
GROUP BY pr."product_category_name"
ORDER BY numero_medio_parcelas DESC;
