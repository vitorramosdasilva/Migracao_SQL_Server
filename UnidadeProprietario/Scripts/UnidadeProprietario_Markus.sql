Select * From (
	Select
	--BRL2.* 
	URB2.*
	From (Select 
			BRL.Empresa_unid ,
			BRL.Prod_unid ,
			BRL.Identificador_unid ,
			BRL.NumPer_unid ,
			BRLP.CodPes_unp ,
			BRLP.PorcImovel_unp
			From REBUAUPRD01.dbo.UnidadePer BRL
				Left Join REBUAUPRD01.dbo.UnidadeProprietario BRLP 
				on BRLP.Empresa_unp=BRL.Empresa_unid 
				And BRLP.Prod_unp=BRL.Prod_unid 
				And BRLP.NumPer_unp=BRL.NumPer_unid

			Where BRL.Empresa_unid>30000 
			--and BRL.Prod_unid>10000
			) BRL2
Left join (Select 
				URB.Empresa_unid ,
				URB.Prod_unid ,
				URB.Identificador_unid ,
				URB.NumPer_unid ,
				URBP.CodPes_unp ,
				URBP.PorcImovel_unp
			From REBUAUPRD01.dbo.UnidadePer URB
			Left Join REBUAUPRD01.dbo.UnidadeProprietario URBP on 
			URBP.Empresa_unp=URB.Empresa_unid 
			and URBP.Prod_unp=URB.Prod_unid 
			and URBP.NumPer_unp=URB.NumPer_unid

			Where URB.Empresa_unid<19999 
			--and URB.Prod_unid>10000
			) URB2 
						   
						   
On URB2.Prod_unid=BRL2.Prod_unid 
And URB2.Identificador_unid=BRL2.Identificador_unid
						   
) As Base
Where 
	Not Exists(Select 1 From UnidadeProprietario Up
					Where Base.Empresa_unid = Up.Empresa_unp
					And Base.Prod_unid = Up.Prod_unp
					And Base.NumPer_unid = Up.NumPer_unp
				)
