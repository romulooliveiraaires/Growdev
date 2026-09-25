Ranking (RANK()) dos vendedores por faturamento dentro de cada estado
********************************************************************************/
-- Pergunta: Qual a posição de cada vendedor no faturamento dentro do seu estado?
SELECT
fs."seller_state",
fs."seller_id",
ROUND(fs.faturamento,2) AS faturamento,
RANK() OVER (PARTITION BY fs."seller_state" ORDER BY fs.faturamento DESC) AS ranking_estado
FROM (
SELECT v."seller_id", v."seller_state", SUM(ppp.total_payment)::numeric AS faturamento
FROM "Itens" it
JOIN "Vendedores" v ON it."seller_id" = v."seller_id"
JOIN (
SELECT "order_id", SUM("payment_value")::numeric AS total_payment
FROM "Pagamentos"
GROUP BY "order_id"
) ppp ON it."order_id" = ppp."order_id"
GROUP BY v."seller_id", v."seller_state"
) fs
ORDER BY fs."seller_state", ranking_estado;
/********************************************************************************
2) Faturamento mensal acumulado por vendedor (SUM(...) OVER (ORDER BY ...))
********************************************************************************/
-- Pergunta: Como evolui o faturamento acumulado mês a mês por vendedor?
WITH pagamentos_por_pedido AS (
SELECT "order_id", SUM("payment_value")::numeric AS total_payment
FROM "Pagamentos"
GROUP BY "order_id"
),
soma_itens_por_vendedor_pedido AS (
SELECT "order_id","seller_id", SUM("price")::numeric AS seller_items_total
FROM "Itens"
GROUP BY "order_id","seller_id"
),
soma_itens_por_pedido AS (
SELECT "order_id", SUM("price")::numeric AS order_items_total
FROM "Itens"
GROUP BY "order_id"
),
revenue_prorated AS (
SELECT
s."seller_id",
date_trunc('month', ped."datahora_pedido")::date AS mes_ref,
(CASE WHEN sip.order_items_total = 0 THEN 0
ELSE (s.seller_items_total / sip.order_items_total) * COALESCE(ppp.total_payment,0)
END)::numeric AS faturamento_seller_order
FROM soma_itens_por_vendedor_pedido s
JOIN soma_itens_por_pedido sip ON s."order_id" = sip."order_id"
LEFT JOIN pagamentos_por_pedido ppp ON s."order_id" = ppp."order_id"
JOIN "Pedidos" ped ON ped."pedido_id" = s."order_id"
),
faturamento_mensal AS (
SELECT "seller_id", mes_ref, SUM(faturamento_seller_order)::numeric AS faturamento
FROM revenue_prorated
GROUP BY "seller_id", mes_ref
)
SELECT
seller_id,
mes_ref,
ROUND(faturamento,2) AS faturamento,
ROUND(SUM(faturamento) OVER (PARTITION BY seller_id ORDER BY mes_ref),2) AS faturamento_acumulado
FROM faturamento_mensal
ORDER BY seller_id, mes_ref;

/********************************************************************************
3) Percentual de participação de cada vendedor no faturamento total do seu estado
********************************************************************************/
-- Pergunta: Qual a participação percentual do vendedor no faturamento do seu estado?
WITH pagamentos_por_pedido AS (
SELECT "order_id", SUM("payment_value")::numeric AS total_payment
FROM "Pagamentos"
GROUP BY "order_id"
),
soma_itens_por_vendedor_pedido AS (
SELECT "order_id","seller_id", SUM("price")::numeric AS seller_items_total
FROM "Itens"
GROUP BY "order_id","seller_id"
),
soma_itens_por_pedido AS (
SELECT "order_id", SUM("price")::numeric AS order_items_total
FROM "Itens"
GROUP BY "order_id"
),
revenue_prorated AS (
SELECT
s."seller_id",
v."seller_state",
(CASE WHEN sip.order_items_total = 0 THEN 0
ELSE (s.seller_items_total / sip.order_items_total) * COALESCE(ppp.total_payment,0)
END)::numeric AS revenue_allocated
FROM soma_itens_por_vendedor_pedido s
JOIN soma_itens_por_pedido sip ON s."order_id" = sip."order_id"
LEFT JOIN pagamentos_por_pedido ppp ON s."order_id" = ppp."order_id"
LEFT JOIN "Vendedores" v ON s."seller_id" = v."seller_id"
),
faturamento_seller_state AS (
SELECT seller_id, seller_state, SUM(revenue_allocated)::numeric AS faturamento
FROM revenue_prorated
GROUP BY seller_id, seller_state
)
SELECT
seller_state,
seller_id,
ROUND(faturamento,2) AS faturamento,
ROUND(100::numeric * faturamento / NULLIF(SUM(faturamento) OVER (PARTITION BY seller_state),0),2) AS participacao_percentual
FROM faturamento_seller_state
ORDER BY seller_state, participacao_percentual DESC;

/********************************************************************************
4) Variação de faturamento de um mês para o outro por vendedor (LAG)
********************************************************************************/
-- Pergunta: Quanto variou o faturamento de um mês para o outro por vendedor?
WITH pagamentos_por_pedido AS (
SELECT "order_id", SUM("payment_value")::numeric AS total_payment
FROM "Pagamentos"
GROUP BY "order_id"
),
soma_itens_por_vendedor_pedido AS (
SELECT "order_id","seller_id", SUM("price")::numeric AS seller_items_total
FROM "Itens"
GROUP BY "order_id","seller_id"
),
soma_itens_por_pedido AS (
SELECT "order_id", SUM("price")::numeric AS order_items_total
FROM "Itens"
GROUP BY "order_id"
),
revenue_prorated AS (
SELECT
s."seller_id",
date_trunc('month', ped."datahora_pedido")::date AS mes_ref,
(CASE WHEN sip.order_items_total = 0 THEN 0
ELSE (s.seller_items_total / sip.order_items_total) * COALESCE(ppp.total_payment,0)
END)::numeric AS faturamento_seller_order
FROM soma_itens_por_vendedor_pedido s
JOIN soma_itens_por_pedido sip ON s."order_id" = sip."order_id"
LEFT JOIN pagamentos_por_pedido ppp ON s."order_id" = ppp."order_id"
JOIN "Pedidos" ped ON ped."pedido_id" = s."order_id"
),
faturamento_mensal AS (
SELECT "seller_id", mes_ref, SUM(faturamento_seller_order)::numeric AS faturamento
FROM revenue_prorated
GROUP BY "seller_id", mes_ref
)
SELECT
seller_id,
mes_ref,
ROUND(faturamento,2) AS faturamento,
ROUND(
100::numeric * (faturamento - LAG(faturamento) OVER (PARTITION BY seller_id ORDER BY mes_ref))
/ NULLIF(LAG(faturamento) OVER (PARTITION BY seller_id ORDER BY mes_ref),0)
,2) AS variacao_percentual
FROM faturamento_mensal
ORDER BY seller_id, mes_ref;
