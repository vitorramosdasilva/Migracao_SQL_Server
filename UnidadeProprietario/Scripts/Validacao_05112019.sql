use [REBUAUTST01];
select 
--'INSERT INTO [dbo].[UnidadeProprietario] ([Empresa_unp],[Prod_unp],[NumPer_unp],[CodPes_unp],[PorcImovel_unp],[UsrCad_unp],[DataCad_unp],[CobrarCPMF_unp],[ParticipaSecuritizacao_unp],[ParticipaCalcReceita_unp],[DataVigencia_unp],[NumSec_unp],[RateiaBoleto_unp],[EmpresaCalcReceita_unp]) 
--    VALUES (30026,10146,',UP.NumPer_unid,',24643,100,''MSOLIVEI'',''2019-11-01'',0,1,0,''2016-01-01'',null,0,null)' 

 

--'INSERT INTO [dbo].[UnidadeDepositario] ([Empresa_und],[Prod_und],[NumPer_und],[CodPesUnp_Und],[CodPes_und],[PorcDeposito_Und],[UsrCad_und],[DataCad_und],[TipoRepasse_und],[PagarImpostoRetidoAdmAluguel_und])
  --   VALUES (30005,10041,' ,NumPer_unid, ',9,39622,100,''MSOLIVEI'',''2019-11-01'',0,0)'

 
UP.Empresa_unid ,
UP.Obra_unid ,UP.Prod_unid ,UP.NumPer_unid ,UP.Identificador_unid ,UPr.CodPes_unp ,UPr.PorcImovel_unp ,

P.nome_pes as 'Proprietario' 
--UD.CodPes_und ,
--UD.PorcDeposito_Und ,
--D.nome_pes
  from UnidadePer UP
       left join UnidadeProprietario UPr on UPr.Empresa_unp=UP.Empresa_unid and UPr.Prod_unp=UP.Prod_unid and UPr.NumPer_unp=UP.NumPer_unid
       --left join UnidadeDepositario UD on UD.Empresa_und=UPr.Empresa_unp and UD.Prod_und=UPr.Prod_unp and UD.NumPer_und=UPr.NumPer_unp and UD.CodPesUnp_Und=UPr.CodPes_unp
       left join Pessoas P on P.cod_pes=UPr.CodPes_unp
       --left join Pessoas D on D.cod_pes=UD.CodPes_und


 where 
 --UP.Empresa_unid > 30000  --and UPr.CodPes_unp=9
	--up.Prod_unid = 10041
 up.Empresa_unid = 30005
And up.Identificador_unid =  'Q03-L21'
--And up.NumPer_unid = 182

/*
Where 
 --UP.Empresa_unid > 30000  --and UPr.CodPes_unp=9
	up.Prod_unid = 10041
And up.Empresa_unid = 30005
And up.Identificador_unid =  'Q03-L21'
And up.NumPer_unid = 23
 Order by UP.Empresa_unid ,UP.Prod_unid ,UP.Identificador_unid
*/
 


select 
--'INSERT INTO [dbo].[UnidadeProprietario] ([Empresa_unp],[Prod_unp],[NumPer_unp],[CodPes_unp],[PorcImovel_unp],[UsrCad_unp],[DataCad_unp],[CobrarCPMF_unp],[ParticipaSecuritizacao_unp],[ParticipaCalcReceita_unp],[DataVigencia_unp],[NumSec_unp],[RateiaBoleto_unp],[EmpresaCalcReceita_unp]) 
--    VALUES (30026,10146,',UP.NumPer_unid,',24643,100,''MSOLIVEI'',''2019-11-01'',0,1,0,''2016-01-01'',null,0,null)' 

 

--'INSERT INTO [dbo].[UnidadeDepositario] ([Empresa_und],[Prod_und],[NumPer_und],[CodPesUnp_Und],[CodPes_und],[PorcDeposito_Und],[UsrCad_und],[DataCad_und],[TipoRepasse_und],[PagarImpostoRetidoAdmAluguel_und])
  --   VALUES (30005,10041,' ,NumPer_unid, ',9,39622,100,''MSOLIVEI'',''2019-11-01'',0,0)'

 

UP.Empresa_unid ,UP.Obra_unid ,UP.Prod_unid ,UP.NumPer_unid ,UP.Identificador_unid ,UPr.CodPes_unp ,UPr.PorcImovel_unp ,P.nome_pes as 'Proprietario' ,UD.CodPes_und ,UD.PorcDeposito_Und ,D.nome_pes
  from UnidadePer UP
       left join UnidadeProprietario UPr on UPr.Empresa_unp=UP.Empresa_unid and UPr.Prod_unp=UP.Prod_unid and UPr.NumPer_unp=UP.NumPer_unid
       left join UnidadeDepositario UD on UD.Empresa_und=UPr.Empresa_unp and UD.Prod_und=UPr.Prod_unp and UD.NumPer_und=UPr.NumPer_unp and UD.CodPesUnp_Und=UPr.CodPes_unp
       left join Pessoas P on P.cod_pes=UPr.CodPes_unp
       left join Pessoas D on D.cod_pes=UD.CodPes_und
 where UP.Empresa_unid in (5) --and UPr.CodPes_unp=9
 and up.Prod_unid = 10041 and UP.Identificador_unid = 'Q03-L21'
 --order by UP.Empresa_unid ,UP.Prod_unid ,UP.Identificador_unid



 /*
 30005	10041	23	19588	39.500000	PSTALENT	2019-11-05	0	1	0	2016-01-07 00:00:00.743	NULL	0	NULL	Q03-L21
30005	10041	23	39622	57.500000	PSTALENT	2019-11-05	0	1	0	2016-01-07 00:00:00.743	NULL	0	NULL	Q03-L21
30005	10041	23	40488	3.000000	PSTALENT	2019-11-05	0	1	0	2016-01-07 00:00:00.743	NULL	0	NULL	Q03-L21

*/

 