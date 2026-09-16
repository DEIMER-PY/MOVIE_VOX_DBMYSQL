# Proyecto de Modelado de Base de Datos

## VideoTienda MovieBox

## 1. Nombre del proyecto

**Diseño y Modelado de la Base de Datos para la VideoTienda MovieBox**

------

## 2. Contexto

La empresa **MovieBox** es una videotienta dedicada al alquiler y venta de películas y contenido audiovisual en formato físico. Actualmente, la administración de clientes, películas, copias disponibles, alquileres y pagos se realiza mediante hojas de cálculo y registros manuales.

El crecimiento del negocio ha generado problemas relacionados con:

- duplicidad de información;
- dificultad para saber qué películas están disponibles;
- pérdida de control sobre los alquileres;
- desconocimiento de las fechas de devolución;
- dificultad para calcular multas por retraso;
- ausencia de historial de clientes;
- dificultad para consultar cuáles películas son más alquiladas;
- falta de control sobre las copias físicas disponibles;
- poca trazabilidad sobre los pagos.

Por esta razón, MovieBox requiere diseñar una base de datos que permita administrar de manera organizada toda la información necesaria para su operación.

El propósito del proyecto consiste en realizar el **modelado de la base de datos**, comenzando por el análisis del negocio y finalizando con la representación estructurada del modelo de datos.

------

# 3. Objetivo general

Diseñar el modelo de datos para una videotienta, aplicando los principios de modelado conceptual, lógico y relacional, identificando correctamente entidades, atributos, relaciones, cardinalidades, claves y restricciones del negocio.

------

# 4. Objetivos específicos

El estudiante deberá:

- analizar los requerimientos del negocio;
- identificar las entidades principales;
- determinar los atributos de cada entidad;
- identificar claves primarias;
- identificar relaciones entre entidades;
- establecer cardinalidades;
- resolver relaciones muchos a muchos;
- transformar el modelo conceptual en un modelo lógico;
- definir claves foráneas;
- establecer restricciones de integridad;
- construir el diagrama ERD final.

------

# 5. Descripción general del negocio

MovieBox administra un catálogo de películas disponibles para alquiler.

De cada película se requiere almacenar información como:

- título;
- año de estreno;
- duración;
- clasificación por edades;
- descripción;
- idioma original.

Una película pertenece a uno o varios géneros.

Ejemplos:

```text
Acción
Drama
Comedia
Terror
Ciencia ficción
Animación
Documental
Romance
```

Una película puede tener varios actores y un actor puede participar en múltiples películas.

Además, cada película tiene uno o varios directores.

------

# 6. Copias físicas de las películas

MovieBox puede disponer de varias copias físicas de una misma película.

Por ejemplo:

```text
Película: Matrix

Copia 001
Copia 002
Copia 003
Copia 004
```

Cada copia debe ser administrada individualmente.

De cada copia se necesita conocer al menos:

- código de copia;
- película a la que pertenece;
- formato;
- fecha de adquisición;
- estado;
- disponibilidad.

Los formatos posibles pueden ser:

```text
DVD
Blu-ray
4K Blu-ray
```

El estado físico de la copia puede ser:

```text
Excelente
Bueno
Regular
Dañado
Fuera de servicio
```

Una copia dañada o fuera de servicio no puede ser alquilada.

------

# 7. Clientes

La videotienta requiere registrar la información de sus clientes.

De cada cliente se debe almacenar:

- número de identificación;
- nombres;
- apellidos;
- fecha de nacimiento;
- dirección;
- teléfono;
- correo electrónico;
- fecha de registro;
- estado del cliente.

Los estados posibles pueden ser:

```text
Activo
Suspendido
Inactivo
```

Un cliente suspendido no puede realizar nuevos alquileres.

------

# 8. Empleados

Los empleados de la videotienta son responsables de registrar los alquileres y las devoluciones.

De cada empleado se requiere almacenar:

- identificación;
- nombres;
- apellidos;
- cargo;
- teléfono;
- correo;
- fecha de contratación;
- estado.

Ejemplos de cargo:

```text
Administrador
Cajero
Auxiliar
```

------

# 9. Alquileres

Cuando un cliente desea alquilar una o varias películas, se genera un alquiler.

El alquiler debe registrar:

- número del alquiler;
- cliente;
- empleado que realiza la operación;
- fecha del alquiler;
- fecha prevista de devolución;
- estado del alquiler;
- valor total.

Un alquiler puede contener una o varias copias de películas.

Ejemplo:

```text
Alquiler 1001

Cliente:
Laura Pérez

Copias alquiladas:

Matrix - copia 003
Avatar - copia 002
Interstellar - copia 005
```

Por lo tanto, debe determinarse cómo representar correctamente esta relación.

------

# 10. Detalle del alquiler

Cada copia incluida en un alquiler puede tener información propia.

Por ejemplo:

- copia alquilada;
- precio de alquiler;
- fecha de devolución;
- días de retraso;
- multa;
- estado de devolución.

Ejemplo:

```text
Alquiler 1001

Matrix
Precio: $5.000
Fecha devolución: 10/09/2026
Multa: $0

Avatar
Precio: $5.000
Fecha devolución: 13/09/2026
Multa: $6.000
```

El estudiante debe analizar si esta información pertenece directamente al alquiler o si debe existir una estructura intermedia.

------

# 11. Devoluciones

Cuando una copia es devuelta, se debe registrar:

- fecha real de devolución;
- estado físico de la copia;
- observaciones;
- posibles daños;
- multa generada.

Una copia puede regresar en condiciones diferentes a aquellas en las que salió.

Ejemplo:

```text
Estado anterior:
Excelente

Estado devolución:
Regular
```

El sistema debe permitir conservar esta información.

------

# 12. Multas

Una multa puede generarse por:

```text
Retraso en devolución
Daño del material
Pérdida de la copia
```

De cada multa se debe conocer:

- alquiler relacionado;
- cliente;
- motivo;
- valor;
- fecha;
- estado.

Estados posibles:

```text
Pendiente
Pagada
Anulada
```

------

# 13. Pagos

Los clientes pueden realizar pagos relacionados con:

- alquileres;
- multas.

De cada pago se requiere registrar:

- número de pago;
- cliente;
- fecha;
- valor;
- método de pago;
- concepto;
- empleado que recibió el pago.

Métodos de pago:

```text
Efectivo
Tarjeta débito
Tarjeta crédito
Transferencia
```

El estudiante deberá analizar si un pago puede cubrir uno o varios conceptos.

------

# 14. Actores

De cada actor se requiere almacenar:

- código;
- nombres;
- apellidos;
- fecha de nacimiento;
- nacionalidad.

Un actor puede participar en muchas películas.

Una película puede contar con muchos actores.

Además, puede registrarse el nombre del personaje interpretado.

Ejemplo:

```text
Película:
The Matrix

Actor:
Keanu Reeves

Personaje:
Neo
```

------

# 15. Directores

De cada director se requiere almacenar:

- código;
- nombres;
- apellidos;
- fecha de nacimiento;
- nacionalidad.

Un director puede dirigir varias películas.

Una película también puede contar con uno o varios directores.

------

# 16. Géneros

MovieBox clasifica las películas mediante géneros.

De cada género se necesita registrar:

- código;
- nombre;
- descripción.

Ejemplo:

```text
Película:
Interstellar

Géneros:
Ciencia ficción
Drama
Aventura
```

Una película puede pertenecer a múltiples géneros.

Un género puede contener múltiples películas.

------

# 17. Reglas de negocio

El modelo deberá considerar las siguientes reglas:

1. Cada película debe tener un identificador único.
2. Una película puede disponer de múltiples copias.
3. Una copia pertenece exclusivamente a una película.
4. Una copia solamente puede encontrarse en un alquiler activo al mismo tiempo.
5. Un cliente puede realizar múltiples alquileres a lo largo del tiempo.
6. Un alquiler pertenece exclusivamente a un cliente.
7. Un alquiler debe ser registrado por un empleado.
8. Un alquiler puede contener una o varias copias.
9. Una copia puede ser alquilada muchas veces durante su vida útil.
10. Una película puede pertenecer a varios géneros.
11. Un género puede clasificar múltiples películas.
12. Una película puede tener varios actores.
13. Un actor puede participar en múltiples películas.
14. Una película puede tener uno o varios directores.
15. Un director puede dirigir múltiples películas.
16. Un cliente suspendido no puede realizar nuevos alquileres.
17. Una copia dañada o fuera de servicio no puede ser alquilada.
18. Cuando una copia se encuentre alquilada, debe considerarse no disponible.
19. Cuando una copia sea devuelta, deberá actualizarse su disponibilidad.
20. Si una devolución se realiza después de la fecha límite, puede generarse una multa.
21. Los pagos deben conservarse como historial y no deben eliminarse físicamente.
22. El número de identificación de un cliente debe ser único.
23. El correo electrónico de un cliente no puede estar asociado a dos clientes diferentes.
24. El código de cada copia física debe ser único.
25. Una película no debe existir sin título.

------

# 18. Caso de ejemplo

Considere la siguiente situación:

El cliente:

```text
Juan Carlos Gómez
CC 1098123456
```

realiza un alquiler el:

```text
10 de septiembre de 2026
```

Alquila:

```text
Matrix
Copia DVD-00015

Interstellar
Copia BR-00021
```

El alquiler es registrado por:

```text
Empleado:
Andrea Martínez
```

La fecha límite de devolución es:

```text
13 de septiembre de 2026
```

Juan devuelve Matrix el día:

```text
13 de septiembre
```

sin retraso.

Sin embargo, devuelve Interstellar:

```text
16 de septiembre
```

generando tres días de retraso.

La videotienta cobra:

```text
$2.000 por cada día de retraso.
```

La multa sería:

```text
3 × $2.000 = $6.000
```

El estudiante deberá verificar que su modelo permita representar completamente este escenario.

------

# 19. Entregable 1: Modelo conceptual

El estudiante deberá construir un **modelo conceptual de alto nivel**.

Este modelo debe representar:

- entidades principales;
- relaciones;
- cardinalidades;
- participación de las entidades.

En esta fase no es necesario definir tipos de datos SQL.

El objetivo consiste en representar el negocio.

El modelo conceptual debería permitir responder preguntas como:

```text
¿Qué elementos existen en el negocio?

¿Cómo están relacionados?

¿Una relación es 1:1, 1:N o N:M?
```

------

# 20. Requisitos del modelo conceptual

Debe incluir como mínimo los conceptos relacionados con:

```text
Película
Copia
Cliente
Empleado
Alquiler
Género
Actor
Director
Pago
Multa
```

Sin embargo, el estudiante podrá identificar entidades adicionales si las considera necesarias.

No se calificará positivamente agregar entidades sin justificación.

------

# 21. Entregable 2: Modelo lógico

A partir del modelo conceptual, se deberá construir el modelo lógico.

El modelo debe contener:

- nombre de cada entidad o relación;
- atributos;
- clave primaria;
- claves foráneas;
- relaciones;
- cardinalidades;
- entidades asociativas;
- restricciones importantes.

Ejemplo de representación:

```text
CLIENTE
--------------------------------
PK id_cliente
   identificacion
   nombres
   apellidos
   correo
   telefono
   estado
```

Para una relación:

```text
CLIENTE
   1
   |
   |
   N
ALQUILER
```

------

# 22. Resolución de relaciones N:M

El estudiante deberá analizar especialmente relaciones como:

```text
Película ↔ Actor

Película ↔ Género

Película ↔ Director
```

y determinar cómo deben representarse en el modelo lógico.

También debe analizarse:

```text
Alquiler ↔ Copia
```

teniendo en cuenta que cada copia puede aparecer en distintos alquileres en fechas diferentes.

------

# 23. Entregable 3: ERD

El estudiante deberá presentar un **Entity Relationship Diagram — ERD** completo.

El ERD deberá contener:

- entidades;
- atributos principales;
- PK;
- FK;
- relaciones;
- cardinalidades;
- opcionalidad.

Puede utilizarse notación:

```text
Crow's Foot
```

preferiblemente.

Ejemplo:

```text
CLIENTE
   |
   | 1
   |
   | N
ALQUILER
```

------

# 24. Diferencia entre los tres entregables

## Modelo conceptual

Responde:

```text
¿Qué existe en el negocio?
```

Ejemplo:

```text
Cliente realiza Alquiler.
Película tiene Copias.
Actor participa en Película.
```

No se concentra todavía en implementación.

------

## Modelo lógico

Responde:

```text
¿Cómo se organizarán los datos?
```

Define:

- atributos;
- PK;
- FK;
- relaciones;
- entidades asociativas.

------

## ERD

Representa gráficamente el modelo lógico mediante notación formal.

Permite visualizar:

```text
tablas
PK
FK
cardinalidad
opcionalidad
```



------

# 25. Restricciones que deben identificarse

Durante el modelado deberán evaluarse restricciones como:

```text
NOT NULL
UNIQUE
PRIMARY KEY
FOREIGN KEY
CHECK
```

Aunque todavía no se implemente SQL.

Ejemplo:

```text
Cliente.identificacion
```

debería ser:

```text
UNIQUE
```

El precio del alquiler:

```text
precio >= 0
```

La multa:

```text
valor >= 0
```

------

# 26. Normalización

El modelo lógico deberá encontrarse como mínimo en:

```text
Tercera Forma Normal
4FN
```

El estudiante deberá evitar:

- atributos multivaluados;
- información repetida innecesariamente;
- grupos repetitivos;
- dependencias parciales;
- dependencias transitivas.

------

# 28. Ejemplo de problema de diseño

No debería diseñarse:

```text
PELICULA
--------------------------------
id
titulo
actor1
actor2
actor3
genero1
genero2
director1
director2
```

porque:

```text
Actor
Género
Director
```

son elementos multivaluados.

El estudiante deberá modelarlos correctamente.

------

# 29. Herramientas recomendadas

El proyecto puede realizarse utilizando:

- StarUML;
- Draw.io;
- Lucidchart;
- Visual Paradigm;
- DBeaver;
- pgModeler;
- MySQL Workbench;
- dbdiagram.io.

Para el ERD se recomienda:

```text
Crow's Foot
```

como notación principal.

------

# 30. Formato de entrega

El estudiante deberá entregar un documento PDF que contenga:

```text
1. Portada

2. Introducción

3. Descripción del problema

4. Reglas de negocio

5. Modelo conceptual

6. Explicación del modelo conceptual

7. Modelo lógico

8. Diccionario básico de entidades y atributos

9. ERD

10. Instrucciones DDL BD

11. Conclusiones
```

------





# 31. Requisitos mínimos del ERD

El diagrama final deberá mostrar claramente:

```text
PK
FK
atributos
relaciones
cardinalidades
opcionalidad
```

Ejemplo:

```text
CLIENTE
----------------------
PK id_cliente
   identificacion
   nombre
   correo


ALQUILER
----------------------
PK id_alquiler
FK id_cliente
FK id_empleado
   fecha_alquiler
   fecha_limite
   estado
```

------

# 32. Criterios de evaluación

| Criterio                             | Porcentaje |
| ------------------------------------ | ---------- |
| Identificación correcta de entidades | 15%        |
| Atributos y claves                   | 15%        |
| Relaciones                           | 15%        |
| Cardinalidades                       | 15%        |
| Modelo conceptual                    | 10%        |
| Modelo lógico                        | 15%        |
| ERD                                  | 10%        |
| Normalización y coherencia           | 5%         |
| **Total**                            | **100%**   |

------

# 33. Preguntas de defensa del proyecto

El estudiante deberá estar en capacidad de responder:

1. ¿Por qué Película y Copia son entidades diferentes?
2. ¿Por qué no se registra únicamente la película dentro del alquiler?
3. ¿Qué relación existe entre Película y Actor?
4. ¿Cómo resolvió la relación entre Película y Género?
5. ¿Por qué se necesita un detalle del alquiler?
6. ¿Cómo identifica si una copia se encuentra disponible?
7. ¿Cómo sabe el sistema si un cliente tiene un alquiler pendiente?
8. ¿Cómo representa una devolución tardía?
9. ¿Dónde se registra la multa?
10. ¿Cómo conservaría el historial de alquiler de una copia?
11. ¿Qué entidades poseen relaciones muchos a muchos?
12. ¿Qué relaciones requieren entidades asociativas?
13. ¿Cómo garantiza que una copia no esté alquilada simultáneamente a dos clientes?
14. ¿Qué información debe mantenerse histórica y cuál puede actualizarse?
15. ¿Qué elementos del modelo garantizan integridad referencial?

------

# 34. Reto adicional

Como funcionalidad opcional, MovieBox desea incorporar una sección de reservas.

Un cliente podría reservar una película cuando todas sus copias se encuentren alquiladas.

La reserva debería almacenar:

```text
cliente
película
fecha de reserva
fecha de vencimiento
estado
```

Estados:

```text
Pendiente
Atendida
Cancelada
Vencida
```

El estudiante deberá analizar cómo incorporar esta funcionalidad sin afectar el modelo existente.

------

# 35. Resultado esperado

Al finalizar el proyecto, deberá existir una evolución clara:

```text
Requerimientos del negocio
          ↓
Reglas de negocio
          ↓
Modelo conceptual
          ↓
Modelo lógico
          ↓
ERD
```

El modelo final debe representar correctamente el funcionamiento de la videotienta y permitir una futura implementación en un sistema gestor de bases de datos relacional como PostgreSQL.

------

# 36. Resultado de aprendizaje

**Diseñar un modelo de datos relacional a partir de los requerimientos de un caso empresarial, aplicando técnicas de identificación de entidades, atributos, relaciones, cardinalidades, normalización, claves primarias y foráneas, y representando la solución mediante modelos conceptual, lógico y ERD.**