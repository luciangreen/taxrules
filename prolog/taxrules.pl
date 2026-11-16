% taxrules: progressive income tax as rules, with explanations and checks. A table is a list of
% band(From, Rate): income above From (whole dollars) is taxed at Rate percent until the next band.
% Tax is computed exactly in cents. The default table is the Australian resident rates for
% 2024-25 (no Medicare levy or offsets); it is an illustration, not tax advice.
%?- tax(60000, T).            % T = 878800 cents, i.e. $8,788
%?- explain(60000, E).        % E = [band(18200, 16, 26800, 428800), band(45000, 30, 15000, 450000)]
%?- marginal(60000, R).       % R = 30
:- module(taxrules, [bands/1, tax/2, tax/3, explain/2, explain/3, marginal/2, marginal/3, net/3, valid_table/1]).
:- use_module(library(lists)).
:- use_module(library(apply)).

bands([band(0, 0), band(18200, 16), band(45000, 30), band(135000, 37), band(190000, 45)]).

tax(I, T) :- bands(Tb), tax(Tb, I, T).
tax(Tb, I, T) :- explain(Tb, I, E), foldl([band(_, _, _, C), A0, A]>>( A is A0 + C ), E, 0, T).

explain(I, E) :- bands(Tb), explain(Tb, I, E).
% explain(+Table, +Income, -Bands): each taxed band with its rate, dollars in it and cents of tax.
explain(Tb, I, E) :- findall(band(F, R, D, C), ( nextto_or_last(Tb, band(F, R), Upper), I > F, ( Upper == inf -> Top = I ; Top is min(I, Upper) ), D is Top - F, D > 0, R > 0, C is D * R ), E).
nextto_or_last(Tb, B, Upper) :- append(_, [B|Rest], Tb), ( Rest = [band(U, _)|_] -> Upper = U ; Upper = inf ).

marginal(I, R) :- bands(Tb), marginal(Tb, I, R).
marginal(Tb, I, R) :- findall(Rt, ( member(band(F, Rt), Tb), I >= F ), Rs), ( last(Rs, R0) -> R = R0 ; Tb = [band(_, R)|_] ).

% net(+Table, +Income, -NetCents)
net(Tb, I, N) :- tax(Tb, I, T), N is I * 100 - T.

% A table is valid when it starts at 0, its thresholds rise and its rates rise and stay within 0..100.
valid_table([band(0, R)|Bs]) :- foldl([band(F, Rt), F0-R0, F-Rt]>>( F > F0, Rt >= R0, Rt =< 100 ), Bs, 0-R, _), between(0, 100, R).
