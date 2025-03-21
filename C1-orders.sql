/* Original Odoo EXIM (export for import) of orders
-- Orders fields
name                       : S00097	
partner_id                 : 3G Wireless LLC
date_order                 : 2023-01-09 09:54:51	
commitment_date            : 2023-01-09 09:54:51
pricelist_id/name          : USD Reseller
fiscal_position_id/name	   : Régime Extra-Communautaire
payment_term_id/name       : 30 Days 	
-- Line orders fields
order_line/name            : [FURN_6666] Acoustic Bloc Screens
order_line                 : S00097 - [FURN_6666] Acoustic Bloc Screens
order_line/discount        : 92.31	
order_line/price_unit      : 10,400.00
order_line/product_uom_qty : 1.00	
order_line/is_expense	     : FALSE
*/
CREATE OR REPLACE VIEW c1_orders AS 
SELECT
  /* Order fields */
  CONCAT("orders",LPAD(cd.rowid,5,0)) AS "External ID",
  -- CONCAT("sorder",LPAD(c.rowid,5,0)) AS "External ID",
  COALESCE(c.ref, '') AS "name",
  COALESCE(c.total_HT, '') AS "total_HT",
  COALESCE(s.nom, '') AS "partner_id",
  CONCAT("compan",LPAD(s.rowid,4,0)) AS "customer/external id",
  first_line.ref AS "order_line/reference",
  "2" AS "order_line/customer_lead",
  -- Dates
  IF(ISNULL(c.date_commande),"2019-07-01",DATE_FORMAT(date(c.date_commande),'%Y-%m-%d')) AS "date_order",
  IF(ISNULL(c.date_livraison),"2019-07-01",DATE_FORMAT(date(c.date_livraison),'%Y-%m-%d')) AS "commitment_date",
  /* CASE 
    WHEN s.remise_client = 0  THEN IF(country.code IN ("US","CA"),"USD MSRP","EUR MSRP") 
    WHEN s.remise_client = 10 THEN IF(country.code IN ("US","CA"),"USD Major","EUR Major") 
    WHEN s.remise_client > 10 THEN IF(country.code IN ("US","CA"),"USD Reseller","EUR Reseller") 
    ELSE NULL
  END AS "pricelist_id",
   CASE 
    WHEN country.code = "BE" THEN  "Régime National"
    WHEN country.code IN ("AT","BG","HR","CY","CZ","DK","EE","FI","FR","DE","GR","HU","IE","IT","LV","LT","LU","MT","NL","PL","PT","RO","SK","SI","ES","SE","EU") THEN "Régime Intra-Communautaire" 
    ELSE IF(ISNULL(country.code),NULL,"Régime Extra-Communautaire") 
  END AS "fiscal_position_id",*/
  CASE 
    WHEN s.cond_reglement = 19 THEN "45 Days"
    WHEN s.cond_reglement = 13 THEN "Immediate Payment"
    WHEN s.cond_reglement = 2  THEN "30 Days"
    ELSE IF(ISNULL(s.cond_reglement),NULL,"30 Days")
  END AS "payment_term_id", 
  -- Order Lines
  CONCAT("[",p.label,"] ",p.ref) AS "order_line/product",
  CONCAT(first_line.ref," - [",p.label,"] ",p.ref) AS "order_line/description",
  cd.remise_percent AS "order_line/discount",
 -- CONCAT("compan",LPAD(s.rowid,4,0)) AS "customer/external id",
  cd.qty AS "order_line/product_uom_qty",
  cd.multicurrency_subprice AS "order_line/price_unit",
  IF(ISNULL(cd.fk_product),"no product",CONCAT("[",p.label,"] ",p.ref)) AS "order_line/product_id"
FROM 
  -- Build an intermediate "first_line" table with the order id and the id of the first line of the order
  ( SELECT
	    c.rowid AS orderId,
      c.ref   AS ref,
  	  MIN(cd.rowid) AS firstLineId
    FROM
  	  llx_commandedet AS cd 
  	  RIGHT JOIN llx_commande AS c ON c.rowid = cd.fk_commande			
    -- WHERE c.rowid IN (1,3) -- LIGHT RESULT
    WHERE 1 = 1  -- FULL RESULT
    GROUP BY c.rowid
  ) AS first_line
  LEFT JOIN llx_commandedet AS cd ON cd.fk_commande = first_line.orderId
  LEFT JOIN llx_product     AS p ON p.rowid = cd.fk_product
  LEFT JOIN llx_commande    AS c ON first_line.firstLineId = cd.rowid AND c.rowid = first_line.orderId
  LEFT JOIN llx_societe     AS s ON s.rowid = c.fk_soc
  LEFT JOIN llx_c_country   AS country ON country.rowid = s.fk_pays
WHERE 1=1 AND cd.multicurrency_subprice <> 0 ;
SELECT * FROM c1_orders;
