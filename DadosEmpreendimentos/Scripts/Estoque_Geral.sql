Use [REBUAUPRD01];

Set NoCount On;   

Select top(50)
	    GetDate()				As 'PesqDataHora' 
	   ,(Year(GetDate()) * 100) + 
			   Month(GetDate()) As 'PesqMesAno' 
	   ,Year(GetDate())			As 'PesqAno'
	   ,UP.Empresa_unid			As 'EmprCod' 
	   ,UP.Obra_unid			As 'ObraCod' 
	   ,O.descr_obr				As 'ObraDesc'
	   ,DP.Projeto_fidcdp		As 'ProdProjeto'
	   ,UP.Prod_unid			As 'ProdCod' 
	   ,P.Descricao_psc			As 'ProdDesc'
	   ,PC.CodCat_cp			As 'ProdCategCod' 
	   ,CP.Desc_cger			As 'ProdCategDesc'
	   ,UP.NumPer_unid			As 'UnidCod' 
	   ,UP.Identificador_unid	As 'UnidDesc' 
	   ,Case 
			When UP.Empresa_unid = 20000 Then 'REBr' 
		Else 'FIDC' 
		End						As 'UnidPortfolio'
	   ,UP.FracaoIdeal_unid		As 'UnidFracaoIdeal' 
	   ,UP.c4_unid				As 'UnidMetragem' 
	   ,UD.Descr_udt			As 'UnidConfrontacao'
	   ,UP.Vendido_unid			As 'UnidStatusCod'
	   ,Case 
			When UP.Vendido_unid =	0  Then 'Disponível   '
			When UP.Vendido_unid =	1  Then  IIF(UD.TipoContrato_udt in (125),'Locada       ','Vendida      ')
			When UP.Vendido_unid =	2  Then 'Reservado    '
			When UP.Vendido_unid =	3  Then 'Proposta     '
			When UP.Vendido_unid =	4  Then 'Quitado      '
			When UP.Vendido_unid =	5  Then 'Escriturado  '
			When UP.Vendido_unid =	6  Then 'Em venda     '
			When UP.Vendido_unid =	7  Then 'Suspenso     '
			When UP.Vendido_unid =	8  Then 'Fora de venda'
			When UP.Vendido_unid =	9  Then 'Em acerto    '
			When UP.Vendido_unid =	10 Then 'Dação        '
		End						As 'UnidStatusDesc' 
	   ,UP.NumCategStatus_unid	As 'UnidStatusCategCod' 
	   ,CS.Desc_csup			As 'UnidStatusCategDesc' 

	   --HSU.DtAlt_hst HSU.UltStatus_hst

	   ,UD.NumBrrLogBrr_udt 
	   ,UD.NumLogrLogBrr_udt 
	   ,EL.Desc_Logr			As 'ProdEndLogradouro' 
	   ,UD.NumEnd_udt			As 'ProdEndNum' 
	   ,UD.ComplEnd_udt			As 'ProdEndCompl' 
	   ,EL.CEP_Logr				As 'ProdEndCEP'
	   ,EB.Desc_brr				As 'ProdEndBairro' 
	   ,EC.Desc_cid				As 'ProdEndCidade' 
	   ,EC.DescUF_cid			As 'ProdEndUF'
	   ,V.Num_Ven				As 'VendaNumero' 
	   ,V.Data_Ven				As 'VendaData' 
	   ,V.Cliente_Ven			As 'ClienteCodigo' 
	   ,C.nome_pes				As 'ClienteNome'

		--UDoP.cod_pes			As 'UnidINTERVENIENTE_DepositarioCodigo' 
		--UDoP.nome_pes			As 'UnidINTERVENIENTE_DepositarioNome'
		 
	   ,UPrs.*
	   ,UDo.*

  From dbo.UnidadePer UP With (NoLock)
   
	   Left Join dbo.UnidadeDetalhe UD With (NoLock)  
			On UD.Empresa_udt	= UP.Empresa_unid 
			And UD.Prod_udt		= UP.Prod_unid 
			And UD.NumPer_udt	= UP.NumPer_unid

	   Left Join dbo.Obras O With (NoLock)  
			On O.cod_obr		= UP.Obra_unid

	   Left Join dbo.PrdSrv P With (NoLock)  
			On P.NumProd_psc	= UP.Prod_unid

	   Left Join dbo.PrdSrvCat PC With (NoLock)  
			On PC.CodProd_cp	= P.NumProd_psc

	   Left Join dbo.CategoriasDeProduto CP With (NoLock)  
			On CP.Codigo_cger	= PC.CodCat_cp

	   Left Join dbo.CategoriaStatusUnidadePer CS With (NoLock)  
			On CS.Num_csup		= UP.NumCategStatus_unid

	   Left Join dbo.LogBairro EBL With (NoLock)  
			On EBL.NumBrr_logBrr = UD.NumBrrLogBrr_udt
			And EBL.NumLogr_logBrr = UD.NumLogrLogBrr_udt

	   Left Join dbo.Logradouro EL With (NoLock)  
			On EL.Num_logr		= EBL.NumLogr_logBrr

	   Left Join dbo.Bairro EB With (NoLock)  
			On EB.Num_brr		= EBL.NumBrr_logBrr

	   Left Join dbo.Cidades EC With (NoLock)  
			On EC.Num_cid		= EB.NumCid_brr

	   Left Join dbo.ItensVenda IV With (NoLock)  
			On IV.Empresa_itv	 = UP.Empresa_unid 
			And IV.Obra_Itv		 = UP.Obra_unid 
			And IV.CodPerson_Itv = UP.NumPer_unid 
			And IV.Produto_Itv	 = UP.Prod_unid

	   Left Join dbo.Vendas V With (NoLock)  
			On V.Empresa_ven	= IV.Empresa_itv 
			And V.Obra_Ven		= IV.Obra_Itv 
			And V.Num_Ven		= IV.NumVend_Itv

	   Left Join dbo.Pessoas C With (NoLock)  
			On C.cod_pes		= V.Cliente_Ven

		--Left Join dbo.UnidadeDepositario UDo With (NoLock)  
		--On UDo.Empresa_und=UP.Empresa_unid 
		--And UDo.Prod_und=UP.Prod_unid 
		--And UDo.NumPer_und=UP.NumPer_unid

	   Left Join REBUAUPRD01_COMPLEMENTO.dbo.VwREBr_UAU_UnidadeDepositarios UDo With (NoLock)  
			On UDo.Empresa		= UP.Empresa_unid 
			And UDo.Produto		= UP.Prod_unid 
			And UDo.Personalizacao = UP.NumPer_unid

		--Left Join dbo.Pessoas UDoP With (NoLock)  
		--On UDoP.cod_pes=UDo.CodPes_und

	   Left Join REBUAUPRD01_COMPLEMENTO.dbo.VwREBr_UAU_UnidadeProprietarios UPrs With (NoLock)  
			On UPrs.Empresa		= UP.Empresa_unid 
			And UPrs.Produto	= UP.Prod_unid 
			And UPrs.Personalizacao = UP.NumPer_unid

	   Left Join REBUAUPRD01_COMPLEMENTO.dbo.FIDC_DePara DP With (NoLock)  
			On DP.Empreendimento_fidcdp = p.Descricao_psc

--	   Left Join dbo.HistStatusPersOn HSU With (NoLock)  
			--On HSU.Empresa_hst  = UP.Empresa_unid 
			--And HSU.NumProd_hst = UP.Prod_unid 
			--And HSU.NumPer_hst  = UP.NumPer_unid

 Where (UP.Empresa_unid Between 30000 And 39999 
		Or UP.Empresa_unid  = 20000) 
		And UP.Prod_unid	>	9999

		/*And UP.Empresa_unid not in (30030)*/ 
		--And UP.Obra_unid /*like '2S08%' */in ('2S18A''2S18B''3S18A''3S18B''3S36A')
		--And UDo.Empresa is null
	    --And UD.Descr_udt is NULL
	    --And UD.NumBrrLogBrr_udt=57111
	    --And UP.Prod_unid in (1008420084)

		And UP.Prod_unid = 20056
		--And UP.Identificador_unid = 'Q01-L01'
		-- Order by UP.Empresa_unid, UP.Obra_unid, UP.Identificador_unid
Order by 
 P.Descricao_psc 
,UP.Identificador_unid

--Select Top(50) * From  [REBUAUPRD01_COMPLEMENTO].[dbo].[DadosEmpreendimentos_201910]
--Select Top(50) * From  REBUAUPRD01_COMPLEMENTO.dbo.VwREBr_UAU_UnidadeDepositarios 
--Select Top(50) * From REBUAUPRD01_COMPLEMENTO.dbo.VwREBr_UAU_UnidadeProprietarios

/*

	Select Top(10) * From UnidadePer
	Select Top(10) * From	dbo.UnidadeDetalhe
	Select Top(10) * From Obras
	Select Top(10) * From PrdSrv
	Select Top(10) * From PrdSrvCat
	Select Top(10) * From CategoriasDeProduto
	Select Top(10) * From CategoriaStatusUnidadePer
	Select Top(10) * From LogBairro
	Select Top(10) * From Logradouro
	Select Top(10) * From Bairro
	Select Top(10) * From Cidades
	Select Top(10) * From ItensVenda
	Select Top(10) * From Vendas
	Select Top(10) * From Pessoas
	Select Top(10) * From REBUAUPRD01_COMPLEMENTO.dbo.VwREBr_UAU_UnidadeDepositarios
	Select Top(10) * From REBUAUPRD01_COMPLEMENTO.dbo.VwREBr_UAU_UnidadeProprietarios
	Select Top(10) * From REBUAUPRD01_COMPLEMENTO.dbo.FIDC_DePara

*/
