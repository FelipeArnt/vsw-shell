# ANOTAÇÕES VSW-SHELLL

```c

/*
 *----------------------------------------------------------------------------------------------------------------*\
 * Estudando                                                                                                       |
 *----------------------------------------------------------------------------------------------------------------*\
 * ac = contador de argumentos;                                                                                    \
 * av = vetor de argumentos;                                                                                       |
 * execvp() = Troca o process image atual por um novo process image;                                               \
 * v = "vetor", p = "path";                                                                                        |
 * char **av = {"ls", "-la", NULL};                                                                                \
 * execvp ("ls", av);                                                                                              |
 *----------------------------------------------------------------------------------------------------------------*\
 * R --> Read          --> vsw_read_line() -> lê a linha de comando que foi digitada.                             |
 * E --> Evaluate      --> vsw_execute()   -> Decide se é builtin ou comando externo,faz fork/exec se necessário. |
 * P --> Print/Execute --> printf/perror;   -> Mostra prompt, saídas e erros.                                      |
 * L --> loop          --> while(status);   -> Repete até o usuário sair (ex: builtin "exit").                     |
 *----------------------------------------------------------------------------------------------------------------*\
 * [Entry point para uma shell sem loop]                                                                           |
 *----------------------------------------------------------------------------------------------------------------*|
 * int main (int ac, char **av){                                                                                   |
 * (void) ac;                                                                                                      |
 *  int status;                                                                                                    \
 *  // processo filho                                                                                              |
 *  if (fork() == 0)                                                                                               |
 *    execvp(av[1], av + 1); // Recebe um array de argumentos e usa o PATH para achar o executável.                |
 *  wait(&status);                                                                                                 \
 * }                                                                                                               |
 *----------------------------------------------------------------------------------------------------------------*|
 * [vetor de argumentos (av)]                                                                        |
 *----------------------------------------------------------------------------------------------------------------*\
 * [comando] -> [argumento] [argumento]                                                                            \
 * 1. tokens --> [ls]                                                                                              |
 * 2. tokens --> [-la]                                                                                             |
 * 3. tokens --> [arquivo]                                                                                         \
 * [ls] --> [-la]-[arquivo]                                                                                            |
 *----------------------------------------------------------------------------------------------------------------*|
 * [ while() ]                                                                                  |
 *----------------------------------------------------------------------------------------------------------------*|
 * 1. get line --> vsw_get_line(void)
 *
 *----------------------------------------------------------------------------------------------------------------*|
*/
’’’

