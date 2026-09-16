-- ============================================================
-- VideoTienda MovieBox - Datos de ejemplo
-- Reproduce el caso de la seccion 18 del enunciado:
--   Juan Carlos Gomez alquila Matrix (DVD-00015) e Interstellar
--   (BR-00021) el 10/09/2026, limite 13/09/2026. Devuelve Matrix
--   a tiempo e Interstellar el 16/09 => 3 dias => multa $6.000.
-- Los triggers (03_triggers.sql) calculan totales, retraso y multa.
-- ============================================================
USE bkddb;

-- Reinicia los contadores para que los IDs del seed sean predecibles
-- (solo tiene efecto si las tablas estan vacias)
ALTER TABLE genero            AUTO_INCREMENT = 1;
ALTER TABLE pelicula          AUTO_INCREMENT = 1;
ALTER TABLE actor             AUTO_INCREMENT = 1;
ALTER TABLE director          AUTO_INCREMENT = 1;
ALTER TABLE copia             AUTO_INCREMENT = 1;
ALTER TABLE cliente           AUTO_INCREMENT = 1;
ALTER TABLE empleado          AUTO_INCREMENT = 1;
ALTER TABLE alquiler          AUTO_INCREMENT = 1;
ALTER TABLE detalle_alquiler  AUTO_INCREMENT = 1;
ALTER TABLE devolucion        AUTO_INCREMENT = 1;
ALTER TABLE multa             AUTO_INCREMENT = 1;
ALTER TABLE pago              AUTO_INCREMENT = 1;
ALTER TABLE detalle_pago      AUTO_INCREMENT = 1;
ALTER TABLE reserva           AUTO_INCREMENT = 1;

-- Catalogo ---------------------------------------------------
INSERT INTO genero (nombre, descripcion) VALUES
  ('Accion', 'Peliculas de accion'),
  ('Drama', 'Drama'),
  ('Comedia', 'Comedia'),
  ('Terror', 'Terror'),
  ('Ciencia ficcion', 'Ciencia ficcion'),
  ('Animacion', 'Animacion'),
  ('Documental', 'Documental'),
  ('Romance', 'Romance'),
  ('Aventura', 'Aventura');

INSERT INTO pelicula (titulo, anio_estreno, duracion_min, clasificacion, descripcion, idioma_original) VALUES
  ('The Matrix',   1999, 136, '+15', 'Un hacker descubre la verdadera naturaleza de su realidad.', 'Ingles'),
  ('Interstellar', 2014, 169, '+12', 'Un grupo de exploradores viaja a traves de un agujero de gusano.', 'Ingles'),
  ('Avatar',       2009, 162, '+12', 'Un marine paraplejico es enviado a la luna Pandora.', 'Ingles');

INSERT INTO actor (nombres, apellidos, fecha_nacimiento, nacionalidad) VALUES
  ('Keanu',    'Reeves',    '1964-09-02', 'Canadiense'),
  ('Matthew',  'McConaughey', '1969-11-04', 'Estadounidense'),
  ('Sam',      'Worthington', '1976-08-02', 'Australiano');

INSERT INTO director (nombres, apellidos, fecha_nacimiento, nacionalidad) VALUES
  ('Lana',        'Wachowski', '1965-06-21', 'Estadounidense'),
  ('Lilly',       'Wachowski', '1967-12-29', 'Estadounidense'),
  ('Christopher', 'Nolan',     '1970-07-30', 'Britanico'),
  ('James',       'Cameron',   '1954-08-16', 'Canadiense');

INSERT INTO pelicula_genero (id_pelicula, id_genero) VALUES
  (1, 1), (1, 5),            -- Matrix: Accion, Ciencia ficcion
  (2, 5), (2, 2), (2, 9),    -- Interstellar: Ciencia ficcion, Drama, Aventura
  (3, 1), (3, 5), (3, 9);    -- Avatar: Accion, Ciencia ficcion, Aventura

INSERT INTO pelicula_actor (id_pelicula, id_actor, personaje) VALUES
  (1, 1, 'Neo'),
  (2, 2, 'Cooper'),
  (3, 3, 'Jake Sully');

INSERT INTO pelicula_director (id_pelicula, id_director) VALUES
  (1, 1), (1, 2), (2, 3), (3, 4);

INSERT INTO copia (codigo_copia, id_pelicula, formato, fecha_adquisicion, estado) VALUES
  ('DVD-00015', 1, 'DVD',       '2024-01-10', 'EXCELENTE'),
  ('DVD-00016', 1, 'DVD',       '2024-01-10', 'BUENO'),
  ('BR-00021',  2, 'BLURAY',    '2024-03-05', 'EXCELENTE'),
  ('4K-00003',  2, 'BLURAY_4K', '2025-02-14', 'EXCELENTE'),
  ('BR-00030',  3, 'BLURAY',    '2024-06-01', 'REGULAR'),
  ('DVD-00040', 3, 'DVD',       '2023-11-20', 'FUERA_DE_SERVICIO');

-- Personas ---------------------------------------------------
INSERT INTO cliente (identificacion, nombres, apellidos, fecha_nacimiento, direccion, telefono, correo, fecha_registro, estado) VALUES
  ('1098123456', 'Juan Carlos', 'Gomez', '1990-05-20', 'Calle 10 # 5-20', '3001112233', 'juan.gomez@mail.com',  '2025-01-15', 'ACTIVO'),
  ('1020304050', 'Laura',       'Perez', '1995-08-11', 'Carrera 7 # 45-10', '3014445566', 'laura.perez@mail.com', '2025-03-02', 'ACTIVO'),
  ('1234567890', 'Pedro',       'Ruiz',  '1988-02-01', NULL, NULL, 'pedro.ruiz@mail.com', '2024-11-30', 'SUSPENDIDO');

INSERT INTO empleado (identificacion, nombres, apellidos, cargo, telefono, correo, fecha_contratacion, estado) VALUES
  ('52000111', 'Andrea', 'Martinez', 'CAJERO',        '3105556677', 'andrea.martinez@moviebox.com', '2023-02-01', 'ACTIVO'),
  ('80000222', 'Carlos', 'Lopez',    'ADMINISTRADOR', '3117778899', 'carlos.lopez@moviebox.com',    '2022-06-15', 'ACTIVO');

-- Caso seccion 18 --------------------------------------------
INSERT INTO alquiler (id_cliente, id_empleado, fecha_alquiler, fecha_prevista_devolucion)
VALUES (1, 1, '2026-09-10', '2026-09-13');                       -- id_alquiler = 1

INSERT INTO detalle_alquiler (id_alquiler, id_copia, precio_alquiler) VALUES
  (1, 1, 5000),   -- Matrix       DVD-00015 (id_detalle = 1)
  (1, 3, 5000);   -- Interstellar BR-00021  (id_detalle = 2)

-- Devoluciones (dias_retraso y multa los calcula el trigger)
INSERT INTO devolucion (id_detalle, id_empleado, fecha_real_devolucion, estado_fisico_entrega, observaciones) VALUES
  (1, 1, '2026-09-13', 'EXCELENTE', 'Sin novedad'),
  (2, 1, '2026-09-16', 'BUENO',     'Devuelta con 3 dias de retraso');

-- Pago: cubre el alquiler ($10.000) y la multa ($6.000) en un solo pago
INSERT INTO pago (id_cliente, id_empleado, fecha, valor_total, metodo_pago)
VALUES (1, 1, '2026-09-16 10:30:00', 0, 'EFECTIVO');             -- id_pago = 1

INSERT INTO detalle_pago (id_pago, concepto, id_alquiler, valor) VALUES (1, 'ALQUILER', 1, 10000);
INSERT INTO detalle_pago (id_pago, concepto, id_multa,    valor) VALUES (1, 'MULTA',    1, 6000);

-- Reserva (reto adicional): Laura reserva Avatar
INSERT INTO reserva (id_cliente, id_pelicula, fecha_reserva, fecha_vencimiento, estado)
VALUES (2, 3, '2026-09-15 09:00:00', '2026-09-18 09:00:00', 'PENDIENTE');
