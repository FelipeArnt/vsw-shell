# Utilização de Python C API

## Método atual utilizado:


vsw-shell → fork() → execl("/bin/python3", "python3", "script.py", NULL)
     ↑                                          ↓
     └──────────── waitpid() ←──────────────────┘
Problemas:
- Overhead de criar processo (lento)
- Não compartilha memória
- Difícil passar dados complexos
- Python inicia do zero toda vez


## Implementação do novo método:

vsw-shell ──→ Python interpretador embutido ──→ Executa código
     ↑                    ↓
     └─────── Compartilha memória, variáveis, objetos ─────┘

Vantagens:
- Mesmo processo (rápido)
- Passa dados C ↔ Python diretamente
- Mantém estado entre chamadas
- Acesso total às libs Python (numpy, requests, etc)


## Arquitetura ideal VSW-SHELL:

vsw-shell (C)
    │
    ├── vsw_python_init() ──→ Py_Initialize() [única vez]
    │
    ├── Comando: autometro ──→ vsw_python_run_script("autometro", args)
    │                              │
    │                              ├── Importa módulo (cacheado pelo Python)
    │                              ├── Chama função main()
    │                              └── Retorna código de erro
    │
    ├── Comando: comparador ──→ vsw_python_run_script("comparador", args)
    │
    ├── Comando: tabela ─────→ vsw_python_run_script("tablelo", args)
    │
    └── vsw_python_fini() ──→ Py_Finalize() [ao sair]

## Vantagens sobre fork+execl:

| Aspecto               | fork+execl                       | Python C API                        |
| --------------------- | -------------------------------- | ----------------------------------- |
| Velocidade            | ~50-100ms (inicialização Python) | ~1-5ms (já inicializado)            |
| Memória               | Processo separado (isolado)      | Mesmo processo (compartilhado)      |
| Estado                | Perdido entre chamadas           | Mantido (variáveis globais, caches) |
| Complexidade de dados | Apenas strings/args              | Qualquer objeto Python              |
| Segurança             | Melhor (isolamento)              | Cuidar com código Python malicioso |
| Debugging             | strace, logs separados           | Integrado, mas mais complexo        |

