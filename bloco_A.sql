Listar os 20 pedidos com status delivered mais recentes, ordenados pela data de entrega.
********************************************************************************/
-- Pergunta: Quais os 20 pedidos entregues mais recentes?
SELECT
"Pedidos"."pedido_id",
"Pedidos"."status_pedido",
"Pedidos"."datahora_entrega"
FROM "Pedidos"
WHERE "Pedidos"."status_pedido" ILIKE 'delivered'
ORDER BY "Pedidos"."datahora_entrega" DESC
LIMIT 20;
/********************************************************************************
2) Listar todos os produtos de uma categoria específica (usar Tradução para filtrar pelo nome em português).
********************************************************************************/
-- Pergunta: Quais produtos pertencem à categoria "X" (filtrada pelo nome em português)?
-- Substitua 'beleza' pelo nome em português desejado.
SELECT
pr."product_id",
pr."product_name_lenght",
pr."product_category_name"
FROM "Produtos" pr
JOIN "Traducao" tr ON pr."product_category_name" = tr."product_category_name"
WHERE tr."product_category_name" ILIKE 'beleza';

/********************************************************************************
3) Listar os métodos de pagamento distintos utilizados na base.
********************************************************************************/
-- Pergunta: Quais tipos de pagamento existem na base?
SELECT DISTINCT "Pagamentos"."payment_type"
FROM "Pagamentos"
ORDER BY "payment_type";

/********************************************************************************
4) Listar os produtos com peso acima de 10kg, ordenados do mais pesado para o mais leve.
********************************************************************************/
-- Pergunta: Quais produtos pesam mais que 10.000 g (10kg)?
SELECT
"product_id",
"product_weight_g"
FROM "Produtos"
WHERE "product_weight_g" > 10000
ORDER BY "product_weight_g" DESC;
