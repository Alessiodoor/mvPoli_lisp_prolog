%%%% 807457 Porta Alessio
%%&& 808710 Dennis Verdino

%%%% -*- Mode: Prolog -*-

%%%% mvpoli.pl

%% . is_monomial(monomial(coefficient, total degree, varpowers).
% E' vero quando total degree é un intero maggiore di 0 e
% varpowers é una lista

is_monomial(m(_C, TD, VPs)) :-
	integer(TD),
	TD >= 0,
	is_list(VPs),
	foreach(member(VP, VPs), is_varpower(VP)).

%% . is_varpower(varpower(Power, VarSymbol)).
% E' vero quando Power é un intero maggiore di 0 e
% VarSymbol é un atomo.

is_varpower(v(Power, VarSymbol)) :-
	integer(Power),
	Power >= 0,
	atom(VarSymbol).

%% . is_polinomial(poly(Monomials))
% E' vero quando Monomials é una lista e
% ogni elemento é un monomio.

is_polynomial(poly(Monomials)) :-
	is_list(Monomials),
	foreach(member(M, Monomials), is_monomial(M)).

%% . as_monomial(Expression, Monomial).
% E' vero quando Monomial è il termine che rappresenta il
% monomio risultante dal "parsing" dell'espressione Expression.
% Se Expression è 0 viene creato direttamente il monomio m(0, 0, [])
% se invece Expression è diversa da zero vengono chiamati tre predicati
% uno per il coefficiente, uno per il totaldegree e uno per i varpowers
% in fine viene ordinato in base alle variabili di varpowers e
% controllato se è un monomio nella forma richiesta.

as_monomial(Ex, M) :-
	estrai_coeff(Ex, C, ExR),
	ExR = 0,
	M = m(C, 0, []),
	is_monomial(M),
	!.

as_monomial(Ex, M) :-
	estrai_coeff(Ex, C, ExR),
	estrai_TD(ExR, TD),
	estrai_VP(ExR, VPs),
	invertiVP(VPs, VPI),
	msort(VPI, VPsO),
	invertiVP(VPsO, VP),
	M = m(C, TD, VP),
	is_monomial(M),
	!.

%% . estrai_coeff(Expression, Coefficient)
% vero quando C è il coefficiente dell'espressione,
% nel caso del compound verifica solo che il coefficiente sia coseno,
% seno, tangente, e potenze

estrai_coeff(X, X, 0) :-
	number(X),
	!.

estrai_coeff(X, 1, X) :-
	atom(X),
	!.

estrai_coeff(X ^ E, 1, X ^ E) :-
	atom(X),
	!.

estrai_coeff(-X ^ E, -1, -X ^ E) :-
	atom(X),
	!.

estrai_coeff(-X, -1, -X) :-
	atom(X),
	!.

estrai_coeff(X, R, 0) :-
	compound(X),
	estrai_Compound(X, R),
	!.

estrai_coeff(X, C, R) :-
	X = F1 * F2,
	estrai_coeff(F1, C, Rs),
	Rs \= 0,
	R = Rs * F2,
	!.

estrai_coeff(X, C, F2) :-
	X = F1 * F2,
	estrai_coeff(F1, C, Rs),
	Rs = 0,
	!.

%% . estrai_Compound(Expression, Result)
%% vero quando  Result è il coefficiente composto dell'espressione

estrai_Compound(cos(X), cos(X)) :-
	number(X),
	!.

estrai_Compound(cos(X), cos(R)) :-
	compound(X),
	estrai_Compound(X, R),
	!.

estrai_Compound(sin(X), sin(X)) :-
	number(X),
	!.

estrai_Compound(sin(X), sin(R)) :-
	compound(X),
	estrai_Compound(X, R),
	!.

estrai_Compound(tan(X),tan(X)) :-
	number(X),
	!.

estrai_Compound(tan(X), tan(R)) :-
	compound(X),
	estrai_Compound(X, R),
	!.

estrai_Compound(B^E, B^E) :-
	estrai_Compound(B, _),
	estrai_Compound(E, _),
	!.

estrai_Compound(B^E, B^E) :-
	estrai_Compound(B, _),
        number(E),
	!.

estrai_Compound(B^E, B^E) :-
	estrai_Compound(E, _),
        number(B),
	!.

estrai_Compound(B^E, B^E) :-
	number(E),
        number(B),
	!.

%% . estrai_TD(Expression, TotalDegree)
% vero quando TD é il grado totale dell'espressione

estrai_TD(X, 1) :-
	atom(X),
	!.

estrai_TD(-X, 1) :-
	atom(X),
	!.

estrai_TD(X, TD) :-
	X = F1 * F2,
	estrai_TD(F1, TDs),
	estrai_TD(F2, TDs2),
	TD is TDs + TDs2,
	!.

estrai_TD(X ^ E, E) :-
	atom(X),
	integer(E),
	E >= 0,
	!.

estrai_TD(-X ^ E, E) :-
	atom(X),
	integer(E),
	E >= 0,
	!.

%%  . estrai_VP(Epressionx, VarPowers)
% vero quando VP è la lista dei valori con le loro incognite

estrai_VP(X, [v(1, F2) | R]) :-
	X = F1 * F2,
	atom(F2),
	estrai_VP(F1, R),
	!.

estrai_VP(X, [v(E, B) | R]) :-
	X = F1 * F2,
	F2 = B ^ E,
	atom(B),
	integer(E),
	estrai_VP(F1, R),
	!.

estrai_VP(X, [v(1, X)]) :-
	atom(X),
	!.

estrai_VP(-X, [v(1, X)]) :-
	atom(X),
	!.

estrai_VP(B ^ E, [v(E, B)]) :-
	atom(B),
	integer(E),
	!.

estrai_VP(-B ^ E, [v(E, B)]) :-
	atom(B),
	integer(E),
	!.

%% . as_polynomial(Expression, Polynomial)
% vero quando P è il termine risultante dal parsing dell'espressione
% Expression.
% Nel caso che Expression sia 0 il polinomio risultante è la lista
% vuota, se no vengono estratti i singoli monomi e poi ordinati in base
% al TotalDegree e ai VarPowers, in fine viene controllato se è nella
% forma richiesta

as_polynomial(Ex, poly([])) :-
	Ex = 0,
	is_polynomial(poly([])),
	!.

as_polynomial(Ex, poly(Sum)) :-
	Ex \= 0,
	estrai_mon(Ex, P),
	inverti_C_TD(P, PI),
	invertiC_VP(PI, PVP),
	msort(PVP, PO),
	invertiC_VP(PO, POR),
	inverti_TD_C(POR, PR),
	somma(PR, Sum),
	is_polynomial(poly(Sum)),
	!.

%% . estrai_mon(Expression, Polynomial)
% vero quando P è la lista di tutti i monomi di Expression

estrai_mon(Ex, P) :-
        Ex = M1 + M2,
	as_monomial(M2, M),
	estrai_mon(M1, Ps),
	append(Ps, [M], P),
	!.

estrai_mon(Ex, P) :-
	Ex = M1 - M2,
	as_monomial(M2, m(C, TD, VPs)),
	MR = m(-C, TD, VPs),
	estrai_mon(M1, Ps),
	append(Ps, [MR], P),
	!.

estrai_mon(Ex, [M]) :-
	as_monomial(Ex, M),
	!.

%% . inverti_C_TD(Monomial, Result)
% vero quanso Result è il monomio Monomial con il coefficiente e il
% TotalDegree invertiti

inverti_C_TD([m(C, TD, VP) | Ms], [m(TD, C, VPR) | R]) :-
	inverti_C_TD(Ms, R),
	invertiVP(VP, VPR),
	!.
inverti_C_TD([], []) :- !.

%% . invertiVP(VarPowers, Result)
% vero quando Result è la lista dei VarPowers con variabili e numeri
% invertiti

invertiVP([v(N, V) | VPs], [v(V, N) | R]) :-
	invertiVP(VPs, R),
	!.
invertiVP([], []) :- !.

%% . invertiC_VP(Monomial, Result)
% vero quando Result è il monomio Monomial con VarPowers e i
% coefficienti invertiti

invertiC_VP([m(TD, C, VP) | Ms], [m(TD, VP, C) | R]) :-
	invertiC_VP(Ms, R),
	!.
invertiC_VP([], []) :- !.

%% . inverti_TD_C(Monomial, Result)
% vero quanso Result è il monomio Monomial con i coefficiente e
% TotalDegree invertiti

inverti_TD_C([m(TD, C, VP) | Ms], [m(C, TD, VPR) | R]) :-
	inverti_TD_C(Ms, R),
	invertiVP(VP, VPR),
	!.
inverti_TD_C([], []) :- !.

%% . Predicate pprint_polynomial(Polynomial)
% Il predicato pprint_polynomial risulta vedo dopo aver stampa
%o (sullo "standard output") una rapp-
% resentazione tradizionale del termine polinomio associato a
% Polynomial. Si pu'o omettere il simbolo di moltiplicazione.
% Vengono chiamati due predicati, uno che stampa il primo monomio da
% solo e un altro che stampa tutti gli altri separati dal carattere *

pprint_polynomial(poly([M | Ms])) :-
	pprint_PrimoM(M),
	pprint_monomial(Ms).

%% . pprint_PrimoM(Monomial)
% stampa il primo monomio della lista nella forma caratteristica
% omettendo il + o il - davanti al monomio

pprint_PrimoM(m(C, TD, VPs)) :-
	stampaM(m(C, TD, VPs)),
	!.
pprint_PrimoM([]) :- !.

%% . pprint_monomial(Monomial)
% stampa la lista di monomi in forma caratteristica separati da + o - a
% seconda della forma del monomio

pprint_monomial([m(C, TD, VPs)]) :-
	C >= 0,
	CC is C,
	!,
	write(' '),
	write(+),
	write(' '),
	stampaM(m(CC, TD, VPs)).
pprint_monomial([m(C, TD, VPs)]) :-
	C < 0,
	CC is C,
	C1 is CC * -1,
	!,
	write(' '),
	write(-),
	write(' '),
	stampaM(m(C1, TD, VPs)).
pprint_monomial([m(C, TD, VPs) | Ms]) :-
	C >= 0,
	CC is C,
	!,
	write(' '),
	write(+),
	write(' '),
	stampaM( m(CC, TD, VPs)),
	pprint_monomial(Ms).

pprint_monomial([m(C, TD, VPs) | Ms]) :-
	C < 0,
	CC is C,
	C1 is CC * -1,
	!,
	write(' '),
	write(-),
	write(' '),
	stampaM(m(C1, TD, VPs)),
	pprint_monomial(Ms).
pprint_monomial([]) :- !.

%% . stampaM(Monomial)
% stampa ogni monomio della lista in forma caratteristica

stampaM(m(C, 0, [])) :-
	C \= 0,
	!,
	write(C).
stampaM(m(1, TD, VPs)) :-
	TD > 0,
	stampaVPs(VPs),
	!.
stampaM(m(C, TD, VPs)) :-
	TD > 0,
	!,
	write(C),
	write(' '),
	write(*),
	write(' '),
	stampaVPs(VPs).

%% . stampaVPs(VarPowers)
% stampa la lista dei VPs in forma caratteristica inserendo anche il
% simbolo di moltiplicazione

stampaVPs([v(N, V)]) :-
	N > 1,
	write(V^N),
	!.
stampaVPs([v(N, V)]) :-
	N = 1,
	write(V),
	!.
stampaVPs([v(0, _)]) :-
	!,
	write('1').

stampaVPs([v(N, V) | VPs]) :-
	N > 1,
	!,
	write(V^N),
	write(' '),
	write(*),
	write(' '),
	stampaVPs(VPs).
stampaVPs([v(N, V) | VPs]) :-
	N = 1,
	!,
	write(V),
	write(' '),
	write(*),
	write(' '),
	stampaVPs(VPs).
stampaVPs([v(0, _) | VPs]) :-
	!,
	write('1 * '),
	stampaVPs(VPs).

stampaVPs([]) :- !.

%% . coefficients(Poly, Coefficients)
% vero quando Coefficients è la lista dei coefficienti del polimonio
% poly.

coefficients(Poly, Cs) :-
	as_polynomial(Poly, PolyR),
	PolyR = poly(P),
	creaListaCs(P, Cs),
	!.

coefficients(Poly, Cs) :-
	Poly = poly(P),
	creaListaCs(P, Cs),
	!.

%% . creaListaCs(Polynomial, Coefficients)
% vero quando Coefficients è la lista dei coefficienti di Polynomial

creaListaCs([], []) :- !.

creaListaCs([m(C, _, _) | MR], [C | Cs]) :-
	creaListaCs(MR, Cs),
	!.

%% . variables(Poly, Variables)
% vero quando Variables è la lista dei simboli delle
% variabili di Poly

variables(Poly, RU) :-
	Poly = poly(P),
	creaListaVs(P, Vs),
	append(Vs, R),
	deleteDuplicates(R, RU).

%% . creaListaVs(Polynomial, Vars)
% vero quando Vars è la lista delle variabili di Polynomial

creaListaVs([], []) :- !.

creaListaVs([m(_, _, VPs) | Ms], [Vs | Vss]) :-
	estrai_Vs_Mon(VPs, Vs),
	creaListaVs(Ms, Vss),	!.

%% . deleteDuplicates(List, Result)
%vero quando Result è la lista List senza duplicati

deleteDuplicates([], []) :- !.
deleteDuplicates([X | Xs], [X | R]) :-
	notmember(X, Xs),
	deleteDuplicates(Xs, R),
	!.
deleteDuplicates([_ | Xs], R) :-
	deleteDuplicates(Xs, R),
	!.

notmember(_, []) :- !.
notmember(X, [Y | Ys]) :-
	X \= Y,
	notmember(X, Ys),
	!.

%% . estrai_Vs_Mon(VarPowers, Vars)
% vero quando Vars è la lista delle variabili della lista
% VarPowers

estrai_Vs_Mon([], []) :- !.

estrai_Vs_Mon([v(_, X) | VPs], [X | Vs]) :-
	estrai_Vs_Mon(VPs, Vs),
	!.

%% . maxdegree(Poly, Degree)
% vero quando Degree è il massimo grado dei monomi di Poly

maxdegree(Poly, Degree) :-
	as_polynomial(Poly, PolyR),
	PolyR = poly(P),
	getDegreeMax(P, Degree),
	!.

maxdegree(Poly, Degree) :-
	Poly = poly(P),
	getDegreeMax(P, Degree),
	!.

%% . getDregreeMax(Polynomial, Degree)
% vero quando D è il grado massimo della lista dei polinomi
%
getDegreeMax([], -1) :- !.

getDegreeMax([m(_, TD, _) | Ms], TD) :-
	getDegreeMax(Ms, TDs),
	TD >= TDs,
	!.

getDegreeMax([m(_, TD, _) | Ms], TDs) :-
	getDegreeMax(Ms, TDs),
	TD < TDs,
	!.

%% . mindegree(Poly, Degree)
% vero quando Degree è il grado minore dei monomi di Poly

mindegree(Poly, Degree) :-
	as_polynomial(Poly, PolyR),
	PolyR = poly(P),
	getDegrees(P, TD),
	getMinDegree(TD, Degree),
	!.


mindegree(Poly, Degree) :-
	Poly = poly(P),
	getDegrees(P, TD),
	getMinDegree(TD, Degree),
	!.

%% . getDegrees(Polynomial, Degree)
% vero quando Degree è la lista dei gradi della lista dei monomi
% Polynomial

getDegrees([], []) :- !.

getDegrees([m(_, TD, _) | Ms], [TD | TDs]) :-
	getDegrees(Ms, TDs),
	!.

getMinDegree(TDs, D) :-
	msort(TDs, TDsO),
	TDsO = [D | _].

%% . monomials(Poly, Monomials)
% vero quando Monomials è la lista ordinata dei	monomi che
% compaiono in Poly

monomials(Poly, P) :-
	Poly = poly(P),
	!.

monomials(Poly, P) :-
	as_polynomial(Poly, R),
	R = poly(P),
	!.

%% . polyplus(Poly1, Poly2, Result)
% vero quando Result è la somma dei polinomi Poly e Poly2(Vedere caso in
% forma normale)

polyplus(Poly1, Poly2, poly(R)) :-
	as_polynomial(Poly1, AsP1),
	as_polynomial(Poly2, AsP2),
	AsP1 = poly(P1),
	AsP2 = poly(P2),
	append(P1, P2, Ps),
	somma(Ps, R),
	!.

polyplus(Poly1, Poly2, poly(R)) :-
	Poly1 = poly(P1),
	Poly2 = poly(P2),
	append(P1, P2, Ps),
	somma(Ps, R),
	!.

%% . somma(Poly1, Poly2, Result)
% Vero quando Rerult è il sisultato della somma tra Poly1 e Poly2

somma([], []) :- !.

somma([M1 | Ps], [Somma | Sommas]) :-
	sommaMs(M1, Ps, Somma),
	Somma = m(C, _, _),
	C \= 0,
	elimina(M1, Ps, R),
	somma(R, Sommas),
	!.

somma([M1 | Ps], Sommas) :-
	sommaMs(M1, Ps, Somma),
	Somma = m(C, _, _),
	C = 0,
	elimina(M1, Ps, R),
	somma(R, Sommas),
	!.


%% . sommaMs(Monomial, Monomials, Result)
% Vero quando result è il risultato della somma tra i monomi uguali a
% Monomial nella lista di monomi

sommaMs(m(C1, TD1, VPs1), [], m(C1, TD1, VPs1)) :- !.

sommaMs(m(C1, TD1, VPs1), [m(C2, _, VPs2) | Ms], m(Cs, TD1, VPs1)) :-
	list_to_set(VPs1, VPs2),
	CR is C1 + C2,
	sommaMs(m(CR, TD1, VPs1), Ms, m(Cs, _, _)),
	!.

sommaMs(m(C1, TD1, VPs1), [_ | Ms], m(Cs, TD1, VPs1)) :-
	sommaMs(m(C1, TD1, VPs1), Ms, m(Cs, _, _)),
	!.

%% . elimina(Monomial, Monomials, Result)
% Vero quando result è la lista dei monomi di Monomials omettendo quelli
% con lo stesso varpower di monomial

elimina(_, [], []) :- !.

elimina(m(C1, TD1, VPs1), [m(_, _, VPs2) | Ms], R) :-
	list_to_set(VPs1, VPs2),
	elimina(m(C1, TD1, VPs1), Ms, R),
	!.

elimina(E, [M | Ms], [M | R]) :-
	elimina(E, Ms, R),
	!.

%% . polyminus(Poly1, Poly2, Result)
% vero quando Result è il polinomio differenza tra Poly1 e
%Poly2 (vedere caso in forma normale)

polyminus(Poly1, Poly2, poly(R)) :-
	as_polynomial(Poly1, AsP1),
	as_polynomial(Poly2, AsP2),
	AsP1 = poly(P1),
	AsP2 = poly(P2),
	semplifica(P2, P2s),
	inverti_Coeff(P2s, P2I),
	append(P1, P2I, Ps),
	somma(Ps, R),
	!.

polyminus(Poly1, Poly2, poly(R)) :-
	Poly1 = poly(P1),
	Poly2 = poly(P2),
	semplifica(P2, P2s),
	inverti_Coeff(P2s, P2I),
	append(P1, P2I, Ps),
	somma(Ps, R),
	!.

%% . semplifica(Poly, Result)
% Vero quando Result è il polinomio Poly semplificato degli elementi con
% lo stesso varpower

semplifica([], []) :- !.

semplifica([M1 | Ps], [Diff | Diffs]) :-
	diffMs(M1, Ps, Diff),
	elimina(M1, Ps, R),
	semplifica(R, Diffs),
	!.

%% . inverti_Coeff(Poly, Result)
% Vero quando Result è la lista di monomi di Poly con il coefficiente
% invertito

inverti_Coeff([], []) :- !.

inverti_Coeff([m(C, TD, VPs) | Ms], [m(CI, TD, VPs) | Rs]) :-
	CI is C * -1,
	inverti_Coeff(Ms, Rs),
	!.

%% . diffMs(Monomial, Monomials, Result)
% Vero quando Result è il risultato della divisione tra i momonial e i
% monomi con il suo stesso varpower in Monomials

diffMs(m(C1, TD1, VPs1), [], m(CR, TD1, VPs1)) :-
	CR is C1,
	!.

diffMs(m(C1, TD1, VPs1), [m(C2, _, VPs2) | Ms], m(Cs, TD1, VPs1)) :-
	list_to_set(VPs1, VPs2),
	CR is C1 - C2,
	diffMs(m(CR, TD1, VPs1), Ms, m(Cs, _, _)),
	!.
diffMs(m(C1, TD1, VPs1), [_ | Ms], m(Cs, TD1, VPs1)) :-
	diffMs(m(C1, TD1, VPs1), Ms, m(Cs, _, _)),
	!.

%% . polytimes(Poly1, Poly2, Result)
% vero quando Result è il valore della moltplicazione tra Poly1 e Poly 2

polytimes(Poly1, Poly2, poly(R)) :-
	as_polynomial(Poly1, AsP1),
	as_polynomial(Poly2, AsP2),
	AsP1 = poly(P1),
	AsP2 = poly(P2),
	molt(P1, P2, Product),
	append(Product, Products),
	somma(Products, R),
	!.

polytimes(Poly1, Poly2, poly(R)) :-
	Poly1 = poly(P1),
	Poly2 = poly(P2),
	molt(P1, P2, Product),
	append(Product, Products),
	somma(Products, R),
	!.

%% . molt(Poly1, Poly2, Result)
% Vero quando Result è il prodotto tra Poly1 e Poly2

molt([], [], []) :- !.

molt(_, [], []) :- !.

molt([], _, []) :- !.

molt([M1 | Ms1], P2, [R | Rs]) :-
	product(M1, P2, R),
	molt(Ms1, P2, Rs),
	!.

%% . product(Monomial, Poly, Result)
% Vero quando Result è il prodotto tra Monomial e i polinomi di Poly

product(_, [], []) :- !.

product(m(C1, TD1, VPs1), [m(C2, TD2, VPs2) | M2s], [m(CR, TDR, VPsR) | Rs]) :-
	CR is C1 * C2,
	CR \= 0,
	TDR is TD1 + TD2,
	append(VPs1, VPs2, LVPs),
	prodVPs(LVPs, VPsR),
	product(m(C1, TD1, VPs1), M2s, Rs),
	!.

product(m(C1, TD1, VPs1), [m(C2, _, _) | M2s], [m(CR, 0, []) | Rs]) :-
	CR is C1 * C2,
	CR = 0,
	product(m(C1, TD1, VPs1), M2s, Rs),
	!.

%% . prodVPs(VarPowers, Result)
% Vero quando Result è la lista dei varpowers sommando le variabili
% uguali

prodVPs([], []) :- !.

prodVPs([VP1 | VPs], [R | VPsR]) :-
	sempliVPs(VP1 , VPs, R),
	eliminaVPs(VP1, VPs, VPe),
	prodVPs(VPe, VPsR),
	!.

%% . sempliVPs(VarPower, VarPowers, Result)
% Vero quando Result è la lista VarPowers senza quelli uguali a VaPower

sempliVPs(v(N, V), [], v(N, V)) :- !.

sempliVPs(v(N1, V1), [v(N2, V2) | VPs], v(NP, V1)) :-
	v(N1, V1) = v(N2, V2),
	NR is N1 + N2,
	sempliVPs(v(NR, V1), VPs, v(NP, _)),
	!.

sempliVPs(v(N1, V1), [v(N2, V2) | VPs], v(NP, V1)) :-
	v(N1, V1) \= v(N2, V2),
	sempliVPs(v(N1, V1), VPs, v(NP, _)),
	!.

%% . eliminaVPs(VarPower, VarPowers, Result)
% Vero quando Result è la lista Varpowers senza i varpower uguali a
% VarPower

eliminaVPs(_, [], []) :- !.

eliminaVPs(VP1, [VP2 | VP2s], R) :-
	VP1 = VP2,
	elimina(VP1, VP2s, R),
	!.

eliminaVPs(VP1, [VP2 | VP2s], [VP2 | R]) :-
	elimina(VP1, VP2s, R),
	!.

%% . polyval(Polynomial, VariableValues, Value)
% Il predicato polyval e' vero quanto Value contiene il valore del
% polinomio Polynomial (che puo anche
% essere un monomio), nel punto n-dimensionale rappresentato dalla lista
% VariableValues, che contiene un
% valore per ogni variabile ottenuta con il predicato variables/2.

polyval(Poly, VarValue, V) :-
	as_polynomial(Poly, AsP),
	variables(AsP, Vars),
	AsP = poly(P),
	sostituzione(P, Vars, VarValue, PSs),
	append(PSs, PS),
	risolvi(PS, V),
	!.

polyval(Poly, VarValue, V) :-
	variables(Poly, Vars),
	Poly = poly(P),
	sostituzione(P, Vars, VarValue, PSs),
	append(PSs, PS),
	risolvi(PS, V),
	!.

%% . sostituzione(Poly, Vars, VarValue, Result)
% Vero quando Result è la lista di polinomi che compaiono in poly con le
% variabili sostituite dai valori che compaiono in VarValue

sostituzione(_, [], [], []) :- !.
sostituzione(P, [V1 | Vs], [Val1 | Vals], [R | Rs]) :-
	sostM(P, V1, Val1, R),
	sostituzione(P, Vs, Vals, Rs),
	!.

%% . sostM(Poly, Var, Value, Result)
% Vero quando Result è la lista di monomi di Poly dove quelli con la
% varibile uguale a Var è sostituita con il valore Value

sostM([], _, _, []) :- !.

sostM([m(C, TD, VPs) | Ms], Var, Value, [m(C, TD, R) | Rs]) :-
	sostVPs(VPs, Var, Value, R),
	R \= [],
	sostM(Ms, Var, Value, Rs),
	!.

sostM([m(C, TD, VPs) | Ms], Var, Value, [m(C, TD, []) |Rs]) :-
	sostVPs(VPs, Var, Value, R),
	R = [],
	TD = 0,
	sostM(Ms, Var, Value, Rs),
	!.

sostM([m(_, TD, VPs) | Ms], Var, Value, Rs) :-
	sostVPs(VPs, Var, Value, R),
	R = [],
	TD \= 0,
	sostM(Ms, Var, Value, Rs),
	!.


%% . sostVPs(VarPowers, Var, Value, Result)
% Vero quando Result è la lista dei varpowers di VarPowers dove la
% variabile Var è sistituita con il valore Value

sostVPs([], _, _, []) :- !.

sostVPs([v(N, Var) | VPs], Var, Value, [v(N, Value) | Rs]) :-
	sostVPs(VPs, Var, Value, Rs),
	!.

sostVPs([v(_, V) | VPs], Var, Value,  Rs) :-
	V \= Var,
	sostVPs(VPs, Var, Value, Rs),
	!.

%% . risolvi(Poly, Result)
% Vero quando Result è il risultato del calcolo del polinomio Poly

risolvi([], 0) :- !.

risolvi([m(C, _, VPs) | Ms], R) :-
	risolviVPs(VPs, RVPs),
	R1 is C * RVPs,
	risolvi(Ms, Rs),
	R is R1 + Rs,
	!.

%% . risolviVPs(VarPowers, Result)
% Vero quando Result è il risultato del calcolo dei varpowers di
% VarPowers

risolviVPs([], 1) :- !.

risolviVPs([v(N1, N2) | VPs], R) :-
	R1 is N2 ^ N1,
	risolviVPs(VPs, Rs),
	R is R1 * Rs,
	!.

%%%% end of file -- mvpoli.pl





































