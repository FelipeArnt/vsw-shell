# Conceitos Fundamentais

1. Estrutura de Objetos Python

Tudo em python é um PyObject* ( Ponteiro para objeto opaco)

```c
PyObject *obj;        // Qualquer objeto Python
PyObject *lista;      // Uma lista Python
PyObject *dict;       // Um dicionário Python
PyObject *func;       // Uma função Python
```
2. Contagem de referências (Crítico)

Python usa garbage collection por contagem de referência:

```c
PyObject *str = PyUnicode_FromString("hello");  // refcnt = 1

Py_INCREF(str);   // refcnt = 2 (você quer usar mais)
Py_DECREF(str);   // refcnt = 1 (libera sua referência)
Py_DECREF(str);   // refcnt = 0 → Python libera memória!

// ESQUECER Py_DECREF = MEMORY LEAK
// Py_DECREF demais = SEGFAULT (use-after-free)
```

Fundamental lembra que:

- Funções `PySomething_New/From` que retornam `PyObject*` --> eu sou dono da referência --> DECREF quando terminar;
- Se eu passo o objeto para outra estrutura que guarda ele --> INCREF antes, DECREF sua cópia;
- `PyTuple_SetItem`, `PyList_SetItem` roubam referências (Não precisa DECREF depois)

## Conversões

| C → Python      | Função                        | Python → C | Função               |
| --------------- | ----------------------------- | ---------- | -------------------- |
| `int/long`      | `PyLong_FromLong()`           | `long`     | `PyLong_AsLong()`    |
| `double`        | `PyFloat_FromDouble()`        | `double`   | `PyFloat_AsDouble()` |
| `char*`         | `PyUnicode_FromString()`      | `char*`    | `PyUnicode_AsUTF8()` |
| `char*` (bytes) | `PyBytes_FromString()`        | `char*`    | `PyBytes_AsString()` |
| `void*` (raw)   | `PyBytes_FromStringAndSize()` | -          | -                    |

