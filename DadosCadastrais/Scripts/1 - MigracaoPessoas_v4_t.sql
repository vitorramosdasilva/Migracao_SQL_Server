--================================================================================================
-- Validar se as Tabelas estão setadas para a BASE DE TESTE: [REBUAUTST01]
-- TABELA DE PRODUÇÃO: REBUAUPRD01
--===============================================================================================

--Desenvolvido Por : Vitor Ramos | Data: 09/10/2019 16:06:00


IF OBJECT_ID('tempdb..#Tb_Pessoa')			IS NOT NULL DROP TABLE #Tb_Pessoa
IF OBJECT_ID('tempdb..#Tb_Pessoa2')			IS NOT NULL DROP TABLE #Tb_Pessoa2
IF OBJECT_ID('tempdb..#Tb_Email')			IS NOT NULL DROP TABLE #Tb_Email
IF OBJECT_ID('tempdb..#Tb_Td_Pessoas')		IS NOT NULL DROP TABLE #Tb_Td_Pessoas
IF OBJECT_ID('tempdb..#Tb_Repetidas')		IS NOT NULL DROP TABLE #Tb_Repetidas

Use [REBUAUTST01];

BEGIN TRANSACTION

------------ Dados de Teste ..........
	
	Print('Carrega Dados de Teste')
	
	DeclaRE @CodeTestes Table
	(
		Id Int IDENTITY(1,1),  
		codigo int,
		Cpf Varchar(20)
	)
	
	Insert @CodeTestes(Cpf) 
	Values
	('01777115582'),
	('03097664513'),
	('02264313390'),
	('04512398902'),
	('32216294861'),
	('02008057380'),
	('60004633326');
	

	
--====================================  Removendo duplicidade e unindo todas as pessoas

Select * 
	Into #Tb_Pessoa
	From (Select 
			Base.*
			,Row_Number() Over(Partition By  Base.Cpf Order By Base.[DataCriacao] Desc) As Unic		
					
			-- Mais recente pelo cpf e data criação ......... 
 
				From (Select 
						e.[Customer Name]				As NomePessoa , 
						[REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_RetornaCpfCnpj](e.[Identity Number (CPF)]) As Cpf, 
							e.[Email Creation Date]		As DataCriacao, 
							e.Empreendimento			As NomeFantasia 
					From [REBUAUPRD01_COMPLEMENTO].[dbo].[DadosClientes_201909_EMAIL] e With (NoLock)
													
						Union

						Select 
						en.[Customer Name]				As NomePessoa ,
						[REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_RetornaCpfCnpj](en.[Identity Number (CPF)]) As Cpf, 
						en.[Address Creation Date]		As DataCriacao, 
						en.Empreendimento				As NomeFantasia 
					From [REBUAUPRD01_COMPLEMENTO].[dbo].[DadosClientes_201909_ENDERECO] en With (NoLock)
								
						Union

						Select 
								t.Customer_Name			 As NomePessoa ,
								[REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_RetornaCpfCnpj](t.[Identity _Number_CPF]) As Cpf, 
								t.[Phone_Creation_ Date] As DataCriacao, 
								t.Empreendimento		 As NomeFantasia 
					From [REBUAUPRD01_COMPLEMENTO].[dbo].[DadosClientes_201909_TELEFONE] t With (NoLock)	
					) As Base
					Where Base.Cpf In (Select Cpf From @CodeTestes)
					
		) Base2
											
	Where Base2.Unic = 1

---------------------- Pego a Data mais antiga ----------------------------

Select * 
	Into #Tb_Pessoa2
	From (Select 
			Base.*
			,Row_Number() Over(Partition By  Base.Cpf Order By Base.[DataCriacao] Asc) As Unic		
					
			-- Mais recente pelo cpf e data criação ......... 
 
				From (Select 
						[REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_RetornaCpfCnpj](e.[Identity Number (CPF)]) As Cpf, 
						e.[Email Creation Date]		    As DataCriacao						
					From [REBUAUPRD01_COMPLEMENTO].[dbo].[DadosClientes_201909_EMAIL] e With (NoLock)
								
						Union

						Select 						
						[REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_RetornaCpfCnpj](en.[Identity Number (CPF)]) As Cpf, 
						en.[Address Creation Date]		As DataCriacao						
					From [REBUAUPRD01_COMPLEMENTO].[dbo].[DadosClientes_201909_ENDERECO] en With (NoLock)
								
						Union

						Select 								
								[REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_RetornaCpfCnpj](t.[Identity _Number_CPF]) As Cpf, 
								t.[Phone_Creation_ Date] As DataCriacao								
					From [REBUAUPRD01_COMPLEMENTO].[dbo].[DadosClientes_201909_TELEFONE] t With (NoLock)	
					) As Base
					Where Base.Cpf In (Select Cpf From @CodeTestes)
		) As Base2

Where Base2.Unic = 1
										
Print('Removendo Duplicidade e Unindo Todas as Pessoas')

--==========================================	Atualizo com data de criacao mais antiga ...

	Update p
	Set p.DataCriacao = pp.DataCriacao
	From #Tb_Pessoa p
	Inner Join #Tb_Pessoa2 pp
	On p.Cpf = pp.Cpf



--==========================================   Retira Emails Repetidos Acima de 6 Vezes na Base...

Declare @NumRepet Int = 3 
		
	Select
	  
		Email_pes As Email		
	   ,Count(p.Email_pes) As Qtd

	Into #Tb_Repetidas
		From [dbo].[Pessoas] p
			
	Group By
		p.Email_pes
	Having Count(p.Email_pes) >= @NumRepet

	Union

	Select
	  
		 E.Email 	
		,Count(E.Email) As Qtd 
		From [REBUAUPRD01_COMPLEMENTO].[dbo].[DadosClientes_201909_EMAIL] As E
	
	Group By
		E.Email 
	Having Count(Email) > @NumRepet

	Insert #Tb_Repetidas(Email,Qtd) Values('teste@teste.com.br', 1);	
	
Print('Retira Emails Repetidos Acima de 6 Vezes na Base')
	
--========================================================================================  Removendo duplicidade

Select 
	* 
	Into #Tb_Email
	From (Select
				[REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_RetornaCpfCnpj](em.[Identity Number (CPF)]) As Cpf 
				,em.[Email Creation Date] As DataCriacao
				,em.Email
				,Row_Number() Over(Partition By  em.[Identity Number (CPF)] Order By em.[Email Creation Date] Desc) As Unic
				From [REBUAUPRD01_COMPLEMENTO].[dbo].[DadosClientes_201909_EMAIL] em With (NoLock)	
				Where 
				em.Email Not In (Select Email From #Tb_Repetidas)
				And [REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_RetornaCpfCnpj](em.[Identity Number (CPF)]) 
				In (Select Cpf From @CodeTestes) 
		 ) As Base
	
	Where Base.Unic = 1

Print('Removendo Duplicidade')

--=====================================================================================  Obtendo todos os dados da Pessoa
	
Select
	 
	p.Cpf, 
	p.DataCriacao,
	p.NomeFantasia, 
	e.Email,
	p.NomePessoa

Into #Tb_Td_Pessoas

From #Tb_Pessoa p
Inner Join #Tb_Email e With (NoLock)	
On p.Cpf = e.Cpf
	
-- Validação com um cliente	 
--Where p.Cpf = '00966524110'
--Order By 1
	
--================================================- Declare de Variaveis representando cada coluna da tabela --================================================-

Declare
 
	 @cod_pes int
	,@nome_pes varchar(150) -- Customer_Name mais antigo email data cadastro
	,@tipo_pes tinyint -- = 0
	,@cpf_pes varchar(14)
	,@dtcad_pes datetime
	,@dtnasc_pes datetime
	,@IntExt_pes tinyint = 0
	,@UsrCad_pes varchar(8)
	,@UsrAlt_pes varchar(8)
	,@Status_pes tinyint = 0
	,@Tratamento_pes varchar(50)
	,@SiglaObr_pes varchar(5)
	,@Email_pes varchar(400)
	,@EndWWW_pes varchar(255)
	,@Matricula_Pes  varchar(15) = Null
	,@Empreendimento_Ppes varchar(50)
	,@ForCli_Ppes varchar(50)
	,@Aval_Prod_Serv_Ppes varchar(50)
	,@Atd_Entrega_Ppes varchar(50)
	,@AtInat_pes tinyint  = 0 --not null
	,@DataAlt_pes datetime
	,@NomeFant_Pes varchar(150)
	,@Anexos_pes tinyint
	,@InscrMunic_pes varchar(30)
	,@inscrest_pes varchar(30)
	,@SiglaEmp_pes varchar(30)
	,@Login_pes varchar(30)
	,@Senha_pes varchar(15)
	,@CNAE_pes varchar(8) = NULL -- ALTER TABLE [dbo].[Pessoas]  WITH NOCHECK ADD  CONSTRAINT [FK_Pessoas_AtividadeEconomica] FOREIGN KEY([CNAE_pes]) REFERENCES [dbo].[AtividadeEconomica] ([Codigo_aec])
	,@DataCadPortal_pes datetime
	,@CadastradoPrefeituraGyn_pes bit = 0 --not null
	,@EmailFinanceiro_PPes varchar(50)
	,@HabilitadoRiscoSacado_pes bit  = 0 --not null
	,@CEI_Pes varchar(12)
	,@Qtd_Linhas Int = -1

Print('Declare de Variaveis Representando Cada Coluna da Tabela')
	
--================================================-     Declare a cursor	--================================================-

Declare Insert_Cursor Cursor Fast_Forward FOR
		
	Select 	-- top(1)	
		NovoT.NomePessoa					As nome_pes,
		IIF(LEN(NovoT.Cpf) <= 11,0,1)		As tipo_pes,					
		[REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_RetornaCpfCnpj](NovoT.Cpf) As cpf_pes,
		NovoT.DataCriacao					As dtcad_pes,
		NULL								As dtnasc_pes,
		2									As IntExt_pes,			--'Indica se cliente é 1-interno ou 2-externo'
		'psTALENT'							As UsrCad_pes,
		'psTALENT'							As UsrAlt_pes,
		1									As Status_pes,			--'1-temporario 2-confirmado'
		''									As Tratamento_pes,
		''									As SiglaObr_pes,
		NovoT.Email							As Email_pes,
		NULL								As EndWWW_pes,
		NULL								As Matricula_Pes,
		NULL								As Empreendimento_Ppes,
		NULL								As ForCli_Ppes,
		NULL								As Aval_Prod_Serv_Ppes,
		NULL								As Atd_Entrega_Ppes,
		0									As AtInat_pes,
		Cast(getDate() As DateTime)			As DataAlt_pes,
		NULL								As NomeFant_Pes,
		1									As Anexos_pes,			--Indicar os tipos de Anexos de um registro (Pendencia, Comentario ou foto)'
		NULL								As InscrMunic_pes,
		NULL								As inscrest_pes,
		0									As SiglaEmp_pes,		--'Guardar o codigo da empresa relacionado com EmpObr'
		''									As Login_pes,
		''									As Senha_pes,
		NULL								As CNAE_pes,
		Cast(getDate() As Date)				As DataCadPortal_pes,
		0									As CadastradoPrefeituraGyn_pes,
		NULL								As EmailFinanceiro_PPes,
		0									As HabilitadoRiscoSacado_pes,
		NULL								As CEI_Pes			
		
			From #Tb_Td_Pessoas As NovoT With (NoLock)				
					
				Where					
				NovoT.Cpf In (Select Cpf From @CodeTestes)
				And
				--Base de Teste.....					

				Not Exists(Select 1 from [dbo].Pessoas  As AntigoT With (NoLock)										
									Where NovoT.Cpf = [REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_RetornaCpfCnpj](AntigoT.cpf_pes) 
													
							) 
								
				
	--================================================- Abrir o cursor and inseri cada linha nas variaveis --================================================-

	Print('Abrir Cursor ...')    
		 
		
	SET @cod_pes = (SELECT MAX(COD_PES) FROM [dbo].Pessoas);
	SET @cod_pes = @cod_pes + 1;

	OPEN Insert_Cursor FETCH NEXT FROM Insert_Cursor 
	Into 			 
		 @nome_pes				,@tipo_pes					,@cpf_pes
		,@dtcad_pes				,@dtnasc_pes				,@IntExt_pes
		,@UsrCad_pes			,@UsrAlt_pes				,@Status_pes
		,@Tratamento_pes		,@SiglaObr_pes				,@Email_pes
		,@EndWWW_pes			,@Matricula_Pes				,@Empreendimento_Ppes
		,@ForCli_Ppes			,@Aval_Prod_Serv_Ppes		,@Atd_Entrega_Ppes
		,@AtInat_pes			,@DataAlt_pes				,@NomeFant_Pes
		,@Anexos_pes			,@InscrMunic_pes			,@inscrest_pes
		,@SiglaEmp_pes			,@Login_pes					,@Senha_pes
		,@CNAE_pes				,@DataCadPortal_pes			,@CadastradoPrefeituraGyn_pes
		,@EmailFinanceiro_PPes	,@HabilitadoRiscoSacado_pes	,@CEI_Pes


	-- Valida se a ha uma nova linha

		Print('Quantida de Linhas Disponíveis: ' + Cast(@@FETCH_STATUS As Varchar(10)))       
			
		Set @Qtd_Linhas = @@FETCH_STATUS

		If @Qtd_Linhas = 0

			Begin
				Print('Temos dados para inserir')
			End			
			
		While @@FETCH_STATUS = 0			
			        
			Begin
					If @Qtd_Linhas <> -1
					Begin					
						
						SET @cod_pes = (SELECT MAX(COD_PES) FROM [dbo].Pessoas);
						SET @cod_pes = @cod_pes + 1;

						--Print('Code Pes : ' + Cast(@cod_pes As Varchar(10)))
						--Print('Cpf_pes : '  + Cast(@cpf_pes As Varchar(10)))
					--=======- Inserção no loop com os valores das variaveis para cada linha do cursor --======
							
							--------------------------   Base de Teste     ............

							--Select top(20) * From [dbo].[Pessoas]

						Insert into [dbo].[Pessoas] 
							(cod_pes,						nome_pes,				tipo_pes,
							cpf_pes,						dtcad_pes,				dtnasc_pes,
							IntExt_pes,						UsrCad_pes,				UsrAlt_pes,
							Status_pes,						Tratamento_pes,			SiglaObr_pes,
							Email_pes,						EndWWW_pes,				Matricula_Pes,
							Empreendimento_Ppes,			ForCli_Ppes,			Aval_Prod_Serv_Ppes,
							Atd_Entrega_Ppes,				AtInat_pes,				DataAlt_pes,
							NomeFant_Pes,					Anexos_pes,				InscrMunic_pes,
							inscrest_pes,					SiglaEmp_pes,			Login_pes,
							Senha_pes,						CNAE_pes,				DataCadPortal_pes,
							CadastradoPrefeituraGyn_pes,	EmailFinanceiro_PPes,	HabilitadoRiscoSacado_pes,
							CEI_Pes
							)

						Select   
							@cod_pes						,@nome_pes				,@tipo_pes
							,@cpf_pes						,@dtcad_pes				,@dtnasc_pes
							,@IntExt_pes					,@UsrCad_pes			,@UsrAlt_pes
							,@Status_pes					,@Tratamento_pes		,@SiglaObr_pes
							,@Email_pes						,@EndWWW_pes			,@Matricula_Pes
							,@Empreendimento_Ppes			,@ForCli_Ppes			,@Aval_Prod_Serv_Ppes
							,@Atd_Entrega_Ppes				,@AtInat_pes			,@DataAlt_pes
							,@NomeFant_Pes					,@Anexos_pes			,@InscrMunic_pes
							,@inscrest_pes					,@SiglaEmp_pes			,@Login_pes
							,@Senha_pes						,@CNAE_pes				,@DataCadPortal_pes
							,@CadastradoPrefeituraGyn_pes	,@EmailFinanceiro_PPes	,@HabilitadoRiscoSacado_pes
							,@CEI_Pes

							
							-- Obter a próxima linha inserida nas variaveis

							Fetch Next From Insert_Cursor Into 
							--@cod_pes
							@nome_pes						,@tipo_pes					,@cpf_pes
							,@dtcad_pes						,@dtnasc_pes				,@IntExt_pes
							,@UsrCad_pes					,@UsrAlt_pes				,@Status_pes
							,@Tratamento_pes				,@SiglaObr_pes				,@Email_pes
							,@EndWWW_pes					,@Matricula_Pes				,@Empreendimento_Ppes
							,@ForCli_Ppes					,@Aval_Prod_Serv_Ppes		,@Atd_Entrega_Ppes
							,@AtInat_pes					,@DataAlt_pes				,@NomeFant_Pes
							,@Anexos_pes					,@InscrMunic_pes			,@inscrest_pes
							,@SiglaEmp_pes					,@Login_pes					,@Senha_pes
							,@CNAE_pes						,@DataCadPortal_pes			,@CadastradoPrefeituraGyn_pes
							,@EmailFinanceiro_PPes			,@HabilitadoRiscoSacado_pes	,@CEI_Pes
					End			
			End

			If @Qtd_Linhas = 0
			Begin
				Commit Transaction
				Print('Commit Transaction Ok !!')
			End
			Else
			Begin
				Print('Sem Dados para Importar !!')
			End

	Close Insert_Cursor
	Deallocate Insert_Cursor
	

--=============================================== Atualizo Email ,Nome, Data de Alteracao, Usuario de Alteração | Condições: Email

		Update AntigoT

			Set AntigoT.Email_pes =	IIF(Lower(NovoT.Email)		Is Not Null,Lower(NovoT.Email), Lower(AntigoT.Email_pes)),
			AntigoT.nome_pes	  =	IIF(Lower(NovoT.NomePessoa) Is Not Null,Lower(NovoT.NomePessoa), Lower(AntigoT.nome_pes)),
			AntigoT.DataAlt_pes	  =	Cast(GetDate() As DateTime),
			AntigoT.UsrAlt_pes	  =	'psTALENT'
								
		From #Tb_Td_Pessoas As NovoT With (NoLock)
		Inner Join 	[dbo].[Pessoas] As AntigoT
	
		-- Validação com um cliente : 
		On  NovoT.Cpf = [REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_RetornaCpfCnpj](AntigoT.cpf_pes) 
		Where --AntigoT.Email_pes Is Null
		--And 
		Novot.Cpf In (Select Cpf From @CodeTestes)
		And Not AntigoT.DataAlt_pes > NovoT.DataCriacao	
	

GO
--========================================================================================

IF OBJECT_ID('tempdb..#Tb_Pessoa')			IS NOT NULL Drop Table #Tb_Pessoa
IF OBJECT_ID('tempdb..#Tb_Pessoa2')			IS NOT NULL Drop Table #Tb_Pessoa2
IF OBJECT_ID('tempdb..#Tb_Email')			IS NOT NULL Drop Table #Tb_Email
IF OBJECT_ID('tempdb..#Tb_Td_Pessoas')		IS NOT NULL Drop Table #Tb_Td_Pessoas
IF OBJECT_ID('tempdb..#Tb_Repetidas')		IS NOT NULL Drop Table #Tb_Repetidas


--select * from [REBUAUTST01].dbo.pessoas as pes where pes.cpf_pes = '01059820838'
-- Correção Tipo Pessoas da Tabela Pessoas .....
--Update dbo.Pessoas
--Set dbo.pessoas.tipo_pes = IIF(len(dbo.pessoas.cpf_pes) <= 11,0,1)


	--Ultimo Cpf de Teste: 0097612731

	
	/*Select * From [dbo].[Pessoas] p
	where [REBUAUPRD01_COMPLEMENTO].[dbo].Fn_RetornaCpfCnpj(p.cpf_pes) in ('00976127318','00966524110')
	
	select * from [dbo].[Pessoas] r
	Where r.cod_pes in(910863,910861)

	Select * From [dbo].[PesEndereco] p
	Where p.CodPes_pend in(910863,910861)

	Select * From [REBUAUPRD01_COMPLEMENTO].[dbo].[DadosClientes_201909_EMAIL] e
	where [REBUAUPRD01_COMPLEMENTO].[dbo].Fn_RetornaCpfCnpj(e.[Identity Number (CPF)]) = '00976127318'

	*/

	--code pes:
	--910860


/*
Select* From [dbo].[Pessoas] p
Where p.cod_pes = 111125
UNION
Select* From [dbo].[Pessoas] p
Where p.cod_pes = 910861


-- Teste com uma pessoa: CPF: 00001463152
Select* From [dbo].[Pessoas] p
Where p.cod_pes = 111125

Select* From [dbo].[Pessoas] p
Where p.cod_pes = 111125


Select* From [dbo].[Pessoas] p
where p.cpf_pes like  '%1041306369%'

*/


/*Select* From [dbo].[Pessoas] p
Where p.cpf_pes = '00001463152'
And p.Cod_pes = 106504


Select* From [dbo].[Pessoas] p
Where p.cpf_pes = '00001463152'
And p.Cod_pes = 106504


select  * from [REBUAUPRD01_COMPLEMENTO].[dbo].[DadosClientes_201909_EMAIL] As e
where [REBUAUPRD01_COMPLEMENTO].[dbo].Fn_RetornaCpfCnpj(e.[Identity Number (CPF)]) = '00001463152'

select  * from [REBUAUPRD01_COMPLEMENTO].[dbo].[DadosClientes_201909_ENDERECO] As e
where [REBUAUPRD01_COMPLEMENTO].[dbo].Fn_RetornaCpfCnpj(e.[Identity Number (CPF)]) = '00001463152'

select  * from [REBUAUPRD01_COMPLEMENTO].[dbo].[DadosClientes_201909_TELEFONE] As e
where [REBUAUPRD01_COMPLEMENTO].[dbo].Fn_RetornaCpfCnpj(e.[Identity _Number_CPF]) = '00001463152'

*/

-- Quantidade de Linhas Antes do insert Total: 65378
-- Obs.: Dados do Banco de Produção

-- Select count(*) From [dbo].[Pessoas] p
-- Quantidade de Linhas Base Testes Depois do Insert: 65581


-- Select count(*) From [dbo].[Pessoas] p
-- Quantidade de Linhas Base Produção: 65378

--Select MAX(COD_PES) From [dbo].[Pessoas]
-- Maximo Id: 910858 Tabela de Produção:


-- (203 rows affected) Inclusões de Novos Clientes

 
/*

Select * From [dbo].[Pessoas] p
where p.cod_pes >= 910859


Delete From [dbo].[Pessoas]
where cod_pes > 910859

select len('07175845502')



Dados não nulos: 

[CadastradoPrefeituraGyn_pes] [bit] NOT NULL
 
[HabilitadoRiscoSacado_pes] [bit] NOT NULL


[AtInat_pes] [tinyint] NOT NULL

*/

				

-- Validação : ----
/*

--Select Count(*) as qtd From [dbo].[Pessoas] p
--Where p.Email_pes is Null


select AntigoT.* From #Tb_Td_Pessoas As NovoT With (NoLock)
				Inner Join 	[dbo].[Pessoas] As AntigoT
				On  NovoT.Cpf = [REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_RetornaCpfCnpj](AntigoT.cpf_pes) 
				--Where AntigoT.Email_pes Is Null
				Order By 1

*/


--Select * From [dbo].Pessoas 
/*
	DeclaRE @CodeTestes Table
	(
		Id Int IDENTITY(1,1),  
		codigo int,
		Cpf Varchar(20)
	)
	
	Insert @CodeTestes(Cpf) 
	Values
	('01777115582'),
	('03097664513'),
	('02264313390'),
	('04512398902'),
	('32216294861'),
	('02008057380'),
	('60004633326');

select * From [dbo].Pessoas AntigoT
Where [REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_RetornaCpfCnpj](cpf_pes) in (Select cpf From @CodeTestes)*/

--Select * From  #Tb_Pessoa2

/*Select  Novot.Cpf,  AntigoT.DataAlt_pes As DataAntiga,Novot.DataCriacao As DataNova, IIF(AntigoT.DataAlt_pes > NovoT.DataCriacao,'Deleto','Altero')  From #Tb_Pessoa	NovoT
	Inner Join [dbo].Pessoas AntigoT
	On [REBUAUPRD01_COMPLEMENTO].[dbo].[Fn_RetornaCpfCnpj](AntigoT.cpf_pes) = NovoT.Cpf	
*/





