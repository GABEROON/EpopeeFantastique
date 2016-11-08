package {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.getDefinitionByName;

	public class Dialogue extends MovieClip {

		private var _tSequence: Array;
		private var _iEtape: uint;

		private var _memTempsFinDialogue: uint;
		private var _clipDemandeur: MovieClip;
		private var _delaiSansRepetition: uint = 4000;

		private var _REPLIQUE: uint = 0;
		private var _COMBAT: uint = 1;
		private var _OBJET: uint = 2;
		private var _EQUIPIER: uint = 3;
		private var _DISPARITION: uint = 4;
		private var _MAGASIN: uint = 5;
		private var _CHOIX: uint = 6;
		private var _QUIT: uint = 7;
		private var _BRANCHE: uint = 8;

		private var _choixHover: uint;
		private var _tBranche: Array = []; //Array contenant l'historique des embranchements

		private var _jeu: MovieClip;

		public function Dialogue() {
			// CONSTRUCTEUR
			addEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, nettoyer);
		}

		/******************************************************************************
		Fonction init
		  Elle initialise les paramètres initiaux et déclenche la première étape
		******************************************************************************/
		private function init(e: Event): void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			_jeu = MovieClip(parent); // initialisation de la référence du parent

			this.x = 4;
			this.y = 520;
		} //init

		/******************************************************************************
		Fonction nettoyer
		******************************************************************************/
		private function nettoyer(e: Event): void {
			removeEventListener(Event.REMOVED_FROM_STAGE, nettoyer);
			// quelquechose d'autre à faire ici?
		} //nettoyer

		/******************************************************************************
		Fonction declencherSiOk
		******************************************************************************/
		public function declencherSiOk(tSequence: Array, clipDemandeur: MovieClip): Boolean {
			var tempsActuel: uint = new Date().time;
			if (clipDemandeur != _clipDemandeur || (_memTempsFinDialogue + _delaiSansRepetition < tempsActuel)) {
				//Puisque ce n'est pas le même clipDemandeur ou que le délai est écoulé, on affiche!
				_iEtape = 0;
				_tSequence = tSequence;
				_clipDemandeur = clipDemandeur; //mémorisation, pour la prochaine fois
				declencherEtape();
				btSuite.addEventListener(MouseEvent.CLICK, declencherEtape);
				return true; //true indique que le dialogue débute
			} else {
				return false; //false indique que le dialogue n'aura pas lieu
			} //if+else
		} //declencherSiOk

		/******************************************************************************
		Fonction quitterDialogue
		******************************************************************************/
		private function quitterDialogue(e: Event = null): void {
			btSuite.removeEventListener(MouseEvent.CLICK, declencherEtape);

			message_txt.text = "";
			_memTempsFinDialogue = new Date().time; // notons le temps pour éviter de ravoir le même message immédiatement

			_jeu.terminerDialogue();
		} //quitterDialogue

		/******************************************************************************
		Fonction declencherEtape
		  Elle passe à la prochaine étape et affiche au besoin.
		******************************************************************************/
		private function declencherEtape(e: Event = null): void {
			if (_iEtape >= _tSequence.length) {
				quitterDialogue();
			} else {
				var tEtape = _tSequence[_iEtape]; //récupération du sous-tableau (Array) tEtape

				// Contenu de tEtape:
				// tEtape[0] = type d'étape (_REPLIQUE/_COMBAT/_OBJET/_EQUIPIER/_DISPARITION)
				// tEtape[1] = chaine réplique (_REPLIQUE) / chaine type (_COMBAT / _OBJET) / booléen cacher sur le champ (_DISPARITION) 
				// tEtape[2] = nom spécial associé à une réplique (_REPLIQUE) / nombre d'objets (_OBJET)

				var typeEtape: uint = tEtape[0];
				if (typeEtape == _QUIT) {
					quitterDialogue();
				}

				_iEtape++; //incrémentation, pour la prochaine fois
				
				//reset de l'affichage
				message_txt.text="";
				message_txt1.text="";
				message_txt2.text="";
				message_txt3.text="";
				btSuite.visible=true;

				switch (typeEtape) {
					case _REPLIQUE:
						//c'est un texte à afficher
						var txtReplique: String = tEtape[1];
						var txtNomPerso: String = ((tEtape.length > 2) ? tEtape[2] : _clipDemandeur.getNomSimple()); //le nom prévu, sinon c'est le nom du demandeur
						message_txt.text = ((txtNomPerso != "") ? txtNomPerso + " – " : "") + txtReplique; //construction de la chaine à afficher
						break;
					case _COMBAT:
						//c'est un combat a déclencher
						quitterDialogue();
						var typeCombat: String = tEtape[1];
						_jeu.amorcerCombat(typeCombat);
						break;
					case _OBJET:
						//c'est un objet a ajouter
						var typeObjet: String = tEtape[1];
						if (typeObjet == "Or") {
							var quantite: Number = ((tEtape.length > 2) ? tEtape[2] : 1); //la quantité prévue, sinon c'est 1 par défaut
							_jeu.ajouterOr(quantite); //ajouter l'or au trésor du joueur...
						} else {
							var classeObj = getDefinitionByName(typeObjet); //On va chercher la classe de l'objet rencontré
							var o: MovieClip = new classeObj(); //Et on en crée une nouvelle instance 
							_jeu.ajouterObjet(o); //Qu'on ajoute dans l'inventaire
						} //if+else
						break;
					case _EQUIPIER:
						//c'est un nouvel équipier a ajouter
						_jeu.ajouterPerso(_clipDemandeur.name); // le perso est maintenant dans l'équipe...
						break;
					case _DISPARITION:
						//il faut faire disparaître le clip (peut être un objet ou un PNJ)
						var desMaintenant: Boolean = ((tEtape.length > 2) ? tEtape[2] : true); //valeur demandée, ou «true» par défaut
						_clipDemandeur.cacher(desMaintenant); // le clip se cache et devient absent (si desMaintenant est faux, il sera absent au prochain affichage du tableau)
						break;
					case _MAGASIN:
						//c'est la rencontre d'un magasin
						var nomMagasin: String = tEtape[1];
						trace(_jeu.getTMagasins()[_jeu.getTMagasins().indexOf(nomMagasin) + 1]);
						var magasin: Magasin = _jeu.getTMagasins()[_jeu.getTMagasins().indexOf(nomMagasin) + 1];
						_jeu.addChild(magasin); //il faut faire apparaitre le magasin
						break;
					case _CHOIX:
						btSuite.visible=false;
						message_txt1.text = "1 - "+tEtape[1];
						if (tEtape[2] is String) message_txt2.text = "2 - "+tEtape[2];
						if (tEtape[3] is String) message_txt3.text = "3 - "+tEtape[3];
						addEventListener(MouseEvent.CLICK, faireUnChoix);
						addEventListener(MouseEvent.MOUSE_MOVE, choixSouris);
						break;
				} //switch

				switch (typeEtape) { //Ce switch va declencher la suite du dialogue si on n'attend pas un input du joueur
					case _REPLIQUE:
					case _CHOIX:
						break;
					default:
						declencherEtape();

				} //switch typeetape

			} //if+else principal
		} //declencherEtape

		/******************************************************************************
		Fonction frappeClavierDialogue
		  Elle est exécutée quand une touche du clavier est enfoncée pendant l'affichage du dialogue.
		******************************************************************************/
		public function frappeClavierDialogue(e: KeyboardEvent): void {
			switch (e.keyCode) {
				case Keyboard.SPACE:
				case Keyboard.ENTER:
					declencherEtape(e);
					break;
			} //switch
		} //frappeClavierDialogue

		private function faireUnChoix(e: MouseEvent): void {
			trace(e.target);
			if (e.target is TextField) {
				var s: String = e.target.name;
				var iCible: uint = parseInt(s.charAt(s.length - 1));
				
				
				for (var i: uint = _iEtape-1; i < _tSequence.length; i++) { //De combien de réplique doit on skipper la séquence ?
					var cible: Array = _tSequence[i];
					if (cible[0] == _BRANCHE && cible[1] == iCible) { //Si on cherche le choix 1 et qu'on trouve 1, on y va pour cette branche
						_iEtape=i;
						removeEventListener(MouseEvent.CLICK, faireUnChoix);
						removeEventListener(MouseEvent.MOUSE_MOVE, choixSouris);
						declencherEtape();
						return void;
					}
				}//for
			}// if is textfield
		} //fonction faireUnChoix

		private function choixSouris(e: MouseEvent): void {
			switch (e.target) {
				case message_txt1:
					_choixHover = 1;
					break;
				case message_txt2:
					_choixHover = 2;
					break;
				case message_txt3:
					_choixHover = 3;
					break;
				default:
					_choixHover=0;
					return void;
			}//switch
			updateChoix();
		} // fonction choixSouris
		
		private function updateChoix():void{
			switch(_choixHover){
				case 0:return void; // Il ne se passe rien
				case 1: 
					message_txt1.textColor = 0x75C7FF;
					message_txt2.textColor = 0x000000;
					message_txt3.textColor = 0x000000;
					break;
				case 2:
					message_txt1.textColor = 0x000000;
					message_txt2.textColor = 0x75C7FF;
					message_txt3.textColor = 0x000000;
					break;
				case 3:
					message_txt1.textColor = 0x000000;
					message_txt2.textColor = 0x000000;
					message_txt3.textColor = 0x75C7FF;
					break;
			}
		}

	} //class
} //package