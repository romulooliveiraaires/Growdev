1) Função: fn_metricas_vendedor_simples(data_inicio, data_fim)
   Retorna faturamento, ticket médio e nota média por vendedor no período.
********************************************************************************/
-- Pergunta: Para cada vendedor, qual faturamento, ticket médio e nota média no período?
CREATE OR REPLACE FUNCTION "fn_metricas_vendedor_simples"(p_data_inicio timestamp, p_data_fim timestamp)
RETURNS TABLE(
  seller_id varchar,
  faturamento numeric(18,2),
  ticket_medio numeric(18,2),
  nota_media numeric(3,2)
)
LANGUAGE sql
AS $$
WITH pedidos_periodo AS (
  SELECT "pedido_id" FROM "Pedidos"
  WHERE "datahora_pedido" BETWEEN p_data_inicio AND p_data_fim
),
seller_pedidos AS (
  SELECT DISTINCT "seller_id", "order_id" FROM "Itens"
  WHERE "order_id" IN (SELECT "pedido_id" FROM pedidos_periodo)
),
faturamento_seller AS (
  SELECT sp."seller_id", SUM(pg."payment_value")::numeric AS faturamento
  FROM seller_pedidos sp
  JOIN "Pagamentos" pg ON sp."order_id" = pg."order_id"
  GROUP BY sp."seller_id"
),
ticket_medio_seller AS (
  SELECT sp."seller_id", COUNT(DISTINCT sp."order_id") AS num_pedidos
  FROM seller_pedidos sp
  GROUP BY sp."seller_id"
),
nota_media_seller AS (
  SELECT i."seller_id", AVG(a."review_score")::numeric(3,2) AS nota_media
  FROM "Avaliacoes" a
  JOIN "Itens" i ON a."order_id" = i."order_id"
  WHERE i."order_id" IN (SELECT "pedido_id" FROM pedidos_periodo)
  GROUP BY i."seller_id"
)
SELECT
  s."seller_id",
  COALESCE(ROUND(f.faturamento,2), 0) AS faturamento,
  COALESCE(ROUND(f.faturamento / NULLIF(t.num_pedidos,0), 2), 0) AS ticket_medio,
  n.nota_media
FROM (
  SELECT sp."seller_id" FROM seller_pedidos sp
  UNION
  SELECT f."seller_id" FROM faturamento_seller f
  UNION
  SELECT t."seller_id" FROM ticket_medio_seller t
  UNION
  SELECT n."seller_id" FROM nota_media_seller n
) s
LEFT JOIN faturamento_seller f ON s."seller_id" = f."seller_id"
LEFT JOIN ticket_medio_seller t ON s."seller_id" = t."seller_id"
LEFT JOIN nota_media_seller n ON s."seller_id" = n."seller_id"
ORDER BY COALESCE(f.faturamento, 0) DESC;
$$;


/********************************************************************************
2) Função: sp_relatorio_vendedor(categoria, data_inicio, data_fim)
   Retorna faturamento total e ticket médio da categoria no período (alocação proporcional).
********************************************************************************/
-- Pergunta: Para a categoria X, qual o faturamento total e ticket médio no período?
CREATE OR REPLACE FUNCTION "sp_relatorio_vendedor"(
  p_categoria text,
  p_data_inicio timestamp,
  p_data_fim timestamp
)
RETURNS TABLE(
  product_category_name varchar,
  faturamento_total numeric(18,2),
  ticket_medio numeric(18,2),
  num_pedidos integer
)
LANGUAGE sql
AS $$
WITH pedidos_periodo AS (
  SELECT "pedido_id" FROM "Pedidos"
-- SELECT * FROM "sp_relatorio_vendedor"('beleza','2020-01-01','2020-01-31');
