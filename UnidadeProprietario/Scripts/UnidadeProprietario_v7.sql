Use [REBUAUTST01];

-- Desenvolvido Por Vitor Ramos
-- Data: 04/11/2019 14:21

If Object_Id('tempdb..#Tb_Brl')		Is Not Null Drop Table #Tb_Brl
If Object_Id('tempdb..#Tb_Urplan')	Is Not Null Drop Table #Tb_Urplan
If Object_Id('tempdb..#Tb_Tudo')	Is Not Null Drop Table #Tb_Tudo
If Object_Id('tempdb..#Tb_Nulos')	Is Not Null Drop Table #Tb_Nulos


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
	, Up.CodPes_unp
	, Up.PorcImovel_unp
	, Up.UsrCad_unp
	, Up.DataCad_unp
	, Up.CobrarCPMF_unp
	, Up.ParticipaSecuritizacao_unp
	, Up.ParticipaCalcReceita_unp
	, Up.DataVigencia_unp
	, Up.NumSec_unp
	, Up.RateiaBoleto_unp
	, Up.EmpresaCalcReceita_unp	
	,per.Obra_unid	

Into #Tb_Urplan
								 
From dbo.UnidadePer per With(NoLock)
Left Join UnidadeProprietario Up With(NoLock)

On per.Empresa_unid = Up.Empresa_unp
	And Per.Prod_unid = Up.Prod_unp
	And Per.NumPer_unid = Up.NumPer_unp

Where per.Empresa_unid < 19999
And per.Prod_unid > 9999

/*
And per.Empresa_unid = 5
And per.Prod_unid = 10041
And per.NumPer_unid = 20842
*/

Order By 1

Print('Carregada Tabela #Tb_Urplan ....')


---- Join Brl Empresa_unid > 30000

Select  
	 per.Empresa_unid 
	,per.Prod_unid 
	,per.NumPer_unid
	,per.Identificador_unid
	, Up.CodPes_unp
	, Up.[PorcImovel_unp]
	, Up.[UsrCad_unp]
	, Up.[DataCad_unp]
	, Up.[CobrarCPMF_unp]
	, Up.[ParticipaSecuritizacao_unp]
	, Up.[ParticipaCalcReceita_unp]
	, Up.[DataVigencia_unp]
	, Up.[NumSec_unp]
	, Up.[RateiaBoleto_unp]
	, Up.[EmpresaCalcReceita_unp]
	,per.Obra_unid
	
Into #Tb_Brl
								 
From dbo.UnidadePer Per With(NoLock)
Left Join UnidadeProprietario Up With(NoLock)
On Per.Empresa_unid = Up.Empresa_unp 
	And Per.Prod_unid = Up.Prod_unp
	And Per.NumPer_unid = Up.NumPer_unp
Where Per.Empresa_unid > 30000
And Per.Prod_unid > 9999

Order By 1

Print('Carregada Tabela #Tb_Brl ....')


--- Todos os casos para Inserção ....

Select distinct

	 br.Empresa_unid 
	,br.Prod_unid 
	,br.NumPer_unid
	,pl.CodPes_unp	As 'pl_Codes_unp'
  ,ps.cod_pes
  ,br.CodPes_unp
	,pl.PorcImovel_unp			As PorcImovel_unp
	,'PSTALENT'					As UsrCad_unp

	--,pl.UsrCad_unp
	--,pl.DataCad_unp

	,Cast(GetDate() As Date)	As DataCad_unp
	,0 As CobrarCPMF_unp
	,1 As ParticipaSecuritizacao_unp
	,0 As ParticipaCalcReceita_unp
	,'2016-01-07 00:00:00.743'  As DataVigencia_unp
	,NULL						As [NumSec_unp]
	,0							As [RateiaBoleto_unp]
	,NULL						As EmpresaCalcReceita_unp
	
	
	--,br.Obra_unid				As 'Obra'

	,br.Identificador_unid

  --,Row_Number() Over(Partition By  pl.CodPes_unp Order By br.Identificador_unid, br.Prod_unid  Desc) As Unic 
  	
--Into #Tb_Tudo

From #Tb_Brl br
Left Join #Tb_Urplan pl

	On	br.Identificador_unid = pl.Identificador_unid
	And br.Prod_unid		  = pl.Prod_unid

Left join Pessoas ps
	On  br.CodPes_unp = ps.cod_pes

Where ps.cod_pes Is Null
	--And pl.CodPes_unp Is Not Null
	--Where br.Prod_unid = 10041 and br.Identificador_unid = 'Q03-l21'
/*
And
Not Exists(Select 1 From UnidadeProprietario UnP
				Where					
					br.Empresa_unid		= unp.Empresa_unp				
				And br.Prod_unid		= UnP.Prod_unp				
				And br.NumPer_unid  =  UnP.NumPer_unp
				And pl.CodPes_unp = UnP.CodPes_unp
)
*/

Print('Carregada Tabela #Tb_Tudo ....')



-- Trata Os Casos Nulos ..........


Select 

	 Per.Empresa_unid
   --UP.Obra_unid
	,Per.Prod_unid
	,Per.NumPer_unid
	,Per.Identificador_unid
	,Up.CodPes_unp
	,Up.PorcImovel_unp
	,P.nome_pes as 'Proprietario'

Into #Tb_Nulos

From dbo.UnidadePer Per

	Left Join dbo.UnidadeProprietario Up 
		On  Up.Empresa_unp			=	Per.Empresa_unid 
		And Up.Prod_unp				=	Per.Prod_unid 
		And Up.NumPer_unp			=	Per.NumPer_unid   

	Left Join Pessoas p
		On p.cod_pes					=	Up.CodPes_unp
	   
 Where 
 Up.CodPes_unp			Is Null
 And Per.Empresa_unid	> 30000
 And Per.Prod_unid		> 9999

 Order By 1,2,4

 --And up.Prod_unid = 10041 and up.Identificador_unid = 'Q03-l21'

 Print('Carregada Tabela #Tb_Nulos ....')

 

-- Inserção Somente Dos Casos Nulos

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

Select distinct  --top(1)

	 Nl.Empresa_unid 
	,Nl.Prod_unid 
	,Nl.NumPer_unid
	,t.pl_Codes_unp	As 'pl_Codes_unp'
	,ps.cod_pes
	,t.PorcImovel_unp			As PorcImovel_unp
	,'PSTALENT'					As UsrCad_unp	
	,Cast(GetDate() As Date)	As DataCad_unp
	,0 As CobrarCPMF_unp
	,1 As ParticipaSecuritizacao_unp
	,0 As ParticipaCalcReceita_unp
	,'2016-01-07 00:00:00.743'  As DataVigencia_unp
	,NULL						As [NumSec_unp]
	,0							As [RateiaBoleto_unp]
	,NULL						As EmpresaCalcReceita_unp
		
  --,nl.Obra_un				As 'Obra'
  --,t.Identificador_unid
  --,Row_Number() Over(Partition By  pl.CodPes_unp Order By br.Identificador_unid, br.Prod_unid  Desc) As Unic  	
  

From #Tb_Nulos nl
Inner Join #Tb_Tudo t

	On	nl.Empresa_unid			= t.Empresa_unid
	And nl.Prod_unid			= t.Prod_unid
	And nl.NumPer_unid			= t.NumPer_unid
	And nl.Identificador_unid	= t.Identificador_unid
	

Left join Pessoas ps
	On nl.CodPes_unp = ps.cod_pes

Where
t.pl_Codes_unp Is Not Null

--ps.cod_pes	Is Null 
--And pl.CodPes_unp is Not Null
--And nl.Prod_unid = 10041 and nl.Identificador_unid = 'Q03-l21'

-- Validação FK UnidadeProprietario .....

And
Not Exists(Select 1 From UnidadeProprietario UnP
				Where					
					nl.Empresa_unid	= unp.Empresa_unp				
				And nl.Prod_unid	= UnP.Prod_unp				
				And nl.NumPer_unid  =  UnP.NumPer_unp
				And t.pl_Codes_unp  = UnP.CodPes_unp
)


Print('Insert Nulos ....')



-- Inserção Todos <>  Nulos.....


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

Select distinct

	 t.Empresa_unid 
	,t.Prod_unid 
	,t.NumPer_unid
	,t.pl_Codes_unp	As 'pl_Codes_unp'
	--,ps.cod_pes
	,t.PorcImovel_unp			As PorcImovel_unp
	,'PSTALENT'					As UsrCad_unp	
	,Cast(GetDate() As Date)	As DataCad_unp
	,0 As CobrarCPMF_unp
	,1 As ParticipaSecuritizacao_unp
	,0 As ParticipaCalcReceita_unp
	,'2016-01-07 00:00:00.743'  As DataVigencia_unp
	,NULL						As [NumSec_unp]
	,0							As [RateiaBoleto_unp]
	,NULL						As EmpresaCalcReceita_unp
	
	--,br.Obra_unid				As 'Obra'
	--,br.Identificador_unid
  --,Row_Number() Over(Partition By  pl.CodPes_unp Order By br.Identificador_unid, br.Prod_unid  Desc) As Unic  	
  
From #Tb_Tudo t

Where
t.pl_Codes_unp Is Not Null

--And t.Prod_unid = 10041 
--And t.Identificador_unid = 'Q03-l21'

-- Validação FK UnidadeProprietario .....

And
Not Exists(Select 1 From UnidadeProprietario UnP
				
				Where					
					t.Empresa_unid	= unp.Empresa_unp				
				And t.Prod_unid		= UnP.Prod_unp				
				And t.NumPer_unid   =  UnP.NumPer_unp
				--And t.Identificador_unid = unp.iden
				--And t.pl_Codes_unp  = UnP.CodPes_unp
)

Print('Insert Tudo ....')


	
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


If Object_Id('tempdb..#Tb_Brl')		Is Not Null Drop Table #Tb_Brl
If Object_Id('tempdb..#Tb_Urplan')	Is Not Null Drop Table #Tb_Urplan
If Object_Id('tempdb..#Tb_Tudo')	Is Not Null Drop Table #Tb_Tudo
If Object_Id('tempdb..#Tb_Nulos')	Is Not Null Drop Table #Tb_Nulos



--------- Validar Tudo  -----------
/*

Select
	t.Empresa_unid,
	t.Identificador_unid,
	t.Prod_unid, 
IIF(Count(Concat(t.Empresa_unid,t.Identificador_unid,t.Prod_unid)) > Count(Concat(Base.Empresa_unp, Base.Identificador_unid,Base.Prod_unp)),1,0) As Valida

From #Tb_Tudo t
Left Join (Select

			 Pro.Empresa_unp 
			,Per.Identificador_unid
			,Pro.Prod_unp

		From unidadeProprietario Pro
		Inner Join UnidadePer Per
			On  Pro.Empresa_unp		= Per.Empresa_unid
				And Pro.Prod_unp	= Per.Prod_unid
				And Pro.NumPer_unp  = Per.NumPer_unid
			) As Base

On 
	Base.Empresa_unp = t.Empresa_unid				
And	Base.Identificador_unid = t.Identificador_unid
And	Base.Prod_unp = t.Prod_unid

Where t.Prod_unid = 10059 
And t.NumPer_unid = 14
And t.Empresa_unid = 30001

Group By 
t.Empresa_unid,t.Identificador_unid,t.Prod_unid
--Having Count(Concat(t.Empresa_unid,t.Identificador_unid,t.Prod_unid)) > Count(Concat(Base.Empresa_unp, Base.Identificador_unid,Base.Prod_unp))
*/

/*
use [REBUAUTST01];
	delete  From UnidadeProprietario 
	Where 
	--DataCad_unp = '2019-11-04'
	--and 
	UsrCad_unp = 'PSTALENT'
*/

-- Replicando a consulyta do Markus ...  e mostra ok  !!!
/*

Select
	
	 per.Empresa_unid 
	,per.Obra_unid 
	,per.Prod_unid 
	,per.NumPer_unid 
	,per.Identificador_unid 
	,Prop.CodPes_unp 
	,Prop.PorcImovel_unp 
	,P.nome_pes As 'Proprietario'
	,p.cod_pes 

From UnidadePer  per

Left Join  UnidadeProprietario  Prop
On  per.Empresa_unid = prop.Empresa_unp
And	per.Prod_unid	= prop.Prod_unp
And per.NumPer_unid	= prop.NumPer_unp

Left join Pessoas p
On Prop.CodPes_unp = p.cod_pes

Where 
per.Prod_unid = 10041
And per.Empresa_unid = 30005
And per.Identificador_unid =  'Q03-L22'
And per.NumPer_unid = 182


Select * 
From UnidadeProprietario Up
Where  (Up.Empresa_unp = 30005
		and Up.Prod_unp = 10041
		and Up.NumPer_unp = 182
		)

Select * 
From UnidadeProprietario Up
Where  (Up.Empresa_unp = 30005
		and Up.Prod_unp = 10041
		and Up.NumPer_unp = 23
		)



(
 br.Empresa_unid = 30005
And br.Identificador_unid = 'Q03-L22'
And br.Prod_unid = 10041
And br.NumPer_unid = 182
)



or(

 br.Empresa_unid in (30005) --and UPr.CodPes_unp=9
 and br.Prod_unid = 10041
 and br.Identificador_unid = 'Q03-L21'
 AND br.Numper_unid = 23
 )


And
 br.Empresa_unid  = 30001 
 --and UPr.CodPes_unp=9
 And br.Prod_unid = 10059
 And br.Identificador_unid = 'QC-L17'
 And br.Numper_unid = 14

 select * From UnidadePer p 
 where p.Empresa_unid = 30001
 and p.Prod_unid = 10059
 and p.NumPer_unid = 14

 select * From UnidadeProprietario br
 Where 
  br.Empresa_unp  = 30001 
 --and UPr.CodPes_unp=9
 And br.Prod_unp = 10059
-- And br.Identificador_unp = 'QC-L17'
 And br.Numper_unp = 14
 


Select

	UP.Empresa_unid ,
	UP.Obra_unid ,
	UP.Prod_unid ,
	UP.NumPer_unid ,
	UP.Identificador_unid ,
	UPr.CodPes_unp ,
	P.cod_pes,
	UPr.PorcImovel_unp ,
	P.nome_pes as 'Proprietario'

	--Into #Tb_Nulos
	--UD.CodPes_und 
	--UD.PorcDeposito_Und 
	--D.nome_pes
	--Into #Tb_Nulos

  From REBUAUPRD01.dbo.UnidadePer UP
       Left Join REBUAUPRD01.dbo.UnidadeProprietario UPr 
	   On UPr.Empresa_unp=UP.Empresa_unid 
	   And UPr.Prod_unp=UP.Prod_unid 
	   And UPr.NumPer_unp=UP.NumPer_unid

      -- left join REBUAUPRD01.dbo.UnidadeDepositario UD 
	   --on UD.Empresa_und=UPr.Empresa_unp and UD.Prod_und=UPr.Prod_unp and UD.NumPer_und=UPr.NumPer_unp and UD.CodPesUnp_Und=UPr.CodPes_unp

       Left Join REBUAUPRD01.dbo.Pessoas P 
	   On P.cod_pes=UPr.CodPes_unp

       --left join REBUAUPRD01.dbo.Pessoas D 
	   --on D.cod_pes=UD.CodPes_und
 Where 
 UPr.CodPes_unp Is Null
 And 
 UP.Empresa_unid > 30000

 And
 
Not Exists(Select 1 From UnidadeProprietario UnP
				Where					
					up.Empresa_unid		= unp.Empresa_unp				
				And up.Prod_unid		= UnP.Prod_unp				
				And up.NumPer_unid  =  UnP.NumPer_unp
				And p.cod_pes = UnP.CodPes_unp
		  )



 --and UPr.CodPes_unp=9
 --and UPr.UsrCad_unp = 'PSTALENT'

 
 And UP.Prod_unid = 10041
 And UP.Identificador_unid = 'Q03-L22'
 And UP.NumPer_unid = 182


 Order By 
 UP.Empresa_unid ,
 UP.Prod_unid ,
 UP.Identificador_unid	
 





-- Teste ---


 

br.Empresa_unid = 32502
And	br.Prod_unid = 20088
And	br.NumPer_unid = 51
And	pl.Identificador_unid = 'Q07-L13'



br.Empresa_unid = 32502
And	br.Prod_unid = 20088
And	br.NumPer_unid = 37
And	pl.Identificador_unid = 'Q07-L04'




-- Validação das chaves PK e FK da Tabela UnidadeProprietario


br.Identificador_unid In ('Q03-L22')
And pl.NumPer_unid In (20842)
And pl.Prod_unid = 10041



Select pr.*, UNPER.Identificador_unid From UnidadeProprietario pr
iNNER jOIN UnidadePer UNPER
On pr.Empresa_unp = 30060

SELECT * FROM UnidadePer UPER
WHERE UPER.Empresa_unid = 30060
--AND UPER.Prod_unid = 31701
--AND NumPer_unid IN(39622,800)
and UPER.Identificador_unid In('QY-L16','QQ-L12','QZ-L17','QZ-L17')


	Select
 
		 prop.Empresa_unp
		,prop.CodPes_unp
		,prop.NumPer_unp
		,prop.Prod_unp
		--,Count(*) As Qtd
		,Sum(IIF(prop.CodPes_unp Is Null, 1, 0)) As Qtd

	From UnidadeProprietario prop
	Left Join UnidadePer per
	On prop.Empresa_unp = per.Empresa_unid
	And prop.Prod_unp = per.Prod_unid
	And prop.NumPer_unp = NumPer_unid
	and prop.CodPes_unp Is Null
	Where per.Empresa_unid > 30000
	and per.Prod_unid > 9999

	Group By
		prop.Empresa_unp
		,prop.CodPes_unp
		,prop.NumPer_unp
		,prop.Prod_unp 
		--Having Count(*) < 1
		Having Sum(IIF(CodPes_unp Is Null, 1, 0)) < 1

	Where 
	prop.Empresa_unp = 30005
	And per.Identificador_unid In ('Q03-L22')
	--And prop.NumPer_unp In (20842)
	And prop.Prod_unp = 10041



	





-- Teste  ---




Select 
	u.Empresa_unp,
	p.Empresa_unid,
	u.Prod_unp,
	p.Prod_unid,
	u.CodPes_unp,
	p.Identificador_unid
	
From UnidadeProprietario u
Inner Join UnidadePer p
On --u.UsrCad_unp = 'PSTALENT' 
 U.EMPRESA_UNP = 5
--And u.Prod_unp = 10041
--and u.CodPes_unp In(40488,19588,39622)


Select 
	u.*
	
From UnidadeProprietario u	
Where u.UsrCad_unp = 'PSTALENT' 
And U.EMPRESA_UNP = 30005
And u.Prod_unp = 10041
and u.CodPes_unp In(40488,19588,39622)





	Use [REBUAUTST01];
	Select * From [UnidadePer] u
	inner Join UnidadeProprietario p
	On U.Empresa_unid = P.Empresa_unP
	AND  u.Prod_unid = p.Prod_unp
	aND u.NumPer_unid = p.NumPer_unp
	Where 	
	 u.NumPer_unid = 20841
	and  u.Prod_unid = 10041

*/

