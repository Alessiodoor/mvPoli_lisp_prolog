Funzionamento predicati mvpoli.pl:

as_monomial(Expression, Monomial):

Ci sono due predicati as_monomial uno che controlla se Expression è uguale a zeor, in tal caso crea direttamente il monomio m(C, 0,[]).
Invece l'altro fa il parser dell'espressione nella forma a lista voluta basandosi su predicati di appoggio come estrai_TD che restitutisce il grado massimo dell'espressione, estrai_VP che restituisce la lista dei varpower nella forma richiesta e estrai_Coeff che estrae il coefficiente dell'espressione valutando anche i casi in cui il coeff non sia un numero ma un composto di coseno, seno, tangente, potenze.

as_polynomial(Expression, Poly):

Anche qua ci sono due predicati, uno che controlla se l'espressione passate è uguale a 0, in tal caso restituisce il polinomio vuoto (poly([])), invece l'altro predicato esegue il parser dell'espressione nella forma a lista richiesta basandosi sul predicato estrai_mon che estrai ogni singolo monomio nell'espressione con as_monomial e li mette in una lista, dopo di che viene ordinata questa lista in base al grado totale e in caso di gradi uguali in ordine lessicografico delle variabili, questa operazione viene fatto cambiando l'ordine del monomio mettendo prima il TD poi il VP e in fine il coeff per ogni monomio della lista e poi viene chiamato il metodo msort che li ordina e in fine vengono rimessi gli elementi dei monomi nella forma originale.

pprint_polynomial(Poly):

Predicato che stampa la lista Poly nella forma standard.
Il predicato chiama altri due predicati, uno che stampa il primo monomio della lista senza + o - davanti eun altro che stampa il resto della lista dei monomi separati da + o -.
La stampa del singolo monomio è fatta tramite pprint_monomial(Mon) che controlla se il coeff è positivo o negativo e mettendo davanti + se p positivo o - se è negativo e in tal caso inverte anche il segon del coeff se no ci sarebbe un altro meno.
La stampa effettiva del gli elementi del monomio è fatta dal predicato 
stampaM(Mon) che scrive il coeff e sua volta chiama il predicato stamaVPs(VPs) che stampa la lista dei varpowers, tutto separato dal simbolo *.

coefficients(Poly, Result):

Anche questo è fatto da due predicati, uno che estrai o coeff nella forma a lista e uno che lo trasforma dalla forma standard a quella a lista e poi estrai i coeff.
Per creare la lista dei coeff si usa il predicato creaListaCs(Poly, Coeff) che prende il coeff di ogni monomi di Poly e li mette in una lista.

variables(Poly, Result):

Questo predicato crea la lista delle variabili del polinomio Poly, per farlo chiama il predicato creaListaVs che prendi le variabili dei VP di ogni monomio di Poly e li mette in una lista, per prende solo le variabili si usa il predicato estrai_Vs_Mon che passandogli la lista dei VP prende solo le variabili, infine vengono eleminati quelli che si ripetono tramite il predicato deleteDuplicate che in pratica che una nuova lista senza quelli duplicati.

maxdegree(Poly, Result):

Anche questo è formato da due predicati, uno che lavora direttamente su Poly nella forma a lista e un altro che prima fa il parser di Poly e poi prende il grado massimo.
Per prendere il grado massimo chiamo il predicato getDegreeMax che controlla se il grado del primo monomio è maggiore del grado dei monomi del resto della lista , quando la lista è vuota il grado è -1.

minDegree(Poly, Result):

Anche questo si divide in due predicati uno dove fa il parser della forma standard e poi calcola il grado minimo e uno che lo fa direttamente su Poly nella forma a lista,
Per calcolare il grado minore chiama il predicato getDegree che estra la lista dei gradi di Poly e poi con getMinDegree questa lista viene ordinata in ordine crescente e viene preso il primo.

monomials(Poly, Result):

Anche questo è diviso in due predicati, uno che fa il parser di Poly nella forma standard e uno no, per estrarre la lista dei monomi univico semplicemente Poly con poly(P), dove P è la lista dei monomi che è gia' stata creata tramite il parser dell'espressione.

polyplus(Poly1, Poly2, Result):

Anche questo è diviso in due predicati, uno fa il parser dei due polinomi e ne fa la somma e un altro che fa direttamente la somma,
Per calcolare la somma si fa l'append delle liste dei monomi dei due polinomi e poi viene chiamato il predicato somma du questa lista.
Il predicato somma chiama a sua volta il predicato sommaMs a cui gli viene passato come primo parametro il primo monomio della lista e come e secondo il resto della lista, questo predicato somma tutti i monomi del resto della lista con il primo monomio se hanno lo stesso vp, poi in somma vengono eliminati dal resto della lista dei monomi tutti quelli uguali al primo con il predicato elimina per evitare che ci siamo somme rindondanti, infine viene richiamato il predicato somma sulla lista dei monomi.

polyminus(Poly1, Poly2, Result):

Anche questo si divide in due predicati, uno che fa il parser dei due polinomi e poi fa la differenza e un altro che fa direttamente la differenza dei polinomi in forma standard.
Prima di fare l'effettiva differenza chiamo il predicato semplifica che esegue la differenza nei singoli polinomi per evitare rindondanze, poi vengono invertiti i coeff del secondo polinomio tramite il predicato inverti_Coeff, poi viene fatto l'appende dei due polinomi e viene richiamata la somma di quest'ultima lista, il resto funziona come il polyplus.

polytimes(Poly1, Poly2, Result):

Anche qua ci sono due predicati , uno che fa il parser dei polinomi nella forma standard e poi fa il prodotto e uno che fa direttamente il prodotto,
Per fare il prodotto chiamo il predicato molt sulle due liste di monomi dei due polinomi.
Il predicato molt moltiplica ogni monomi della lista di Poly1 con tutti i monomi della lista di Poly2 tramite il predicato product a cui gli viene passato il primo monomio di Poly1 e tutti quelli di Poly2, questo predicato fa il prodotto monomio per monomio, moltipicando i coeff e sommando i VP in modo opportuno.
La somma dei VP viene eseguita dal predicato ProdVPs a cui viene passata l'append della lista dei VPs dei due monomi da moltiplicare e crea a sua volta la lista risultante dalla somma dei VP sommando quelli con la stessa variabile tramite il predicato sempliVPs e poi eliminando quelli rindondanti con eliminaVPs che evitare si sommare di nuovo quelli gia sommati.

polyval(Poly, VarValue, Result):

Anche questo e formato da due predicati, uno che fa il parser di Poly nella forma standard e uno che lavora direttamente sulla forma gia parsata.
Per fare la sostituzione chiama il predicato sostituzione a cui gli passo Poly, la lista delle variabili di Poly estrate con il metodo variables e la lista dei valori delle variabili.
Il predicato sostituzione a sua volta chiama il predicato sostM passandogli il Polinomio, la prima variabile e il suo valore, questo predicato sostituira' in tutti i monomi le variabili della lista VP uguali a quella passata con il sue valore, per sostituire i VP chiamo un altro predicato a cui passo il VP, la variabile e il valore che sostituirà le variabili uguali a quell passta con il valore.
Dopo aver eseguito la sostituzione faccio l'append della lista risultante per eliminare eventuali sottoliste non volute e infine chiamo il predicato risolvi che moltiplica il coeff per il VP, il VP viene calcolato tramite il predicato risolviVPs che esegue la potenza di ogni vp.















































































