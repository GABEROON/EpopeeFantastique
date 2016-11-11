package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.net.Socket;
	
	public class MenuInfo extends MovieClip {
		private var _tPersos:Array;
		private var _jeu:MovieClip;
		private var _scaleObjet:Number = 0.55; // Grosseur d'affichage des objets
		private var _elementHighlight:MovieClip;
		
		public function MenuInfo(tPersos) {
			// CONSTRUCTEUR
			_tPersos = tPersos;
			addEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, nettoyer);
		}
		
		/******************************************************************************
		Fonction init
		  Elle initialise les paramètres initiaux et affiche les fiches.
		******************************************************************************/
		private function init(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			_jeu = MovieClip(parent); // initialisation de la référence du parent
			afficherLesFichesPersos();
			afficherLesObjets();
			btRetourMenuInfo.addEventListener(MouseEvent.CLICK, quitterMenuInfo);
			addEventListener(MouseEvent.MOUSE_MOVE, mouseOver);
			addEventListener(MouseEvent.CLICK, cliquer);
			
		} //init
		
		/******************************************************************************
		Fonction nettoyer
		******************************************************************************/		
		private function nettoyer(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, nettoyer);
			removeEventListener(MouseEvent.CLICK, cliquer);
			// quelquechose d'autre à faire ici?
		} //nettoyer
		
		/******************************************************************************
		Fonction quitterMenuInfo
		******************************************************************************/		
		private function quitterMenuInfo(e:Event=null):void {
			btRetourMenuInfo.removeEventListener(MouseEvent.CLICK, quitterMenuInfo);
			removeEventListener(MouseEvent.MOUSE_MOVE, mouseOver);
			removeEventListener(MouseEvent.CLICK, cliquer);
			_jeu.fermerMenuInfo();	
		} //quitterMenuInfo
	
		/******************************************************************************
		Fonction afficherLesFichesPersos
		  Elle affiche une fiche pour chaque personnage avec ses «statistiques».
		******************************************************************************/
		private function afficherLesFichesPersos():void {
			for(var i:int=0; i<4; i++){
				var fiche_mc:MovieClip = MovieClip(getChildByName("fiche"+i));
				var p:Perso = _tPersos[i];
				if(i<_tPersos.length){
					log(fiche_mc, 3);
					
					fiche_mc.visible = true
					fiche_mc.identite_mc.gotoAndStop(p.getNom());
					fiche_mc.niveau_txt.text  = p.getNiveau();
					fiche_mc.PV_txt.text  = p.getPVAct()+" / "+p.getPVMax();
					fiche_mc.PM_txt.text  = p.getPMAct()+" / "+p.getPMMax();
					fiche_mc.XP_txt.text  = p.getXPAct()+" / "+p.getXPSuivant();
					fiche_mc.baseAtt_txt.text = p.getBaseAtt();
					fiche_mc.baseDef_txt.text = p.getBaseDef();
					fiche_mc.baseAttMag_txt.text = p.getBaseAttMag();
					fiche_mc.baseDefMag_txt.text = p.getBaseDefMag();
					fiche_mc.baseVitesse_txt.text = p.getBaseVitesse();
					fiche_mc.amelioRestante_txt.text = p.getAmelioRestante();
					
					if(p.getAmelioRestante()<=0){
						fiche_mc.bt_upBaseVitesse.visible = false;
						fiche_mc.bt_upBaseAtt.visible = false;
						fiche_mc.bt_upBaseDef.visible = false;
						fiche_mc.bt_upBaseAttMag.visible = false;
						fiche_mc.bt_upBaseDefMag.visible = false;
					}
					
					
				} else {
					fiche_mc.visible = false
				} //if+else
			} //for
		} //afficherLesFichesPersos<
		
		private function cliquer(e:MouseEvent):void{ //Fonction qui a pour de detecter un click sur un des boutons d'amélioration
			var c:String = e.target.parent.name;
			var i:int=parseInt(c.charAt(c.length-1));	//On retransforme le chiffre d'identification de la fiche
			var p:Perso=_tPersos[i];				//pour savoir le personnage à qui on parle
			
			switch(e.target.name){
				case "bt_upBaseVitesse":p.ameliorer("baseVitesse");break;
				case "bt_upBaseAtt":p.ameliorer("baseAtt");break;
				case "bt_upBaseDef":p.ameliorer("baseDef");break;
				case "bt_upBaseAttMag":p.ameliorer("baseAttMag");break;
				case "bt_upBaseDefMag":p.ameliorer("baseDefMag");break;
				
			}
			afficherLesFichesPersos();
		}
		
		/******************************************************************************
		Fonction afficherLesObjets
		  Elle affiche une liste des objets obtenus par les personnages.
		******************************************************************************/
		private function afficherLesObjets():void {
			var tObjets:Array = _jeu.getTObjets();
			enleverLesObjets();
			if(tObjets.length>0){
				//inventaire_txt.text = "• "+_jeu.getTObjets().join("\n• ");
				inventaire_txt.text = "";
				
				for(var i:int = 0; i<tObjets.length-1; i++){ //Note : Les valeurs en pixels sont un peu biaisées par le scale
					var o:MovieClip = _jeu.getTObjets()[i];
					o.scaleX=_scaleObjet;
					o.scaleY=_scaleObjet;
					o.scaleX/= invMenuInfo.scaleX;
					o.scaleY/= invMenuInfo.scaleY; // Pour que l'objet ne soit pas toute tordu
					invMenuInfo.addChild(o);
					o.x = o.width*Math.floor(i/2) + 10*Math.floor(i/2) + 5;
					o.y = 40;
					if(i%2==0){
						o.y+=260; 
					}
					
				}//for 
				
			} else {
				inventaire_txt.text = "(Aucun objet)";
				description_txt.text = "";
				effet_txt.text = "";
			} //if+else
			or_txt.text = _jeu.getFortune();
		} //afficherLesObjets
		
		
		private function changerHighlight(e:MouseEvent = null):void{
			//select_mc.x=_elementHighlight.x+_elementHighlight.parent.x-6;
			//select_mc.y=_elementHighlight.y+_elementHighlight.parent.y-6;
			//select_mc.width = _elementHighlight.width+12;
			//select_mc.height = _elementHighlight.height+12;
		}
		
		private function enleverLesObjets():void{
			while(invMenuInfo.numChildren>1){
				removeChildAt(numChildren-1);
			}
			
		}
		
		private function mouseOver(e:MouseEvent):void{
			var o: Class = e.target.constructor;
			if(e.target is MovieClip && (e.target.parent==invMenuInfo)){ //Si on adresse un objet dans l'inventaire
				voirInfoObjet(o);
				_elementHighlight = MovieClip(e.target);
				changerHighlight();
			}//if dans ivnentaire
		}//fonction voirInfoObjet
			

		private function voirInfoObjet(classe:Class): void { //Appelé quand on veut voir les infos reliés à un objet

			if (Magasin.tPrix[Magasin.tPrix.indexOf(classe) + 1] is int) { //Si on trouve la classe dans le tableau des prix
				description_txt.text = Magasin.tPrix[Magasin.tPrix.indexOf(classe) + 2]; //Description 
				effet_txt.text = Magasin.tPrix[Magasin.tPrix.indexOf(classe) + 3]; //Effet
				trace(Magasin.tPrix[Magasin.tPrix.indexOf(classe) + 3].search("+"));
				if(effet_txt.text.search("+")>0)effet_txt.textColor = 0x00ff00;
				else effet_txt.textColor = 0x000000;
			} else {
				description_txt.text = ""; //Description
				effet_txt.text = ""; //Description
			}//if trouvé dans t prix else
			
		}//fonction voirInfoObjet
		
		/******************************************************************************
		Fonction frappeClavierMenuInfo
		  Elle est exécutée quand une touche du clavier est enfoncée pendant l'affichage du menu.
		******************************************************************************/
		public function frappeClavierMenuInfo(e:KeyboardEvent):void {
			switch (e.keyCode) {
				case Keyboard.I :
					log("i!", 3);
				case Keyboard.ENTER :
					quitterMenuInfo();
					break;
			} //switch
		} //frappeClavierMenuInfo
		
	} //class
} //package