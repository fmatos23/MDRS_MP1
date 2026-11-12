# MDRS Mini-Projeto 1 — Resultados das Tarefas 1 e 2

12/11/2026

## Parâmetros

| Parâmetro | Valor |
| --- | --- |
| Capacidade da ligação C | 10 Mbps |
| Critério de paragem P | 100 000 pacotes transmitidos |
| Corridas por cenário | 50 |
| Filas | f = 1 000 000 B (FIFO); f1 = f2 = 1 000 000 B (prioridades) |
| Tamanho dos pacotes (uniforme discreto) | Fluxo 1: 100–1500 B · Fluxo 2: 100–150 B · Fluxo 3: 500–1000 B |

| Caso | λ Fluxo 1 (pps) | λ Fluxo 2 (pps) | λ Fluxo 3 (pps) |
| --- | --- | --- | --- |
| A | 400 | 400 | 600 |
| B | 600 | 600 | 600 |
| C | 800 | 800 | 600 |

## Tarefa 1 — FIFO

### 1.b — Simulação, caso C

| Parâmetro | Fluxo 1 | Fluxo 2 | Fluxo 3 |
| --- | --- | --- | --- |
| Packet loss (%) | 0.000 ± 0.000 | 0.000 ± 0.000 | 0.000 ± 0.000 |
| Atraso médio (ms) | 7.324 ± 0.176 | 6.780 ± 0.169 | 7.278 ± 0.171 |
| Atraso máximo (ms) | 43.932 ± 2.223 | 43.487 ± 2.205 | 43.673 ± 2.211 |
| Throughput (Mbps) | 5.116 ± 0.008 | 0.799 ± 0.001 | 3.595 ± 0.005 |

### 1.c — Teoria M/G/1 vs simulação, caso C

| Parâmetro | Fluxo 1 | Fluxo 2 | Fluxo 3 |
| --- | --- | --- | --- |
| Atraso médio simulado (ms) | 7.3243 ± 0.1758 | 6.7805 ± 0.1690 | 7.2778 ± 0.1713 |
| Atraso médio teórico (ms) | 7.3438 | 6.8038 | 7.3038 |
| Throughput simulado (Mbps) | 5.1158 ± 0.0076 | 0.7987 ± 0.0010 | 3.5948 ± 0.0054 |
| Throughput teórico (Mbps) | 5.1200 | 0.8000 | 3.6000 |

### 1.d — Fluxo 3 nos casos A, B e C

| Caso | Atraso médio (ms) | Atraso máximo (ms) |
| --- | --- | --- |
| A | 1.2291 ± 0.0026 | 8.7842 ± 0.2187 |
| B | 1.9742 ± 0.0099 | 14.6136 ± 0.5233 |
| C | 7.1313 ± 0.1614 | 42.6011 ± 1.5987 |

## Tarefa 2 — Prioridades

### 2.b — Simulação, caso C

| Parâmetro | Fluxo 1 | Fluxo 2 | Fluxo 3 |
| --- | --- | --- | --- |
| Packet loss (%) | 0.000 ± 0.000 | 0.000 ± 0.000 | 0.000 ± 0.000 |
| Atraso médio (ms) | 10.918 ± 0.290 | 10.378 ± 0.283 | 1.102 ± 0.001 |
| Atraso máximo (ms) | 67.258 ± 3.446 | 67.057 ± 3.428 | 4.580 ± 0.117 |
| Throughput (Mbps) | 5.115 ± 0.006 | 0.800 ± 0.001 | 3.597 ± 0.006 |

### 2.c — Teoria M/G/1 com prioridades vs simulação, caso C

| Parâmetro | Fluxo 1 | Fluxo 2 | Fluxo 3 |
| --- | --- | --- | --- |
| Atraso médio simulado (ms) | 10.9177 ± 0.2899 | 10.3775 ± 0.2832 | 1.1017 ± 0.0014 |
| Atraso médio teórico (ms) | 11.1148 | 10.5748 | 1.1028 |

### 2.d — Fluxo 3 nos casos A, B e C

| Caso | Atraso médio (ms) | Atraso máximo (ms) |
| --- | --- | --- |
| A | 0.9394 ± 0.0010 | 4.4816 ± 0.1113 |
| B | 1.0225 ± 0.0012 | 4.5748 ± 0.0905 |
| C | 1.1032 ± 0.0015 | 4.4667 ± 0.1104 |

## FIFO vs prioridades

| Fluxo 3 | FIFO — médio (ms) | Prioridade — médio (ms) | FIFO — máximo (ms) | Prioridade — máximo (ms) |
| --- | --- | --- | --- | --- |
| Caso A | 1.23 | 0.94 | 8.78 | 4.48 |
| Caso B | 1.97 | 1.02 | 14.61 | 4.57 |
| Caso C | 7.13 | 1.10 | 42.60 | 4.47 |
