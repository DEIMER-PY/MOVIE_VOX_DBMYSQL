-- Disposición inicial de las tablas en el Diseñador de phpMyAdmin (bkddb)
USE phpmyadmin;
DELETE tc FROM pma__table_coords tc JOIN pma__pdf_pages pp ON pp.page_nr = tc.pdf_page_number WHERE pp.db_name = 'bkddb';
DELETE FROM pma__pdf_pages WHERE db_name = 'bkddb';
INSERT INTO pma__pdf_pages (db_name, page_descr) VALUES ('bkddb', 'MovieBox ERD');
SET @pg = LAST_INSERT_ID();
INSERT INTO pma__table_coords (db_name, table_name, pdf_page_number, x, y) VALUES
-- Fila 1: catálogo
('bkddb','genero',            @pg,   20,  20),
('bkddb','pelicula_genero',   @pg,  420,  20),
('bkddb','pelicula',          @pg,  800,  20),
('bkddb','pelicula_actor',    @pg, 1250,  20),
('bkddb','actor',             @pg, 1650,  20),
-- Fila 2: copias, reservas, personas
('bkddb','director',          @pg,   20, 330),
('bkddb','pelicula_director', @pg,  420, 330),
('bkddb','copia',             @pg,  800, 330),
('bkddb','reserva',           @pg, 1250, 330),
('bkddb','cliente',           @pg, 1650, 330),
-- Fila 3: operación de alquiler
('bkddb','empleado',          @pg,   20, 660),
('bkddb','alquiler',          @pg,  420, 660),
('bkddb','detalle_alquiler',  @pg,  800, 660),
('bkddb','devolucion',        @pg, 1250, 660),
('bkddb','multa',             @pg, 1650, 660),
-- Fila 4: pagos
('bkddb','pago',              @pg,  420, 990),
('bkddb','detalle_pago',      @pg,  800, 990);
