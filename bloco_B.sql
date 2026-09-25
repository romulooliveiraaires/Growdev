Relatório com categoria do produto (traduzida), valor do item, cidade do vendedor.
********************************************************************************/
-- Pergunta: Para cada item, qual a categoria traduzida, valor e cidade do vendedor?
SELECT
it."order_id",
pr."product_id",
pr."product_category_name",
tr."product_category_name_english",
it."price",
v."seller_city"
FROM "Itens" it
JOIN "Produtos" pr ON it."product_id" = pr."product_id"
LEFT JOIN "Traducao" tr ON pr."product_category_name" = tr."product_category_name"
JOIN "Vendedores" v ON it."seller_id" = v."seller_id";
/********************************************************************************
2) Identificar pedidos com atraso na entrega (comparar estimativa x data real).
********************************************************************************/
-- Pergunta: Quais pedidos foram entregues após a data estimada?
SELECT
p."pedido_id",
p."estimativa_entrega_pedido",
p."datahora_entrega"
FROM "Pedidos" p
WHERE p."datahora_entrega" IS NOT NULL
AND p."estimativa_entrega_pedido" IS NOT NULL
AND p."datahora_entrega" > p."estimativa_entrega_pedido";

/********************************************************************************
3) Listar pedidos e suas formas de pagamento, incluindo pedidos pagos em mais de uma parcela.
********************************************************************************/
-- Pergunta: Quais pedidos e os detalhes de parcelamento/forma de pagamento?
SELECT
pg."order_id",
pg."payment_type",
pg."payment_installments",
COUNT(*) OVER (PARTITION BY pg."order_id") AS pagamentos_por_pedido
FROM "Pagamentos" pg
ORDER BY pg."order_id";

/********************************************************************************
4) Listar produtos com categoria traduzida, incluindo produtos sem tradução (LEFT JOIN).
********************************************************************************/
-- Pergunta: Listar produtos e suas traduções de categoria quando existirem.
SELECT
pr."product_id",
pr."product_category_name",
tr."product_category_name_english"
FROM "Produtos" pr
LEFT JOIN "Traducao" tr ON pr."product_category_name" = tr."product_category_name";

/********************************************************************************
5) Identificar pedidos onde cliente e vendedor são do mesmo estado.
********************************************************************************/
-- Pergunta: Em quais pedidos cliente e vendedor pertencem ao mesmo estado?
SELECT DISTINCT
p."pedido_id",
c."customer_state" AS estado_cliente,
v."seller_state" AS estado_vendedor
FROM "Pedidos" p
JOIN "Clientes" c ON p."cliente_id" = c."customer_id"
JOIN "Itens" it ON it."order_id" = p."pedido_id"
JOIN "Vendedores" v ON it."seller_id" = v."seller_id"
WHERE c."customer_state" = v."seller_state";
