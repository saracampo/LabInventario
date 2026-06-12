-- ============================================================
-- Sistema Web de Gestión de Inventario y Solicitudes de Laboratorio
-- Universidad del Cauca - Desarrollo de Aplicaciones Web
-- Base de datos: MySQL
-- ============================================================

CREATE DATABASE IF NOT EXISTS laboratorio_inventario
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE laboratorio_inventario;

-- -----------------------------------------------------------
-- Tabla: roles
-- -----------------------------------------------------------
CREATE TABLE roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  descripcion VARCHAR(255) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -----------------------------------------------------------
-- Tabla: users
-- -----------------------------------------------------------
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  contraseña VARCHAR(255) NOT NULL,
  rol_id INT NOT NULL DEFAULT 2,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_rol ON users(rol_id);

-- -----------------------------------------------------------
-- Tabla: categorias
-- -----------------------------------------------------------
CREATE TABLE categorias (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  descripcion VARCHAR(255) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -----------------------------------------------------------
-- Tabla: equipos
-- -----------------------------------------------------------
CREATE TABLE equipos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(200) NOT NULL,
  descripcion TEXT DEFAULT NULL,
  serial_number VARCHAR(100) UNIQUE DEFAULT NULL,
  categoria_id INT DEFAULT NULL,
  precio DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  cantidad_total INT NOT NULL DEFAULT 1,
  cantidad_disponible INT NOT NULL DEFAULT 1,
  estado ENUM('disponible', 'mantenimiento', 'dado_baja') NOT NULL DEFAULT 'disponible',
  ubicacion VARCHAR(255) DEFAULT NULL,
  imagen_url VARCHAR(500) DEFAULT NULL,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_equipos_disponible CHECK (cantidad_disponible >= 0),
  CONSTRAINT chk_equipos_total CHECK (cantidad_total >= 0),
  CONSTRAINT chk_equipos_stock CHECK (cantidad_disponible <= cantidad_total)
) ENGINE=InnoDB;

CREATE INDEX idx_equipos_categoria ON equipos(categoria_id);
CREATE INDEX idx_equipos_estado ON equipos(estado);
CREATE INDEX idx_equipos_activo ON equipos(activo);

-- -----------------------------------------------------------
-- Tabla: materiales
-- -----------------------------------------------------------
CREATE TABLE materiales (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(200) NOT NULL,
  descripcion TEXT DEFAULT NULL,
  categoria_id INT DEFAULT NULL,
  precio DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  cantidad_total INT NOT NULL DEFAULT 1,
  cantidad_disponible INT NOT NULL DEFAULT 1,
  unidad_medida VARCHAR(50) DEFAULT 'unidad',
  ubicacion VARCHAR(255) DEFAULT NULL,
  imagen_url VARCHAR(500) DEFAULT NULL,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_materiales_disponible CHECK (cantidad_disponible >= 0),
  CONSTRAINT chk_materiales_total CHECK (cantidad_total >= 0),
  CONSTRAINT chk_materiales_stock CHECK (cantidad_disponible <= cantidad_total)
) ENGINE=InnoDB;

CREATE INDEX idx_materiales_categoria ON materiales(categoria_id);
CREATE INDEX idx_materiales_activo ON materiales(activo);

-- -----------------------------------------------------------
-- Tabla: prestamos
-- -----------------------------------------------------------
CREATE TABLE prestamos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  equipo_id INT NOT NULL,
  cantidad INT NOT NULL DEFAULT 1,
  fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_inicio DATE DEFAULT NULL,
  fecha_fin DATE DEFAULT NULL,
  fecha_devolucion DATE DEFAULT NULL,
  estado ENUM('pendiente', 'aprobado', 'rechazado', 'en_curso', 'devuelto', 'cancelado') NOT NULL DEFAULT 'pendiente',
  observaciones TEXT DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (equipo_id) REFERENCES equipos(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_prestamos_usuario ON prestamos(usuario_id);
CREATE INDEX idx_prestamos_equipo ON prestamos(equipo_id);
CREATE INDEX idx_prestamos_estado ON prestamos(estado);

-- -----------------------------------------------------------
-- Tabla: historial_prestamos
-- -----------------------------------------------------------
CREATE TABLE historial_prestamos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  prestamo_id INT NOT NULL,
  usuario_accion_id INT NOT NULL,
  accion ENUM('solicitado', 'aprobado', 'rechazado', 'iniciado', 'devuelto', 'cancelado', 'modificado') NOT NULL,
  descripcion TEXT DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (prestamo_id) REFERENCES prestamos(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (usuario_accion_id) REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_historial_prestamo ON historial_prestamos(prestamo_id);

-- ============================================================
-- INSERTS DE DATOS INICIALES
-- ============================================================

-- Roles
INSERT INTO roles (nombre, descripcion) VALUES
  ('admin', 'Administrador del sistema con acceso completo'),
  ('docente', 'Docente con permisos para solicitar préstamos'),
  ('estudiante', 'Estudiante con permisos básicos de solicitud');

-- Usuarios (contraseñas en bcrypt, todas: 1234567890)
INSERT INTO users (nombre, email, contraseña, rol_id) VALUES
  ('Administrador', 'admin@laboratorio.com', '$2a$10$g4/BD/c3ckH7GB1150PRcuEr4pzi8FCGAj.yByyo81gW8gqYnCkQ.', 1);
INSERT INTO users (nombre, email, contraseña, rol_id) VALUES
  ('Carlos Mendoza', 'carlos@unicauca.edu.co', '$2a$10$g4/BD/c3ckH7GB1150PRcuEr4pzi8FCGAj.yByyo81gW8gqYnCkQ.', 2),
  ('Maria Gomez', 'maria@unicauca.edu.co', '$2a$10$g4/BD/c3ckH7GB1150PRcuEr4pzi8FCGAj.yByyo81gW8gqYnCkQ.', 2);
INSERT INTO users (nombre, email, contraseña, rol_id) VALUES
  ('Sara Perez', 's@gmail.com', '$2a$10$g4/BD/c3ckH7GB1150PRcuEr4pzi8FCGAj.yByyo81gW8gqYnCkQ.', 3);

-- Categorías
INSERT INTO categorias (nombre, descripcion) VALUES
  ('Computo', 'Equipos de cómputo como laptops, desktops, tablets'),
  ('Electronica', 'Componentes y equipos electrónicos'),
  ('Instrumentacion', 'Instrumentos de medición y prueba'),
  ('Redes', 'Equipos de redes y telecomunicaciones'),
  ('Herramientas', 'Herramientas manuales y eléctricas'),
  ('Materiales', 'Materiales de consumo y suministros'),
  ('Sensores', 'Sensores y módulos de medición');

-- Equipos de cómputo y electrónicos (precios en COP)
INSERT INTO equipos (nombre, descripcion, serial_number, categoria_id, precio, cantidad_total, cantidad_disponible, estado, ubicacion) VALUES
  ('Laptop Dell Latitude 5490', 'Intel Core i5, 16GB RAM, 256GB SSD', 'SN-DELL-001', 1, 2500000.00, 5, 4, 'disponible', 'Laboratorio 101'),
  ('Laptop HP ProBook 450', 'Intel Core i7, 16GB RAM, 512GB SSD', 'SN-HP-001', 1, 3200000.00, 3, 3, 'disponible', 'Laboratorio 101'),
  ('Desktop Lenovo ThinkCentre', 'Intel Core i5, 8GB RAM, 1TB HDD', 'SN-LEN-001', 1, 1800000.00, 8, 7, 'disponible', 'Laboratorio 102'),
  ('Osciloscopio Digital Hantek', '2 canales, 100MHz', 'SN-OSC-001', 3, 850000.00, 2, 2, 'disponible', 'Laboratorio 103'),
  ('Multímetro Fluke 117', 'Multímetro digital True RMS', 'SN-FLK-001', 3, 520000.00, 5, 5, 'disponible', 'Laboratorio 103'),
  ('Fuente de Poder DC', '30V 5A regulable', 'SN-FNT-001', 3, 380000.00, 4, 3, 'disponible', 'Laboratorio 103'),
  ('Router Cisco 2901', 'Router empresarial con 4 puertos Gigabit', 'SN-CIS-001', 4, 1200000.00, 2, 2, 'disponible', 'Laboratorio Redes'),
  ('Switch Cisco 2960', 'Switch 24 puertos Gigabit', 'SN-CIS-002', 4, 950000.00, 3, 3, 'disponible', 'Laboratorio Redes'),
  ('Kit Arduino Mega 2560', 'Placa Arduino Mega con cable USB', 'SN-ARD-001', 2, 135000.00, 10, 8, 'disponible', 'Laboratorio 104'),
  ('Raspberry Pi 4 Model B', '4GB RAM, 64GB microSD incluida', 'SN-RPI-001', 2, 280000.00, 4, 3, 'disponible', 'Laboratorio 104'),
  ('ESP32 DevKit V1', 'Módulo WiFi y Bluetooth dual-core', 'SN-ESP-001', 2, 45000.00, 15, 12, 'disponible', 'Laboratorio 104'),
  ('ESP32-CAM', 'Módulo ESP32 con cámara OV2640', 'SN-ESP-002', 2, 65000.00, 10, 9, 'disponible', 'Laboratorio 104'),
  ('Módulo Bluetooth HC-05', 'Bluetooth serial maestro/esclavo', 'SN-BT-001', 2, 22000.00, 8, 8, 'disponible', 'Laboratorio 104'),
  ('Módulo WiFi ESP8266', 'ESP8266 NodeMCU V3', 'SN-ESP-003', 2, 28000.00, 12, 10, 'disponible', 'Laboratorio 104');

-- Materiales de laboratorio (precios en COP)
INSERT INTO materiales (nombre, descripcion, categoria_id, precio, cantidad_total, cantidad_disponible, unidad_medida, ubicacion) VALUES
  ('LED Rojo 5mm', 'LED difuso rojo 5mm, 20mA', 6, 500.00, 200, 180, 'unidad', 'Cajón 1 - Lab 104'),
  ('LED Verde 5mm', 'LED difuso verde 5mm, 20mA', 6, 500.00, 200, 190, 'unidad', 'Cajón 1 - Lab 104'),
  ('LED Azul 5mm', 'LED difuso azul 5mm, 20mA', 6, 500.00, 150, 140, 'unidad', 'Cajón 1 - Lab 104'),
  ('LED RGB 5mm', 'LED RGB cátodo común 5mm', 6, 2000.00, 80, 75, 'unidad', 'Cajón 2 - Lab 104'),
  ('LED RGB WS2812B', 'Tira LED RGB direccionable 1m 60 LEDs', 6, 25000.00, 10, 8, 'unidad', 'Cajón 2 - Lab 104'),
  ('Servomotor SG90', 'Micro servo 9g 180°', 6, 18000.00, 20, 18, 'unidad', 'Cajón 3 - Lab 104'),
  ('Servomotor MG995', 'Servo estándar metal 180° 10kg', 6, 35000.00, 8, 7, 'unidad', 'Cajón 3 - Lab 104'),
  ('Display OLED 0.96"', 'Display OLED I2C 128x64 blanco', 6, 25000.00, 15, 13, 'unidad', 'Cajón 4 - Lab 104'),
  ('Display OLED 1.3"', 'Display OLED I2C 128x64 blanco/azul', 6, 32000.00, 10, 9, 'unidad', 'Cajón 4 - Lab 104'),
  ('Buzzer Activo 5V', 'Buzzer piezoeléctrico activo 5V', 6, 3000.00, 40, 38, 'unidad', 'Cajón 5 - Lab 104'),
  ('Buzzer Pasivo 5V', 'Buzzer piezoeléctrico pasivo 5V', 6, 3500.00, 30, 28, 'unidad', 'Cajón 5 - Lab 104'),
  ('Sensor DHT11', 'Sensor temperatura y humedad DHT11', 7, 12000.00, 20, 18, 'unidad', 'Cajón 6 - Lab 104'),
  ('Sensor DHT22', 'Sensor temperatura y humedad DHT22 (AM2302)', 7, 25000.00, 10, 9, 'unidad', 'Cajón 6 - Lab 104'),
  ('Sensor Ultrasonido HC-SR04', 'Sensor distancia ultrasónico 2cm-400cm', 7, 10000.00, 15, 14, 'unidad', 'Cajón 7 - Lab 104'),
  ('Sensor Infrarrojo HC-SR501', 'Sensor movimiento PIR', 7, 8500.00, 12, 11, 'unidad', 'Cajón 7 - Lab 104'),
  ('Sensor de Gas MQ-2', 'Sensor detector de gas GLP/propano', 7, 15000.00, 8, 7, 'unidad', 'Cajón 8 - Lab 104'),
  ('Sensor de Gas MQ-135', 'Sensor calidad del aire', 7, 16000.00, 8, 7, 'unidad', 'Cajón 8 - Lab 104'),
  ('Sensor de Humedad Suelo', 'Sensor detector de humedad para suelo', 7, 8000.00, 10, 10, 'unidad', 'Cajón 9 - Lab 104'),
  ('Módulo Relé 1 canal', 'Módulo relé 5V 10A para Arduino', 6, 8000.00, 15, 14, 'unidad', 'Cajón 10 - Lab 104'),
  ('Módulo Relé 4 canales', 'Módulo relé 5V 4 canales 10A', 6, 22000.00, 8, 7, 'unidad', 'Cajón 10 - Lab 104'),
  ('Driver Motor L298N', 'Puente H para motores DC', 6, 18000.00, 10, 9, 'unidad', 'Cajón 11 - Lab 104'),
  ('Joystick Módulo KY-023', 'Joystick analógico 2 ejes con botón', 6, 5000.00, 15, 15, 'unidad', 'Cajón 12 - Lab 104'),
  ('Teclado Matricial 4x4', 'Teclado matricial 16 teclas membrana', 6, 8000.00, 10, 10, 'unidad', 'Cajón 12 - Lab 104'),
  ('Resistencias 220Ω (pack 100)', 'Resistencias 1/4W 220Ω lote 100 unidades', 6, 3000.00, 10, 9, 'paquete', 'Cajón 13 - Lab 104'),
  ('Resistencias 1kΩ (pack 100)', 'Resistencias 1/4W 1kΩ lote 100 unidades', 6, 3000.00, 10, 10, 'paquete', 'Cajón 13 - Lab 104'),
  ('Resistencias 10kΩ (pack 100)', 'Resistencias 1/4W 10kΩ lote 100 unidades', 6, 3000.00, 10, 10, 'paquete', 'Cajón 13 - Lab 104'),
  ('Condensadores 100µF (pack 10)', 'Condensadores electrolíticos 100µF 25V lote 10', 6, 4000.00, 8, 8, 'paquete', 'Cajón 14 - Lab 104'),
  ('Protoboard 830 puntos', 'Protoboard 830 puntos de conexión', 6, 15000.00, 20, 18, 'unidad', 'Estante 1 - Lab 104'),
  ('Cables Dupont M-M (pack 40)', 'Cables jumper Dupont macho-macho 20cm pack 40', 6, 5000.00, 25, 23, 'paquete', 'Estante 2 - Lab 104'),
  ('Cables Dupont M-H (pack 40)', 'Cables jumper Dupont macho-hembra 20cm pack 40', 6, 5000.00, 25, 25, 'paquete', 'Estante 2 - Lab 104'),
  ('Cables Dupont H-H (pack 40)', 'Cables jumper Dupont hembra-hembra 20cm pack 40', 6, 5000.00, 25, 25, 'paquete', 'Estante 2 - Lab 104');

-- ============================================================
-- TABLAS DE AUDITORÍA (soft-delete) + TRIGGERS
-- ============================================================

CREATE TABLE IF NOT EXISTS equipos_eliminados (
  id INT AUTO_INCREMENT PRIMARY KEY,
  registro_id INT NOT NULL,
  datos JSON NOT NULL,
  deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_registro_id (registro_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS usuarios_eliminados (
  id INT AUTO_INCREMENT PRIMARY KEY,
  registro_id INT NOT NULL,
  datos JSON NOT NULL,
  deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_registro_id (registro_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS prestamos_eliminados (
  id INT AUTO_INCREMENT PRIMARY KEY,
  registro_id INT NOT NULL,
  datos JSON NOT NULL,
  deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_registro_id (registro_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DELIMITER //
CREATE TRIGGER IF NOT EXISTS after_update_equipos_audit
AFTER UPDATE ON equipos
FOR EACH ROW
BEGIN
  IF NEW.activo = 0 AND OLD.activo = 1 THEN
    INSERT INTO equipos_eliminados (registro_id, datos)
    VALUES (NEW.id, JSON_OBJECT(
      'id', OLD.id, 'nombre', OLD.nombre, 'descripcion', OLD.descripcion,
      'serialNumber', OLD.serial_number, 'categoriaId', OLD.categoria_id,
      'precio', OLD.precio, 'cantidadTotal', OLD.cantidad_total,
      'cantidadDisponible', OLD.cantidad_disponible, 'estado', OLD.estado,
      'ubicacion', OLD.ubicacion, 'imagenUrl', OLD.imagen_url,
      'activo', OLD.activo, 'createdAt', OLD.created_at, 'updatedAt', OLD.updated_at
    ));
  END IF;
END;//

CREATE TRIGGER IF NOT EXISTS after_update_users_audit
AFTER UPDATE ON users
FOR EACH ROW
BEGIN
  IF NEW.activo = 0 AND OLD.activo = 1 THEN
    INSERT INTO usuarios_eliminados (registro_id, datos)
    VALUES (NEW.id, JSON_OBJECT(
      'id', OLD.id, 'nombre', OLD.nombre, 'email', OLD.email,
      'rolId', OLD.rol_id, 'activo', OLD.activo,
      'createdAt', OLD.created_at, 'updatedAt', OLD.updated_at
    ));
  END IF;
END;//

CREATE TRIGGER IF NOT EXISTS before_delete_prestamos
BEFORE DELETE ON prestamos
FOR EACH ROW
BEGIN
  INSERT INTO prestamos_eliminados (registro_id, datos)
  VALUES (OLD.id, JSON_OBJECT(
    'id', OLD.id, 'usuarioId', OLD.usuario_id, 'equipoId', OLD.equipo_id,
    'cantidad', OLD.cantidad, 'fechaSolicitud', OLD.fecha_solicitud,
    'fechaInicio', OLD.fecha_inicio, 'fechaFin', OLD.fecha_fin,
    'fechaDevolucion', OLD.fecha_devolucion, 'estado', OLD.estado,
    'observaciones', OLD.observaciones, 'createdAt', OLD.created_at,
    'updatedAt', OLD.updated_at
  ));
END;//

DELIMITER ;
