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
					addEventListener(MouseEvent.CLICK, cliquer);
					
					
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
			if(_jeu.getTObjets().length>0){
				inventaire_txt.text = "• "+_jeu.getTObjets().join("\n• ");
			} else {
				inventaire_txt.text = "(Aucun objet)";
			} //if+else
			or_txt.text = _jeu.getFortune();
		} //afficherLesObjets
		
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