Use [REBUAUTST01];


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
Select  
	 Up.Empresa_unid As [Empresa_unp]
	,up.Prod_unid	As [Prod_unp]
	,up.NumPer_unid  As [NumPer_unp]
	,C.cod_pes As [CodPes_unp]
	,'' As [PorcImovel_unp]
	,'PsTalent' As [UsrCad_unp]
	,Cast(GetDate()As Date) As [DataCad_unp]
	,0 As [CobrarCPMF_unp]
	,1 As [ParticipaSecuritizacao_unp]
	,0 As [ParticipaCalcReceita_unp]
	,Cast(GetDate()As Date) As [DataVigencia_unp]
	,NULL As [NumSec_unp]
	,0 As [RateiaBoleto_unp]
	,NULL As [EmpresaCalcReceita_unp]
		   

From REBUAUPRD01.dbo.UnidadePer UP with (nolock)
	Left Join REBUAUPRD01.dbo.UnidadeDetalhe UD With (NoLock) 
		On UD.Empresa_udt = UP.Empresa_unid 
	And UD.Prod_udt = UP.Prod_unid 
	And UD.NumPer_udt = UP.NumPer_unid


	Left Join REBUAUPRD01.dbo.Obras O With (NoLock) 
		On O.cod_obr = UP.Obra_unid

	Left Join REBUAUPRD01.dbo.PrdSrv P With (NoLock) 
		On P.NumProd_psc = UP.Prod_unid

	Left Join REBUAUPRD01.dbo.PrdSrvCat PC With (NoLock) 
		On PC.CodProd_cp = P.NumProd_psc 

	Left Join REBUAUPRD01.dbo.CategoriasDeProduto CP With (NoLock) 
		On CP.Codigo_cger = PC.CodCat_cp

	Left Join REBUAUPRD01.dbo.CategoriaStatusUnidadePer CS With (NoLock) 
		On CS.Num_csup = UP.NumCategStatus_unid

	Left Join REBUAUPRD01.dbo.LogBairro EBL With (NoLock) 
		On EBL.NumBrr_logBrr = UD.NumBrrLogBrr_udt
	And EBL.NumLogr_logBrr = UD.NumLogrLogBrr_udt

	Left Join REBUAUPRD01.dbo.Logradouro EL With (NoLock) 
		On EL.Num_logr = EBL.NumLogr_logBrr

	Left Join REBUAUPRD01.dbo.Bairro EB With (NoLock) 
		On EB.Num_brr = EBL.NumBrr_logBrr

	Left Join REBUAUPRD01.dbo.Cidades EC With (NoLock) 
		On EC.Num_cid = EB.NumCid_brr

	Left Join REBUAUPRD01.dbo.ItensVenda IV With (NoLock) 
		On IV.Empresa_itv = UP.Empresa_unid 
	And IV.Obra_Itv = UP.Obra_unid 
	And IV.CodPerson_Itv = UP.NumPer_unid 
	And IV.Produto_Itv = UP.Prod_unid

	Left Join REBUAUPRD01.dbo.Vendas V With (NoLock) 
		On V.Empresa_ven = IV.Empresa_itv 
		and V.Obra_Ven = IV.Obra_Itv 
	And V.Num_Ven = IV.NumVend_Itv

	Left Join REBUAUPRD01.dbo.Pessoas C With (NoLock) 
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
		
	--And UP.Empresa_unid  = 27
	--And up.Prod_unid = 1006
	--And UP.NumPer_unid = 8

	And 
	Not Exists (Select 1 
					From REBUAUPRD01.dbo.UnidadePer UP with (nolock)
					Where UD.Empresa_udt = UP.Empresa_unid 
					And UD.Prod_udt = UP.Prod_unid 
					And UD.NumPer_udt = UP.NumPer_unid)

Order By P.Descricao_psc ,UP.Identificador_unid 



































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

  From REBUAUPRD01.dbo.UnidadePer UP with (nolock)
	   Left Join REBUAUPRD01.dbo.UnidadeDetalhe UD With (NoLock) 
			On UD.Empresa_udt = UP.Empresa_unid 
	   And UD.Prod_udt = UP.Prod_unid 
	   And UD.NumPer_udt = UP.NumPer_unid


	   Left Join REBUAUPRD01.dbo.Obras O With (NoLock) 
			On O.cod_obr = UP.Obra_unid

	   Left Join REBUAUPRD01.dbo.PrdSrv P With (NoLock) 
			On P.NumProd_psc = UP.Prod_unid

	   Left Join REBUAUPRD01.dbo.PrdSrvCat PC With (NoLock) 
			On PC.CodProd_cp = P.NumProd_psc 

	   Left Join REBUAUPRD01.dbo.CategoriasDeProduto CP With (NoLock) 
			On CP.Codigo_cger = PC.CodCat_cp

	   Left Join REBUAUPRD01.dbo.CategoriaStatusUnidadePer CS With (NoLock) 
			On CS.Num_csup = UP.NumCategStatus_unid

	   Left Join REBUAUPRD01.dbo.LogBairro EBL With (NoLock) 
			On EBL.NumBrr_logBrr = UD.NumBrrLogBrr_udt
	   And EBL.NumLogr_logBrr = UD.NumLogrLogBrr_udt

	   Left Join REBUAUPRD01.dbo.Logradouro EL With (NoLock) 
			On EL.Num_logr = EBL.NumLogr_logBrr

	   Left Join REBUAUPRD01.dbo.Bairro EB With (NoLock) 
			On EB.Num_brr = EBL.NumBrr_logBrr

	   Left Join REBUAUPRD01.dbo.Cidades EC With (NoLock) 
			On EC.Num_cid = EB.NumCid_brr

	   Left Join REBUAUPRD01.dbo.ItensVenda IV With (NoLock) 
			On IV.Empresa_itv = UP.Empresa_unid 
	   And IV.Obra_Itv = UP.Obra_unid 
	   And IV.CodPerson_Itv = UP.NumPer_unid 
	   And IV.Produto_Itv = UP.Prod_unid

	   Left Join REBUAUPRD01.dbo.Vendas V With (NoLock) 
			On V.Empresa_ven = IV.Empresa_itv 
			and V.Obra_Ven = IV.Obra_Itv 
	   And V.Num_Ven = IV.NumVend_Itv

	   Left Join REBUAUPRD01.dbo.Pessoas C With (NoLock) 
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
						From REBUAUPRD01.dbo.UnidadePer UP with (nolock)
						Where UD.Empresa_udt = UP.Empresa_unid 
						And UD.Prod_udt = UP.Prod_unid 
						And UD.NumPer_udt = UP.NumPer_unid)

Order By P.Descricao_psc ,UP.Identificador_unid*/
