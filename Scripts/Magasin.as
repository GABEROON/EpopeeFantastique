﻿package {

	import flash.display.Sprite;
	import flash.events.*;
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.Font;
	import flash.utils.getQualifiedClassName;
	import flash.display.MovieClip;

	public class Magasin extends Sprite {

		private var _inventaire: Array = [new Patate(),new Patate(),new Potion()]; //Array contenant la définition des objets du magasin
		private var _change: uint = 30; //Entier positif représentant le nombre d'or du marchand
		private var _tauxRachat: uint = 80; //Entier positif représentant le pourcentage du prix donné lorsque le joueur vend au marchand
		protected static var _tPrix: Array = [	Patate, 5, "Une vulgaire patate. Elle vous redonnera surement un peu de vigueur.", //Tableau contenant le prix de tous les items du jeu !!!DEFINIR LOBJET AVEC UNE CLASSE!!!
												Potion, 10, "Une étrange liqueur. Elle semble dégager une énergie étrange"
												];
		private var _marquePourVente: Array = [];
		private var _marquePourAchat: Array = [];
		private var _balance: int; //balance de la transaction actuelle
		private var _elementHighlight:DisplayObject;

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
			changerHighlight

			btRetour.addEventListener(MouseEvent.CLICK, quitter);
			btConfirmer.addEventListener(MouseEvent.CLICK, confirmer);
			addEventListener(MouseEvent.MOUSE_MOVE, voirInfoObjet);
			addEventListener(MouseEvent.CLICK, cliquer);

		}

		public function fermeture(e: Event): void {
			addEventListener(Event.ADDED_TO_STAGE, ouverture);
			removeEventListener(Event.REMOVED_FROM_STAGE, fermeture);
			removeEventListener(MouseEvent.MOUSE_MOVE, voirInfoObjet);
			removeEventListener(MouseEvent.CLICK, cliquer);
			btConfirmer.removeEventListener(MouseEvent.CLICK, confirmer);
			

		}
		
		public function frappeClavierMagasin(e:KeyboardEvent){
			
		}

		public function achat(objet: String): Boolean {
			var index: uint = _tPrix.indexOf(objet);
			if (index == -1) return false; //L'élément n'a pas été trouvé
			var prix: uint = _tPrix[index + 1];
			if (_inventaire[index] is String) {
				_inventaire.splice(index, 1);
				_change += prix;
				actualiserInfo();
				return true
			} else return false //Retourne faux si la vente est impossible
		}
		
		private function changerHighlight(e:MouseEvent = null):void{
			select_mc.x=_elementHighlight.x;
			select_mc.y=_elementHighlight.y;
		}

		private function cliquer(e: MouseEvent): void {
			if (e.target is MovieClip && e.target.parent is MovieClip) {
				var objetCible: MovieClip = MovieClip(e.target);
				var inventaireSource: String = e.target.parent.name;


				//On veut que le joueur puisse faire des choix avant de cliquer sur confirmer et de procéder à la transaction et que ca ne lui coute pas d'argent juste pour "essayer" d'acheter des objets
				var i: uint = 0;
				objetCible.alpha = 1;
				while (i < _marquePourVente.length) { //Parcourir les éléments du tableau pour savoir si l'objet est marqué pour vente
					if (_marquePourVente[i] == objetCible) { //Si l'élément était marqué pour vente
						_marquePourVente.splice(i, 1); //On annule le marquage
						_balance -= _tPrix[_tPrix.indexOf(objetCible.constructor) + 1]*(_tauxRachat/100);
						chBalance.text = "" + _balance;
						trace("Marqué pour vente : " + _marquePourVente);
						trace("Marqué pour Achat : " + _marquePourAchat);
						return void;
					} else i++;
				}
				var k: uint = 0;
				while (k < _marquePourAchat.length) { //Parcourir pour savoir si l'élément est marqué pour achat
					if (_marquePourAchat[k] == objetCible) {
						_marquePourAchat.splice(k, 1);
						_balance += _tPrix[_tPrix.indexOf(objetCible.constructor) + 1];
						chBalance.text = "" + _balance;
						trace("Marqué pour vente : " + _marquePourVente);
						trace("Marqué pour Achat : " + _marquePourAchat);
						return void;
					} else k++;
				}

				//On atteint cette portion de code si l'objet n'était pas marqué

				if (inventaireSource == "invJoueur") { //Si l'objet venait de l'inventaire du joueur, on procede a une vente.
					_marquePourVente.push(objetCible);
					objetCible.alpha = 0.2;
					_balance += _tPrix[_tPrix.indexOf(objetCible.constructor) + 1]*(_tauxRachat/100);
				} else { //Si l'objet venait de l'inventaire du marchand, on procede a un achat.
					_marquePourAchat.push(objetCible);
					objetCible.alpha = 0.2;
					_balance -= _tPrix[_tPrix.indexOf(objetCible.constructor) + 1];
				}
				trace("Marqué pour vente : " + _marquePourVente);
				trace("Marqué pour Achat : " + _marquePourAchat);
			} //if target and target's parent are MovieClip
			
			if(_balance>0)chBalance.text = "+" + _balance;
			else chBalance.text = "" + _balance;

		} //Fonction cliquer

		private function confirmer(e: MouseEvent): void {
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
				if(inventaireJoueur.numChildren>0)_elementHighlight = inventaireJoueur.getChildAt(0);
				else if(_inventaire.numChildren>0)_elementHighlight = _inventaire.getChildAt(0);
				else _elementHighlight = btConfirmer;
			}//if no highlight

		} //fonction Actualiser info

		private function voirInfoObjet(e: MouseEvent): void { //PASSAGE AU DESSUS DUN OBJET AVEC LA SOURIS
			var o: Class = e.target.constructor;
			if (_tPrix[_tPrix.indexOf(o) + 1] is int) {
				chObjet.text = getQualifiedClassName(o);
				chPrix.text = "" + _tPrix[_tPrix.indexOf(o) + 1]; //Prix
				chFeedback.text = _tPrix[_tPrix.indexOf(o) + 2]; //Description 
			} else {
				chObjet.text = "-";
				chPrix.text = "-";
				chFeedback.text = "Cliquez sur les objets\npour vendre ou acheter";
			}

		}

		private function quitter(e: Event): void {
			stage.focus = Jeu(parent);
			Jeu(parent).removeChild(this);
		}

	}

}