Classificar pedidos por prazo de entrega
********************************************************************************/
-- Pergunta: Cada pedido foi adiantado, no prazo ou atrasado?
SELECT
"pedido_id",
"datahora_entrega",
"estimativa_entrega_pedido",
CASE
WHEN "datahora_entrega" IS NULL OR "estimativa_entrega_pedido" IS NULL THEN 'indeterminado'
WHEN "datahora_entrega" < "estimativa_entrega_pedido" THEN 'adiantado'
WHEN "datahora_entrega" = "estimativa_entrega_pedido" THEN 'no prazo'
WHEN "datahora_entrega" > "estimativa_entrega_pedido" THEN 'atrasado'
END AS classificacao_entrega
FROM "Pedidos";
/********************************************************************************
2) Classificar clientes por faixa de gasto total: bronze/prata/ouro
********************************************************************************/
-- Pergunta: Em qual faixa de gasto cada cliente se encaixa?
SELECT
c."customer_id",
CAST(SUM(pg."payment_value") AS numeric(18,2)) AS gasto_total,
CASE
WHEN SUM(pg."payment_value") < 1000 THEN 'bronze'
WHEN SUM(pg."payment_value") BETWEEN 1000 AND 3000 THEN 'prata'
WHEN SUM(pg."payment_value") > 3000 THEN 'ouro'
ELSE 'indeterminado'
END AS faixa
FROM "Pedidos" p
JOIN "Clientes" c ON p."cliente_id" = c."customer_id"
JOIN "Pagamentos" pg ON p."pedido_id" = pg."order_id"
GROUP BY c."customer_id"
ORDER BY gasto_total DESC;

/********************************************************************************
3) Classificar produtos por faixa de peso
********************************************************************************/
-- Pergunta: Produtos são leves, médios ou pesados?
SELECT
"product_id",
"product_weight_g",
CASE
WHEN "product_weight_g" < 500 THEN 'leve'
WHEN "product_weight_g" BETWEEN 500 AND 2000 THEN 'médio'
WHEN "product_weight_g" > 2000 THEN 'pesado'
ELSE 'indeterminado'
END AS faixa_peso
FROM "Produtos"
ORDER BY "product_weight_g" DESC;

/********************************************************************************
4) Classificar pagamentos como à vista / parcelado e sinalizar parcelado longo
********************************************************************************/
-- Pergunta: Pagamentos são à vista, parcelado curto ou parcelado longo (>6 parcelas)?
SELECT
"order_id",
"payment_installments",
CASE
WHEN "payment_installments" = 1 THEN 'à vista'
WHEN "payment_installments" > 6 THEN 'parcelado longo'
WHEN "payment_installments" BETWEEN 2 AND 6 THEN 'parcelado curto'
ELSE 'indeterminado'
END AS tipo_pagamento
FROM "Pagamentos"
ORDER BY "payment_installments" DESC;
