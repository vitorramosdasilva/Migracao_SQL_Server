Use [REBUAUTST01];

If Object_Id('tempdb..#Tb_Urplan_Nao_Existe')	Is Not Null Drop Table #Tb_Urplan_Nao_Existe

SET NOEXEC OFF;

BEGIN TRANSACTION; 
GO

GO
If @@Error != 0 Set NoExec On;


---- Cliente Urplan Que Não Existem na UnidadeProprietario


Select  
	per.Empresa_unid, 
	per.Prod_unid, 
	per.NumPer_unid

Into #Tb_Urplan_Nao_Existe
								 
From dbo.UnidadePer per
Where per.Empresa_unid < 19999
And per.Prod_unid > 10000
And								
Not Exists(Select 1 
			From UnidadeProprietario Pro 
			Where	per.Empresa_unid =	Pro.Empresa_unp
				And per.NumPer_unid =	Pro.NumPer_unp
				And per.Prod_unid =		Pro.Prod_unp
			)
Order By 1



---- Cliente Urplan Que Não Existem Cruzados com Clientes Brl .....


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



Select

	 Distinct 
	 Urp.Empresa_unid
	,Urp.Prod_unid
	,Urp.NumPer_unid
	,UniP.CodPes_unp
	,UniP.PorcImovel_unp
	,'PsTalent' As [UsrCad_unp]
	,Cast(GetDate() As Date) As [DataCad_unp]
	,UniP.CobrarCPMF_unp As [CobrarCPMF_unp]
	,UniP.ParticipaCalcReceita_unp
	,UniP.ParticipaSecuritizacao_unp
	,Cast(GetDate() As Date) As [DataVigencia_unp] 
	,UniP.NumSec_unp
	,UniP.RateiaBoleto_unp
	,UniP.EmpresaCalcReceita_unp

From #Tb_Urplan_Nao_Existe As Urp
Left Join UnidadeProprietario UniP --
	--Where UniP.Empresa_unp >= 30000
	On 	
	Urp.NumPer_unid	  =	UniP.NumPer_unp
	And Urp.Prod_unid = UniP.Prod_unp
		
	Where  UniP.Empresa_unp Is Not Null									
	And
	Not Exists(Select 1 
				From  UnidadeProprietario Pro 
				Where Urp.Empresa_unid = Pro.Empresa_unp
				And	  Urp.NumPer_unid   = Pro.NumPer_unp
				And   Urp.Prod_unid = Pro.Prod_unp
				)											

Order By 1


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


	If Object_Id('tempdb..#Tb_Urplan_Nao_Existe')	Is Not Null Drop Table #Tb_Urplan_Nao_Existe