package  {
    import flash.geom.Point;
	
	public class Perso extends Etre {
		private var _niveau:int; // niveau actuel du perso
		private var _XPAct:int; // points d'expériences actuels
		private var _XPSuivant:int; // points d'expériences requis pour atteindre le prochain niveau
		private var _amelioRestante:uint=30; //Nb de points pouvant être dépensées dans dans les améliorations
		private var _estPresent:Boolean; // présence dans la groupe
		private var _action:String; // l'action choisie pour ce perso
		private var _facteurAmelio:Number = 1.1; //Nombre par lequel les stats seront modifiés en montant de niveau
		
		public function Perso(){ } // CONSTRUCTEUR
		
		/******************************************************************************
		Fonction initParam
		******************************************************************************/		
		public function initParam(nom:String, PVAct:int, PVMax:int, PMAct:int, PMMax:int, baseAtt:int, baseDef:int, baseAttMag:int, baseDefMag:int, baseVitesse:int, niv:int, XPAct:int, XPSuivant:int, estPresent:Boolean){
			initParamEtre(nom, PVAct, PVMax, PMAct, PMMax, baseAtt, baseDef, baseAttMag, baseDefMag, baseVitesse, "Perso"); //transmission des paramètres au constructeur de l'Etre
			_niveau=niv;
			_XPAct=XPAct;
			_XPSuivant=XPSuivant;
			_estPresent=estPresent;
		} //initParam
		
		/******************************************************************************
		Fonction augmenterXP
		  Elle permet d'ajouter des points d'expérience au perso (s'il est vivant!)
		******************************************************************************/
		public function augmenterXP(gainXP:int):void {
			if(getPVAct()>0) {
				setXPAct(getXPAct()+gainXP);
				log(_nom + " a maintenant "+ getXPAct()+" points d'expérience", 3);
				if(getXPAct() >= getXPSuivant()){ changerNiveau();	} // si un niveau doit être passé, go!
			} //if
		} //augmenterXP
				
		/******************************************************************************
		Fonction changerNiveau
		  Elle permet de faire passer un niveau au perso
		******************************************************************************/
		public function changerNiveau():void {
			setXPAct(getXPAct() - getXPSuivant()); //on enlève les points qui serviront au changement de niveau
			setNiveau(getNiveau()+1); // on change le niveau
			setXPSuivant(getNiveau()*100); // on augmente le seuil des points pour le prochain niveau
			log(_nom + " est maintenant au niveau "+ getNiveau(), 2);
			_amelioRestante += 3;
			
			if(getXPAct() >= getXPSuivant()){ changerNiveau();	} // si un autre niveau doit être passé, on y va!
		} //changerNiveau
		
		public function ameliorer(stat:String):void{ //Note : Test et equilibrage necessaire!!!!!!!!!!!!!!!!!!!
			switch(stat){
				case "PVMax" : _PVMax = Math.round(_PVMax*_facteurAmelio);break;
				case "PMMax" : _PMMax = Math.round(_PMMax*_facteurAmelio);break;
				case "baseAtt" : _baseAtt = Math.round(_baseAtt*_facteurAmelio); break;
				case "baseDef" : _baseDef = Math.round(_baseDef*_facteurAmelio);  break; 
				case "baseAttMag" : _baseAttMag = Math.round(_baseAttMag*_facteurAmelio); break;
				case "baseDefMag" : _baseDefMag = Math.round(_baseDefMag*_facteurAmelio); break;
				case "baseVitesse" : _baseVitesse = Math.round(_baseVitesse*_facteurAmelio); break;
				default:break;
			}
			_PMAct = _PMMax;
			_PVAct = _PVMax;
			_amelioRestante--;
			
		}
		
		/******************************************************************************
		Fonction getPosPerso
		  Elle permet d'obtenir le point X, Y du perso sur la carte du tableau.
		******************************************************************************/
		public function getPosPerso():Point{ return (new Point(x, y)); }
		
		/******************************************************************************
		*******************************     GETTERS     *******************************
		******************************************************************************/
		public function getNiveau():int{ return _niveau; }
		public function getXPAct():int{ return _XPAct; }
		public function getXPSuivant():int{ return _XPSuivant; }
		public function getEstPresent():Boolean{ return _estPresent; }
		public function getAction():String{ return _action; }
		public function getAmelioRestante():int{return _amelioRestante;}
				
		/******************************************************************************
		*******************************     SETTERS     *******************************
		******************************************************************************/
		public function setNiveau(niv:int):void{ _niveau = niv; }
		public function setXPAct(XPAct:int):void{ _XPAct = XPAct; }
		public function setXPSuivant(XPSuivant:int):void{ _XPSuivant = XPSuivant; }
		public function setEstPresent(estPresent:Boolean):void{ _estPresent = estPresent; }
		public function setAction(action:String):void{ _action = action; }
				
		/******************************************************************************
		**************************** Fonctions de débogage ****************************
		******************************************************************************/
		public function superForceDebogage():void{
			_baseAtt *= 10;
			_baseAttMag *= 10;
			_baseDef *= 10;
			_baseDefMag *= 10;
			_PVAct *= 10;
			_PVMax *= 10;
			log("Super-"+_nom+" est là!", 2);
		} //superForceDebogage
		public function mauvietteDebogage():void{
			_baseAtt /= 10;
			_baseAttMag /= 10;
			_baseDef /= 10;
			_baseDefMag /= 10;
			_PVAct /= 10;
			_PVMax /= 10;
			log("Mauviette-"+_nom+" est là!", 2);
		} //mauvietteDebogage
		
	} //class
} //package