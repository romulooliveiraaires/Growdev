CTE: faturamento mensal por estado + variação percentual mês a mês
********************************************************************************/
-- Pergunta: Como varia o faturamento mês a mês por estado?
WITH faturamento_mensal AS (
SELECT
c."customer_state" AS customer_state,
date_trunc('month', p."datahora_pedido")::date AS mes_ref,
SUM(pg."payment_value")::numeric AS faturamento
FROM "Pedidos" p
JOIN "Pagamentos" pg ON p."pedido_id" = pg."order_id"
JOIN "Clientes" c ON p."cliente_id" = c."customer_id"
WHERE p."datahora_pedido" IS NOT NULL
GROUP BY c."customer_state", mes_ref
)
SELECT
customer_state,
EXTRACT(YEAR FROM mes_ref) AS ano,
EXTRACT(MONTH FROM mes_ref) AS mes,
ROUND(faturamento, 2) AS faturamento,
ROUND(
100::numeric * (faturamento - LAG(faturamento) OVER (PARTITION BY customer_state ORDER BY mes_ref))
/ NULLIF(LAG(faturamento) OVER (PARTITION BY customer_state ORDER BY mes_ref), 0)
, 2) AS variacao_percentual
FROM faturamento_mensal
ORDER BY customer_state, ano, mes;
/********************************************************************************
2) CTE: volume de avaliações e nota média por categoria (filtrar volume relevante)
********************************************************************************/
-- Pergunta: Quais categorias têm pior reputação considerando volume relevante?
WITH avaliacoes_por_categoria AS (
SELECT
pr."product_category_name",
COUNT(a."review_id") AS volume_avaliacoes,
ROUND(AVG(a."review_score")::numeric, 2) AS nota_media
FROM "Avaliacoes" a
JOIN "Itens" it ON a."order_id" = it."order_id"
JOIN "Produtos" pr ON it."product_id" = pr."product_id"
GROUP BY pr."product_category_name"
)
SELECT
product_category_name,
volume_avaliacoes,
nota_media
FROM avaliacoes_por_categoria
WHERE volume_avaliacoes >= 50 -- ajuste este limite conforme necessidade
ORDER BY nota_media ASC, volume_avaliacoes DESC
LIMIT 50;

/********************************************************************************
3) CTE: frete médio por estado e comparação com média geral
********************************************************************************/
-- Pergunta: Cada estado tem frete médio acima / abaixo da média geral?
WITH frete_estado AS (
SELECT
c."customer_state",
AVG(it."freight_value")::numeric AS frete_medio_estado
FROM "Pedidos" p
JOIN "Clientes" c ON p."cliente_id" = c."customer_id"
JOIN "Itens" it ON p."pedido_id" = it."order_id"
GROUP BY c."customer_state"
),
frete_geral AS (
SELECT AVG("freight_value")::numeric AS frete_medio_geral FROM "Itens"
)
SELECT
fe."customer_state",
ROUND(fe.frete_medio_estado,2) AS frete_medio_estado,
ROUND(fg.frete_medio_geral,2) AS frete_medio_geral,
CASE
WHEN fe.frete_medio_estado > fg.frete_medio_geral THEN 'acima da média'
WHEN fe.frete_medio_estado < fg.frete_medio_geral THEN 'abaixo da média'
ELSE 'igual à média'
END AS comparacao
FROM frete_estado fe
CROSS JOIN frete_geral fg
ORDER BY fe.frete_medio_estado DESC;
