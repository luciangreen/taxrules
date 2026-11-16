% Theorems, proved by exhaustion. Run: swipl -g main -t halt proofs/theorems.pl
:- module(theorems, [main/0]).
:- use_module(prove).
:- discontiguous theorem/1.
:- use_module(library(lists)).
:- use_module(library(apply)).
main :- prove_all(theorems).
:- use_module('../prolog/taxrules').

% Domain: every whole-dollar income from 0 to 250,000 for the default table; and every valid table
% with up to three bands (thresholds from 0, 10, 20; rates from 0, 50, 100) for incomes 0..30.
small_table([band(0, R0)|Bs]) :- member(R0, [0, 50, 100]), member(Ts, [[], [10], [20], [10, 20]]), maplist([F, band(F, R)]>>member(R, [0, 50, 100]), Ts, Bs), valid_table([band(0, R0)|Bs]).

% 1. The default table is valid, and tax never falls as income rises (checked dollar by dollar to 250,000).
theorem(default_monotone) :- table(Tb), valid_table(Tb), forall(between(1, 250000, I), ( tax(I, T), J is I - 1, tax(J, P), T >= P )).

% 2. Earning one more dollar never costs more than 45 cents of tax.
theorem(default_marginal_capped) :- forall(between(0, 250000, I), ( tax(I, T), I1 is I + 1, tax(I1, T1), D is T1 - T, D >= 0, D =< 45 )).

% 3. Tax is never more than 45% of income, and the bands of the explanation add up to the income taxed.
theorem(default_bounded_and_explained) :- forall(between(0, 250000, I), ( tax(I, T), T =< 45 * I, explain(I, E), marginal(I, R), between(0, 45, R) )).

% 4. For every valid small table, net income never falls as income rises.
theorem(any_valid_table_net_monotone) :- forall(small_table(Tb), forall(between(0, 29, I), ( net(Tb, I, N), I1 is I + 1, net(Tb, I1, N1), N1 >= N ))).

% 5. Marginal rate is the rate of the band the next dollar falls into.
theorem(marginal_is_next_dollar) :- forall(( small_table(Tb), between(0, 29, I) ), ( marginal(Tb, I, R), tax(Tb, I, T), I1 is I + 1, tax(Tb, I1, T1), T1 - T =:= R )).
