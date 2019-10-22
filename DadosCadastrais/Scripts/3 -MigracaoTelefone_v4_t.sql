--================================================================================================
-- Validar se as Tabelas estão setadas para a BASE DE TESTE: [REBUAUTST01]
-- TABELA DE PRODUÇÃO: REBUAUPRD01
--===============================================================================================

--Desenvolvido Por : Vitor Ramos | Data: 09/10/2019

SET NOEXEC OFF;

USE [REBUAUPRD01];

IF OBJECT_ID('tempdb..#Tb_Repetidas') IS NOT NULL DROP TABLE #Tb_Repetidas

BEGIN TRANSACTION
GO

	GO
	If @@error != 0 set noexec on;
	
	 ------------ Dados de Teste ..........
	
	Print('Carrega Dados de Teste')
	
	DECLARE @CodeTestes TABLE
	(
		id int IDENTITY(1,1),  
		codigo int
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
	
	--Retira repetidos acima de 6 vezes na base................
	
	Declare @NumRepet Int = 3
			
		Select

			ddd_tel As Fone,
			fone_tel As DDD, 
			Count(Concat(ddd_tel,fone_tel)) As Qtd

		Into #Tb_Repetidas
			From [dbo].[PesTel]
		
		Group By
			ddd_tel, 
			fone_tel
		Having Count(Concat(ddd_tel,fone_tel)) > @NumRepet
	
		Union
	
		Select  
			[Area_Code] As Fone, 
			Phone_Number As DDD, 
			Count(Concat([Area_Code],[Phone_Number])) As Qtd 
			From [REBUAUPRD01_COMPLEMENTO].[dbo].[DadosClientes_201909_TELEFONE] With (NoLock)
		
		Group By
			[Area_Code], 
			Phone_Number 
		Having Count(Concat([Area_Code],[Phone_Number])) > @NumRepet
		
	Print('Coleta Telefones Repetidos Mais de ' + Cast(@NumRepet As Varchar(4)) + ' Vezes')



		
	------------- Inserção de Novos Tefones Por Cliente --------------- 
	
	Insert into [dbo].[PesTel] (pes_tel, fone_tel, ddd_tel, ram_tel, tipo_tel)
	
	Select 
			 		
		 Base.pes_tel
		,Base.fone_tel
		,Base.ddd_tel
		,Base.ram_tel
		,Base.tipo_tel		
					
	From (Select 								
				 p.cod_pes As pes_tel
				,LTrim(Rtrim(NovoT.[Phone_Number])) As fone_tel
				,LTrim(RTrim(NovoT.[Area_Code]))	As ddd_tel
				,'' As ram_tel
				,Case
					When NovoT.[Phone_Type] = 'Residential' Then 0
					When NovoT.[Phone_Type] = 'Business'	Then 1
					When NovoT.[Phone_Type] = 'Mobile'		Then 2
					When NovoT.[Phone_Type] = 'Fax'			Then 4
					When NovoT.[Phone_Type] = 'Unknown'		Then 7
				Else
						7
				End As tipo_tel
				,Row_Number() Over(Partition By  Concat(p.cod_pes, NovoT.[Area_Code],NovoT.[Phone_Number])
					Order By Concat(p.cod_pes, NovoT.[Area_Code],NovoT.[Phone_Number]) Desc) As Unic
			
			From [REBUAUPRD01_COMPLEMENTO].[dbo].[DadosClientes_201909_TELEFONE] As NovoT With (NoLock)
	
					--Base de Testes ...
	
				Inner Join [dbo].[Pessoas] p With (NoLock) 
					On [REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_RetornaCpfCnpj] (NovoT.[Identity _Number_CPF]) 
					= [REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_RetornaCpfCnpj] (p.cpf_pes)						
						--Retira Numeros Repetidos
					Where Concat(NovoT.[Area_Code],NovoT.[Phone_Number]) Not In(Select Concat(Fone,DDD) From #Tb_Repetidas)
					And
					-- Filtro numeros de Testes
					p.cod_pes In (Select codigo From @CodeTestes)
					And
	
					--Filtra Telefones por Clientes que não existam Na Base de Dados .....
									
					Not Exists(Select 1 from [dbo].[PesTel] As AntigoT With (NoLock)
					--Verifica se o Telefone Não Existe por Pessoa...
								Where RTrim(LTrim(NovoT.[Area_Code]))	=	Rtrim(Ltrim(AntigoT.ddd_tel))
								And Rtrim(LTrim(NovoT.[Phone_Number]))  =	Rtrim(LTrim(AntigoT.fone_tel))
								And Rtrim(LTrim(p.[cod_pes]))			=	Rtrim(LTrim(AntigoT.pes_tel))
															
							  )
			) As Base	
	
	--Tira as Duplicidades dos Telefones...
	Where Base.Unic = 1
	
	Print('Inserção de Novos Tefones Por Cliente')

	
Declare @finished BIT;
Set @Finished = 1;
	
Set Noexec Off;
	
If @Finished = 1
Begin
	Print 'Commit Transaction'
	Commit Transaction
	IF OBJECT_ID('tempdb..#Tb_Repetidas') IS NOT NULL DROP TABLE #Tb_Repetidas
End
Else
Begin
	Print 'errors occured. rollback transaction'
	Rollback Transaction
End
	
	
	-- Quantidade de Linhas Antes do insert Total: 29146
	-- Obs.: Dados do Banco de Produção
	
	-- Select count(*) From [dbo].[PesTel] p
	-- Quantidade de Linhas Base Testes Depois do Insert: 61769
	
	
	-- Select count(*) From [dbo].[PesTel] p
	-- Quantidade de Linhas Base Produção: 32618
	