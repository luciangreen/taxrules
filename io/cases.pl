:- module(cases, [title/1, case/3]).
:- use_module('../prolog/taxrules').
:- use_module(engine).
title('taxrules').
income_g(I) :- rnd_pick([10000, 30000, 80000, 150000, 300000], M), rnd_int(0, M, I).
case(tax, [I], tax) :- income_g(I).
case(explain, [I], explain) :- income_g(I).
case(marginal, [I], marginal) :- income_g(I).
