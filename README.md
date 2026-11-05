# MDRS – Mini-Projeto 1

Avaliação de desempenho de uma ligação ponto-a-ponto (C = 10 Mbps) com 3 fluxos.

## Estrutura

| Pasta/ficheiro | Conteúdo |
|---|---|
| `simuladores/` | `Sim3Flows` (1.a), `Sim3FlowsPrio` (2.a), `Sim3FlowsDRR` (3.a) |
| `utils/` | `runSims` (N corridas + IC), `plotBarsCI` (barras + error bars), `params` (dados comuns) |
| `task1b.m` … | um script por alínea |
| `results/` | figuras `.png` (os `.mat` não vão para o Git) |
| `relatorio/` | relatório |

## Como correr

Abrir o MATLAB na raiz do repositório e correr o script da alínea (ex.: `task1b`).
Cada script faz `addpath` das pastas necessárias.

## Divisão

- Tarefa 1 – Francisco
- Tarefa 2 – (colega)
- Tarefa 3 – (a definir)

## Regras Git

- `git pull` antes de começar, `commit` + `push` no fim.
- Um branch por tarefa (`task1`, `task2`, ...), merge para `main` quando funcionar.
- Não alterar `Sim3Flows.m` depois do merge da 1.a sem avisar (as Tarefas 2 e 3 partem dele).
