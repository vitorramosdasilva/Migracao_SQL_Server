Use [REBUAUPRD01];


-- Desenvolvido Por Vitor Ramos
-- Data: 31/10/2019 14:21


If Object_Id('tempdb..#Teste')	Is Not Null Drop Table #Teste
If Object_Id('tempdb..#Teste2')	Is Not Null Drop Table #Teste2
If Object_Id('tempdb..#Teste3')	Is Not Null Drop Table #Teste3
If Object_Id('tempdb..#Teste4')	Is Not Null Drop Table #Teste4


SET NOEXEC OFF;

BEGIN TRANSACTION; 
GO

GO
If @@Error != 0 Set NoExec On;

-- Cria a Tabela Modelo -- 

CREATE TABLE #Teste(
	[Empresa_unp] [smallint],
	[Prod_unp] [int],
	[NumPer_unp] [int],
	[CodPes_unp] [int],
	[PorcImovel_unp] [numeric](18, 6),
	[UsrCad_unp] [varchar](8),
	[DataCad_unp] [datetime],
	[CobrarCPMF_unp] [tinyint],
	[ParticipaSecuritizacao_unp] [bit],
	[ParticipaCalcReceita_unp] [bit],
	[DataVigencia_unp] [datetime],
	[NumSec_unp] [int],
	[RateiaBoleto_unp] [bit],
	Identificador_unp varchar(30),
	[EmpresaCalcReceita_unp] [smallint]
)


-- Insiro Clientes NumPer_unp	,Prod_unp	,Empresa_unp, Identificador_unp dos clientes Urplan que não existem UnidadeProprietario

Insert Into #Teste(NumPer_unp	,Prod_unp	,Empresa_unp, Identificador_unp)

Select
 
	Per.NumPer_unid, 
	Per.Prod_unid,
	Per.Empresa_unid,
	Per.Identificador_unid

From UnidadePer Per With(NoLock)

Where 
	Not Exists(Select 1 From UnidadeProprietario UnP With(NoLock)
					Where					
					Per.Empresa_unid	= unp.Empresa_unp
					And 
					Per.NumPer_unid = UnP.NumPer_unp
					And 
					Per.Prod_unid = UnP.Prod_unp				
				)
	And Per.Empresa_unid < 19000


	-- Obtenho todos os dados do Cliente BRL

Select 
	 per.Empresa_unid 
	,per.Prod_unid 
	,per.NumPer_unid
	,per.Identificador_unid
	,Pro.*	
	
Into #Teste2

From UnidadePer Per With(NoLock)
	Inner Join UnidadeProprietario Pro
	On	Per.NumPer_unid = Pro.NumPer_unp
	And Per.Empresa_unid = Pro.Empresa_unp
	And Per.Prod_unid = Pro.Prod_unp
	--Where Per.Empresa_unid > 30000 
	Where Per.Empresa_unid Between 30000 and 39999



Select  Distinct
	 t.Empresa_unp
	,t.Prod_unp
	,t.NumPer_unp
	,t.Identificador_unp
	,t2.CodPes_unp
	,t2.[PorcImovel_unp]
	,t2.[UsrCad_unp]
	,t2.[DataCad_unp]
	,t2.[CobrarCPMF_unp]
	,t2.[ParticipaSecuritizacao_unp]
	,t2.[ParticipaCalcReceita_unp]
	,t2.[DataVigencia_unp]
	,t2.[NumSec_unp]
	,t2.[RateiaBoleto_unp]
	,t2.[EmpresaCalcReceita_unp]
	--,Row_Number() Over(Partition By  t.Empresa_unid Order By t.Empresa_unid, t2.CodPes_unp Desc) As Unic	
	
	Into #Teste3		

From #Teste t

	Left Join #Teste2 t2
	On 
	t.NumPer_unp = t2.NumPer_unid	 
	
	--And 
	--t.Prod_unp = t2.Prod_unid
	--And t.Identificador_unp = t2.Identificador_unid
	--And t.Empresa_unp = t2.Empresa_unid
	--Order By 1


-- Ordeno para o maior Usuario BRL

Select * 
	Into #Teste4
From (
Select t3.*
 ,Row_Number() Over(Partition By   t3.Empresa_unp, t3.Prod_unp, t3.Numper_unp,  t3.Identificador_unp
 Order By t3.CodPes_unp Desc) As Unic	

From #Teste t
Inner Join #Teste3 t3
	On t.Empresa_unp =			t3.Empresa_unp
	And t.Identificador_unp =	t3.Identificador_unp
	And t.NumPer_unp =			t3.NumPer_unp
	And t.Prod_unp =			t3.Prod_unp

	/*
			where		t3.Empresa_unp = 1004
			And			t3.Prod_unp = 1006
			And			t3.NumPer_unp = 33
		
						t3.Empresa_unp = 1
			And			t3.Prod_unp = 1006
			And			t3.NumPer_unp = 6

	*/		

		) As Base
Order By Unic Asc



-- Insiro dados na Tabela Modelo

Update t

Set  t.CobrarCPMF_unp 				= t4.CobrarCPMF_unp 
	,t.CodPes_unp					= t4.CodPes_unp
	,t.DataCad_unp					= t4.DataCad_unp
	,t.DataVigencia_unp				= t4.DataVigencia_unp
	,t.Empresa_unp					= t4.Empresa_unp
	,t.EmpresaCalcReceita_unp		= t4.EmpresaCalcReceita_unp
	,t.Identificador_unp			= t4.Identificador_unp
	,t.NumPer_unp					= t4.NumPer_unp
	,t.NumSec_unp					= t4.NumSec_unp
	,t.ParticipaCalcReceita_unp		= t4.ParticipaCalcReceita_unp
	,t.ParticipaSecuritizacao_unp	= t4.ParticipaSecuritizacao_unp
	,t.PorcImovel_unp				= t4.PorcImovel_unp
	,t.Prod_unp						= t4.Prod_unp
	,t.RateiaBoleto_unp				= t4.RateiaBoleto_unp
	,t.UsrCad_unp					= t4.UsrCad_unp

 From #Teste t

Inner Join #Teste4 t4
	On  t.Empresa_unp =			t4.Empresa_unp
	And t.Identificador_unp =	t4.Identificador_unp
	And t.NumPer_unp =			t4.NumPer_unp
	And t.Prod_unp =			t4.Prod_unp

Where 
Not Exists(Select 1 From UnidadeProprietario UnP
				Where					
					t4.Empresa_unp	= unp.Empresa_unp
				And t4.CodPes_unp	= UnP.CodPes_unp
				And t4.Prod_unp		= UnP.Prod_unp				
			)


/*
INSERT INTO [dbo].[UnidadeProprietario]
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
           ,[EmpresaCalcReceita_unp])
*/


Select 
	 t.[Empresa_unp]
    ,t.[Prod_unp]
    ,t.[NumPer_unp]
    ,t.[CodPes_unp]
    ,t.[PorcImovel_unp]
    ,t.[UsrCad_unp]
    ,t.[DataCad_unp]
    ,t.[CobrarCPMF_unp]
    ,t.[ParticipaSecuritizacao_unp]
    ,t.[ParticipaCalcReceita_unp]
    ,t.[DataVigencia_unp]
    ,t.[NumSec_unp]
    ,t.[RateiaBoleto_unp]
    ,t.[EmpresaCalcReceita_unp]

From #Teste t
Where t.CodPes_unp Is Not Null


					
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


If Object_Id('tempdb..#Teste')	Is Not Null Drop Table #Teste
If Object_Id('tempdb..#Teste2')	Is Not Null Drop Table #Teste2
If Object_Id('tempdb..#Teste3')	Is Not Null Drop Table #Teste3
If Object_Id('tempdb..#Teste4')	Is Not Null Drop Table #Teste4	

/*
-- Testes ---

Select * From #Teste4 t4
where		t4.Empresa_unp		= 1
		And T4.Prod_unp		= 1029
		And T4.NumPer_unp		= 1

Select * From #teste t
where		t.Empresa_unp = 1
And			t.Prod_unp = 1029
And			t.NumPer_unp = 1


select * From #teste t
Where Not Exists(Select 1 From UnidadeProprietario UnP
	Where					
		t.Empresa_unp	= unp.Empresa_unp
	And t.CodPes_unp	= UnP.CodPes_unp
	And t.Prod_unp		= UnP.Prod_unp
				
)

select * FRom UnidadeProprietario pp
where pp.NumPer_unp = 1

*/





		










