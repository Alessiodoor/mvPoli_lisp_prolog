;;;; 807457 Alessio Porta
;;;; 808710 Dennis Verdino

;;;; -*- Mode : Lisp -*-

;;;; mvpoli.lisp

;;;; Dato un monomio nella struttura lista riconoscie se è correttamente formato

(defun is-monomial (m)
  (and (listp m)
       (eq 'm (first m))
       (let ((mtd (monomial-degree m))
             (vps (monomial-varpowers m))
             )
         (and (integerp mtd)
              (>= mtd 0)
              (listp vps)
              (every #'is-varpower vps)))))

;;;; Dato un monomio nella struttura a lista o in quella standard la
;;;; funzione ritorna il suo coefficiente

(defun monomial-coefficient (m)
  (cond ((null (as-monomial m)) 0)
        ((listp m)
         (second (as-monomial m)))))

;;;; Dato un monomio nella struttura a lista o in quella standard la
;;;; funzione estrae il grado del monomio.

(defun monomial-degree (m)
  (if (listp m)
      (third (as-monomial m))))

;;;; Dato un monomio nella struttura a lista o in quella standard la
;;;; funzione estrae le variabili con i loro esponenti.

(defun monomial-varpowers (m)
  (if (listp m)
      (fourth (as-monomial m))))

;;;; Funzione che controlla se la lista di varpowers passata contiene
;;;; una variabile ed un esponente, il tutto in una lista del tipo (V 5 X),
;;;; dove 5 sta per l'esponente e X per la variabile. Le
;;;; funzioni varpower-power e varpower-symbol servono appunto per
;;;; estrarre da questa lista la potenza e la variabile.

(defun is-varpower (vp)
  (and (listp vp)
       (eq 'v (first vp))
       (let ((p (varpower-power vp))
             (v (varpower-symbol vp))
             )
         (and (integerp p)
              (>= p 0)
              (symbolp v)))))

(defun varpower-power (vp)
      (second vp))

(defun varpower-symbol (vp)
      (third vp))

;;;; Dato un polinomio nella struttura a lista riconosce se è
;;;; correttamente formato

(defun is-polynomial (p) 
  (and (listp p)
       (eq 'poly (first p))
       (let ((ms (poly-monomials p)))
         (and (listp ms)
              (every #'is-monomial ms)))))

;;;; Dato un polinomio nella struttura a lista o in quella standard 
;;;; restituisce la lista dei monomi

(defun poly-monomials (p)
  (second p))

;;;; Dato un monomio nella struttura standard la funzione lo trasfoma
;;;; nella struttura a lista, invece se è gia nella struttura a lista lo 
;;;; lascia invariato.

(defun as-monomial (m) 
  (cond ((and (listp m) (eq 'm (first m))) m)
        ((and (listp m) (eq '* (first m)) (/= 0 (estrai-coeff m)))
         (let ((mon (list 'm 
                        (estrai-coeff m)
                        (estrai-td m)
                        (sort 
                         (prod-vp (estrai-vp m)) 
                         #'string-lessp :key #'third))))
           (if (is-monomial mon) mon)))
        ((numberp m)
         (list 'm m 0 ()))
        ((symbolp m)
         (list 'm 1 1 (prod-vp (estrai-vp m))))
        ((and (listp m) (eq 'expt (first m)))
         (let ((mon (list 'm 1 
                        (third m)
                        (prod-vp (estrai-vp m)))))
           (if (is-monomial mon) mon)))
        ((and 
          (listp m) 
          (eq '- (first m)) 
          (symbolp (second m)))
         (let ((mon (list 'm -1 1 
                   (list 
                    (list 'v 1 (second m))))))
           (if (is-monomial mon) mon)))
        ((and 
          (listp m) 
          (eq '- (first m)) 
          (eq 'expt (first (second m))))
         (let ((mon (list 'm -1 
                        (third (second m))
                        (list (list 
                               'v 
                               (third (second m)) 
                               (second (second m)))))))
           (if (is-monomial mon) mon)))))

;;;; Funzione d'appoggio chiamata in as-monomial che dato un monomio
;;;; nella struttura standard restituisce il suo coefficiente.
         
(defun estrai-coeff (m)
  (cond ((symbolp (second m)) 1)
        ((and 
          (listp (second m)) 
          (eq 'expt (first (second m)))) 1)
        ((numberp (eval (second m)))
        (eval (second m)))))
      
;;;; Funzione d'appoggio chiamata da as-monomial che dato un monomio
;;;; nella struttura standard resistuisce il grado totale del monomio.

(defun estrai-td (m)
  (cond ((null m) 0) 
        ((numberp (first m)) (+ 0 (estrai-td (cdr m))))
        ((and 
          (symbolp (first m)) 
          (not (eq '* (first m)))) 
         (+ 1 (estrai-td (cdr m))))
        ((eq '* (first m)) 
         (+ 0 (estrai-td (cdr m)))) 
        ((eq 'expt (first (first m)))
         (+ (third (first m)) (estrai-td (cdr m))))
        ((numberp (eval (first m)))
         (+ 0 (estrai-td (cdr m))))))
 
;;;; Funzione d'appoggio chiamata in as-monomial che dato un monomio
;;;; della struttura standard restituisce la lista dei varpowers nella
;;;; forma a lista voluta.

(defun estrai-vp (m)
  (cond ((null m) nil)
        ((symbolp m)
         (list (list 'v 1 m)))
        ((numberp (first m)) (estrai-vp (cdr m)))
        ((or (eq '* (first m))) (estrai-vp (cdr m)))
        ((and 
          (symbolp (first m)) 
          (not (eq '* (first m))) 
          (not (eq 'expt (first m)))) 
         (append 
          (list 
           (append '(v 1) 
                   (list (first m)))) 
          (estrai-vp (cdr m))))
        ((and 
          (symbolp (first m))
          (eq 'expt (first m)))
         (if (/= 0 (third m))
             (list (list 'v (third m) (second m)))
           nil))
        ((eq 'expt (first (first m))) 
         (if (/= 0 (third (first m)))
             (append 
              (list 
               (append 
                '(v) 
                (list (third (first m))) 
                (list (second (first m))))) 
          (estrai-vp (cdr m)))
           (estrai-vp (cdr m))))
        ((numberp (eval (first m)))
         (estrai-vp (cdr m)))))  

;;;; Dato un polinomio nella struttura standard lo restituisce nella 
;;;; struttura a lista, invece se viene passato un polinomio nella
;;;; struttra a lista viene restituito uguale,
;;;; la funzione si occupa anche di semplificare eventuali somme tra 
;;;; variabili uguali e dell'eliminazione dei monomi con coefficiente 
;;;; uguale a 0, se il polinomio risultante è 0 la funzione 
;;;; restituirà (poly nil).

(defun as-polynomial (p) 
  (cond ((numberp p)
         (if (/= 0 p)
             (list
              'poly 
              (list (list
                     'm p '0 nil)))
           (list
            'poly
            nil)))
        ((symbolp p)
         (list
          'poly
          (list(list
                'm 1 1 (list 
                        (list 'v 1 p))))))
        ((and (listp p) (eq '+ (first p)))
         (let ((pol (polyplus (list 
                               'poly 
                               (sort 
                                (estrai-monomials (cdr p))
                                #'monomials-sort)) nil)))
           (if (is-polynomial pol) pol)))
        ((and (list p) (eq '* (first p)))
         (list 
          'poly
          (list (as-monomial p))))
        ((is-polynomial p)  p)))
         
;;;; Funzione d'appoggio chiamata in as-polynomial che data il
;;;; polinomio nella forma standard senza il + in testa restituisce 
;;;; la lista dei monomi che lo compongono della forma a lista,
;;;; poi in as-polynomial verrà aggiunto poly davanti a questa lista.

(defun estrai-monomials (p)  
  (if (= 1 (list-length p))
      (let ((mon
             (as-monomial (first p))))
        (if (null mon) nil
          (list mon)))
         (cons  
          (as-monomial (first p))
          (estrai-monomials (cdr p)))))

;;;; Funzione di ordinamento che viene gestita dalla funzione sort,
;;;; questa funzione riceve due monomi e restitutisce true se sono in
;;;; ordine in base all'ordinamento standand
;;;; invece restituisce false se non sono ordinati, poi sarà la
;;;; funzione sort a ordinare la lista dei monomio in base ai valori 
;;;; restituiti da questa funzione


(defun monomials-sort (m1 m2)
  (cond ((null m1) t)
        ((null m2) t)
        ((< (third m1) (third m2)) t)
        ((> (third m1) (third m2)) nil)
        ((= (third m1) (third m2))
         (variable-sort (fourth m1) (fourth m2)))))
 
;;;; Funzione d'appoggio chiamata in monomial-sort che restituisce
;;;; true se i varpowers dei due monomi sono ordinati invece
;;;; restituisce false se non sono ordinati.

(defun variable-sort (v1 v2)
   (cond ((null v1) t)
         ((null v2) t)
         ((string-lessp 
           (third (first v1)) 
           (third (first v2))) 
          t)
         ((string-greaterp 
           (third (first v1)) 
           (third (first v2))) 
          nil)
         ((string-equal 
           (third (first v1)) 
           (third (first v2)))
          (variable-sort (cdr v1) (cdr v2)))))

;;;; Dato un monomio nella struttura a lista o in quella standard 
;;;; restituisce la lista dei varpowers.

(defun varpowers (m)
  (fourth (as-monomial m)))
 
;;;; Dato un monomio nella struttura a lista o in quella standard
;;;; restituisce la lista delle variabili del polinomio basandosi
;;;; sulla funzione varpowers.

(defun vars-of (m)
  (get-vars (varpowers m)))

;;;; Funzione d'appoggio chiamata in vars-od che restituisce la lista
;;;; delle variabili passandogli come parametro la lista dei varpowers

(defun get-vars (vp)
  (if (null vp) nil
      (cons (third (first vp)) (get-vars (cdr vp)))))

;;;; La funzione pprint-polynomial ritorna NIL dopo aver stampato 
;;;; (sullo \standard output") una rappresentazione
;;;; tradizionale del termine polinomio associato a Polynomial. 
;;;; Si puo' omettere il simbolo di
;;;; moltiplicazione.

(defun pprint-polynomial (p)
  (if (null p) nil   
         (print-p (second (as-polynomial p)))))

;;;; Funzione d'appoggio usata per scorrere la lista dei monomi 
;;;; e chiamare la funzione che li stamperà uno alla volta.

(defun print-p (p)
  (cond ((null p) nil)
        ((pprint-monomial (first p))
         (print-p (cdr p))))) 
  
;;;; Funzione d'appoggio che stampa un monomio nella forma standard
;;;; omettendo il simbolo di moltiplicazione.

(defun pprint-monomial (m)
  (if (null m) nil
    (cond ((< (eval (second m)) 0)
           (format t "~S" (eval (second m))) 
           (pprint-vars (fourth m)))
          ((> (eval (second m)) 1) 
           (format t "+~S" (eval (second m))) 
           (pprint-vars (fourth m)))
          ((= (eval (second m)) 1)
           (format t "+") 
           (pprint-vars (fourth m)))
          ((= (second m) 0)))))

;;;; Funzione d'appoggio che stampa la lista dei varpowers dove 
;;;; omette l'esponente se è uguale a 1.

(defun pprint-vars (vp)
  (cond ((null vp) nil)
        ((= (second (first vp)) 1)
         (format t "~S" (third (first vp))) (pprint-vars (cdr vp)))
        ((> (second (first vp)) 1)
         (format t "~S^~S" (third (first vp)) (second (first vp)))
         (pprint-vars (cdr vp)))))

;;;; La funzione variables restituisce la lista delle variabili 
;;;; del polinomio passaro nella forma standard o in quella a 
;;;; lista omettendo quelle che si ripetono.

(defun variables (p)
  (if (null p) nil
         (remove-duplicates 
          (get-vars-pol (second (as-polynomial p))))))

;;;; Funzione d'appoggio chiamata da variables che crea la lista 
;;;; delle variabili passandogli la lista dei monomi del polinomio.

(defun get-vars-pol (p)
  (if (null p) nil
    (append (vars-of (first p)) (get-vars-pol (cdr p)))))

;;;; La funzione coefficients ritorna la lista dei coefficienti del 
;;;; polinomio passato nella forma standard o in quella a lista.

(defun coefficients (p)
  (if (or (null p) (null (second (as-polynomial p)))) (list 0)
         (get-coeff-pol (second (as-polynomial p)))))

;;;; Funzione d'appoggio chiamata in coefficients che crea la lista
;;;; dei ciefficienti passandogli la lista dei monomi del polinomio
;;;; di partenza.

(defun get-coeff-pol (p)
  (if(null p) nil
    (append (list (second (first p))) (get-coeff-pol (cdr p)))))

;;;; La funzione maxdegree ritorna il grado massimo tra i gradi totali
;;;; dei monomi che compaiono nel polinomio passato nella forma
;;;; standard o in quella a lista, la funzione crea la lista dei gradi
;;;; del polinomio in ordine crescente e poi viene chiamato get-last 
;;;; su questa lista per prendere il maggiore.

(defun maxdegree (p)
  (if (null p) nil
         (get-last (degrees (as-polynomial p)))))

;;;; Funzione d'appoggio chiamata da maxdegree che restituisce
;;;; l'ultimo elemento della lista, usato per restituire il grado
;;;; maggiore tra i gradi dei monomi che compaionio nel polinomio.

(defun get-last (p)
  (cond ((eq 1 (list-length p)) (car p))
        ((not (eq 1 (list-length p)))
         (get-last (cdr p)))))

;;;; La funzione mindegree restituisce il grado minore tra quelli 
;;;; che  compaiono nei monomi del polinomio passato nella forma
;;;; standard o in quella a lista,
;;;; la funzione crea la lista dei gradi in ordine crescente e
;;;;  poi estrai il primo tramite la funzione car.

(defun mindegree (p)
  (if (null p) nil
         (car (degrees (as-polynomial p)))))

;;;; Funzione d'appoggio chiamata in maxdegree e in mindegree 
;;;; che resituisce la lista dei gradi passandogli la lista 
;;;; dei monomi del polinomio gia parsato.

(defun degrees (p)
  (if (null p) nil
         (get-degrees-pol (second (as-polynomial p)))))

;;;; Funzione d'appoggio chiamata da degree che estrae il grado
;;;; da ogni moboio della lista e li appende in un unica lista.

(defun get-degrees-pol (p)
  (if(null p) nil
    (append (list 
             (third (first p)))
            (get-degrees-pol 
             (cdr p)))))

;;;; La funzione resitutisce la lista dei monomi del polinomio
;;;; passato nella forma standard o in quella a lista ordinandoli,
;;;; l'ordinamento viene gia eseguito nella funzione as-polynomial, 
;;;; in questa funzione viene solo estratta la lista dei monomi che 
;;;; sarebbe il second elemento della lista.

(defun monomials (p)
  (second (as-polynomial p)))

;;;; La funzione polyplus calcola la somma tra due polinomi passati
;;;; nella forma standard o in quella caratteristica,
;;;; la funzione appende le due liste dei monomi dei due polinomi poi 
;;;; tramite funzioni d'appoggio somma quelli con lo stesso varpower,
;;;; la somma viene eseguita sommando ogni monomio con tutti gli altri
;;;; con lo stesso varpower nella lista dei monomi dei due polinomi e
;;;; creando una lista con queste somme.
;;;; Viene anche considerato il caso in cui uno dei due polinomi sia
;;;; null, e infine
;;;; dal polinomio risultante vengono eliminati gli 0 e
;;;; viene ordinato.

(defun polyplus (p1 p2)
  (let ((sum (cond ((null p1) 
                    (list
                     'poly
                     (equal-zero
                      (plus (second (as-polynomial p2))))))
                   ((null p2) 
                    (list
                     'poly
                     (equal-zero 
                      (plus (second (as-polynomial p1))))))
                   ((and 
                     (not (null p1)) 
                     (not (null p2))) 
                    (list
                     'poly
                     (equal-zero 
                      (sort 
                       (plus (append 
                              (second (as-polynomial p1)) 
                              (second (as-polynomial p2))))
                       #'monomials-sort )))))))
    (if (null (first (second sum)))
        (list 
         'poly
         nil)
      sum)))

;;;; Funzione d'appoggio usata per eliminare gli elementi con
;;;; coefficiente 0 dalla lista dei monomi del polinomio.

(defun equal-zero (p)
  (cond ((null p) nil)
        ((/= 0 (second (first p)))
         (cons (first p) 
               (equal-zero (cdr p))))
        ((= 0 (second (first p)))
         (equal-zero (cdr p)))))

;;;; Funzione d'appoggio chiamata da polyplus che riceve la lista 
;;;; dei monomi dei due polinomi da sommare ed esegue la somma 
;;;; di quelli uguali tramite un altra funzione d'appoggio.


(defun plus (p)
  (cond ((null p) nil)
        ((> (list-length p) 1)
         (append 
          (list (plus-eq (first p) (cdr p))) 
          (plus (delete-eq (first p)(cdr p)))))
        ((= (list-length p) 1) p)))

;;;; Funzione d'appoggio usata nella somma tra polinomi che elimina
;;;; gli elementi con lo stesso varpower del monomio dalla lista dei polinomi,
;;;; viene usata per facilitare la somma tra polinomi evitando delle
;;;; somme rindondanti. 

(defun delete-eq (m p)
  (cond ((null p) nil)
        ((equal-vp (fourth m) (fourth (first p)))
         (delete-eq m (cdr p)))
        ((not (equal-vp (fourth m) (fourth (first p))))
         (cons (first p) (delete-eq m (cdr p))))))

;;;; Funzione d'appoggio chiamata da plus che restituisce la somma
;;;; tra il monomio e il polinomio passato.

(defun plus-eq (m p)
  (cond ((null p) m)
        ((equal-vp 
               (fourth m) 
               (fourth (first p)))
         (plus-eq (list 
                   'm 
                   (+ 
                    (eval (second m)) 
                    (eval (second (first p))))
                   (third m)
                   (fourth m))
                  (cdr p)))
        ((not (equal-vp (fourth m) (fourth (first p))))
         (plus-eq m (cdr p)))))

;;;; Funzione d'appoggio che restituisce true se due varpower sono
;;;; uguali, usata per gestire la somma tra monomi con lo stesso varpower.

(defun equal-vp (vp1 vp2)
  (cond ((and (null vp1) (not (null vp2))) nil)
        ((and (null vp2) (not (null vp2))) nil)
        ((and (null vp1) (null vp2)) t)
        ((and
          (eq 
           (list-length vp1) 
           (list-length vp2))
          (= 1 (list-length vp1))
          (= 
           (second (first vp1))
           (second (first vp2)))
          (string-equal 
           (third (first vp1))
           (third (first vp2))))
         t)
        ((not (eq (list-length vp1) (list-length vp2))) nil)
        ((and (eq 
               (list-length vp1) 
               (list-length vp2)) 
              (= 
               (second (first vp1))
               (second (first vp2)))
              (string-equal 
               (third (first vp1))
               (third (first vp2))))
         (equal-vp (cdr vp1) (cdr vp2)))))

;;;; La funzione polyminus esegue la sottrazione tra due polinomi
;;;; passati nella forma standard o in quella a lista,
;;;; la funzione inverte i segni dei monomi del secondo polinomio
;;;; e poi richiama la funzione polyplus definita sopra per calcolare
;;;; la differenza,
;;;; la funzione tiene anche conto del caso in cui uno dei duo
;;;; polinomi sia null.

(defun polyminus (p1 p2)
  (cond ((null p2) 
         (polyplus (as-polynomial p1) nil))
        ((null p1) 
         (list
          'poly
          (invert-coeff (second (as-polynomial p2)))))
        ((polyplus p1 (list 
                       'poly 
                       (invert-coeff (second (as-polynomial p2))))))))

;;;; Funzione d'appoggio usata in polyminus che inverti il segno dei 
;;;; coefficienti dei monomi che compaiono nel polinomio, usata per
;;;; seguire successivamente la differenza tra 
;;;; il primo polinomio e quello risultante da questa funzione.

(defun invert-coeff (p)
  (if (null p) nil
    (cons (list 
             'm 
             (* -1 (eval (second (first p)))) 
             (third (first p)) 
             (fourth (first p)))
            (invert-coeff (cdr p)))))

;;;; La funzione polytimes esegue la moltiplicazione tra due polinomi 
;;;; passati nella forma standard o in quella a lista considerando 
;;;; anche il fatto che uno dei 
;;;; due possa essere nil, poi la fuznione semplifica il risultato 
;;;; sommando quelli con lo stesso varpower e eliminando quelli con
;;;; coeff uguale a 0.

(defun polytimes (p1 p2)
  (cond ((null p1) (as-polynomial p2))
        ((null p2) (as-polynomial p1))
        ((and (not (null p1)) (not (null p2)))
         (list
          'polyu
          (equal-zero 
           (plus (prod 
                  (second (as-polynomial p1)) 
                  (second (as-polynomial p2)))))))))

;;;; Funzione d'appoggio chiamata da polytimes che riceve due liste 
;;;; di monomi gia parsati e crea la lista dei prodotto basandosi 
;;;; su un altra funzione che li calcola.

(defun prod (p1 p2)
  (if (null p1) nil
    (append
     (prod-mon (first p1) p2)
     (prod (cdr p1) p2))))

;;;; Funzione d'appoggio chiamata da prod che restituisce 
;;;; la moltiplicazione tra un monomio e una lista di monomi
;;;;  passati, poi verranno appesi tutti in una lista dal metodo prod.

(defun prod-mon (m p)
  (if (null p) nil
    (cons (list 
             'm
             (* (second m) (second (first p)))
             (+ (third m) (third (first p)))
             (prod-vp (append (fourth m) (fourth (first p)))))
            (prod-mon m (cdr p)))))

;;;; Funzione d'appoggio che restituisce la somma della lista 
;;;; dei varpowers passati, questa funzione viene richiamata 
;;;; in prod-mon quando viene creato il monomio risultante dalla
;;;; moltiplicazione.

(defun prod-vp (vp)
  (cond ((null vp) nil)
        ((not (null vp))
         (cons
          (somma-vp (first vp) (cdr vp))
          (prod-vp 
           (delete-vp 
            (first vp)
            (cdr vp)))))))

;;;; Funzione d'appoggio che elimina i varpowers uguali a vp dalla
;;;; lista vps, questa funzione serve a semplificare la somma dei
;;;; varpowers quando viene seguito il prodotto tra polinomi.

(defun delete-vp (vp vps)
  (cond ((null vps) nil)
        ((eq (third vp) (third (first vps)))
         (delete-vp vp (cdr vps)))
        ((not (eq (third vp) (third (first vps))))
         (cons (first vps) (delete-vp vp (cdr vps))))))

;;;; Funzione d'appoggio che viene richiamata in prod-vp che somma 
;;;; tutti i varpowers uguali a vp tra quelli della lista vps.

(defun somma-vp (vp vps)
  (cond ((null vps) vp)
        ((eq (third vp) (third (first vps)))
         (somma-vp (list 
                    'v 
                    (+ (eval (second vp)) (eval (second (first vps)))) 
                    (third vp))
                   (cdr vps)))
        ((not (eq (third vp) (third (first vps))))
         (somma-vp vp (cdr vps)))))
        
;;;; La funzione polyval restituisce il valore Value del polinomio
;;;;  Polynomial (che puo' anche essere un
;;;; monomio), nel punto n-dimensionale rappresentato dalla lista
;;;;  VariableValues, che contiene un valore per
;;;; ogni variabile ottenuta con la funzione variables.
;;;; La funzione sostituisce nei polinomio le variabili della lista
;;;;  v e poi richiama la funzione eval su di esso
;;;; La funzione restitusce (0) nel caso in cui il polinomio sia uguale
;;;;  a nil o quando il polinomio passato venga semplificato a nil o 
;;;; quando la lista dei valori delle variabili sia
;;;;  minore di quella delle variabili del polinomio.

(defun polyval (p v)
  (if (null p) 0
         (let ((vars (variables (as-polynomial p)))) 
           (if (>= (list-length v) (list-length vars))
               (let ((result (eval (append 
                                    (list '+) 
                                    (sost-p 
                                     (second (as-polynomial p))
                                     vars v)))))
                 (if (null result) 0
                   result))
             0))))

;;;; Funzione d'appoggio che ricrea i monomi della lista di monomi p
;;;; con i valori della lista v al posto delle variabili della lista 
;;;; vars nella forma standard,
;;;; cioè (* v1 v2 ecc).

(defun sost-p (p vars v)
  (if (null p) nil
    (cons
     (append
      (list 
       '* 
       (second (first p)))
      (sost-vp (fourth (first p)) vars v))
     (sost-p (cdr p) vars v))))

;;;; Funzione d'appoggio che ricostruisce i varpowers della lista vp
;;;; passata sostituendo le variabili della lista var con i relativi valori
;;;; della lista v nella forma (expt base esponente).

(defun sost-vp (vp vars v)
  (if (null vars) nil
        (append
         (create-vp vp (first vars) (first v)) 
         (sost-vp vp (cdr vars) (cdr v)))))

;;;; Funzione d'appoggio che ricrea il singolo varpower nella forma 
;;;; (expt base esponente) sistituendo la variabile var con il valore value.

(defun create-vp (vp var value)
  (cond ((null vp) nil)
        ((string-equal (third (first vp)) var)
         (cons
          (list
           'expt  
           value 
           (second (first vp)))
          (create-vp (cdr vp) var value)))
        ((not (string-equal (third (first vp)) var))
         (create-vp (cdr vp) var value))))

;;;; end of file -- mvpoli.lisp