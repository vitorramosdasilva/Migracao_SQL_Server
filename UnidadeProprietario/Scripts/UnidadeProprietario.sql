Use [REBUAUTST01];

If Object_Id('tempdb..#Tb_Estoque') Is Not Null Drop Table #Tb_Estoque
If Object_Id('tempdb..#Tab_Dif')	Is Not Null Drop Table #Tab_Dif

Set NoCount On;   

-- Consulta do Estoque Geral ---

Select 
	 Getdate()								As 'PesqDataHora'
	,(Year(GetDate())*100)+Month(GetDate()) As 'PesqMesAno'
	,Year(GetDate())						As 'PesqAno'
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
	,UD.Descr_udt							As 'UnidConfrontacao'
	,UP.Vendido_unid						As 'UnidStatusCod'
	,Case 
		When UP.Vendido_unid = 0  Then 'Disponível   '
		When UP.Vendido_unid = 1  Then IIF(UD.TipoContrato_udt In (1,2,5),'Locada       ','Vendida      ')
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
	,UD.NumBrrLogBrr_udt
	,UD.NumLogrLogBrr_udt 
	,EL.Desc_Logr							As 'ProdEndLogradouro' 
	,UD.NumEnd_udt							As 'ProdEndNum' 
	,UD.ComplEnd_udt						As 'ProdEndCompl' 
	,EL.CEP_Logr							As 'ProdEndCEP'
	,EB.Desc_brr							As 'ProdEndBairro'
	,EC.Desc_cid							As 'ProdEndCidade' 
	,EC.DescUF_cid							As 'ProdEndUF'
	,V.Num_Ven								As 'VendaNumero' 
	,V.Data_Ven								As 'VendaData' 
	,V.Cliente_Ven							As 'ClienteCodigo' 
	,C.nome_pes								As 'ClienteNome'

--	   ,UDoP.cod_pes As 'UnidINTERVENIENTE_DepositarioCodigo' ,UDoP.nome_pes As 'UnidINTERVENIENTE_DepositarioNome' 
	--,UPrs.*
	--,UDo.*

	   Into #Tb_Estoque

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

	--Left Join REBUAUPRD01.dbo.UnidadeDepositario UDo With (NoLock) 
	--on UDo.Empresa_und = UP.Empresa_unid and UDo.Prod_und = UP.Prod_unid and UDo.NumPer_und = UP.NumPer_unid

	   Left Join REBUAUPRD01_COMPLEMENTO.dbo.VwREBr_UAU_UnidadeDepositarios UDo With (NoLock) 
			On UDo.Empresa = UP.Empresa_unid
	   And UDo.Produto = UP.Prod_unid 
	   And UDo.Personalizacao = UP.NumPer_unid

	--Left Join REBUAUPRD01.dbo.Pessoas UDoP With (NoLock) 
	--on UDoP.cod_pes = UDo.CodPes_und
	   
	   Left Join REBUAUPRD01_COMPLEMENTO.dbo.VwREBr_UAU_UnidadeProprietarios UPrs With (NoLock) 
			On UPrs.Empresa = UP.Empresa_unid
	   And UPrs.Produto = UP.Prod_unid and UPrs.Personalizacao = UP.NumPer_unid

	   Left Join REBUAUPRD01_COMPLEMENTO.dbo.FIDC_DePara DP With (NoLock) 
			On DP.Empreendimento_fidcdp = p.Descricao_psc

		-- left Join REBUAUPRD01.dbo.HistStatusPerson HSU With (NoLock) 
		--on HSU.Empresa_hst = UP.Empresa_unid 
		--and HSU.NumProd_hst = UP.Prod_unid 
		--and HSU.NumPer_hst = UP.NumPer_unid

 Where (UP.Empresa_unid 
		between 30000 And 39999 
		 Or UP.Empresa_unid = 20000 
		 And UP.Prod_unid > 9999)

		--And UP.Vendido_unid  =  0
		/*and UP.Empresa_unid not in (30030)*/ 
		-- and UP.Obra_unid /*like '2S08%' */in ('2S18A','2S18B','3S18A','3S18B','3S36A')
		--and UDo.Empresa is null
		--and UD.Descr_udt is NULL
		--and UD.NumBrrLogBrr_udt = 57111
		--and UP.Prod_unid in (10084,20084)
		-- order by UP.Empresa_unid ,UP.Obra_unid ,UP.Identificador_unid

Order By P.Descricao_psc ,UP.Identificador_unid

-- Comparativo entre estoque geral e endereco dos DadosEmpreendimentos ---
--Obs.: Validação final feita e Excel...

Select Distinct

	e.ID_Projeto, 
	Lower(e.Bairro)							As Bairro , 
	Lower([REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_Remove_Acentuacao](t.ProdEndBairro)) As ProdEndBairro, 
	Replace(Replace(e.CEP,'-',''),'.','')	As CEP, 
	Rtrim(Ltrim(t.ProdEndCEP))				As ProdEndCEP, 
	Lower(e.UF)								As UF, 
	Lower(t.ProdEndUF)						As ProdEndUF,
	Lower(e.Municipio)						As Municipio, 
	Lower(t.ProdEndCidade)					As ProdEndCidade,
	Lower(Case 
			When e.Tipo_Logr  =  'AV'	Then 'Avenida ' + e.Endereço
			When e.Tipo_Logr  =  'R'	Then 'Rua '		+ e.Endereço
			When e.Tipo_Logr  =  'Q'	Then 'Quadra '	+ e.Endereço
			When e.Tipo_Logr  =  'EST'	Then 'Estrada '+ e.Endereço
			When e.Tipo_Logr  =  'ROD'	Then 'Rodovia '+ e.Endereço
			When e.Tipo_Logr  =  'FAZ'	Then 'Fazenda '+ e.Endereço
	Else
		''
	End)									As 'Endereco' , 
	Lower([REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_Remove_Acentuacao](t.ProdEndLogradouro)) As ProdEndLogradouro,
	Lower(e.Numero)							As Numero, 
	Lower(t.ProdEndNum)						As ProdEndNum

Into #Tab_Dif

From  [REBUAUPRD01_COMPLEMENTO].[dbo].[DadosEmpreendimentos_201910] e
Inner Join #Tb_Estoque t
			On t.ProdProjeto  =  e.ID_Projeto 
Where Not Exists (Select 1 From #Tb_Estoque te 
					Where 
					te.ProdProjeto  =  e.ID_Projeto
						--And lower(te.ProdEndBairro)  =  lower(e.Bairro)												
						And Replace(Replace(te.ProdEndCEP,'-',''),'.','')  =  Replace(Replace(e.CEP,'-',''),'.','')						
						And Lower(te.ProdEndCidade)  =  Lower(e.Municipio)
						And Lower(te.ProdEndLogradouro)  =  Lower(Case 
														When e.Tipo_Logr  =  'AV'  Then 'Avenida ' + [REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_Remove_Acentuacao](e.Endereço)
														When e.Tipo_Logr  =  'R'   Then 'Rua '	   + [REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_Remove_Acentuacao](e.Endereço)
														When e.Tipo_Logr  =  'Q'   Then 'Quadra '  + [REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_Remove_Acentuacao](e.Endereço)
														When e.Tipo_Logr  =  'EST' Then 'Estrada ' + [REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_Remove_Acentuacao](e.Endereço)
														When e.Tipo_Logr  =  'ROD' Then 'Rodovia ' + [REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_Remove_Acentuacao](e.Endereço)
														When e.Tipo_Logr  =  'FAZ' Then 'Fazenda ' + [REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_Remove_Acentuacao](e.Endereço)
													Else
													 ''
													End)
						--And te.ProdEndNum  =  e.Numero
						--And te.ProdEndComplemento  =  e.Numero
						And Lower(te.ProdEndUF)  =  Lower(e.UF)
						)
				

Select * From #Tab_Dif f

If Object_Id('tempdb..#Tb_Estoque') Is Not Null Drop Table #Tb_Estoque
If Object_Id('tempdb..#Tab_Dif')	Is Not Null Drop Table #Tab_Dif

/*
Use [REBUAUTST01];

Set NoCount On;   

Declare  @Id Int
Set @Id  =  (SELECT MAX(NumProd_psc) FROM [dbo].PrdSrv);

-- Inserção Tabela dbo.[PrdSrv]

INSERT INTO [dbo].[PrdSrv]
           ([NumProd_psc]
           ,[Descricao_psc]
           ,[Unidade_psc]
           ,[TabPer_psc]
           ,[Status_psc]
           ,[UsrCad_psc]
           ,[AtInat_psc]
           ,[Obs_psc]
           ,[Anexos_psc]
           ,[NCM_psc]
           ,[TipoUnidade_psc]
           ,[NumApi_psc]
           ,[Atividade_psc]
           ,[CEST_psc]
           ,[NumCsf_psc])
		 

Select
	Row_Number() Over(Order By Nome_Real_do_Empreendimento) + @Id  As NumProd_psc
	,P.Nome_Real_do_Empreendimento	 As [Descricao_psc]
	,'un'		As [Unidade_psc]
	,NULL		As [TabPer_psc]
	,1			As [Status_psc]
	,'psTalent'	As [UsrCad_psc]
	,0			As [AtInat_psc]
	,''			As [Obs_psc]
	,NULL		As [Anexos_psc]
	,NULL		As [NCM_psc]
	,02			As [TipoUnidade_psc]
	,2			As [NumApi_psc]
	,1			As [Atividade_psc]
	,NULL		As [CEST_psc]
	,NULL			As [NumCsf_psc]

From [REBUAUPRD01_COMPLEMENTO].[dbo].[DadosEmpreendimentos_201910] P

Where Not Exists(Select 1 From [dbo].[PrdSrv] pr With(NoLock) Where pr.Descricao_psc  =  p.Nome_Real_do_Empreendimento)
And P.Nome_Real_do_Empreendimento Is Not Null

*/

-- ,DP.Projeto_fidcdp		As 'ProdProjeto' -- Id_PROJETO

/*
Select * From dbo.Logradouro EL where el.Num_logr  =  2599050
select  * From dbo.LogBairro el where el.NumLogr_logBrr  =  2599050 
select * From dbo.UnidadeDetalhe ud WHERE UD.NumBrrLogBrr_udt  =  2599050
OR NumBrrLogBrr_udt  =  2599050

	On EBL.NumBrr_logBrr  =  UD.NumBrrLogBrr_udt
			And EBL.NumLogr_logBrr  =  UD.NumLogrLogBrr_udt

			LogBairro


where el.Num_logr between 2599050 And 2599089
*/
--dbo.Bairro EB
--dbo.Cidades EC
--dbo.UnidadeDetalhe UD


--And t.ProdEndBairro <> '..'

--'14800700'	'14800700'


-- =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  Select ----
/*select * From #Tb_Estoque t
where t.ProdProjeto Not In(SELECT ID_Projeto fROM [REBUAUPRD01_COMPLEMENTO].[dbo].[DadosEmpreendimentos_201910])*/


/*
select From  [REBUAUPRD01_COMPLEMENTO].[dbo].[DadosEmpreendimentos_201910]
 where spe is null
where ID_Projeto  =  'P0056-B'
*/

