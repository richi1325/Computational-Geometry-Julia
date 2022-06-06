# Computational Geometry in Julia
Este proyecto es una implementación de algunos algoritmos y códigos mostrados en: "J. O’Rourke (1998), Computational Geometry In C, Cambridge University Press." en el lenguaje de programación [Julia](https://julialang.org/), para la asignatura "Temas Selectos de Matemáticas II", perteneciente a la currícula de la licenciatura en Matemáticas Aplicadas y Computación de la División de Matemáticas e Ingeniería del plan de estudios 2014.

***
## Instrucciones
Para correr el código del repositorio es necesario contar con `docker` y `docker-compose` instalados. (Si no es el caso visitar: https://docs.docker.com/engine/install/ y https://docs.docker.com/compose/install/ respectivamente)  

Esto generará un contenedor, para acceder a él es necesario ejecutar el siguiente comando:  

```bash
docker-compose up -d --build
```
Ahora puede interactuar con el proyecto accediendo a: `127.0.0.1/lab` 

Si por el contrario desea detener el servicio, simplemente debe correr el siguiente código, esto dentendrá el contenedor y liberará el puerto `80`:
```bash
docker-compose down
```
***
## modules

Esta carpeta contiene la implementación de los algoritmos en archivos con la extención `*.jl` (_Script de Julia_), separados de los notebooks para mantener a estos más legibles y para que los módulos puedan ser reutilizados o copiados para algún proyecto personal.

***
## Implementaciones

Es esta carpeta puede encontrar ejemplos implementando los algoritmos que desarrollamos de las diferentes unidades que contempló nuestro curso, cada unidad cuenta con al menos los siguientes archivos:

| Archivo   	  | Descripción                                                                                  |
|-----------------|----------------------------------------------------------------------------------------------|
| `README.md`     | Contiene la lista de temas que contemplaba el temario para la respectiva unidad.             |
| `main.ipynb`    | Es un notebook de Julia con algunos ejemplos implementando los algoritmos que desarrollamos. |