Funzionamento predicati mvpoli.lisp:

monomial-coefficient (m):

Funzione che ritorna il coefficiente del monomio sia che esso è in forma standard che in forma a lista.

monomial-degree (m):

Funzione che ritorna il coefficiente del monomio sia che esso è in forma standard che in forma a lista.

monomial-varpowers (m):

Funzione che ritorna il coefficiente del monomio sia che esso è in forma standard che in forma a lista.

as-monomial(Expression):

La funzione usa altre funzioni d'appoggio come estrai-TD che restitutisce il grado massimo dell'espressione, estrai-VP che restituisce la lista dei varpower nella forma richiesta e estrai-coeff che estrae il coefficiente dell'espressione valutando anche i casi in cui il coeff non sia un numero ma un composto chiamando la funzione eval.
LA funzione as-monomial valuta anche il caso che il monomio sia già nella forma a lista e lo restituisce uguale.

as_polynomial(Expression):

La funzione fa il parser del polinomio dalla forma standard a quella a lista basandosi sulla funzione estrai-monomials che estrai ogni singolo monomio nell'espressione con as-monomial e li mette in una lista, dopo di che viene ordinata questa lista in base al grado totale e in caso di gradi uguali in ordine lessicografico delle variabili tramite la funzione sort e in base allordinamento impostato nella funzione monomials-sort.
Dopo viene semplificato il polinomio sommando quelli uguali e viene controllato se è corretto tramite is-polynomial.
Viene anche controllato il caso che il polinomio sia un numero, una variabile singola o una potenza.
Se è 0 viene restituito (poly nil) cioè il polinomio nullo.

varpowers (m):

Funzione che restituisce i varpowers del monomio sia che esso è nella forma standard che in quella a lista.

vars-of (m):

Funzione che restituisce le variabili del monomio senza ripetizioni.
Viene chiamata la funzione get-vars sui varpowers del monomio, questa funzione crea la lista delle variabili.

pprint_polynomial(Poly):

Funzione che stampa la lista Poly nella forma standard.
La funzione chiama la funzione print-p passandogli la lista di monomi del polinomio, che a sua volta chiama pprint-monomial passandolgi un monomio.
Pprint_monomial(Mon) controlla se il coeff è positivo, negativo o uguale a 0 stampa il monomio con davanti il piu o il meno a seconda del caso in cui è.
La stampa dei varpowers è fatta tramite la funzione pprint-vars.

coefficients(Poly):

Questa funzione crea la lista dei coefficienti del polinomio Poly, per farlo chiama la funzione get-coeff-pol che prende i coefficienti di ogni monomio di Poly e li mette in una lista.

variables(Poly):

Questa funzione crea la lista delle variabili del polinomio Poly, per farlo chiama la funzione get-vars-pol che prende le variabili dei VP di ogni monomio di Poly tramite la funzione fatta prima vars-of, infine vengono eleminati quelli che si ripetono tramite la funzione remove-duplicates.
La funzione è utilizzabile sia con polinomi nella forma standard che con quelli nella forma a lista.

maxdegree(Poly):

La funzione restitusce il grado massimo, per farlo chiama la funzione degrees che crea la lista dei gradi dei monomi che compongono il polinomio e poi tramite la funzione get-last prende l'ultimo, l'ultimo è il maggiore visto che il polinomio è ordinato, se il polinomio è nella forma standar viene fatto il parser nella forma a lista e di conseguenza viene ordinato.

minDegree(Poly):

La funzione restitusce il grado minimo, per farlo chiama la funzione degrees che crea la lista dei gradi dei monomi che compongono il polinomio e poi tramite la funzione car prende il primo della lista, il primo è il minore visto che il polinomio è ordinato, se il polinomio è nella forma standar viene fatto il parser nella forma a lista e di conseguenza viene ordinato.

monomials(Poly):

Restituisce la lista dei monomi del polinomio passato, viene fatto il parser del polinomio che se è già nella forma a lista rimane uguale, e poi viene preso il secondo elemento della lista risultante dal parser.

polyplus(Poly1, Poly2):

La funzione valuta il caso in cui uno dei due sia nil, in tal caso faccio solo la somma degli elementi dell'altro.
Se nessuno dei due è nil unisco le due liste di monomi dei due polinomi e poi chiamo la funzione plus su di essa.
La somma viene fatta dalla funzione plus-eq che somma il primo monomi della lista con quelli uguali nel resto della lista di monomi.
Poi queste somme vengono unite nella funzione plus e viene richimata la somma sul cdr della lista senza i monomi che hanno lo stesso vp dei monomi che ho appena sommato per evitare somme rindondanti.
In fine il polyplus elimino i monomi nulli con equal-zero e controllo se la lista risultante sia nil, in tal caso ritorno (poly nil) se no ritorno il polinomi che  risultato dalla somma nella forma a lista richiesta.

polyminus(Poly1, Poly2):

Questa funzione ritorna la differenza tra due polinomi, nel caso il primo sia nil inverte i coefficienti del secondo polinomio, sei il secondo è nil faccio la somma del primo per sommare eventuali elementi uguali.
Invece se nessuno dei due è nil inverto i coefficienti del secondo polinomio tramite invert-coeff e lo sommo con il primo polinomio.
La funzione gestisce sia il caso che i due polinomi sia nella forma standard che nella forma a lista.

polytimes(Poly1, Poly2):

Questa funzione ritorna il prodotto tra due polinomi, nel caso uno dei due sia nil ritorno l'altro.
Invece se nessuno dei due è nil chiamo la funzione prod sulla lista di monomi deii due polinomi, la funzione prod a sua volta chiama la funzione prod-mon che calcola la moltiplicazione tra il primo monomio della prima lista e la seconda lista, poi il risultato di prod-mon viene aggiunto alla lista dei prodotti in prod e viene richiamato pro sul cdr della prima lista di monomi e la seconda lista.
Quando faccio il prodotto in prod-mon chiamo prod-vp per fare la lista dei vp risultanto dalla moltiplicazione che a sua volta chiama somma-vp che somma quelli uguali.
Infine in polytimes viene fatta la somma degli elementi uguali nella lista di prodotti tramite la funzione plus e vengono eliminati quelli con coefficiente uguale a zero tramite la funzione equal-zero.

polyval(Poly, VarValue):

Per fare la sostituzione chiama la funzione sost-p a cui gli passo la lista di monimo del polinomio, la lista delle variabili di Poly estrate con la funzione variables e la lista dei valori delle variabili.
La funzione sost-p ricrea la lista di monomi nella forma standard uno alla volta, per creare un monomio chiamo la funzione list tra : '*, il coefficiente del monomio e la lista delle variabili dopo aver sistutito le incognite con i valori tramite la funzione sost-vp.
La funzione sost-vp ricrea i vp nella forma , dove ogni vp viene creato dalla funzione create-vp passandogli il vp la variabile da sostitire e il valore , in questa funzione i vp vengono costruiti nella forma (expt base esponente) se la variabile del vp passato è uguale a quella passata come parametro.
Infine a questa lista di monomi nella forma standard viene aggiunto davanti il segno '+ e viene fatto l'eval per calcolarne il valore.















































































