-- ============================================================
-- VideoTienda MovieBox - Modelo físico (MySQL 8.4)
-- Generado a partir de docs/modelo_logico.dbml
-- Idempotente: puede ejecutarse varias veces.
-- ============================================================

CREATE DATABASE IF NOT EXISTS bkddb
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bkddb;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS reserva, detalle_pago, pago, multa, devolucion,
  detalle_alquiler, alquiler, empleado, cliente, copia,
  pelicula_director, pelicula_actor, pelicula_genero,
  director, actor, genero, pelicula;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- Catálogo de películas
-- ============================================================
CREATE TABLE pelicula (
  id_pelicula     INT AUTO_INCREMENT PRIMARY KEY,
  titulo          VARCHAR(150) NOT NULL,
  anio_estreno    INT          NOT NULL,
  duracion_min    INT          NOT NULL,
  clasificacion   VARCHAR(10)  NOT NULL COMMENT 'Clasificación por edades: TP, +7, +12, +15, +18',
  descripcion     TEXT,
  idioma_original VARCHAR(50)  NOT NULL,
  CONSTRAINT chk_pelicula_anio     CHECK (anio_estreno >= 1888),
  CONSTRAINT chk_pelicula_duracion CHECK (duracion_min > 0)
) ENGINE=InnoDB;

CREATE TABLE genero (
  id_genero   INT AUTO_INCREMENT PRIMARY KEY,
  nombre      VARCHAR(50)  NOT NULL UNIQUE,
  descripcion VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE actor (
  id_actor         INT AUTO_INCREMENT PRIMARY KEY,
  nombres          VARCHAR(80) NOT NULL,
  apellidos        VARCHAR(80) NOT NULL,
  fecha_nacimiento DATE,
  nacionalidad     VARCHAR(60)
) ENGINE=InnoDB;

CREATE TABLE director (
  id_director      INT AUTO_INCREMENT PRIMARY KEY,
  nombres          VARCHAR(80) NOT NULL,
  apellidos        VARCHAR(80) NOT NULL,
  fecha_nacimiento DATE,
  nacionalidad     VARCHAR(60)
) ENGINE=InnoDB;

-- Entidades asociativas (relaciones N:M)
CREATE TABLE pelicula_genero (
  id_pelicula INT NOT NULL,
  id_genero   INT NOT NULL,
  PRIMARY KEY (id_pelicula, id_genero),
  CONSTRAINT fk_pelicula_genero_pelicula FOREIGN KEY (id_pelicula) REFERENCES pelicula (id_pelicula)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_pelicula_genero_genero   FOREIGN KEY (id_genero)   REFERENCES genero (id_genero)
    ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE pelicula_actor (
  id_pelicula INT NOT NULL,
  id_actor    INT NOT NULL,
  personaje   VARCHAR(100) COMMENT 'Nombre del personaje interpretado',
  PRIMARY KEY (id_pelicula, id_actor),
  CONSTRAINT fk_pelicula_actor_pelicula FOREIGN KEY (id_pelicula) REFERENCES pelicula (id_pelicula)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_pelicula_actor_actor    FOREIGN KEY (id_actor)    REFERENCES actor (id_actor)
    ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE pelicula_director (
  id_pelicula INT NOT NULL,
  id_director INT NOT NULL,
  PRIMARY KEY (id_pelicula, id_director),
  CONSTRAINT fk_pelicula_director_pelicula FOREIGN KEY (id_pelicula) REFERENCES pelicula (id_pelicula)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_pelicula_director_director FOREIGN KEY (id_director) REFERENCES director (id_director)
    ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB;

-- ============================================================
-- Copias físicas
-- ============================================================
CREATE TABLE copia (
  id_copia          INT AUTO_INCREMENT PRIMARY KEY,
  codigo_copia      VARCHAR(20) NOT NULL UNIQUE COMMENT 'Ej: DVD-00015, BR-00021',
  id_pelicula       INT         NOT NULL,
  formato           ENUM('DVD','BLURAY','BLURAY_4K') NOT NULL,
  fecha_adquisicion DATE        NOT NULL,
  estado            ENUM('EXCELENTE','BUENO','REGULAR','DANADO','FUERA_DE_SERVICIO') NOT NULL DEFAULT 'EXCELENTE',
  disponible        BOOLEAN     NOT NULL DEFAULT TRUE
    COMMENT 'FALSE mientras esté alquilada. Regla 17: no alquilable si estado IN (DANADO, FUERA_DE_SERVICIO)',
  CONSTRAINT fk_copia_pelicula FOREIGN KEY (id_pelicula) REFERENCES pelicula (id_pelicula)
    ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB;

-- ============================================================
-- Personas
-- ============================================================
CREATE TABLE cliente (
  id_cliente       INT AUTO_INCREMENT PRIMARY KEY,
  identificacion   VARCHAR(20)  NOT NULL UNIQUE,
  nombres          VARCHAR(80)  NOT NULL,
  apellidos        VARCHAR(80)  NOT NULL,
  fecha_nacimiento DATE         NOT NULL,
  direccion        VARCHAR(150),
  telefono         VARCHAR(20),
  correo           VARCHAR(120) NOT NULL UNIQUE,
  fecha_registro   DATE         NOT NULL DEFAULT (CURRENT_DATE),
  estado           ENUM('ACTIVO','SUSPENDIDO','INACTIVO') NOT NULL DEFAULT 'ACTIVO'
    COMMENT 'Regla 16: SUSPENDIDO no puede alquilar'
) ENGINE=InnoDB;

CREATE TABLE empleado (
  id_empleado        INT AUTO_INCREMENT PRIMARY KEY,
  identificacion     VARCHAR(20)  NOT NULL UNIQUE,
  nombres            VARCHAR(80)  NOT NULL,
  apellidos          VARCHAR(80)  NOT NULL,
  cargo              ENUM('ADMINISTRADOR','CAJERO','AUXILIAR') NOT NULL,
  telefono           VARCHAR(20),
  correo             VARCHAR(120) UNIQUE,
  fecha_contratacion DATE         NOT NULL,
  estado             ENUM('ACTIVO','INACTIVO') NOT NULL DEFAULT 'ACTIVO'
) ENGINE=InnoDB;

-- ============================================================
-- Alquileres
-- ============================================================
CREATE TABLE alquiler (
  id_alquiler               INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente                INT  NOT NULL,
  id_empleado               INT  NOT NULL COMMENT 'Empleado que registra',
  fecha_alquiler            DATE NOT NULL,
  fecha_prevista_devolucion DATE NOT NULL,
  estado                    ENUM('ACTIVO','CERRADO','CANCELADO') NOT NULL DEFAULT 'ACTIVO',
  valor_total               DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT 'Suma de precios del detalle',
  CONSTRAINT chk_alquiler_fechas CHECK (fecha_prevista_devolucion >= fecha_alquiler),
  CONSTRAINT chk_alquiler_valor  CHECK (valor_total >= 0),
  CONSTRAINT fk_alquiler_cliente  FOREIGN KEY (id_cliente)  REFERENCES cliente (id_cliente)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_alquiler_empleado FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado)
    ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE detalle_alquiler (
  id_detalle        INT AUTO_INCREMENT PRIMARY KEY,
  id_alquiler       INT NOT NULL,
  id_copia          INT NOT NULL,
  precio_alquiler   DECIMAL(10,2) NOT NULL,
  estado_devolucion ENUM('PENDIENTE','DEVUELTO','PERDIDO') NOT NULL DEFAULT 'PENDIENTE',
  UNIQUE KEY uq_detalle_alquiler_copia (id_alquiler, id_copia),
  CONSTRAINT chk_detalle_precio CHECK (precio_alquiler >= 0),
  CONSTRAINT fk_detalle_alquiler_alquiler FOREIGN KEY (id_alquiler) REFERENCES alquiler (id_alquiler)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_detalle_alquiler_copia    FOREIGN KEY (id_copia)    REFERENCES copia (id_copia)
    ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB
  COMMENT='Regla 4: una copia solo puede estar en UN detalle con estado PENDIENTE a la vez (se valida por trigger)';

-- ============================================================
-- Devoluciones y multas
-- ============================================================
CREATE TABLE devolucion (
  id_devolucion         INT AUTO_INCREMENT PRIMARY KEY,
  id_detalle            INT  NOT NULL UNIQUE,
  id_empleado           INT  NOT NULL COMMENT 'Empleado que recibe',
  fecha_real_devolucion DATE NOT NULL,
  dias_retraso          INT  NOT NULL DEFAULT 0 COMMENT 'Calculado: fecha_real - fecha_prevista',
  estado_fisico_entrega ENUM('EXCELENTE','BUENO','REGULAR','DANADO','FUERA_DE_SERVICIO') NOT NULL
    COMMENT 'Estado con el que regresa (puede diferir del de salida)',
  observaciones         TEXT,
  danios                TEXT,
  CONSTRAINT chk_devolucion_retraso CHECK (dias_retraso >= 0),
  CONSTRAINT fk_devolucion_detalle  FOREIGN KEY (id_detalle)  REFERENCES detalle_alquiler (id_detalle)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_devolucion_empleado FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado)
    ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE multa (
  id_multa   INT AUTO_INCREMENT PRIMARY KEY,
  id_detalle INT NOT NULL COMMENT 'Desde aquí se obtiene alquiler y cliente',
  motivo     ENUM('RETRASO','DANO','PERDIDA') NOT NULL,
  valor      DECIMAL(10,2) NOT NULL,
  fecha      DATE NOT NULL,
  estado     ENUM('PENDIENTE','PAGADA','ANULADA') NOT NULL DEFAULT 'PENDIENTE',
  CONSTRAINT chk_multa_valor  CHECK (valor >= 0),
  CONSTRAINT fk_multa_detalle FOREIGN KEY (id_detalle) REFERENCES detalle_alquiler (id_detalle)
    ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB;

-- ============================================================
-- Pagos (historial: regla 21, nunca se eliminan físicamente)
-- ============================================================
CREATE TABLE pago (
  id_pago     INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente  INT      NOT NULL,
  id_empleado INT      NOT NULL COMMENT 'Empleado que recibe el pago',
  fecha       DATETIME NOT NULL,
  valor_total DECIMAL(10,2) NOT NULL COMMENT 'Suma de detalle_pago',
  metodo_pago ENUM('EFECTIVO','TARJETA_DEBITO','TARJETA_CREDITO','TRANSFERENCIA') NOT NULL,
  CONSTRAINT chk_pago_valor   CHECK (valor_total >= 0),
  CONSTRAINT fk_pago_cliente  FOREIGN KEY (id_cliente)  REFERENCES cliente (id_cliente)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_pago_empleado FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado)
    ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE detalle_pago (
  id_detalle_pago INT AUTO_INCREMENT PRIMARY KEY,
  id_pago         INT NOT NULL,
  concepto        ENUM('ALQUILER','MULTA') NOT NULL,
  id_alquiler     INT,
  id_multa        INT,
  valor           DECIMAL(10,2) NOT NULL,
  CONSTRAINT chk_detalle_pago_valor CHECK (valor >= 0),
  CONSTRAINT chk_detalle_pago_concepto CHECK (
       (concepto = 'ALQUILER' AND id_alquiler IS NOT NULL AND id_multa IS NULL)
    OR (concepto = 'MULTA'    AND id_multa    IS NOT NULL AND id_alquiler IS NULL)
  ),
  CONSTRAINT fk_detalle_pago_pago     FOREIGN KEY (id_pago)     REFERENCES pago (id_pago)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_detalle_pago_alquiler FOREIGN KEY (id_alquiler) REFERENCES alquiler (id_alquiler)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_detalle_pago_multa    FOREIGN KEY (id_multa)    REFERENCES multa (id_multa)
    ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB;

-- ============================================================
-- Reto adicional: reservas
-- ============================================================
CREATE TABLE reserva (
  id_reserva        INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente        INT      NOT NULL,
  id_pelicula       INT      NOT NULL COMMENT 'Se reserva la película, no una copia',
  fecha_reserva     DATETIME NOT NULL,
  fecha_vencimiento DATETIME NOT NULL,
  estado            ENUM('PENDIENTE','ATENDIDA','CANCELADA','VENCIDA') NOT NULL DEFAULT 'PENDIENTE',
  CONSTRAINT chk_reserva_fechas CHECK (fecha_vencimiento > fecha_reserva),
  CONSTRAINT fk_reserva_cliente  FOREIGN KEY (id_cliente)  REFERENCES cliente (id_cliente)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_reserva_pelicula FOREIGN KEY (id_pelicula) REFERENCES pelicula (id_pelicula)
    ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB;
