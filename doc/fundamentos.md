# Funcionamento de uma SHELL

┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   READ      │ →   │   PARSE     │ →   │  EXECUTE    │ →   │   LOOP      │
│  (Ler)      │     │ (Dividir)   │     │  (Executar) │     │  (Repetir)  │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
   getline()          strtok()           fork()+exec()        while(status)


## Processos (fork, exec, wait)

O fork() é utilizado pois, no linux um processo não pode simplesmente se transformar em outro diretamente, é preciso:

1. Clonar o processo atual (fork)
2. No processo clone (filho), trocar o programa (exec)
3. No processo original (pai), esperar o filho terminar (wait)

PAI (vsw-shell)        FILHO (clone do vsw-shell)
     │                          │
     │────── fork() ───────────→│  // Cria cópia
     │                          │
     │←───── PID do filho ──────│  // Pai continua
     │                          │
     │                          ↓
     │                    execve("/bin/ls", ...)
     │                          │
     │                    [transforma em ls]
     │                          │
     │←───── waitpid() ─────────┘  // Pai espera
     │
   [continua shell]

No código, foram utilizadas as seguintes variáveis:

- **pid_t pid** -> ID do processo (int);
- **int status** -> Status de saída do filho;
- **pid = fork()** -> Retorna o 0 no filho, PID>0 no PAI, -1 erro;



