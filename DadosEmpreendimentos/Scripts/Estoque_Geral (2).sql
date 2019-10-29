select getdate() as 'PesqDataHora' ,(year(getdate())*100)+month(getdate()) as 'PesqMesAno' ,year(getdate()) as 'PesqAno'
	   ,UP.Empresa_unid as 'EmprCod' ,UP.Obra_unid as 'ObraCod' ,O.descr_obr as 'ObraDesc'
	   ,DP.Projeto_fidcdp as 'ProdProjeto'
	   ,UP.Prod_unid as 'ProdCod' ,P.Descricao_psc as 'ProdDesc'
	   ,PC.CodCat_cp as 'ProdCategCod' ,CP.Desc_cger as 'ProdCategDesc'
	   ,UP.NumPer_unid as 'UnidCod' ,UP.Identificador_unid as 'UnidDesc' 
	   ,case when UP.Empresa_unid=20000 then 'REBr' else 'FIDC' end as 'UnidPortfolio'
	   ,UP.FracaoIdeal_unid as 'UnidFracaoIdeal' ,UP.c4_unid as 'UnidMetragem' ,UD.Descr_udt as 'UnidConfrontacao'
	   ,UP.Vendido_unid as 'UnidStatusCod'
	   ,case when UP.Vendido_unid=0  then 'Disponível   '
			 when UP.Vendido_unid=1  then case when UD.TipoContrato_udt in (1,2,5) then 'Locada       ' else 'Vendida      ' end
			 when UP.Vendido_unid=2  then 'Reservado    '
			 when UP.Vendido_unid=3  then 'Proposta     '
			 when UP.Vendido_unid=4  then 'Quitado      '
			 when UP.Vendido_unid=5  then 'Escriturado  '
			 when UP.Vendido_unid=6  then 'Em venda     '
			 when UP.Vendido_unid=7  then 'Suspenso     '
			 when UP.Vendido_unid=8  then 'Fora de venda'
			 when UP.Vendido_unid=9  then 'Em acerto    '
			 when UP.Vendido_unid=10 then 'Dação        '
		end as 'UnidStatusDesc' ,UP.NumCategStatus_unid as 'UnidStatusCategCod' ,CS.Desc_csup as 'UnidStatusCategDesc' --,HSU.DtAlt_hst ,HSU.UltStatus_hst
	   ,UD.NumBrrLogBrr_udt ,UD.NumLogrLogBrr_udt 
	   ,EL.Desc_Logr as 'ProdEndLogradouro' ,UD.NumEnd_udt as 'ProdEndNum' ,UD.ComplEnd_udt as 'ProdEndCompl' ,EL.CEP_Logr as 'ProdEndCEP'
	   ,EB.Desc_brr as 'ProdEndBairro' ,EC.Desc_cid as 'ProdEndCidade' ,EC.DescUF_cid as 'ProdEndUF'
	   ,V.Num_Ven as 'VendaNumero' ,V.Data_Ven as 'VendaData' ,V.Cliente_Ven as 'ClienteCodigo' ,C.nome_pes as 'ClienteNome'
--	   ,UDoP.cod_pes as 'UnidINTERVENIENTE_DepositarioCodigo' ,UDoP.nome_pes as 'UnidINTERVENIENTE_DepositarioNome' 
	   ,UPrs.*
	   ,UDo.*
  from REBUAUPRD01.dbo.UnidadePer UP with (nolock)
	   left join REBUAUPRD01.dbo.UnidadeDetalhe UD with (nolock) on UD.Empresa_udt=UP.Empresa_unid and UD.Prod_udt=UP.Prod_unid and UD.NumPer_udt=UP.NumPer_unid
	   left join REBUAUPRD01.dbo.Obras O with (nolock) on O.cod_obr=UP.Obra_unid
	   left join REBUAUPRD01.dbo.PrdSrv P with (nolock) on P.NumProd_psc=UP.Prod_unid
	   left join REBUAUPRD01.dbo.PrdSrvCat PC with (nolock) on PC.CodProd_cp=P.NumProd_psc
	   left join REBUAUPRD01.dbo.CategoriasDeProduto CP with (nolock) on CP.Codigo_cger=PC.CodCat_cp
	   left join REBUAUPRD01.dbo.CategoriaStatusUnidadePer CS with (nolock) on CS.Num_csup=UP.NumCategStatus_unid
	   left join REBUAUPRD01.dbo.LogBairro EBL with (nolock) on EBL.NumBrr_logBrr=UD.NumBrrLogBrr_udt and EBL.NumLogr_logBrr=UD.NumLogrLogBrr_udt
	   left join REBUAUPRD01.dbo.Logradouro EL with (nolock) on EL.Num_logr=EBL.NumLogr_logBrr
	   left join REBUAUPRD01.dbo.Bairro EB with (nolock) on EB.Num_brr=EBL.NumBrr_logBrr
	   left join REBUAUPRD01.dbo.Cidades EC with (nolock) on EC.Num_cid=EB.NumCid_brr
	   left join REBUAUPRD01.dbo.ItensVenda IV with (nolock) on IV.Empresa_itv=UP.Empresa_unid and IV.Obra_Itv=UP.Obra_unid and IV.CodPerson_Itv=UP.NumPer_unid and IV.Produto_Itv=UP.Prod_unid
	   left join REBUAUPRD01.dbo.Vendas V with (nolock) on V.Empresa_ven=IV.Empresa_itv and V.Obra_Ven=IV.Obra_Itv and V.Num_Ven=IV.NumVend_Itv
	   left join REBUAUPRD01.dbo.Pessoas C with (nolock) on C.cod_pes=V.Cliente_Ven
--	   left join REBUAUPRD01.dbo.UnidadeDepositario UDo with (nolock) on UDo.Empresa_und=UP.Empresa_unid and UDo.Prod_und=UP.Prod_unid and UDo.NumPer_und=UP.NumPer_unid
	   left join REBUAUPRD01_COMPLEMENTO.dbo.VwREBr_UAU_UnidadeDepositarios UDo with (nolock) on UDo.Empresa=UP.Empresa_unid and UDo.Produto=UP.Prod_unid and UDo.Personalizacao=UP.NumPer_unid
--	   left join REBUAUPRD01.dbo.Pessoas UDoP with (nolock) on UDoP.cod_pes=UDo.CodPes_und
	   left join REBUAUPRD01_COMPLEMENTO.dbo.VwREBr_UAU_UnidadeProprietarios UPrs with (nolock) on UPrs.Empresa=UP.Empresa_unid and UPrs.Produto=UP.Prod_unid and UPrs.Personalizacao=UP.NumPer_unid
	   left join REBUAUPRD01_COMPLEMENTO.dbo.FIDC_DePara DP with (nolock) on DP.Empreendimento_fidcdp=p.Descricao_psc
--	   left join REBUAUPRD01.dbo.HistStatusPerson HSU with (nolock) on HSU.Empresa_hst=UP.Empresa_unid and HSU.NumProd_hst=UP.Prod_unid and HSU.NumPer_hst=UP.NumPer_unid
 where (UP.Empresa_unid between 30000 and 39999 or UP.Empresa_unid=20000 and UP.Prod_unid>9999) 
 And UP.Vendido_unid = 0
 /*and UP.Empresa_unid not in (30030)*/ -- and UP.Obra_unid /*like '2S08%' */in ('2S18A','2S18B','3S18A','3S18B','3S36A')
--	   and UDo.Empresa is null
	   --and UD.Descr_udt is NULL
	   --and UD.NumBrrLogBrr_udt=57111
	   --and UP.Prod_unid in (10084,20084)
-- order by UP.Empresa_unid ,UP.Obra_unid ,UP.Identificador_unid
 order by P.Descricao_psc ,UP.Identificador_unid
 
 