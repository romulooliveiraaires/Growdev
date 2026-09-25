--Listar os 20 pedidos com status delivered mais recentes, ordenados pela data de entrega.
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
