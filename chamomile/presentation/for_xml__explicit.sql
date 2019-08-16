use [DM_EXPORT_DATA];

go

select 1      [Tag]
       , null [Parent]
       , null [Document!1]
       , null [ECORESPRODUCTCATEGORYASSIGNMENTENTITY!2!PRODUCTNUMBER!cdata]
       , null [ECORESPRODUCTCATEGORYASSIGNMENTENTITY!2!PRODUCTCATEGORYNAME!cdata]
       , null [ECORESPRODUCTCATEGORYASSIGNMENTENTITY!2!PRODUCTCATEGORYHIERARCHYNAME!cdata]
union all
select 2
       , 1
       , [x].[product_number]
       , [x].[product_number]
       , [x].[product_category_name]
       , [x].[product_category_heirarchy_name]
from   [m2k__export].[kate__test_01] as [x]
for    XML EXPLICIT;
