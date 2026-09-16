-- ============================================================
-- VideoTienda MovieBox - Reglas de negocio que no se expresan
-- con PK/FK/CHECK y se implementan con triggers (MySQL 8.4)
--
--   R4  Una copia solo puede estar en un alquiler activo a la vez
--   R16 Un cliente SUSPENDIDO no puede alquilar
--   R17 Una copia DANADO / FUERA_DE_SERVICIO no puede alquilarse
--   R18 Copia alquilada => disponible = FALSE
--   R19 Copia devuelta  => disponible = TRUE (y se actualiza su estado fisico)
--   R20 Devolucion tardia => multa por RETRASO ($2.000 por dia)
--   R21 Los pagos no se eliminan fisicamente
--   Atributos derivados: alquiler.valor_total, pago.valor_total,
--   devolucion.dias_retraso
-- ============================================================
USE bkddb;

DROP TRIGGER IF EXISTS trg_detalle_alquiler_bi;
DROP TRIGGER IF EXISTS trg_detalle_alquiler_ai;
DROP TRIGGER IF EXISTS trg_devolucion_bi;
DROP TRIGGER IF EXISTS trg_devolucion_ai;
DROP TRIGGER IF EXISTS trg_detalle_pago_ai;
DROP TRIGGER IF EXISTS trg_pago_bd;

DELIMITER $$

-- ------------------------------------------------------------
-- Antes de agregar una copia a un alquiler: validar R4, R16, R17
-- ------------------------------------------------------------
CREATE TRIGGER trg_detalle_alquiler_bi
BEFORE INSERT ON detalle_alquiler
FOR EACH ROW
BEGIN
  DECLARE v_estado_copia   VARCHAR(20);
  DECLARE v_disponible     BOOLEAN;
  DECLARE v_estado_cliente VARCHAR(20);
  DECLARE v_pendientes     INT;

  SELECT estado, disponible INTO v_estado_copia, v_disponible
    FROM copia WHERE id_copia = NEW.id_copia;

  SELECT c.estado INTO v_estado_cliente
    FROM alquiler a JOIN cliente c ON c.id_cliente = a.id_cliente
   WHERE a.id_alquiler = NEW.id_alquiler;

  SELECT COUNT(*) INTO v_pendientes
    FROM detalle_alquiler
   WHERE id_copia = NEW.id_copia AND estado_devolucion = 'PENDIENTE';

  IF v_estado_cliente = 'SUSPENDIDO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'R16: un cliente SUSPENDIDO no puede realizar alquileres';
  END IF;
  IF v_estado_copia IN ('DANADO', 'FUERA_DE_SERVICIO') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'R17: la copia esta DANADA o FUERA_DE_SERVICIO';
  END IF;
  IF v_pendientes > 0 OR v_disponible = FALSE THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'R4: la copia ya se encuentra en un alquiler activo';
  END IF;
END$$

-- ------------------------------------------------------------
-- Despues de agregar la copia: marcar no disponible (R18)
-- y recalcular el total del alquiler (atributo derivado)
-- ------------------------------------------------------------
CREATE TRIGGER trg_detalle_alquiler_ai
AFTER INSERT ON detalle_alquiler
FOR EACH ROW
BEGIN
  UPDATE copia SET disponible = FALSE WHERE id_copia = NEW.id_copia;
  UPDATE alquiler
     SET valor_total = (SELECT COALESCE(SUM(precio_alquiler), 0)
                          FROM detalle_alquiler WHERE id_alquiler = NEW.id_alquiler)
   WHERE id_alquiler = NEW.id_alquiler;
END$$

-- ------------------------------------------------------------
-- Antes de registrar la devolucion: calcular dias de retraso
-- ------------------------------------------------------------
CREATE TRIGGER trg_devolucion_bi
BEFORE INSERT ON devolucion
FOR EACH ROW
BEGIN
  DECLARE v_prevista DATE;
  SELECT a.fecha_prevista_devolucion INTO v_prevista
    FROM detalle_alquiler d JOIN alquiler a ON a.id_alquiler = d.id_alquiler
   WHERE d.id_detalle = NEW.id_detalle;
  SET NEW.dias_retraso = GREATEST(0, DATEDIFF(NEW.fecha_real_devolucion, v_prevista));
END$$

-- ------------------------------------------------------------
-- Despues de la devolucion: liberar copia (R19), actualizar su
-- estado fisico, cerrar el detalle, generar multa si hay retraso
-- (R20) y cerrar el alquiler cuando no queden copias pendientes
-- ------------------------------------------------------------
CREATE TRIGGER trg_devolucion_ai
AFTER INSERT ON devolucion
FOR EACH ROW
BEGIN
  DECLARE v_copia    INT;
  DECLARE v_alquiler INT;

  SELECT id_copia, id_alquiler INTO v_copia, v_alquiler
    FROM detalle_alquiler WHERE id_detalle = NEW.id_detalle;

  UPDATE detalle_alquiler SET estado_devolucion = 'DEVUELTO' WHERE id_detalle = NEW.id_detalle;

  UPDATE copia
     SET disponible = TRUE,
         estado     = NEW.estado_fisico_entrega
   WHERE id_copia = v_copia;

  IF NEW.dias_retraso > 0 THEN
    INSERT INTO multa (id_detalle, motivo, valor, fecha)
    VALUES (NEW.id_detalle, 'RETRASO', NEW.dias_retraso * 2000, NEW.fecha_real_devolucion);
  END IF;

  IF NEW.estado_fisico_entrega IN ('DANADO', 'FUERA_DE_SERVICIO') THEN
    INSERT INTO multa (id_detalle, motivo, valor, fecha)
    VALUES (NEW.id_detalle, 'DANO', 0, NEW.fecha_real_devolucion);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM detalle_alquiler
                  WHERE id_alquiler = v_alquiler AND estado_devolucion = 'PENDIENTE') THEN
    UPDATE alquiler SET estado = 'CERRADO' WHERE id_alquiler = v_alquiler;
  END IF;
END$$

-- ------------------------------------------------------------
-- Despues de cada linea de pago: recalcular total del pago y
-- marcar la multa como PAGADA
-- ------------------------------------------------------------
CREATE TRIGGER trg_detalle_pago_ai
AFTER INSERT ON detalle_pago
FOR EACH ROW
BEGIN
  UPDATE pago
     SET valor_total = (SELECT COALESCE(SUM(valor), 0) FROM detalle_pago WHERE id_pago = NEW.id_pago)
   WHERE id_pago = NEW.id_pago;
  IF NEW.concepto = 'MULTA' THEN
    UPDATE multa SET estado = 'PAGADA' WHERE id_multa = NEW.id_multa;
  END IF;
END$$

-- ------------------------------------------------------------
-- R21: los pagos son historial, no se borran
-- ------------------------------------------------------------
CREATE TRIGGER trg_pago_bd
BEFORE DELETE ON pago
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'R21: los pagos no pueden eliminarse (historial)';
END$$

DELIMITER ;
