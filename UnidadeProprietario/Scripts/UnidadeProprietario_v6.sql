Use [REBUAUPRD01];

-- Desenvolvido Por Vitor Ramos
-- Data: 04/11/2019 14:21

If Object_Id('tempdb..#Tb_Brl')	Is Not Null Drop Table #Tb_Brl
If Object_Id('tempdb..#Tb_Urplan')	Is Not Null Drop Table #Tb_Urplan

SET NOEXEC OFF;

BEGIN TRANSACTION; 
GO

GO
If @@Error != 0 Set NoExec On;


---- Join Urplan Empresa_unid < 19999


Select  
	 per.Empresa_unid 
	,per.Prod_unid 
	,per.NumPer_unid
	,per.Identificador_unid
	,Up.CodPes_unp
	,Up.[PorcImovel_unp]
	,Up.[UsrCad_unp]
	,Up.[DataCad_unp]
	,Up.[CobrarCPMF_unp]
	,Up.[ParticipaSecuritizacao_unp]
	,Up.[ParticipaCalcReceita_unp]
	,Up.[DataVigencia_unp]
	,Up.[NumSec_unp]
	,Up.[RateiaBoleto_unp]
	,Up.[EmpresaCalcReceita_unp]
	
Into #Tb_Urplan
								 
From dbo.UnidadePer per
Left Join UnidadeProprietario Up
On per.Empresa_unid = Up.Empresa_unp
	And Per.Prod_unid = Up.Prod_unp
	And Per.NumPer_unid = Up.NumPer_unp
Where per.Empresa_unid < 19999


Order By 1


---- Join Brl Empresa_unid > 30000

Select  
	 per.Empresa_unid 
	,per.Prod_unid 
	,per.NumPer_unid
	,per.Identificador_unid
	,Up.CodPes_unp
	,Up.[PorcImovel_unp]
	,Up.[UsrCad_unp]
	,Up.[DataCad_unp]
	,Up.[CobrarCPMF_unp]
	,Up.[ParticipaSecuritizacao_unp]
	,Up.[ParticipaCalcReceita_unp]
	,Up.[DataVigencia_unp]
	,Up.[NumSec_unp]
	,Up.[RateiaBoleto_unp]
	,Up.[EmpresaCalcReceita_unp]
	
Into #Tb_Brl
								 
From dbo.UnidadePer per
Left Join UnidadeProprietario Up
On per.Empresa_unid = Up.Empresa_unp
	And Per.Prod_unid = Up.Prod_unp
	And Per.NumPer_unid = Up.NumPer_unp
Where per.Empresa_unid > 30000

Order By 1



-- Inserção de Clientes Que Não Existem Em UnidadeProprietario pela Junção das Tabelas #Tb_Brl e #Tb_Urplan por br.Identificador_unid e br.Prod_unid

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



Select Distinct

	 br.Empresa_unid 
	,br.Prod_unid 
	,br.NumPer_unid--br.--
	,IsNull(br.CodPes_unp,pl.CodPes_unp) As Codes_unp
	,IsNull(br.PorcImovel_unp,pl.PorcImovel_unp) As PorcImovel_unp
	,'PSTALENT' As UsrCad_unp
	,Cast(GetDate() As Date) As DataCad_unp
	,0 As CobrarCPMF_unp
	,1 As ParticipaSecuritizacao_unp
	,0 As ParticipaCalcReceita_unp
	,'2016-01-07 00:00:00.743' As DataVigencia_unp
	,NULL As [NumSec_unp]
	,0 As [RateiaBoleto_unp]
	,NULL As [EmpresaCalcReceita_unp]
		
	--Into #Tb_Tudo
From #Tb_Brl br
Left Join #Tb_Urplan pl
	On	br.Identificador_unid = pl.Identificador_unid
	And br.Prod_unid		  = pl.Prod_unid
Where 
IsNull(br.CodPes_unp,pl.CodPes_unp) Is Not Null

-- Validação das chaves PK e FK da Tabela UnidadeProprietario
And Not Exists(Select 1 From UnidadeProprietario UnP
					Where					
						br.Empresa_unid	=	unp.Empresa_unp
					And IsNull(br.CodPes_unp,pl.CodPes_unp) = UnP.CodPes_unp
					And br.Prod_unid =		UnP.Prod_unp
							
					)


			
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


If Object_Id('tempdb..#Tb_Brl')	Is Not Null Drop Table #Tb_Brl
If Object_Id('tempdb..#Tb_Urplan')	Is Not Null Drop Table #Tb_Urplan