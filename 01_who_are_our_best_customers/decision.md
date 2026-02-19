# Decision — Reactivation focus (Chinook)

## What we saw
- Выручка distributed evenly: VIP ~28%, Core ~25%, Occasional ~24%, Low ~23%.
- Middle segment gives ~57% всей выручки.
- At_risk gives ~21% выручки, но люди пропали в среднем ~459 дней.
- We have “возвращаемые” клиенты (comeback_count>0), it is better to reach them first.

## What are we doing
1) Wave #1: At_risk с comeback history (higher chance to bring back).
2) Wave #2: остальные At_risk.
3) VIP_sleepy: manually, точечно.

## Why
Вернуть старого клиента обычно дешевле, чем искать нового, а часть At_risk уже показывала паттерн что может камбекнуть

## Success Rate
- return rate in 30 days
- количество покупок за 30 дней
- выручка от вернувшихся
