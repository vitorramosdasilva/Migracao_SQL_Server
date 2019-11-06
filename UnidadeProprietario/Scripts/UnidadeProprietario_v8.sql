Use [REBUAUTST01];

-- Desenvolvido Por Vitor Ramos
-- Data: 04/11/2019 14:21

If Object_Id('tempdb..#Tb_Brl')		Is Not Null Drop Table #Tb_Brl
If Object_Id('tempdb..#Tb_Urplan')	Is Not Null Drop Table #Tb_Urplan
If Object_Id('tempdb..#Tb_Tudo')	Is Not Null Drop Table #Tb_Tudo
If Object_Id('tempdb..#Tb_Nulos')	Is Not Null Drop Table #Tb_Nulos


SET NOEXEC OFF;
BEGIN TRANSACTION; 
GO

GO
If @@Error != 0 Set NoExec On;


Declare @UserPro  Varchar(20) = 'PSTALENT';

---- Join Urplan Empresa_unid < 19999

Select 

	 per.Empresa_unid 
	,per.Prod_unid 
	,per.NumPer_unid
	,per.Identificador_unid
	, Up.CodPes_unp
	, Up.PorcImovel_unp
	, Up.UsrCad_unp
	, Up.DataCad_unp
	, Up.CobrarCPMF_unp
	, Up.ParticipaSecuritizacao_unp
	, Up.ParticipaCalcReceita_unp
	, Up.DataVigencia_unp
	, Up.NumSec_unp
	, Up.RateiaBoleto_unp
	, Up.EmpresaCalcReceita_unp	
	,per.Obra_unid	

Into #Tb_Urplan
								 
From dbo.UnidadePer per With(NoLock)
Left Join UnidadeProprietario Up With(NoLock)

On per.Empresa_unid = Up.Empresa_unp
	And Per.Prod_unid = Up.Prod_unp
	And Per.NumPer_unid = Up.NumPer_unp

Where per.Empresa_unid < 19999
And per.Prod_unid > 9999


Order By 1

Print('Carregada Tabela #Tb_Urplan ....')


---- Join Brl Empresa_unid > 30000

Select 

	 per.Empresa_unid 
	,per.Prod_unid 
	,per.NumPer_unid
	,per.Identificador_unid
	, Up.CodPes_unp
	, Up.[PorcImovel_unp]
	, Up.[UsrCad_unp]
	, Up.[DataCad_unp]
	, Up.[CobrarCPMF_unp]
	, Up.[ParticipaSecuritizacao_unp]
	, Up.[ParticipaCalcReceita_unp]
	, Up.[DataVigencia_unp]
	, Up.[NumSec_unp]
	, Up.[RateiaBoleto_unp]
	, Up.[EmpresaCalcReceita_unp]
	,per.Obra_unid
	
Into #Tb_Brl
								 
From dbo.UnidadePer Per With(NoLock)
Left Join UnidadeProprietario Up With(NoLock)
On  Per.Empresa_unid = Up.Empresa_unp 
And Per.Prod_unid	 = Up.Prod_unp
And Per.NumPer_unid  = Up.NumPer_unp
Where 
	Per.Empresa_unid > 30000
And Per.Prod_unid	 > 9999

Order By 1

Print('Carregada Tabela #Tb_Brl ....')


--- Todos os casos para Inserção ....

Insert Into [dbo].[UnidadeProprietario]
([Empresa_unp]
,[Prod_unp]
,[NumPer_unp]
,[CodPes_unp]
,[PorcImovel_unp]
,[UsrCad_unp]
,[DataCad_unp]
,[CobrarCPMF_unp]
,[ParticipaSecuritizacao_unp]
,[ParticipaCalcReceita_unp]
,[DataVigencia_unp]
,[NumSec_unp]
,[RateiaBoleto_unp]
,[EmpresaCalcReceita_unp]
)

Select distinct

	 br.Empresa_unid 
	,br.Prod_unid 
	,br.NumPer_unid
	,pl.CodPes_unp	As 'pl_Codes_unp'
  	,pl.PorcImovel_unp			As PorcImovel_unp
	,@UserPro					As UsrCad_unp
	,Cast(GetDate() As Date)	As DataCad_unp
	,0 As CobrarCPMF_unp
	,1 As ParticipaSecuritizacao_unp
	,0 As ParticipaCalcReceita_unp
	,'2016-01-07 00:00:00.743'  As DataVigencia_unp
	,NULL						As [NumSec_unp]
	,0							As [RateiaBoleto_unp]
	,NULL						As EmpresaCalcReceita_unp
		
	--,br.Obra_unid				As 'Obra'
	--,br.Identificador_unid
  --,Row_Number() Over(PartitiOn By  pl.CodPes_unp Order By br.Identificador_unid, br.Prod_unid  Desc) As Unic 
  	
--Into #Tb_Tudo

From #Tb_Brl br
Left Join #Tb_Urplan pl

	On	br.Identificador_unid = pl.Identificador_unid
	And br.Prod_unid		  = pl.Prod_unid

Left join Pessoas ps
	On  br.CodPes_unp = ps.cod_pes

Where ps.cod_pes Is Null
	And pl.CodPes_unp Is Not Null
	--Where br.Prod_unid = 10041 And br.Identificador_unid = 'Q03-l21'
And
Not Exists(Select 1 From UnidadeProprietario UnP
				Where					
					br.Empresa_unid		= unp.Empresa_unp				
				And br.Prod_unid		= UnP.Prod_unp				
				And br.NumPer_unid  =  UnP.NumPer_unp
				And pl.CodPes_unp = UnP.CodPes_unp
)




Print('Insert Tabela UnidadePropriedade ....')


	
Declare @finished BIT;
Set @Finished = 1;
	
Set Noexec Off;
	
If @Finished = 1
	Begin
		Print 'Commit Transaction'
		Commit Transaction
		
	End
Else
	Begin
		Print 'Errors Occured. Rollback Transaction'
		Rollback Transaction
	End

GO

If Object_Id('tempdb..#Tb_Brl')		Is Not Null Drop Table #Tb_Brl
If Object_Id('tempdb..#Tb_Urplan')	Is Not Null Drop Table #Tb_Urplan
If Object_Id('tempdb..#Tb_Tudo')	Is Not Null Drop Table #Tb_Tudo
If Object_Id('tempdb..#Tb_Nulos')	Is Not Null Drop Table #Tb_Nulos
If Object_Id('tempdb..#Tb_Erros')	Is Not Null Drop Table #Tb_Erros




-- Valida Quantidade de Quadrilotes Divergentes entre Urplan e BRL Feitos Pelo Usuario Declarado na Variavel e Data de Hoje

SET NOEXEC OFF;
BEGIN TRANSACTION; 
GO

GO
If @@Error != 0 Set NoExec On;


Print('Valida Import ...')


Use [REBUAUTST01];
Declare @UserPro  Varchar(20) = 'PSTALENT';

Select 
  Per.Empresa_unid
 ,Per.Prod_unid
 ,Per.Identificador_unid
 ,Count(Concat(Per.Prod_unid, Per.Identificador_unid)) As Qtd

Into #Tb_Brl
From UnidadePer Per

       Left Join UnidadeProprietario Up 
	   On  Up.Empresa_unp	=	Per.Empresa_unid 
	   And Up.Prod_unp		=	Per.Prod_unid 
	   And Up.NumPer_unp	=	Per.NumPer_unid      

       Left Join Pessoas P 
	   On P.cod_pes	=	Up.CodPes_unp      

 Where  Per.Empresa_unid > 30000
 And	Per.Prod_unid	 > 9999
 And UsrCad_unp = @UserPro

Group By
  Per.Empresa_unid, Per.Prod_unid, Per.Identificador_unid
Order by
 Per.Prod_unid
,Per.Identificador_unid


Print('Carrega #Tb_Brl Validação ...')

Select 
   Per.Empresa_unid
  ,Per.Prod_unid
  ,Per.Identificador_unid
  ,Count(Concat(Per.Prod_unid,Per.Identificador_unid)) As Qtd

Into #Tb_UrPlan
From UnidadePer Per

       Left Join UnidadeProprietario Up	
	     
			On  Up.Empresa_unp = Per.Empresa_unid 
			And Up.Prod_unp    = Per.Prod_unid 
			And Up.NumPer_unp  = Per.NumPer_unid    

       Left Join Pessoas P 
			
			On P.cod_pes	=	Up.CodPes_unp 

 Where Per.Empresa_unid < 19000 
 And Per.Prod_unid		> 9999

 Group By 
  Per.Empresa_unid, Per.Prod_unid, Per.Identificador_unid
 Order by   
 Per.Prod_unid,Per.Identificador_unid

 Print('Carrega #Tb_UrPlan Validação ...')
 
Select * 
	Into #Tb_Erros
From ( 
 Select 
	--P.
	--,
	B.* 
	,Case 
		When P.Qtd < B.Qtd Then 'ERRADO'
	Else						'OK' 
	End As Valida 
 From #Tb_UrPlan P
 Left Join #Tb_Brl B
	On p.Prod_unid = b.prod_unid
	And p.Identificador_unid  =  b.Identificador_unid 
 Where B.Prod_unid Is Not Null
		) 
		As Base 
Where Base.Valida = 'ERRADO'

 Print('Carrega #Tb_Erros Validação ...')


-- Deleta os Casos com a quantidade incorreta de Quadrilote em comparacacao aos da Urplan

Delete up
From UnidadeProprietario Up
Inner Join UnidadePer Per
	On Up.Empresa_unp = Per.Empresa_unid
	And Up.NumPer_unp = Per.NumPer_unid
	And Up.Prod_unp = Per.Prod_unid
	And Up.UsrCad_unp = @UserPro
	And UP.DataCad_unp = Cast(GetDate() As Date)

Inner Join #Tb_Erros E
	On E.Identificador_unid = Per.Identificador_unid
	And E.Empresa_unid  = Up.Empresa_unp
	And E.Prod_unid		= Up.Prod_unp


	
Declare @finished BIT;
Set @Finished = 1;
	
Set Noexec Off;
	
If @Finished = 1
	Begin
		Print 'Commit Transaction'
		Commit Transaction
		
	End
Else
	Begin
		Print 'Errors Occured. Rollback Transaction'
		Rollback Transaction
	End


If Object_Id('tempdb..#Tb_Brl')		Is Not Null Drop Table #Tb_Brl
If Object_Id('tempdb..#Tb_Urplan')	Is Not Null Drop Table #Tb_Urplan
If Object_Id('tempdb..#Tb_Tudo')	Is Not Null Drop Table #Tb_Tudo
If Object_Id('tempdb..#Tb_Nulos')	Is Not Null Drop Table #Tb_Nulos
If Object_Id('tempdb..#Tb_Erros')	Is Not Null Drop Table #Tb_Erros


	/*select * From #tb_erros e
	Where e.prod_unid  = 10102
	and e.Identificador_unid = 'Q14-L26'
	and e.Empresa_unid = 30014*/

	

--------- Validar Tudo  -----------
/*
Use [REBUAUTST01];
	SELECT *  From UnidadeProprietario 
	Where 
	--DataCad_unp = '2019-11-04'
	--And 
	UsrCad_unp = 'PSTALENT'

*/

