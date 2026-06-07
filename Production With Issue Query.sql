Declare FromDate timestamp; 
Declare ToDate timestamp; 
Declare loc varchar(50);  
Select MIN(S0."PostDate") INTO FromDate FROM OWOR S0 where S0."PostDate" >= '[%0]'; 
SELECT MAX(S1."PostDate") INTO ToDate FROM OWOR s1 where S1."PostDate" <= '[%1]'; 
SELECT MAX(S3."BPLName") INTO loc FROM OBPL s3 where S3."BPLName"='[%2]';  



Select A."DocNum" ,A."Item Code",A."Product Description" 
,Max(A."PlannedQty") as "PlannedQty"
,A."Child Item"
,Max(A."Child Planned Quantity") as"Child Planned Quantity"
,MaX(A."Child Issued Quantity")as "Child Issued Quantity"
,MAX(A."Issued For Production Item")as "Issued For Production Item"
,MAX(A."Issued For Production Dscription")as "Issued For Production Dscription"
,MAX(A."Issued For Production Quantity")as "Issued For Production Quantity"
,MAX(A."Recipt for Production Item")as "Recipt for Production Item"
,Max(A."Recipt For Production Dscription")as "Recipt For Production Dscription"
,Max(A."Recipt For Production Quantity")as "Recipt For Production Quantity"
,A."BPLName"
,A."Batch Number"

From

(
Select WOR."DocNum" , WOR."ItemCode" as "Item Code",WOR."ProdName" as "Product Description"
,WOR."PlannedQty",WR1."ItemCode" as "Child Item"
,WR1."PlannedQty" as "Child Planned Quantity",WR1."IssuedQty" as "Child Issued Quantity"

,IfNull(IG1."ItemCode",'') as "Issued For Production Item" 
,IfNull(IG1."Dscription",'') as "Issued For Production Dscription"
,IfNull(IG1."Quantity",0) as "Issued For Production Quantity"

,'' as "Recipt for Production Item" ,'' as "Recipt For Production Dscription"
,'0' as "Recipt For Production Quantity"
,BPL."BPLName"
--,BTN."DistNumber" as"BatchNum",ITL."AllocateTp"
--,IG1."DocEntry"

,IFNULL((
Select FIRST_VALUE(T4."DistNumber" ORDER BY T4."DistNumber") From IGE1 T1
Inner join (select IG1."DocEntry", S0."DocLine", S1."SysNumber"
, -sum(S1."Quantity") as "AllocQty" from OITL S0 
inner join ITL1 S1 on S0."LogEntry" = S1."LogEntry" 
Left Outer Join IGE1 IG1 on IG1."DocEntry"=S0."DocEntry"
where S0."DocType" = '60' and S0."DocEntry" = IG1."DocEntry" 
group by IG1."DocEntry", S0."DocLine", S1."SysNumber") 
T3 on T1."DocEntry" = T3."DocEntry" and T1."LineNum" = T3."DocLine"
inner join OBTN T4 on T3."SysNumber" = T4."SysNumber" and T1."ItemCode" = T4."ItemCode"
Where T1."DocEntry"= IG1."DocEntry" and T1."ItemCode" =IG1."ItemCode"),0)as "Batch Number"

From OWOR WOR
Left Outer Join WOR1 WR1 on WOR."DocEntry"=WR1."DocEntry"
Left Outer Join IGE1 IG1 on IG1."BaseEntry" = WR1."DocEntry" and IG1."BaseLine" = WR1."LineNum" 
				and IG1."BaseType" ='202'
Left Outer Join OIGE IGE on IG1."DocEntry"=IGE."DocEntry"
Left Outer Join OBPL BPL On WR1."LocCode"=BPL."BPLId"

			 
Where WOR."PostDate" Between :FromDate AND :ToDate and BPL."BPLName" = :Loc
--WOR."DocEntry" in ('919')--'776','653')
 --and IG1."BaseType" = '202' --and IG1."BaseEntry" = '175'

Union All

Select WOR."DocNum", WOR."ItemCode" as "Item Code",WOR."ProdName" as "Product Description"
,WOR."PlannedQty",WR1."ItemCode" as "Child Item"

,WR1."PlannedQty" as "Child Planned Quantity",WR1."IssuedQty" as "Child Issued Quantity"

,'' as "Issued For Production Item" ,'' as "Issued For Production Dscription"
,'0' as "Issued For Production Quantity"

,IfNull(IN1."ItemCode",'') as "Recipt for Production Item" 
,IfNull(IN1."Dscription",'') as "Recipt For Production Dscription"
, Case when WR1."VisOrder" = '0' then IfNull(IN1."Quantity",'0') Else '0' End
as "Recipt For Production Quantity"
,BPL."BPLName"
,'0' as "Batch Number"
From OWOR WOR
Left Outer Join WOR1 WR1 on WOR."DocEntry"=WR1."DocEntry"
  Inner join IGN1 IN1 On WOR."DocEntry"=IN1."BaseEntry" and In1."BaseType"=202 
  Inner join OIGN IGN On IGN."DocEntry"=IN1."DocEntry"
  Left Outer Join OBPL BPL On WR1."LocCode"=BPL."BPLId"
Where WOR."PostDate" Between :FromDate and :ToDate and BPL."BPLName" = :Loc
--WOR."DocEntry" in ('776','653')

) "A"

Group By A."DocNum",A."Item Code",A."Product Description"
,A."Child Item",A."BPLName",A."Batch Number";
