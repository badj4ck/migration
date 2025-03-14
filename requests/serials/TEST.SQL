SELECT DISTINCT
CASE WHEN (ps.fk_entrepot IS NULL OR pb.qty < 1) THEN 'OUT' ELSE  'IN' END AS Location,
CASE WHEN (ps.fk_entrepot IS NULL OR pb.qty < 1) THEN 'NONE' ELSE  en.ref END AS Entrepot,
ps.batch AS Batch,
s.nom AS Company, cc.code AS Country, cp.code AS PaymentMode, e.date_creation AS Date_c
FROM
llx_product_lot AS pl
LEFT JOIN llx_expeditiondet_batch AS edb ON edb.batch = pl.batch
LEFT JOIN llx_product_batch AS  pb ON pb.batch = pl.batch
LEFT JOIN llx_expeditiondet AS ed ON ed.rowid = edb.fk_expeditiondet
LEFT JOIN llx_expedition AS e ON e.rowid = ed.fk_expedition
LEFT JOIN llx_societe AS s ON s.rowid = e.fk_soc
LEFT JOIN llx_c_country AS cc ON cc.rowid = s.fk_pays
LEFT JOIN llx_element_element AS ee ON ee.fk_target = e.rowid AND ee.targettype = 'shipping' AND ee.sourcetype = 'commande'
LEFT JOIN llx_commande AS c ON c.rowid = ee.fk_source
LEFT JOIN llx_c_paiement AS cp ON cp.id = c.fk_mode_reglement -- cp.code
LEFT JOIN llx_product_stock AS  ps ON ps.rowid = pb.fk_product_stock
LEFT JOIN llx_entrepot AS en ON en.rowid = ps.fk_entrepot
WHERE pl.batch LIKE 'CY-RCP-18-4%'
ORDER BY pl.batch, e.date_creation