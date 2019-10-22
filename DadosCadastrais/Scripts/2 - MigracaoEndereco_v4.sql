--================================================================================================
-- Validar se as Tabelas estão setadas para a BASE DE TESTE: [REBUAUTST01]
-- TABELA DE PRODUÇÃO: REBUAUPRD01 
--===============================================================================================

--Desenvolvido Por : Vitor Ramos | Data: 15/10/2019 15:30

Use [REBUAUPRD01];

If Object_Id('tempdb..#Tb_Base')  Is Not Null Drop Table #Tb_Base
If Object_Id('tempdb..#Tb_Base2') Is Not Null Drop Table #Tb_Base2
If Object_Id('tempdb..#Tb_Base3') Is Not Null Drop Table #Tb_Base3	

SET NOEXEC OFF;

BEGIN TRANSACTION; 
 GO

	GO
	If @@Error != 0 Set NoExec On;

 ------------ Dados de Teste ..........

	 Declare @CodeTestes Table
	(
	  Id int Identity(1,1),  
	  Codigo Int
	)

	Insert @CodeTestes(codigo) 
	Values
	(600152),
	(80), 
	(474),
	(1173),
	(1343),
	(4345),
	(2868),
	(911030),
	(911029),
	(911028),
	(911027),
	(911026);

	Print('Carrega Dados de Teste')

	
------- Seleciono Pessoas Ordenado Pelo CPF e Maior data de Criação - (Rankeando) pelo Campo Unic

	Select 	--top(10)
		 p.cod_pes				As [CodPes_pend]
		,0						As Tipo_pend							
		,NovoT.Address			As [Endereco_pend]
		,NovoT.District			As [Bairro_pend]
		,NovoT.City				As [Cidade_pend]
		,NovoT.State			As [UF_pend]
		,NovoT.[Postal Code]	As [CEP_pend]
		,NovoT.[Address Number] As [NumEnd_pend]
		,NULL					As [ComplEndereco_pend]
		,NULL					As [ReferEnd_pend]
		,1						As [Proprio_pend]

		,NULL					As [NumCid_pend]			  
		,NULL					As [NumBrr_pend]
		,NULL					As [NumLogr_pend]						
										  
		--,C.Num_cid			As [NumCid_pend]			  
		--,Lb.[NumBrr_logBrr]	As [NumBrr_pend]
		--,Lb.[NumLogr_logBrr]	As [NumLogr_pend]

							
		,NULL					As [CodEmp_pend]
		,NULL					As [NomeEmp_pend]
		,NULL					As [TipoEndEmp_pend]
		--p.DataAlt_pes
		,Novot.[Address Creation Date]
		,Row_Number() Over(Partition By  p.cod_pes Order By p.cod_pes, Novot.[Address Creation Date] Desc) As Unic								
		--,p.cpf_pes
		--,p.UsrAlt_pes
		Into #Tb_Base

		From [REBUAUPRD01_COMPLEMENTO].[dbo].[DadosClientes_201909_ENDERECO] As NovoT WITH (NOLOCK)							
		Inner Join [dbo].[Pessoas] p WITH (NOLOCK) 
		On [REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_RetornaCpfCnpj] (NovoT.[Identity Number (CPF)])	= [REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_RetornaCpfCnpj] (p.cpf_pes)
		Where 
		--p.cod_pes in (Select codigo From @CodeTestes) 
		--And 
		NovoT.Address Is Not Null
		-- Removo Clientes com Data de Aleteração Maior que a Data de Criação dos Novos Enedereco
		And Not p.DataAlt_pes > NovoT.[Address Creation Date]
		--And Novot.[Identity Number (CPF)] = '3097664513'
		--And p.UsrAlt_pes <> 'psTalent'

		Print('Seleciono Pessoas Ordenado Pelo CPF e Maior data de Criação - (Rankeando) pelo Campo Unic')

---------  Tiro duplicados trazendo cruzando e trazendo os maiores do Ranking  ------------

	Select

		 T.[CodPes_pend]					
		,T.Endereco_Pend
		,T.Bairro_Pend
		,T.Cep_Pend				
		,T.UF_Pend
		,T.NumEnd_Pend
		,Min(T.Unic) As Unic
							
	Into #Tb_Base2

	From #Tb_Base T
	Where 
		--T.[CodPes_pend] in (Select codigo From @CodeTestes)
		--And 
		T.Endereco_Pend Is Not Null
		And T.Endereco_Pend <> 'O MESMO'

	Group By 

		 T.Endereco_Pend
		,T.Bairro_Pend
		,T.Cep_Pend		
		,T.UF_Pend
		,T.NumEnd_Pend
		,T.[CodPes_pend]

	Order By 1, 7

	Print('Tiro duplicados trazendo cruzando e trazendo os maiores do Ranking')

	
------ Tras apenas o 3 mais recentes contatos

	Select 
		* 
		Into #Tb_Base3
		From (Select	 
				t1.[CodPes_pend]
				,Row_Number() Over(Partition By t1.[CodPes_pend] Order By t1.[CodPes_pend], t1.[Address Creation Date] Desc) -1  As Tipo_pend			
				,t1.[Endereco_pend]
				,t1.[Bairro_pend]
				,t1.[Cidade_pend]
				,t1.[UF_pend]
				,t1.[CEP_pend]
				,t1.[NumEnd_pend]
				,t1.[ComplEndereco_pend]
				,t1.[ReferEnd_pend]
				,t1.[Proprio_pend] 
				,t1.[NumCid_pend]
				,t1.[NumBrr_pend]
				,t1.[NumLogr_pend]
				,t1.[CodEmp_pend]
				,t1.[NomeEmp_pend]
				,t1.[TipoEndEmp_pend]		

			From #Tb_Base t1		
				Inner Join #Tb_Base2 t2
			On t1.Unic = t2.Unic
				And t1.CodPes_pend = t2.CodPes_pend	
				Where T1.[Endereco_pend] Is Not Null	
			) As Base

		Where Base.Tipo_pend <= 2
	
	Print('Tras apenas o 3 mais recentes contatos')
	--select * From  #Tb_Base3 t
	--where 	t.CodPes_pend = 911027



GO



--======================================================== Insiro enderecos que não existem ....

Insert dbo.PesEndereco

Select t.* From #Tb_Base3 t
Where 
Not Exists   (Select 1 From PesEndereco p
				Where  p.CodPes_pend = t.CodPes_pend
				And p.Tipo_pend = t.Tipo_pend

--And Not p.DataAlt_pes > NovoT.[Address Creation Date]
)



--=============================================== Atualizo Data de Alteracao, Usuario de Alteração da Pessoas

	Update Pes

		Set Pes.DataAlt_pes	  =	Cast(GetDate() As DateTime),
			Pes.UsrAlt_pes	  =	'psTALENT'
								
	From #Tb_Base3 As Origem With (NoLock)
	Inner Join 	[dbo].[Pessoas] As Pes	With (NoLock)		
		On  Origem.CodPes_pend = Pes.cod_pes

	Inner Join dbo.PesEndereco As Destino With (NoLock)
		On Origem.CodPes_pend = Destino.CodPes_pend

	Where 
	Cast(Destino.Tipo_pend As BigInt) = Origem.Tipo_pend		
		And	Destino.Endereco_Pend	<>	Origem.Endereco_pend 
		And	Destino.Bairro_pend		<>	Origem.Bairro_pend 
		And	Destino.Cidade_pend		<>	Origem.Cidade_pend
		And	Destino.UF_pend			<>	Origem.UF_pend	   
		And	Destino.CEP_pend		<>	Origem.CEP_pend
		And	Destino.NumEnd_pend		<>	Cast(Origem.NumEnd_pend As Varchar(20))

		Print('Update dos Contatos ')


Print('Insiro pessoas que não existem no Endereço')	

------------- Merge com Update Ou Insert ---------------

----Obs.: Update: Se houve Tipo_pend <= 2 E Endereco_Pend Is Not Null

	

		MERGE 
			dbo.PesEndereco As Destino
							
		USING 

			#Tb_Base3 As Origem 
			ON Destino.CodPes_pend = Origem.CodPes_pend
 
 
		WHEN MATCHED 
				And Cast(Destino.Tipo_pend As BigInt) = Origem.Tipo_pend
				And	Destino.Endereco_Pend	<>	Origem.Endereco_pend 
				And	Destino.Bairro_pend		<>	Origem.Bairro_pend 
				And	Destino.Cidade_pend		<>	Origem.Cidade_pend
				And	Destino.UF_pend			<>	Origem.UF_pend	   
				And	Destino.CEP_pend		<>	Origem.CEP_pend
				And	Destino.NumEnd_pend		<>	Cast(Origem.NumEnd_pend As Varchar(50))
				-- Data de Alteração...
		THEN
		
			UPDATE SET

				Destino.Endereco_Pend =	Origem.Endereco_pend,
				Destino.Bairro_pend	  =	Origem.Bairro_pend,
				Destino.Cidade_pend	  =	Origem.Cidade_pend,
				Destino.UF_pend		  =	Origem.UF_pend,
				Destino.CEP_pend	  =	Origem.CEP_pend,
				Destino.NumEnd_pend   =	Cast(Origem.NumEnd_pend As Varchar(50))
			

		WHEN NOT MATCHED THEN
		
			INSERT
			VALUES(Origem.CodPes_pend ,Origem.Tipo_pend ,Origem.Endereco_pend ,Origem.Bairro_pend ,Origem.Cidade_pend ,Origem.UF_pend ,
					Origem.CEP_pend ,Origem.NumEnd_pend ,Origem.ComplEndereco_pend ,Origem.ReferEnd_pend ,Origem.Proprio_pend ,
					Origem.NumCid_pend ,Origem.NumBrr_pend ,Origem.NumLogr_pend ,Origem.CodEmp_pend ,Origem.NomeEmp_pend ,Origem.TipoEndEmp_pend);
					

Print('Merge com Update Ou Insert')



------------ Insiro o Segundo Contato ...............


	Insert dbo.PesEndereco

	Select 	 
		 t.[CodPes_pend]
		,Base.Total As Tipo_pend			
		,t.[Endereco_pend]
		,t.[Bairro_pend]
		,t.[Cidade_pend]
		,t.[UF_pend]
		,t.[CEP_pend]
		,t.[NumEnd_pend]
		,t.[ComplEndereco_pend]
		,t.[ReferEnd_pend]
		,t.[Proprio_pend] 
		,t.[NumCid_pend]
		,t.[NumBrr_pend]
		,t.[NumLogr_pend]
		,t.[CodEmp_pend]
		,t.[NomeEmp_pend]
		,t.[TipoEndEmp_pend]

	From #Tb_Base3 T

	Inner Join (Select 
					T.CodPes_pend ,
					Sum(IIF(T.CodPes_pend > 0, 1,0)) As Total 
				From dbo.PesEndereco t	
				--Where 
				--T.CodPes_pend In(Select codigo 
				--							From @CodeTestes
				--				)				
				Group By T.CodPes_pend			
				Having Sum(IIF(T.CodPes_pend > 0, 1,0)) = 1
				) As Base

	On Base.CodPes_pend = T.CodPes_pend

Print('Incluido + 1 Endereço')


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


If Object_Id('tempdb..#Tb_Base')  Is Not Null Drop Table #Tb_Base
If Object_Id('tempdb..#Tb_Base2') Is Not Null Drop Table #Tb_Base2
If Object_Id('tempdb..#Tb_Base3') Is Not Null Drop Table #Tb_Base3




/*
select * From [REBUAUTST01].dbo.PesEndereco pes 
Where pes.CodPes_pend = 474

select * From [REBUAUPRD01].dbo.Pessoas pes
Where pes.Cod_Pes = 474



select * From 
[REBUAUPRD01_COMPLEMENTO].[dbo].[DadosClientes_201909_ENDERECO] e
Where e.[Identity Number (CPF)] = '3097664513'

--Where p.CodPes_pend Is Null
Order By 1


--And p.cpf_pes like '%01777115582%'
--And p.UsrAlt_pes = 'psTalent'
	
*/



