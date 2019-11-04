Use REBUAUTST01;

SET NOEXEC OFF;

BEGIN TRANSACTION; 
GO

GO
If @@Error != 0 Set NoExec On;


/*
Insert Into [dbo].[UnidadeProprietario]
           ( Empresa_unp
			,NumPer_unp
			,CodPes_unp
			,Prod_unp			 
			,PorcImovel_unp 
			,CobrarCPMF_unp 
			,DataCad_unp 
			,DataVigencia_unp
			,EmpresaCalcReceita_unp
          	,NumSec_unp		 	
			,ParticipaSecuritizacao_unp
			,ParticipaCalcReceita_unp	
			,RateiaBoleto_unp
			,UsrCad_unp
			)

*/

Select distinct -- top(3)
	 Base.Empresa_unid
	,Base.NumPer_unid
	,Base.CodPes_unp
	,Base.Prod_unid			 
	,Base.PorcImovel_unid 
	,Base.CobrarCPMF_unid 
	,Base.DataCad_unid 
	,Base.DataVigencia_unid
	,Base.EmpresaCalcReceita_unid 	
	,Base.NumSec_unid		 	
	,Base.ParticipaSecuritizacao_unid		 
	,Base.ParticipaCalcReceita_unid	
	,Base.RateiaBoleto_unid 
	,Base.UsrCad_unid
	
	From ( Select 
			--BRL2.*,
			 URB2.Empresa_unid																								As  Empresa_unid
			,URB2.NumPer_unid																								As	NumPer_unid
			,IIF(URB2.CodPes_unp Is Null ,					brl2.CodPes_unp,	URB2.CodPes_unp)							As	CodPes_unp
			,URB2.Prod_unid 																								As	Prod_unid						 
			,IIF(urb2.PorcImovel_unp Is Null,				brl2.PorcImovel_unp 	,			urb2.PorcImovel_unp 	)	As	PorcImovel_unid 
			,IIF(urb2.CobrarCPMF_unp Is Null,				brl2.CobrarCPMF_unp 	,			urb2.CobrarCPMF_unp 	)	As	CobrarCPMF_unid 
			,IIF(urb2.DataCad_unp Is Null,					brl2.DataCad_unp 		,			urb2.DataCad_unp 	)		As	DataCad_unid 
			,IIF(urb2.DataVigencia_unp Is Null,				brl2.DataVigencia_unp 	,			urb2.DataVigencia_unp 	)	As	DataVigencia_unid
			,IIF(urb2.EmpresaCalcReceita_unp Is Null,		brl2.EmpresaCalcReceita_unp 	,	urb2.EmpresaCalcReceita_unp)As	EmpresaCalcReceita_unid 			
			,IIF(urb2.NumSec_unp Is Null,					brl2.NumSec_unp		,				urb2.NumSec_unp 	)		As	NumSec_unid
			,IIF(urb2.ParticipaSecuritizacao_unp Is Null,	brl2.ParticipaSecuritizacao_unp,	urb2.ParticipaSecuritizacao_unp 	)	
																															As	ParticipaSecuritizacao_unid	 
			,IIF(urb2.ParticipaCalcReceita_unp Is Null,		brl2.ParticipaCalcReceita_unp 	,	urb2.ParticipaCalcReceita_unp 	)	
																															As	ParticipaCalcReceita_unid				
			,IIF(urb2.RateiaBoleto_unp Is Null,				brl2.RateiaBoleto_unp 	,			urb2.RateiaBoleto_unp 	)	As	RateiaBoleto_unid 
			,IIF(urb2.UsrCad_unp Is Null,					brl2.UsrCad_unp		,				urb2.UsrCad_unp	)			As	UsrCad_unid
	
		From (Select

				 BRL.Empresa_unid
				,BRL.Prod_unid
				,BRL.Identificador_unid
				,BRL.NumPer_unid
				,BRLP.CodPes_unp
				,BRLP.PorcImovel_unp		
				,BRLP.CobrarCPMF_unp
				,BRLP.DataCad_unp
				,BRLP.DataVigencia_unp
				,BRLP.EmpresaCalcReceita_unp
				,BRLP.NumPer_unp
				,BRLP.NumSec_unp
				,BRLP.ParticipaCalcReceita_unp
				,BRLP.ParticipaSecuritizacao_unp
				,BRLP.RateiaBoleto_unp
				,BRLP.UsrCad_unp

				From REBUAUPRD01.dbo.UnidadePer BRL With(NoLock)
					Left Join REBUAUPRD01.dbo.UnidadeProprietario BRLP With(NoLock)
					on BRLP.Empresa_unp	=	BRL.Empresa_unid 
					And BRLP.Prod_unp	=	BRL.Prod_unid 
					And BRLP.NumPer_unp	=	BRL.NumPer_unid

				Where BRL.Empresa_unid > 30000 
				--and BRL.Prod_unid>10000
			
				) BRL2
	Left join (Select 

					 URB.Empresa_unid
					,URB.Prod_unid
					,URB.Identificador_unid
					,URB.NumPer_unid
					,URBP.CodPes_unp
					,URBP.PorcImovel_unp
					,URBP.CobrarCPMF_unp
					,URBP.DataCad_unp
					,URBP.DataVigencia_unp
					,URBP.EmpresaCalcReceita_unp
					,URBP.NumPer_unp
					,URBP.NumSec_unp
					,URBP.ParticipaCalcReceita_unp
					,URBP.ParticipaSecuritizacao_unp
					,URBP.RateiaBoleto_unp
					,URBP.UsrCad_unp

				From REBUAUPRD01.dbo.UnidadePer URB With(NoLock)
				Left Join REBUAUPRD01.dbo.UnidadeProprietario URBP With(NoLock) 
					On URBP.Empresa_unp		=	URB.Empresa_unid 
						and URBP.Prod_unp	=	URB.Prod_unid 
						and URBP.NumPer_unp	=	URB.NumPer_unid

				Where URB.Empresa_unid < 19999 
				--and URB.Prod_unid>10000
				) URB2						   
						   
	On		URB2.Prod_unid			=	BRL2.Prod_unid 
	And		URB2.Identificador_unid	=	BRL2.Identificador_unid		
	
			) As Base

Where

Base.CodPes_unp Is Not Null
	
/*
And 
Not Exists(Select 1 From UnidadeProprietario p
				Where   
				--p.CodPes_unp	= Base.CodPes_unp
				--And	
				p.Empresa_unp	= Base.Empresa_unid 
				And		p.Prod_unp		= Base.Prod_unid
				And		p.NumPer_unp	= Base.NumPer_unid)

*/


Order By 1,2,3,4 Desc

					
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


		

/*	

	Select * FROM UnidadeProprietario Pr
	Where Pr.Empresa_unp = 1
	And Pr.NumPer_unp = 2
	And Pr.CodPes_unp = 9244
	And Pr.Prod_unp = 10059	

	Select * FROM UnidadeProprietario Pr
	Where Pr.Empresa_unp = 1
	And Pr.NumPer_unp = 2
	And Pr.CodPes_unp = 40485
	And Pr.Prod_unp = 10059	

	Select * FROM UnidadeProprietario Pr
	Where Pr.Empresa_unp = 1
	And Pr.NumPer_unp = 2
	And Pr.CodPes_unp = 39622
	And Pr.Prod_unp = 10059


*/

