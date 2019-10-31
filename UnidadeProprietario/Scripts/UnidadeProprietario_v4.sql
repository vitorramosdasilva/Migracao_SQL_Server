Use [REBUAUPRD01];

-- Desenvolvido Por Vitor Ramos
-- Data: 31/10/2019 14:21

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
--And up.UsrCad_unp Is Not Null

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

	 pl.[Empresa_unid]
	,pl.[Prod_unid]
	,pl.[NumPer_unid]
	,pl.CodPes_unp
	,pl.[PorcImovel_unp]
	,pl.[UsrCad_unp]
	,pl.[DataCad_unp]
	,pl.[CobrarCPMF_unp]
	,pl.[ParticipaSecuritizacao_unp]
	,pl.[ParticipaCalcReceita_unp]
	,pl.[DataVigencia_unp]
	,pl.[NumSec_unp]
	,pl.[RateiaBoleto_unp]
	,pl.[EmpresaCalcReceita_unp]


From #Tb_Brl br
Left Join #Tb_Urplan pl
On br.Identificador_unid = pl.Identificador_unid
And br.Prod_unid		 = pl.Prod_unid

Where 
	Not Exists(Select 1 From UnidadeProprietario UnP
				Where					
					pl.Empresa_unid	= unp.Empresa_unp
				And pl.CodPes_unp = UnP.CodPes_unp
				And pl.Prod_unid = UnP.Prod_unp
				
				)
	And pl.[Empresa_unid] Is Not Null


					
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

