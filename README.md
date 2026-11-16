# taxrules

progressive income tax as rules, with explanations and checks. A table is a list of band(From, Rate): income above From (whole dollars) is taxed at Rate percent until the next band. Tax is computed exactly in cents. The default table is the Australian resident rates for 2024-25 (no Medicare levy or offsets); it is an illustration, not tax advice.

## Use

```prolog
?- use_module(prolog/taxrules).
?- tax(60000, T).            % T = 878800 cents, i.e. $8,788
?- explain(60000, E).        % E = [band(18200, 16, 26800, 428800), band(45000, 30, 15000, 450000)]
?- marginal(60000, R).       % R = 30
```

## Proofs

`proofs/theorems.pl` proves 5 theorems by exhaustion: each one is checked for every case in a finite domain that covers every branch of the definitions. every whole-dollar income from 0 to 250,000 for the default table; and every valid table

1. The default table is valid, and tax never falls as income rises (checked dollar by dollar to 250,000).
2. Earning one more dollar never costs more than 45 cents of tax.
3. Tax is never more than 45% of income, and the explanation's bands add up to the tax.
4. For every valid small table, net income never falls as income rises.
5. Marginal rate is the rate of the band the next dollar falls into.

```sh
swipl -g main -t halt proofs/theorems.pl
```

## 200 inputs and outputs

`io/ios.txt` lists 200 inputs and outputs from real runs, and `io/ios.pl` has the same as Prolog facts. The inputs come from a fixed seed (`io/cases.pl`). `swipl -g check -t halt io/run.pl` runs them again. It fails if any output changes, or if a predicate doesn't confirm its own recorded output, which checks steadfastness. GitHub Actions runs the proofs and the examples on every push, and records the examples on the first push.

Licence: BSD-3-Clause.
