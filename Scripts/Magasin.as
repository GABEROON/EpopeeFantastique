package {

	import flash.display.Sprite;
	import flash.events.*;
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.Font;
	import flash.utils.getQualifiedClassName;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.display.SimpleButton;

	public class Magasin extends Sprite {

		private var _inventaire: Array = [new Patate(),new Patate(),new Potion(),new Potion(),new Potion(),new Potion(),new Potion(),new Potion(),new Patate(),new Potion(),new Potion(),new Potion(),new Potion(),new Potion(),]; //Array contenant la définition des objets du magasin
		private var _change: uint = 30; //Entier positif représentant le nombre d'or du marchand
		private var _tauxRachat: uint = 80; //Entier positif représentant le pourcentage du prix donné lorsque le joueur vend au marchand
		public static var tPrix: Array = [	Patate, 5, "Une vulgaire patate. Elle vous redonnera surement un peu de vigueur.", "+50 points de vie",  //Tableau contenant le prix de tous les items du jeu !!!DEFINIR LOBJET AVEC UNE CLASSE!!!
											Potion, 10, "Une étrange liqueur. Elle semble dégager une énergie étrange", "+ 50 points de mana"
										 ];
		private var _marquePourVente: Array = [];
		private var _marquePourAchat: Array = [];
		private var _balance: int; //balance de la transaction actuelle
		private var _elementHighlight:DisplayObject;
		//private var _inventaireHighlight:MovieClip;

		public function Magasin() {
			addEventListener(Event.ADDED_TO_STAGE, ouverture);
		}

		public function ouverture(e: Event): void {
			addEventListener(Event.REMOVED_FROM_STAGE, fermeture);
			removeEventListener(Event.ADDED_TO_STAGE, ouverture);

			chObjet.text = "-";
			chPrix.text = "-";
			chFeedback.text = "Cliquez sur les objets\npour vendre ou acheter";

			actualiserInfo();
			changerHighlight();

			btRetour.addEventListener(MouseEvent.CLICK, quitter);
			btConfirmer.addEventListener(MouseEvent.CLICK, confirmer);
			addEventListener(MouseEvent.MOUSE_MOVE, mouseOver);
			addEventListener(MouseEvent.CLICK, cliquer);

		}

		public function fermeture(e: Event): void {
			addEventListener(Event.ADDED_TO_STAGE, ouverture);
			removeEventListener(Event.REMOVED_FROM_STAGE, fermeture);
			removeEventListener(MouseEvent.MOUSE_MOVE, mouseOver);
			removeEventListener(MouseEvent.CLICK, cliquer);
			btConfirmer.removeEventListener(MouseEvent.CLICK, confirmer);
			

		}
		
		public function frappeClavierMagasin(e:KeyboardEvent){ //Cette fonction (un peu ésotérique) définit quel élément doit être highlighté ensuite
			if(_elementHighlight==btConfirmer){// si on est présentement sur le bouton
				
				switch(e.keyCode){
					case Keyboard.UP:
					case Keyboard.LEFT:
						_elementHighlight=invJoueur.getChildAt(invJoueur.numChildren-1);
						break;
					case Keyboard.RIGHT:
						_elementHighlight=invMarchand.getChildAt(invMarchand.numChildren-1);
						break;
					case Keyboard.ENTER:
					case Keyboard.SPACE:
						confirmer();
						break;
				}
				
			}else {
				var inventaire:MovieClip = MovieClip(_elementHighlight.parent);
				var index:int = inventaire.getChildIndex(_elementHighlight);
				switch(e.keyCode){
					case Keyboard.LEFT:
						if((index-1)%6==0 && inventaire==invMarchand && invJoueur.numChildren>1){ //Si on sort de l'inventaire marchand
							inventaire=invJoueur;
							index=index+=5;//on atterit ici
						}else index--;
						if(index<=0)index=1;
						break;
					case Keyboard.RIGHT:
						if((index)%6==0 && inventaire==invJoueur || index==inventaire.numChildren-1){ //Si on sort de l'inventaire joueur
							inventaire=invMarchand;
							index-=5;//on atterit ici
							while(7%index!=0){ //Si on atterit à un endroit inattendu..
								index++; 
								if(index>numChildren-1)break;
							}//while index != multiple de 7
						}else index++;
						if(index>inventaire.numChildren-1)index=inventaire.numChildren-1
						break;
					case Keyboard.UP:
						if(index-6>=1)index-=6;
						break;
					case Keyboard.DOWN:
						if(inventaire.numChildren-1>=index+6)index+=6;
						else{
							_elementHighlight = btConfirmer;
							changerHighlight();
							return void;
						}
						break;
					case Keyboard.SPACE:
					case Keyboard.ENTER:
						cliquer();
						break;
				}//switch
				//Sécurité contre l'erreur 2006
				while(index>inventaire.numChildren-1){
					index--;
					if(index<=1)break;
				}
				//on change l'element
				_elementHighlight=inventaire.getChildAt(index);
				voirInfoObjet(MovieClip(inventaire.getChildAt(index)).constructor);
				
			}//if else
			changerHighlight();
		}//function frappeClavierMagasin

		public function achat(objet: String): Boolean {
			var index: uint = tPrix.indexOf(objet);
			if (index == -1) return false; //L'élément n'a pas été trouvé
			var prix: uint = tPrix[index + 1];
			if (_inventaire[index] is String) {
				_inventaire.splice(index, 1);
				_change += prix;
				actualiserInfo();
				return true
			} else return false //Retourne faux si la vente est impossible
		}
		
		private function changerHighlight(e:MouseEvent = null):void{
			select_mc.x=_elementHighlight.x+_elementHighlight.parent.x-6;
			select_mc.y=_elementHighlight.y+_elementHighlight.parent.y-6;
			select_mc.width = _elementHighlight.width+12;
			select_mc.height = _elementHighlight.height+12;
		}

		private function cliquer(e: MouseEvent=null): void {
			
				var objetCible: MovieClip;
				var inventaireSource: String;
				
				if(e!=null){ // Pour un clic de souris
					
					if (e.target is MovieClip && e.target.parent is MovieClip) {
						objetCible = MovieClip(e.target); 
						inventaireSource = e.target.parent.name;
					}else return void; //si on a cliqué à un endroit pas rapport
					
				}else { //pour un enter ou un espace
					if(_elementHighlight is SimpleButton){//Si c'est le bouton confirmer
						return void;
					} else {
						objetCible = MovieClip(_elementHighlight);
						inventaireSource=_elementHighlight.parent.name;
					}
				}
				


				//On veut que le joueur puisse faire des choix avant de cliquer sur confirmer et de procéder à la transaction et que ca ne lui coute pas d'argent juste pour "essayer" d'acheter des objets
				var i: uint = 0;
				objetCible.alpha = 1;
				while (i < _marquePourVente.length) { //Parcourir les éléments du tableau pour savoir si l'objet est marqué pour vente
					if (_marquePourVente[i] == objetCible) { //Si l'élément était marqué pour vente
						_marquePourVente.splice(i, 1); //On annule le marquage
						_balance -= tPrix[tPrix.indexOf(objetCible.constructor) + 1]*(_tauxRachat/100);
						chBalance.text = "" + _balance;
						return void;
					} else i++;
				}
				var k: uint = 0;
				while (k < _marquePourAchat.length) { //Parcourir pour savoir si l'élément est marqué pour achat
					if (_marquePourAchat[k] == objetCible) {
						_marquePourAchat.splice(k, 1);
						_balance += tPrix[tPrix.indexOf(objetCible.constructor) + 1];
						chBalance.text = "" + _balance;
						return void;
					} else k++;
				}

				//On atteint cette portion de code si l'objet n'était pas marqué

				if (inventaireSource == "invJoueur") { //Si l'objet venait de l'inventaire du joueur, on procede a une vente.
					_marquePourVente.push(objetCible);
					objetCible.alpha = 0.2;
					_balance += tPrix[tPrix.indexOf(objetCible.constructor) + 1]*(_tauxRachat/100);
					
				} else { //Si l'objet venait de l'inventaire du marchand, on procede a un achat.
					_marquePourAchat.push(objetCible);
					objetCible.alpha = 0.2;
					_balance -= tPrix[tPrix.indexOf(objetCible.constructor) + 1];
				}
			
			if(_balance>0)chBalance.text = "+" + _balance;
			else chBalance.text = "" + _balance;

		} //Fonction cliquer

		private function confirmer(e: MouseEvent=null): void {
			var inventaireJoueur: Array = Jeu(parent).getTObjets();
			var indexAComparer: int = 0;

			if (Jeu(parent).getFortune() + _balance < 0) { //Transaction impossible. Fonds insuffisants
				chFeedback.text = "Vous n'avez pas assez d'argent !";
			} else if (_change - _balance < 0) {
				chFeedback.text = "Le marchand n'a pas assez d'argent !";
			} else if(_marquePourVente.length==0 && _marquePourAchat.length==0){ //Transaction impossible, rien n'a été sélectionné
				chFeedback.text = "Vous n'avez rien selectionné !";
			} else { //Transaction possible
				
				for each(var avendre: MovieClip in _marquePourVente) {
					for each(var acomparer: MovieClip in inventaireJoueur) {
						if (avendre == acomparer) {
							Jeu(parent).enleverObjet(inventaireJoueur.indexOf(acomparer));
							_inventaire.push(acomparer);
							
							acomparer.alpha = 1;

						}
					}
				} // for each element a vendre

				for each(var aacheter: MovieClip in _marquePourAchat) {
					for each(var acomparer: MovieClip in _inventaire) {
						if (aacheter == acomparer) {
							_inventaire.splice(_inventaire.indexOf(acomparer),1);
							Jeu(parent).ajouterObjet(acomparer);

							acomparer.alpha = 1;
						}
					}
				} // for each element a acheter

				Jeu(parent).ajouterOr(_balance);
				_change-=_balance;
				_marquePourVente = [];
				_marquePourAchat = [];
				_balance = 0;
				

				actualiserInfo();
				chFeedback.text = "Merci d'avoir magasiné chez nous !";
			}//else transaction possible
		}// fonction confirmer

		private function actualiserInfo(): void {
			var inventaireJoueur: Array = Jeu(parent).getTObjets();
			//VIDANGE DU MAGASIN
			while (invJoueur.numChildren > 1) {
				invJoueur.removeChild(invJoueur.getChildAt(invJoueur.numChildren - 1))
			} //tant qu'il y a du stock dans la displaylist, enleve le. On garde juste un clip qui est le background
			while (invMarchand.numChildren > 1) {
				invMarchand.removeChild(invMarchand.getChildAt(invMarchand.numChildren - 1))
			} //tant qu'il y a du stock dans la displaylist, enleve le

			//REMPLISSAGE INVENTAIRE JOUEUR
			var i: int = 0;
			while (i < inventaireJoueur.length) {
				var o: MovieClip = inventaireJoueur[i];
				invJoueur.addChild(o);
				o.scaleX = 0.6;
				o.scaleY = 0.6; //On reduit un peu le scale des patates
				o.x = (i * o.width + 10 * i) + 20; //Le x de la patate est augmenté pour chaque nouvelle patate
				o.x -= Math.floor(i / 6) * (o.width * 6 + 6 * 10); //Si on dépasse 6 patates, on les décale pour chaque nouveau paquet de 6
				o.y = (Math.floor(i / 6) * (o.height) + Math.floor(i / 6) * 10) + 20; // k/6 parce qu'on veut 6 éléments dans une rangée

				i++;
			}
			chOrJoueur.text = "" + Jeu(parent).getFortune();

			var k: int = 0;
			//REMPLISSAGE INVENTAIRE MARCHAND
			while (k < _inventaire.length) {
				var o: MovieClip = _inventaire[k];
				invMarchand.addChild(o);
				o.scaleX = 0.6;
				o.scaleY = 0.6; //On reduit un peu le scale des patates
				o.x = (k * o.width + 10 * k) + 20; //Le x de la patate est augmenté pour chaque nouvelle patate
				o.x -= Math.floor(k / 6) * (o.width * 6 + 6 * 10); //Si on dépasse 6 patates, on les décale pour chaque nouveau paquet de 6
				o.y = (Math.floor(k / 6) * (o.height) + Math.floor(k / 6) * 10) + 20; // k/6 parce qu'on veut 6 éléments dans une rangée

				k++;
			} //while has item
			chOrMarchand.text = _change + "";
			chBalance.text = "" + _balance;
			
			//Boucle pour trouver le premier object à Highlight s'il n'y en a pas déjà un
			if(_elementHighlight==null){
				if(invJoueur.numChildren>1)_elementHighlight = invJoueur.getChildAt(1);
				else if(invMarchand.numChildren>1)_elementHighlight = invMarchand.getChildAt(1); // 0 est la forme de l'inventaire
				else _elementHighlight = btConfirmer;
			}//if no highlight

		} //fonction Actualiser info
		
		private function mouseOver(e:MouseEvent):void{
			var o: Class = e.target.constructor;
			if(e.target is MovieClip && (e.target.parent==invJoueur || e.target.parent==invMarchand)){
				voirInfoObjet(o);
				_elementHighlight = MovieClip(e.target);
				changerHighlight();
			}//if dans ivnentaire
		}//fonction voirInfoObjet
			

		private function voirInfoObjet(classe:Class): void { //Appelé quand on veut voir les infos reliés à un objet

			if (tPrix[tPrix.indexOf(classe) + 1] is int) { //Si on trouve la classe dans le tableau des prix
				chObjet.text = getQualifiedClassName(classe);
				chPrix.text = "" + tPrix[tPrix.indexOf(classe) + 1]; //Prix
				chFeedback.text = tPrix[tPrix.indexOf(classe) + 2]; //Description 
			} else {
				chObjet.text = "-";
				chPrix.text = "-";
				chFeedback.text = "Cliquez sur les objets\npour vendre ou acheter";
			}//if trouvé dans t prix else
			
		}//fonction voirInfoObjet

		private function quitter(e: Event): void {
			stage.focus = Jeu(parent);
			Jeu(parent).removeChild(this);
		}

	}

}