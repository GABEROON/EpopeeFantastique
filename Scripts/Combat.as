﻿package {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import flash.media.Sound;
	import flash.media.SoundChannel;
    import flash.geom.Point;

	public class Combat extends MovieClip {
		private var _tPersos:Array, _tMonstres:Array; // Array des 2 groupes: permettent d'accéder aux propriétés de tous les participants (PV, attaques, etc.)
		private var _tRonde:Array; // Array de la ronde d'attaque: permet d'accéder aux participants, en fonction de leur classement (vitesse)
		private var _typeCombat:String;
		private var _peutChoisir:Boolean = false;
		private var _iPerso:int = 0;
		private var _iMonstreCible:int = 0;
		private var _actionChoisie:String = "Attaque";// action sélectionnée, par défaut c'est l'attaque
		private var _messAction:String;
		private var _timerPreCombat:Timer;
		private var _delaiParParticipant:uint = 1500; //millisecondes par action
		private var _intervalCombat:uint, _intervalVictoire:uint;
		private var _attaque:Number, _defense:Number, _dommages:Number;
		private var _jeu:MovieClip;
		
		public function Combat(unTableauPersos:Array, unTypeCombat:String){
			// CONSTRUCTEUR
			_tPersos = unTableauPersos;
			_typeCombat = unTypeCombat;

			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		/******************************************************************************
		Fonction init
		******************************************************************************/		
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);

			_jeu = MovieClip(parent); // initialisation de la référence du parent

			for( var i:int = 0; i<_tPersos.length ; i++ ){
				var placePerso:MovieClip = MovieClip(getChildByName("placePerso"+i));
				var placeStats:MovieClip = MovieClip(getChildByName("placeStats"+i));
				addChild(_tPersos[i]);//ajout de l'object perso
				_tPersos[i].placerCorps(new Point(placePerso.x, placePerso.y));//ajout du MC, à la position X, Y souhaitée;
				_tPersos[i].jouerAnim("PosCombat");
				_tPersos[i].placerStats();//ajout du MC des points;
			} //for
			
			_iPerso = 0;
			_iMonstreCible = 0;

			switch (_typeCombat){
				case "CombatChef" :
					log('Combat avec le méchant chef', 2);
					creerChef();
					break;
				case "CombatSousChef1" :
					log("c'est le sous-chef 1", 2); 
					//rien de spécial n'est prévu, donc on passe par le même script que les autres combats (default):
				default :
					creerMonstres();
			} //switch

			addEventListener(Event.REMOVED_FROM_STAGE, nettoyer);
			
			//dans 1,5 seconde, on donnera le contrôle au joueur (sinon, le joueur pourrait changer le choix avant la fin de la transition)
			_timerPreCombat = new Timer(1500*_jeu.getFacteurTemps(), 1);
			_timerPreCombat.addEventListener(TimerEvent.TIMER, activerLesChoix);
			_timerPreCombat.start();
		} //init

		/******************************************************************************
		Fonction creerChef
		  Elle permet de creer le méchant Torgul
		******************************************************************************/
		private function creerChef():void {
			_tMonstres = [];
			_tMonstres.push(new MonstreChef());
			//caractéristiques:          nom, PVAct, PVMax, PMAct, PMMax, baseAtt, baseDef, baseAttMag, baseDefMag, baseVitesse, valeurXP
			_tMonstres[0].initParam("Torgul",   500,   500,   250,   250,      50,      25,         50,         50,          50,      25);
			addChild(_tMonstres[0]);//ajout de l'object monstre, afin de lui permettre d'ajouter son MC ensuite
			_tMonstres[0].placerCorps(new Point(300, 200)); //ajout du clip, à la position X, Y souhaitée;
			afficherNomsMonstres();
		} //creerChef

		/******************************************************************************
		Fonction creerMonstres
		  Elle exécute la création des monstres sur la zone de combat.
		******************************************************************************/
		private function creerMonstres():void {
			_tMonstres = [];
			var nbMonstres = Math.floor(Math.random()*100);
			//attribution du nombre de monstres selon différents pourcentages:
			if(nbMonstres<=40){nbMonstres=1;} //40% des cas
			else if(nbMonstres<=75){nbMonstres=2;} //35% des cas
			else if(nbMonstres<=95){nbMonstres=3;} //20% des cas
			else{nbMonstres=4;} //5% des cas (salut mon ami... on s'amuse, non?!)
			for( var i:int=0; i<=nbMonstres; i++ ){
				var placeMonstre:MovieClip = MovieClip(getChildByName("placeMonstre"+i));
				var choix:int = Math.floor(Math.random() * 3) + 1;
				switch (choix){
					case 1 :
						_tMonstres[i] = new MonstreKorrigan();
						//caractéristiques:            nom, PVAct, PVMax, PMAct, PMMax, baseAtt, baseDef, baseAttMag, baseDefMag, baseVitesse, valeurXP
						_tMonstres[i].initParam("Korrigan",   150,   200,    75,    75,      25,      20,         10,         10,          10,      25);
						break;
					case 2 :
						_tMonstres[i] = new MonstreBlorg();
						//caractéristiques:            nom, PVAct, PVMax, PMAct, PMMax, baseAtt, baseDef, baseAttMag, baseDefMag, baseVitesse, valeurXP
						_tMonstres[i].initParam(   "Blorg",    75,   125,     0,     0,      15,      25,         10,          5,           5,      15);
						break;
					case 3 :
						_tMonstres[i] = new MonstreTumulus();
						//caractéristiques:            nom, PVAct, PVMax, PMAct, PMMax, baseAtt, baseDef, baseAttMag, baseDefMag, baseVitesse, valeurXP
						_tMonstres[i].initParam("Tumulus",    100,   175,    50,    50,      10,      15,         30,          30,         15,      20);
						break;
				} //switch
				addChild(_tMonstres[i]);//ajout de l'object monstre, afin de lui permettre d'ajouter son MC ensuite
				_tMonstres[i].placerCorps(new Point(placeMonstre.x, placeMonstre.y));//ajout du MC, à la position X, Y souhaitée;
				_tMonstres[i].placerStats();
			} //for
			afficherNomsMonstres();
		} //creerMonstres

		/******************************************************************************
		Fonction afficherNomsMonstres
		  Elle affiche le nom des monstres présents
		  Reçoit en paramètre le texte à afficher
		******************************************************************************/
		public function afficherNomsMonstres():void {
			var nomsDesMonstres:String = "";
			// string possédant les noms des monstres pour l'afficher
			for( var i:int=0; i < _tMonstres.length; i++ ){
				//nomsDesMonstres += (_tMonstres[i].getNom()+"\n"); 
			}
			messagesRonde_txt.text = nomsDesMonstres;
		} //afficherNomsMonstres
		
		/******************************************************************************
		Fonction nettoyer
		******************************************************************************/		
		private function nettoyer(e:Event):void {
			for( var i:int = 1; i<_tPersos.length ; i++ ){ removeChild(_tPersos[i]); } //retrait des persos
			removeEventListener(Event.REMOVED_FROM_STAGE, nettoyer);
		} //nettoyer
	
		/******************************************************************************
		Fonction frappeClavierCombat
		  Elle est exécutée quand une touche du clavier est enfoncée pendant un combat.
		******************************************************************************/
		public function frappeClavierCombat(e:KeyboardEvent):void {
			if(_peutChoisir){
				switch (e.keyCode){
					case Keyboard.NUMBER_1 :
					case Keyboard.NUMPAD_1 : choisirAction(e, "Attaque"); break;
					case Keyboard.NUMBER_2 : 
					case Keyboard.NUMPAD_2 : choisirAction(e, "Magie"); break;
					case Keyboard.NUMBER_3 : 
					case Keyboard.NUMPAD_3 : choisirAction(e, "Fuite"); break;
				} //switch
			} //if
		} //frappeClavierCombat
		
		/******************************************************************************
		Fonction choisirAction
		  Elle est exécutée quand une action est choisie au clavier ou par un clic.
		******************************************************************************/
		public function choisirAction(e:Event, action:String=null):void {
			if(action==null){
				//il faut obtenir le nom du bouton:
				action = (e.target.name).slice(2); //le nom de l'action correspond au mot qui suit les lettres «bt»
				log("> l'action du bouton est: "+action, 3)
			} //if
			_actionChoisie = action;
			if(_actionChoisie == "Magie" && _tPersos[_iPerso].getPMAct()<15){return void;}
			if(_actionChoisie == "Fuite"){
				if(_typeCombat != "CombatChef"){ _jeu.finirCombat(); }
			} else {
				log("> l'action "+_actionChoisie+" doit être effectuée", 3);
				auSuivant(); 
			} //if+else
		} //choisirAction
		
		/******************************************************************************
		Fonction auSuivant
		  Elle est appelé quand le joueur a sélectionné une action pour un personnage
		  Elle place le curseur devant le personnage suivant ou déclenche la suite si c'était le dernier
		******************************************************************************/
		private function auSuivant():void {
			_tPersos[_iPerso].setAction(_actionChoisie);
			do {
				_iPerso++;
				if(_iPerso >= _tPersos.length){ break; }
				pointeur.y = _tPersos[_iPerso].getPosPerso().y+4; // le curseur est placé devant le prochain perso
				barreActions_mc.btMagie.alpha=1;
				if(_tPersos[_iPerso].getPMAct()<15)barreActions_mc.btMagie.alpha=0.15;//On set le bouton de magie transparent si le perso n'a pas assez de mana
			} while (_tPersos[_iPerso].getPVAct() == 0); //on saute au suivant si le perso est mort!
			
			if(_iPerso >= _tPersos.length){
				//tous les persos vivants ont fait leur choix, donc on passe à la prochaine étape (le classement)
				pointeur.visible = false; //on cache le pointeur
				desactiverLesChoix(); //on bloque l'activité
				messagesRonde_txt.text=""; //on vide le champ texte
				classerLesParticipants();
			} //if
		} //auSuivant
		
		/******************************************************************************
		Fonction classerLesParticipants
		  Elle construit un Array qui définit l'ordre
		  des actions des 2 clans (monstres et personnages)
		******************************************************************************/
		private function classerLesParticipants():void {
			_tRonde = [];
			//d'abord on solicite les monstres
			for( var i=0; i<_tMonstres.length; i++ ){
				_tMonstres[i].etablirVitesseRonde()
				_tRonde.push(_tMonstres[i]);
			} //for
			for( i=0; i<_tPersos.length; i++ ){
				_tPersos[i].etablirVitesseRonde()
				_tRonde.push(_tPersos[i]);
			} //for
			_tRonde.sortOn('pVitesseRonde', Array.DESCENDING | Array.NUMERIC); // tri des persos et des monstres, en fonction de leur vitesse d'attaque (les + grands nb sont plus rapides, donc tri descendant)
			
			// mécanisme de trace pour vérification:
			var txtOrdreDeRonde:String = "ORDRE: ";
			for( i=0; i<_tRonde.length; i++ ){
				txtOrdreDeRonde += _tRonde[i].getNom()+", "+_tRonde[i].pVitesseRonde+" (PV="+_tRonde[i].getPVAct()+"). ";
			} //for
			log(txtOrdreDeRonde, 2);
			
			_intervalCombat = setInterval(prochainParticipant, _delaiParParticipant*_jeu.getFacteurTemps());
		} //classerLesParticipants
		
		/******************************************************************************
		Fonction prochainParticipant
		  Elle contrôle le déroulement des combats
		******************************************************************************/
		private function prochainParticipant():void {
			log("prochainParticipant", 3);
			if(_tMonstres.length <= _iMonstreCible){
				log("il ne reste plus de monstres à tuer :-(", 3);
				clearInterval(_intervalCombat);
				victoire();
			} else {
				if(_tRonde.length == 0){
					clearInterval(_intervalCombat);
					prochaineRonde();
				} else {
					if(_tRonde[0].getType() == "Perso"){
						joueurAttaque(_tRonde[0]);
					} else {
						//c'est forcément un monstre
						monstreAttaque(_tRonde[0]);
					} //if+else
					_tRonde.splice(0, 1); //après son tour, le participant (monstre ou perso) est éliminé du Array de la ronde d'attaque
				} //if+else
			} //if+else
		} //prochainParticipant
		
		/******************************************************************************
		Fonction victoire
		  Elle permet de quitter le combat une fois tous les monstres tués
		******************************************************************************/
		public function victoire():void {
			log('Victoire du combat', 2);
			
			var nouvelOr:Number = (_tMonstres.length * Math.floor(Math.random()*10+1) * Math.floor(Math.random()*2)); // une chance sur 2 d'avoir de l'or (nb de monstres * un dé 10)
			_jeu.ajouterOr(nouvelOr);
			 
			_messAction = "Victoire!"
			if(nouvelOr >= 2){ _messAction += " Vous avez gagné "+nouvelOr+" pièces d'or.";}
			else if(nouvelOr == 1){ _messAction += " Vous avez gagné une pièce d'or.";}
			afficherEtape(_messAction);
			
			var gainXP:Number = 0;
			for( var i=0; i<_tMonstres.length; i++ ){
				gainXP += _tMonstres[i].getValeurXP();
				removeChild(_tMonstres[i]);
			} //for
			
			for( i=0; i<_tPersos.length; i++ ){ _tPersos[i].augmenterXP(gainXP); }
			
			_intervalVictoire = setInterval(apresVictoire, 2000*_jeu.getFacteurTemps());
		} //victoire
		
		/******************************************************************************
		Fonction apresVictoire
		  Elle fait les dernières étapes, après la transition
		******************************************************************************/
		private function apresVictoire():void{
			clearInterval(_intervalVictoire);
			if(_typeCombat=="CombatChef"){ _jeu.montrerAnimFinale(true); } 
			else { _jeu.finirCombat(); }
		} //apresVictoire
		
		/******************************************************************************
		Fonction prochaineRonde
		  Elle permet la préparation de la prochaine ronde du combat.
		******************************************************************************/
		public function prochaineRonde():void {
			log("C'est une nouvelle ronde...", 3); 
			
			pointeur.visible = true; //on montre le pointeur

			for( var i=0; i<_tPersos.length; i++ ){
				if(_tPersos[i].getPVAct() != 0){ _iPerso = i; break; }
			} //for
			
			pointeur.y = _tPersos[_iPerso].getPosPerso().y+4; // le curseur est place devant le perso
			afficherNomsMonstres();
			
			activerLesChoix(); //on débloque l'activité
		} //prochaineRonde
		
		/******************************************************************************
		Fonctions activerLesChoix
		  Pour permettre les choix
		******************************************************************************/
		private function activerLesChoix(e:Event=null){
			_peutChoisir = true;
			barreActions_mc.addEventListener(MouseEvent.CLICK, choisirAction);
			barreActions_mc.alpha = 1;
			if(_tPersos[_iPerso].getPMAct()<15)barreActions_mc.btMagie.alpha=0.25;
			else barreActions_mc.btMagie.alpha=1;
		} //activerLesChoix
		
		/******************************************************************************
		Fonctions desactiverLesChoix
		  Pour empêcher les choix
		******************************************************************************/
		private function desactiverLesChoix(e:Event=null){
			_peutChoisir = false;
			barreActions_mc.removeEventListener(MouseEvent.CLICK, choisirAction);
			barreActions_mc.btMagie.alpha=1;
			barreActions_mc.alpha = 0.25;
		} //desactiverLesChoix
		
		/******************************************************************************
		Fonction monstreAttaque
		  Elle est exécutée lorsqu'un monstre attaque
		  Reçoit en paramètre l'instance du monstre
		******************************************************************************/
		private function monstreAttaque(leMonstre){
			log('monstreAttaque', 3);
			var iPersoCible:int;
			if(leMonstre.getPVAct()>0){
				//identification de la victime (la cible):
				do { iPersoCible = Math.floor(Math.random()*_tPersos.length); } 
				while (_tPersos[iPersoCible].getPVAct() == 0);
					
				var choixAction:int = Math.floor(Math.random()*2); // choix aléatoire de l'action du monstre
				if(choixAction == 0){
					_attaque = leMonstre.etablirAttRonde();
					_defense = _tPersos[iPersoCible].getBaseDef();
					if(isNaN(_attaque)||isNaN(_defense)){
						log("boque important: _attaque="+_attaque+" _defense="+_defense)
					} //if
					_messAction = " attaque ";
					leMonstre.jouerAnim("Attaque");
				} else { //c'est donc la magie
					_attaque = leMonstre.etablirAttMagRonde();
					_defense = _tPersos[iPersoCible].getBaseDefMag();
					if(isNaN(_attaque)||isNaN(_defense)){
						log("boque important: _attaque="+_attaque+" _defense="+_defense)
					} //if
					_messAction = " lance un sort sur ";
					leMonstre.jouerAnim("Attaque"); //à changer pour montrer la magie
				} //if+else
				calculerDommages();
				_tPersos[iPersoCible].blesser(_dommages);
				addChild(degat_mc);
				degat_mc.x=_tPersos[iPersoCible].x-degat_mc.width/2;
				degat_mc.y=_tPersos[iPersoCible].y-degat_mc.height/2;
				degat_mc.gotoAndPlay(1);
				
				afficherEtape(leMonstre.getNom()+_messAction+_tPersos[iPersoCible].getNom()+" pour "+_dommages+" point"+((_dommages>1)?"s":"")+" de dommage.");
				var nbMorts:int = 0;
				// compteur des personnages morts
				for( var i=0; i<_tPersos.length; i++ ){
					if(_tPersos[i].getPVAct() == 0){ nbMorts++; }
				} //for
				if(nbMorts == _tPersos.length){
					clearInterval(_intervalCombat);
					_jeu.montrerAnimFinale(false);
				} //if
			} //if(leMonstre.getPVAct()>0)
		} //monstreAttaque
		
		/******************************************************************************
		Fonction joueurAttaque
		  Elle est exécutée lorsqu'un personage attaque
		  Reçoit en paramètre l'instance du personnage
		******************************************************************************/
		private function joueurAttaque(lePerso){
			log('joueurAttaque', 3);
			if(lePerso.getPVAct()>0){
				if(lePerso.getAction() == "Attaque"){
					_attaque = lePerso.etablirAttRonde();
					_defense = _tMonstres[_iMonstreCible].getBaseDef(); // _iMonstreCible correspond à l'indice du monstre ciblé dans tMonstres
					if(isNaN(_attaque)||isNaN(_defense)){
						log("boque important: _attaque="+_attaque+" _defense="+_defense)
					} //if
					calculerDommages();
					_tMonstres[_iMonstreCible].blesser(_dommages);
					_messAction = lePerso.getNom()+" fait "+_dommages+" point"+((_dommages>1)?"s":"")+" de dommage sur "+_tMonstres[_iMonstreCible].getNom()+".";
					lePerso.jouerAnim("Attaque");
					
					addChild(degat_mc);
					degat_mc.x=_tMonstres[_iMonstreCible].x-degat_mc.width/2;
					degat_mc.y=_tMonstres[_iMonstreCible].y-degat_mc.height/2;
					degat_mc.gotoAndPlay(1);
					
				} else { //c'est donc la magie
					_defense = _tMonstres[_iMonstreCible].getBaseDefMag();
					switch (lePerso.getNom()){
						case "Nova" :
						case "Fortis" :
						case "Horas" :
							_attaque = lePerso.etablirAttMagRonde(2.5);
							if(isNaN(_attaque)||isNaN(_defense)){
								log("boque important: _attaque="+_attaque+" _defense="+_defense)
							} //if
							
							trace(lePerso.getNom()+" a maintenant "+lePerso.getPMAct()+" points de magie");
							calculerDommages();
							_tMonstres[_iMonstreCible].blesser(_dommages);
							
							addChild(degat_mc);
							degat_mc.x=_tMonstres[_iMonstreCible].x-degat_mc.width/2;
							degat_mc.y=_tMonstres[_iMonstreCible].y-degat_mc.height/2;
							degat_mc.gotoAndPlay(1);
							break;
						case "Lucem" :
							_attaque = lePerso.etablirAttMagRonde(3);
							for( var i=0; i<_tPersos.length; i++ ){
								if(_tPersos[i].getPVAct()>0){
									_tPersos[i].guerir(_attaque); //applique la guérison au personnage
								} //if
								var anim:MovieClip = MovieClip(getChildByName("heal"+i+"_mc"));
								trace("L'animation trouvée est "+anim+". Son nom est "+anim.name);
								if(anim is MovieClip) trace("L'animation trouvée est un MoviClip");
								addChild(anim);
								anim.x=_tPersos[i].x-anim.width/2;
								anim.y=_tPersos[i].y-anim.height/2;
								anim.gotoAndPlay(1);
							} //for
							break;
					} //switch
					lePerso.setPMAct(lePerso.getPMAct()-15); //Enleve des points de magie
					switch (lePerso.getNom()){
						case "Spero" : 
							_messAction = lePerso.getNom()+" profère des insultes à "+_tMonstres[_iMonstreCible].getNom()+", causant "+_dommages+" point"+((_dommages>1)?"s":"")+" de dommage."; break;
						case "Nova" :
							_messAction = lePerso.getNom()+" lance une flèche enchantée sur "+_tMonstres[_iMonstreCible].getNom()+", causant "+_dommages+" point"+((_dommages>1)?"s":"")+" de dommage.";break;
						case "Lucem" :
							_messAction = lePerso.getNom()+" lance «Guérison» sur le groupe, permettant de récupérer "+_attaque+" point"+((_attaque>1)?"s":"")+".";break;
						case "Fortis" :
							_messAction = lePerso.getNom()+" lance «Boule de Feu» sur "+_tMonstres[_iMonstreCible].getNom()+", causant "+_dommages+" point"+((_dommages>1)?"s":"")+" de dommage.";break;
					} //switch
					lePerso.jouerAnim("Magie"); //à changer pour montrer la magie
					
				} //if(c'est une attaque)			
				if(_tMonstres[_iMonstreCible].getPVAct()<=0){ 
					_iMonstreCible++;// si le monstre est mort, on change de cible
				} //if
				
				lePerso.afficherStats();
				afficherEtape(_messAction);
				
			} //if(lePerso.getPVAct()>0)
		} //joueurAttaque
		
		/******************************************************************************
		Fonction afficherEtape
		  Elle affiche le texte lors des combat
		  Reçoit en paramètre le texte à afficher
		******************************************************************************/
		private function afficherEtape(message):void{
			log(" • "+message, 2);
			messagesRonde_txt.appendText(" • "+message+"\n");
		} //afficherEtape
		
		/******************************************************************************
		Fonction calculerDommages
		******************************************************************************/		
		private function calculerDommages():void{
			_dommages = Math.round(_attaque-_defense);
			if(_dommages<0){ _dommages = 0; }
		} //calculerDommages
		
		/******************************************************************************
		*******************************     GETTERS     *******************************
		******************************************************************************/
		public function getTMonstres():Array{ return _tMonstres; } //pour débogage, ne pas supprimer cette ligne!
		
	} //class
} //package