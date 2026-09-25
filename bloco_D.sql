Clientes cujo gasto total está acima da média geral de gasto por cliente
********************************************************************************/
-- Pergunta: Quais clientes gastaram mais que a média de todos os clientes?
SELECT
c."customer_id",
CAST(SUM(pg."payment_value") AS numeric(18,2)) AS gasto_total
FROM "Pedidos" p
JOIN "Pagamentos" pg ON p."pedido_id" = pg."order_id"
JOIN "Clientes" c ON p."cliente_id" = c."customer_id"
GROUP BY c."customer_id"
HAVING SUM(pg."payment_value") >
(
SELECT AVG(gasto_por_cliente)
FROM (
SELECT SUM(pg2."payment_value") AS gasto_por_cliente
FROM "Pedidos" p2
JOIN "Pagamentos" pg2 ON p2."pedido_id" = pg2."order_id"
GROUP BY p2."cliente_id"
) s
)
ORDER BY gasto_total DESC;
/********************************************************************************
2) Produtos que nunca receberam avaliação (NOT EXISTS)
********************************************************************************/
-- Pergunta: Quais produtos não têm nenhuma avaliação associada?
SELECT
pr."product_id",
pr."product_category_name"
FROM "Produtos" pr
WHERE NOT EXISTS (
SELECT 1
FROM "Itens" it
JOIN "Avaliacoes" a ON it."order_id" = a."order_id"
WHERE it."product_id" = pr."product_id"
);

/********************************************************************************
3) Vendedores que venderam produtos de mais de 5 categorias diferentes
********************************************************************************/
-- Pergunta: Quais vendedores venderam em mais de 5 categorias distintas?
SELECT
v."seller_id"
FROM "Vendedores" v
WHERE (
SELECT COUNT(DISTINCT pr."product_category_name")
FROM "Itens" it
JOIN "Produtos" pr ON it."product_id" = pr."product_id"
WHERE it."seller_id" = v."seller_id"
) > 5;

/********************************************************************************
4) Pedidos cujo frete é maior que o valor total dos itens do pedido
********************************************************************************/
-- Pergunta: Quais pedidos têm custo de frete total maior que o total dos itens?
SELECT
it."order_id",
SUM(it."freight_value") AS total_frete,
SUM(it."price") AS total_itens
FROM "Itens" it
GROUP BY it."order_id"
HAVING SUM(it."freight_value") > SUM(it."price")
ORDER BY total_frete DESC;
