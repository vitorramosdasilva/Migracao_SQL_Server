Use [REBUAUTST01];

IF OBJECT_ID('tempdb..#Tb_Sem_Pessoas')		IS NOT NULL DROP TABLE #Tb_Sem_Pessoas
IF OBJECT_ID('tempdb..#Tb_Com_Pessoas')		IS NOT NULL DROP TABLE #Tb_Com_Pessoas

SET NOEXEC OFF;

BEGIN TRANSACTION; 
GO

GO
If @@Error != 0 Set NoExec On;


Select  
	 Up.Empresa_unid As [Empresa_unp]
	,up.Prod_unid	As [Prod_unp]
	,up.NumPer_unid  As [NumPer_unp]	
	,IIF(Upro.CodPes_unp Is Null, c.cod_pes,Upro.CodPes_unp)  As [CodPes_unp]
		   
Into #Tb_Sem_Pessoas

From dbo.UnidadePer UP with (nolock)
	Left Join dbo.UnidadeDetalhe UD With (NoLock) 
		On UD.Empresa_udt	= UP.Empresa_unid 
	And UD.Prod_udt			= UP.Prod_unid 
	And UD.NumPer_udt		= UP.NumPer_unid
	

	Left Join dbo.PrdSrv P With (NoLock) 
		On P.NumProd_psc = UP.Prod_unid

	Left Join dbo.PrdSrvCat PC With (NoLock) 
		On PC.CodProd_cp = P.NumProd_psc 

	Left Join dbo.CategoriasDeProduto CP With (NoLock) 
		On CP.Codigo_cger = PC.CodCat_cp

	Left Join dbo.ItensVenda IV With (NoLock) 
		On IV.Empresa_itv = UP.Empresa_unid 
	And IV.Obra_Itv = UP.Obra_unid 
	And IV.CodPerson_Itv = UP.NumPer_unid 
	And IV.Produto_Itv = UP.Prod_unid

	Left Join dbo.Vendas V With (NoLock) 
		On V.Empresa_ven = IV.Empresa_itv 
		and V.Obra_Ven = IV.Obra_Itv 
	And V.Num_Ven = IV.NumVend_Itv

	Left Join dbo.Pessoas C With (NoLock) 
		On C.cod_pes = V.Cliente_Ven

	Left Join REBUAUPRD01_COMPLEMENTO.dbo.VwREBr_UAU_UnidadeDepositarios UDo With (NoLock) 
		On UDo.Empresa = UP.Empresa_unid
	And UDo.Produto = UP.Prod_unid 
	And UDo.Personalizacao = UP.NumPer_unid

	Left Join REBUAUPRD01_COMPLEMENTO.dbo.VwREBr_UAU_UnidadeProprietarios UPrs With (NoLock) 
		On UPrs.Empresa = UP.Empresa_unid
	And UPrs.Produto = UP.Prod_unid and UPrs.Personalizacao = UP.NumPer_unid

	Left Join REBUAUPRD01_COMPLEMENTO.dbo.FIDC_DePara DP With (NoLock) 
		On DP.Empreendimento_fidcdp = p.Descricao_psc

	Left Join [dbo].[UnidadeProprietario] Upro
	On UP.Empresa_unid = Upro.Empresa_unp
	And	UP.Prod_unid = Upro.[Prod_unp]
	And	UP.NumPer_unid = Upro.[NumPer_unp]

Where (UP.Empresa_unid Between 1 And 1500
		--Or 
		--UP.Empresa_unid Between 3000 And 3999
		)		

	And 
	Not Exists (Select 1 
					From dbo.UnidadePer UP With (nolock)
					Where UD.Empresa_udt = UP.Empresa_unid 
					And UD.Prod_udt = UP.Prod_unid 
					And UD.NumPer_udt = UP.NumPer_unid
				)		

	--And Upro.CodPes_unp Is Null
	--And c.cod_pes Is Null

Order By P.Descricao_psc ,UP.Identificador_unid 



Select Distinct
	 Upro.[Empresa_unp]
	,Upro.[Prod_unp]
	,Upro.[NumPer_unp]
	,Upro.CodPes_unp
Into #Tb_Com_Pessoas
From [dbo].[UnidadeProprietario] Upro
Where Exists (Select 1 From #Tb_Sem_Pessoas P  
				Where	   P.Empresa_unp = Upro.Empresa_unp
						And P.[Prod_unp] = Upro.[Prod_unp]
						And P.NumPer_unp = Upro.[NumPer_unp]
				-- And Upro.CodPes_unp Is Null
				)

 
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
 
	 Up.Empresa_unid As [Empresa_unp]
	,up.Prod_unid	As [Prod_unp]
	,up.NumPer_unid  As [NumPer_unp]	
	,Cpp.CodPes_unp As [CodPes_unp]
	
	,0 As [PorcImovel_unp]
	,'PsTalent' As [UsrCad_unp]
	,Cast(GetDate()As Date) As [DataCad_unp]
	,0 As [CobrarCPMF_unp]
	,1 As [ParticipaSecuritizacao_unp]
	,0 As [ParticipaCalcReceita_unp]
	,Cast(GetDate()As Date) As [DataVigencia_unp]
	,NULL As [NumSec_unp]
	,0 As [RateiaBoleto_unp]
	,NULL As [EmpresaCalcReceita_unp]

From dbo.UnidadePer UP with (nolock)
	Left Join dbo.UnidadeDetalhe UD With (NoLock) 
		On UD.Empresa_udt = UP.Empresa_unid 
	And UD.Prod_udt = UP.Prod_unid 
	And UD.NumPer_udt = UP.NumPer_unid
	
	Left Join dbo.Obras O With (NoLock) 
		On O.cod_obr = UP.Obra_unid

	Left Join dbo.PrdSrv P With (NoLock) 
		On P.NumProd_psc = UP.Prod_unid

	Left Join dbo.PrdSrvCat PC With (NoLock) 
		On PC.CodProd_cp = P.NumProd_psc 

	Left Join dbo.CategoriasDeProduto CP With (NoLock) 
		On CP.Codigo_cger = PC.CodCat_cp

	Left Join dbo.CategoriaStatusUnidadePer CS With (NoLock) 
		On CS.Num_csup = UP.NumCategStatus_unid

	Left Join dbo.LogBairro EBL With (NoLock) 
		On EBL.NumBrr_logBrr = UD.NumBrrLogBrr_udt
	And EBL.NumLogr_logBrr = UD.NumLogrLogBrr_udt

	Left Join dbo.Logradouro EL With (NoLock) 
		On EL.Num_logr = EBL.NumLogr_logBrr

	Left Join dbo.Bairro EB With (NoLock) 
		On EB.Num_brr = EBL.NumBrr_logBrr

	Left Join dbo.Cidades EC With (NoLock) 
		On EC.Num_cid = EB.NumCid_brr

	Left Join dbo.ItensVenda IV With (NoLock) 
		On IV.Empresa_itv = UP.Empresa_unid 
	And IV.Obra_Itv = UP.Obra_unid 
	And IV.CodPerson_Itv = UP.NumPer_unid 
	And IV.Produto_Itv = UP.Prod_unid

	Left Join dbo.Vendas V With (NoLock) 
		On V.Empresa_ven = IV.Empresa_itv 
		and V.Obra_Ven = IV.Obra_Itv 
	And V.Num_Ven = IV.NumVend_Itv

	--Left Join dbo.Pessoas C With (NoLock) 
	--	On C.cod_pes = V.Cliente_Ven

	Left Join REBUAUPRD01_COMPLEMENTO.dbo.VwREBr_UAU_UnidadeDepositarios UDo With (NoLock) 
		On UDo.Empresa = UP.Empresa_unid
	And UDo.Produto = UP.Prod_unid 
	And UDo.Personalizacao = UP.NumPer_unid

	Left Join REBUAUPRD01_COMPLEMENTO.dbo.VwREBr_UAU_UnidadeProprietarios UPrs With (NoLock) 
		On UPrs.Empresa = UP.Empresa_unid
	And UPrs.Produto = UP.Prod_unid and UPrs.Personalizacao = UP.NumPer_unid

	Left Join REBUAUPRD01_COMPLEMENTO.dbo.FIDC_DePara DP With (NoLock) 
		On DP.Empreendimento_fidcdp = p.Descricao_psc

		Left Join  #Tb_Com_Pessoas Cpp
		On  Cpp.Empresa_unp = up.Empresa_unid
		And Cpp.NumPer_unp = up.NumPer_unid
		And Cpp.Prod_unp = up.Prod_unid

Where (UP.Empresa_unid Between 1 And 1500)	
	And 
	Not Exists (Select 1 
					From dbo.UnidadeProprietario UP with (nolock)
					Where UD.Empresa_udt = UP.Empresa_unp 
					And UD.Prod_udt = UP.Prod_unp 
					And UD.NumPer_udt = UP.NumPer_unp				
				)
							
	And Cpp.CodPes_unp Is Not Null

Order By P.Descricao_psc, UP.Identificador_unid


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

IF OBJECT_ID('tempdb..#Tb_Sem_Pessoas')		IS NOT NULL DROP TABLE #Tb_Sem_Pessoas
IF OBJECT_ID('tempdb..#Tb_Com_Pessoas')		IS NOT NULL DROP TABLE #Tb_Com_Pessoas




-----     Validações ....

	--And UP.Empresa_unid  = 27
	--And up.Prod_unid = 1006
	--And UP.NumPer_unid = 8



 --select * from dbo.pessoas where cod_pes in(40485,9244)
  /*select * from #Tb_Com_Pessoas cp
 where 
 cp.Empresa_unp = 21
 And cp.NumPer_unp =2
 And 
 cp.Prod_unp = 1006
 27	1006	8*/

 /*
				Select Distinct
	 Upro.[Empresa_unp]
	,Upro.[Prod_unp]
	,Upro.[NumPer_unp]
	,Upro.CodPes_unp
--Into #Tb_Com_Pessoas
From [dbo].[UnidadeProprietario] Upro
where Upro.[Empresa_unp] = 60
	AND Upro.[Prod_unp] = 10006
	aND Upro.[NumPer_unp] = 39322
	--aND Upro.CodPes_unp


		Select Distinct
	 Upro.[Empresa_unp]
	,Upro.[Prod_unp]
	,Upro.[NumPer_unp]
	,Upro.CodPes_unp
--Into #Tb_Com_Pessoas
From [dbo].[UnidadeProprietario] Upro
where Upro.[Empresa_unp] = 27

	AND Upro.[Prod_unp] = 1006
	aND Upro.[NumPer_unp] = 3
	--aND Upro.CodPes_unp
	oRDER BY 2

*/





























/*
Select

	UD.NumPer_udt
	,UP.Empresa_unid						As 'EmprCod' 
	,UP.Obra_unid							As 'ObraCod' 
	,O.descr_obr							As 'ObraDesc'
	,DP.Projeto_fidcdp						As 'ProdProjeto'
	,UP.Prod_unid							As 'ProdCod'
	,P.Descricao_psc						As 'ProdDesc'
	,PC.CodCat_cp							As 'ProdCategCod' 
	,CP.Desc_cger							As 'ProdCategDesc'
	,UP.NumPer_unid							As 'UnidCod' 
	,UP.Identificador_unid					As 'UnidDesc' 
	,Case 
		When UP.Empresa_unid  =  20000 Then 'REBr' 
		Else 'FIDC' 
	 End									As 'UnidPortfolio'

	,UP.FracaoIdeal_unid					As 'UnidFracaoIdeal'
	,UP.c4_unid								As 'UnidMetragem'

	--,UD.Descr_udt							As 'UnidConfrontacao'
	,UP.Vendido_unid						As 'UnidStatusCod'

	,Case 
		When UP.Vendido_unid = 0  Then 'Disponível   '
		When UP.Vendido_unid = 1  Then  IIF(UD.TipoContrato_udt In (1,2,5),'Locada       ','Vendida      ')
		When UP.Vendido_unid = 2  Then 'Reservado    '
		When UP.Vendido_unid = 3  Then 'Proposta     '
		When UP.Vendido_unid = 4  Then 'Quitado      '
		When UP.Vendido_unid = 5  Then 'Escriturado  '
		When UP.Vendido_unid = 6  Then 'Em venda     '
		When UP.Vendido_unid = 7  Then 'Suspenso     '
		When UP.Vendido_unid = 8  Then 'Fora de venda'
		When UP.Vendido_unid = 9  Then 'Em acerto    '
		When UP.Vendido_unid = 10 Then 'Dação        '
	End										As 'UnidStatusDesc'

	,UP.NumCategStatus_unid					As 'UnidStatusCategCod'
	,CS.Desc_csup							As 'UnidStatusCategDesc'

	--,HSU.DtAlt_hst ,HSU.UltStatus_hst

	--,UD.NumBrrLogBrr_udt
	--,UD.NumLogrLogBrr_udt 
	,EL.Desc_Logr							As 'ProdEndLogradouro'

	--,UD.NumEnd_udt						As 'ProdEndNum' 
	--,UD.ComplEnd_udt						As 'ProdEndCompl'

	,EL.CEP_Logr							As 'ProdEndCEP'
	,EB.Desc_brr							As 'ProdEndBairro'
	,EC.Desc_cid							As 'ProdEndCidade' 
	,EC.DescUF_cid							As 'ProdEndUF'

	,V.Num_Ven								As 'VendaNumero' 
	,V.Data_Ven								As 'VendaData' 
	,V.Cliente_Ven							As 'ClienteCodigo' 
	,C.nome_pes								As 'ClienteNome'
	
	--,UDoP.cod_pes							As 'UnidINTERVENIENTE_DepositarioCodigo'
	--,UDoP.nome_pes						As 'UnidINTERVENIENTE_DepositarioNome'

	,UPrs.*
	,UDo.*

	   --Into #Tb_Estoque

  From dbo.UnidadePer UP with (nolock)
	   Left Join dbo.UnidadeDetalhe UD With (NoLock) 
			On UD.Empresa_udt = UP.Empresa_unid 
	   And UD.Prod_udt = UP.Prod_unid 
	   And UD.NumPer_udt = UP.NumPer_unid


	   Left Join dbo.Obras O With (NoLock) 
			On O.cod_obr = UP.Obra_unid

	   Left Join dbo.PrdSrv P With (NoLock) 
			On P.NumProd_psc = UP.Prod_unid

	   Left Join dbo.PrdSrvCat PC With (NoLock) 
			On PC.CodProd_cp = P.NumProd_psc 

	   Left Join dbo.CategoriasDeProduto CP With (NoLock) 
			On CP.Codigo_cger = PC.CodCat_cp

	   Left Join dbo.CategoriaStatusUnidadePer CS With (NoLock) 
			On CS.Num_csup = UP.NumCategStatus_unid

	   Left Join dbo.LogBairro EBL With (NoLock) 
			On EBL.NumBrr_logBrr = UD.NumBrrLogBrr_udt
	   And EBL.NumLogr_logBrr = UD.NumLogrLogBrr_udt

	   Left Join dbo.Logradouro EL With (NoLock) 
			On EL.Num_logr = EBL.NumLogr_logBrr

	   Left Join dbo.Bairro EB With (NoLock) 
			On EB.Num_brr = EBL.NumBrr_logBrr

	   Left Join dbo.Cidades EC With (NoLock) 
			On EC.Num_cid = EB.NumCid_brr

	   Left Join dbo.ItensVenda IV With (NoLock) 
			On IV.Empresa_itv = UP.Empresa_unid 
	   And IV.Obra_Itv = UP.Obra_unid 
	   And IV.CodPerson_Itv = UP.NumPer_unid 
	   And IV.Produto_Itv = UP.Prod_unid

	   Left Join dbo.Vendas V With (NoLock) 
			On V.Empresa_ven = IV.Empresa_itv 
			and V.Obra_Ven = IV.Obra_Itv 
	   And V.Num_Ven = IV.NumVend_Itv

	   Left Join dbo.Pessoas C With (NoLock) 
			On C.cod_pes = V.Cliente_Ven

	   Left Join REBUAUPRD01_COMPLEMENTO.dbo.VwREBr_UAU_UnidadeDepositarios UDo With (NoLock) 
			On UDo.Empresa = UP.Empresa_unid
	   And UDo.Produto = UP.Prod_unid 
	   And UDo.Personalizacao = UP.NumPer_unid

	   Left Join REBUAUPRD01_COMPLEMENTO.dbo.VwREBr_UAU_UnidadeProprietarios UPrs With (NoLock) 
			On UPrs.Empresa = UP.Empresa_unid
	   And UPrs.Produto = UP.Prod_unid and UPrs.Personalizacao = UP.NumPer_unid

	   Left Join REBUAUPRD01_COMPLEMENTO.dbo.FIDC_DePara DP With (NoLock) 
			On DP.Empreendimento_fidcdp = p.Descricao_psc

 Where (UP.Empresa_unid 
		between 1 And 1500)

		 --Or UP.Empresa_unid = 20000 
		 --And UP.Prod_unid > 9999)

		--And UP.Vendido_unid  =  0
		/*and UP.Empresa_unid not in (30030)*/ 
		-- and UP.Obra_unid /*like '2S08%' */in ('2S18A','2S18B','3S18A','3S18B','3S36A')
		--and UDo.Empresa is null
		--and UD.Descr_udt is NULL
		--and UD.NumBrrLogBrr_udt = 57111
		--and UP.Prod_unid in (10084,20084)
		-- order by UP.Empresa_unid ,UP.Obra_unid ,UP.Identificador_unid
		
		And UP.Empresa_unid  = 27
		And up.Prod_unid = 1006
		And UP.NumPer_unid = 8

		And 
		Not Exists (Select 1 
						From dbo.UnidadePer UP with (nolock)
						Where UD.Empresa_udt = UP.Empresa_unid 
						And UD.Prod_udt = UP.Prod_unid 
						And UD.NumPer_udt = UP.NumPer_unid)

Order By P.Descricao_psc ,UP.Identificador_unid*/
