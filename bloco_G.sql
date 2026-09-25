View: vw_pedidos_completos — consolidando pedido, cliente, agregados de pagamentos e itens
********************************************************************************/
-- Pergunta: Criar uma view que consolide as informações principais por pedido.
CREATE OR REPLACE VIEW "vw_pedidos_completos" AS
SELECT
p."pedido_id",
p."cliente_id",
c."customer_city",
c."customer_state",
p."datahora_pedido",
COALESCE(pg.total_payment::numeric(18,2), 0) AS total_pagamento,
COALESCE(pg.num_payments, 0) AS num_pagamentos,
COALESCE(it.total_items_price::numeric(18,2), 0) AS total_itens,
COALESCE(it.total_freight::numeric(18,2), 0) AS total_frete,
COALESCE(it.qtd_itens, 0) AS qtd_itens,
COALESCE(it.sellers, ARRAY[]::text[]) AS sellers
FROM "Pedidos" p
LEFT JOIN "Clientes" c ON p."cliente_id" = c."customer_id"
LEFT JOIN (
SELECT
"order_id",
SUM("payment_value") AS total_payment,
COUNT() AS num_payments
FROM "Pagamentos"
GROUP BY "order_id"
) pg ON p."pedido_id" = pg."order_id"
LEFT JOIN (
SELECT
"order_id",
SUM("price") AS total_items_price,
SUM("freight_value") AS total_freight,
COUNT() AS qtd_itens,
array_agg(DISTINCT "seller_id") AS sellers
FROM "Itens"
GROUP BY "order_id"
) it ON p."pedido_id" = it."order_id";
/********************************************************************************
2) View: vw_avaliacoes_categoria — nota média e volume de avaliações por categoria
********************************************************************************/
-- Pergunta: Criar view com volume e média de avaliações por categoria.
CREATE OR REPLACE VIEW "vw_avaliacoes_categoria" AS
SELECT
pr."product_category_name",
COUNT(a."review_id") AS volume_avaliacoes,
ROUND(AVG(a."review_score")::numeric, 2) AS nota_media
FROM "Avaliacoes" a
JOIN "Itens" it ON a."order_id" = it."order_id"
JOIN "Produtos" pr ON it."product_id" = pr."product_id"
GROUP BY pr."product_category_name";
