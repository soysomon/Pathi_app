--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3
-- Dumped by pg_dump version 16.3

-- Started on 2024-11-27 00:03:36

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 16551)
-- Name: comentarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comentarios (
    id bigint NOT NULL,
    servicio_id integer,
    usuario_id integer,
    comentario text NOT NULL,
    valoracion integer,
    creado_en timestamp without time zone DEFAULT now(),
    texto character varying(255),
    CONSTRAINT comentarios_valoracion_check CHECK (((valoracion >= 1) AND (valoracion <= 5)))
);


ALTER TABLE public.comentarios OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16558)
-- Name: comentarios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.comentarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comentarios_id_seq OWNER TO postgres;

--
-- TOC entry 4898 (class 0 OID 0)
-- Dependencies: 216
-- Name: comentarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.comentarios_id_seq OWNED BY public.comentarios.id;


--
-- TOC entry 222 (class 1259 OID 16701)
-- Name: promociones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promociones (
    id integer NOT NULL,
    servicio_id integer NOT NULL,
    nombre_servicio character varying(255) NOT NULL,
    usuario_id integer NOT NULL,
    fecha timestamp without time zone NOT NULL,
    estado character varying(50) NOT NULL,
    creado_en timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    detalles text
);


ALTER TABLE public.promociones OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16700)
-- Name: promociones_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.promociones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.promociones_id_seq OWNER TO postgres;

--
-- TOC entry 4899 (class 0 OID 0)
-- Dependencies: 221
-- Name: promociones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.promociones_id_seq OWNED BY public.promociones.id;


--
-- TOC entry 224 (class 1259 OID 16723)
-- Name: reservas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reservas (
    id integer NOT NULL,
    usuario_id integer NOT NULL,
    nombre_usuario character varying(255) NOT NULL,
    correo character varying(255) NOT NULL,
    telefono character varying(20) NOT NULL,
    fecha date NOT NULL,
    hora time without time zone NOT NULL,
    estado character varying(50) DEFAULT 'reservado'::character varying,
    creado_en timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    detalles text,
    total_pagar numeric(10,2),
    usuario_registrado integer,
    transaction_id character varying(255)
);


ALTER TABLE public.reservas OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16722)
-- Name: reservas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reservas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reservas_id_seq OWNER TO postgres;

--
-- TOC entry 4900 (class 0 OID 0)
-- Dependencies: 223
-- Name: reservas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reservas_id_seq OWNED BY public.reservas.id;


--
-- TOC entry 217 (class 1259 OID 16565)
-- Name: servicios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.servicios (
    id bigint NOT NULL,
    nombre character varying(255) NOT NULL,
    descripcion text,
    empresa_id integer,
    creado_en timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    precio numeric(10,2),
    imagen_servicio character varying(255)
);


ALTER TABLE public.servicios OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16571)
-- Name: servicios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.servicios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.servicios_id_seq OWNER TO postgres;

--
-- TOC entry 4901 (class 0 OID 0)
-- Dependencies: 218
-- Name: servicios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.servicios_id_seq OWNED BY public.servicios.id;


--
-- TOC entry 219 (class 1259 OID 16572)
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios (
    id bigint NOT NULL,
    nombre character varying(255),
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    rol character varying(50) NOT NULL,
    creado_en timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    foto_url character varying(255),
    nombre_usuario character varying(255),
    ubicacion character varying(255),
    imagen_empresarial character varying(255),
    detalles character varying(255),
    publico boolean DEFAULT false,
    reservas integer DEFAULT 0,
    localizacion character varying(255)
);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16578)
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuarios_id_seq OWNER TO postgres;

--
-- TOC entry 4902 (class 0 OID 0)
-- Dependencies: 220
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;


--
-- TOC entry 4708 (class 2604 OID 16618)
-- Name: comentarios id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentarios ALTER COLUMN id SET DEFAULT nextval('public.comentarios_id_seq'::regclass);


--
-- TOC entry 4716 (class 2604 OID 16704)
-- Name: promociones id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promociones ALTER COLUMN id SET DEFAULT nextval('public.promociones_id_seq'::regclass);


--
-- TOC entry 4718 (class 2604 OID 16726)
-- Name: reservas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservas ALTER COLUMN id SET DEFAULT nextval('public.reservas_id_seq'::regclass);


--
-- TOC entry 4710 (class 2604 OID 16634)
-- Name: servicios id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicios ALTER COLUMN id SET DEFAULT nextval('public.servicios_id_seq'::regclass);


--
-- TOC entry 4712 (class 2604 OID 16653)
-- Name: usuarios id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);


--
-- TOC entry 4883 (class 0 OID 16551)
-- Dependencies: 215
-- Data for Name: comentarios; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4890 (class 0 OID 16701)
-- Dependencies: 222
-- Data for Name: promociones; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.promociones VALUES (5, 9, 'Paquete Todo Incluido', 8, '2024-11-30 00:00:00', 'activo', '2024-11-25 16:40:59.885151', 'Obtén una extensión de 2 días en el servicio solicita hoy');


--
-- TOC entry 4892 (class 0 OID 16723)
-- Dependencies: 224
-- Data for Name: reservas; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.reservas VALUES (40, 11, 'Elian De Los Santos ', 'elian@gmail.com', '8495563832', '2024-11-26', '12:00:00', 'cancelado', '2024-11-26 20:32:29.568276', 'Reserva para destino 11', 15.00, 7, 'qy56z7ys');
INSERT INTO public.reservas VALUES (41, 11, 'Elian De Los Santos ', 'elian@gmail.com', '8095775455', '2024-11-30', '12:00:00', 'cancelado', '2024-11-26 20:33:18.199874', 'Reserva para destino 11', 15.00, 7, 'kx4bmrf4');
INSERT INTO public.reservas VALUES (35, 9, 'Elian De Los Santos ', 'elian@gmail.com', '8495505633', '2024-11-30', '12:00:00', 'cancelado', '2024-11-26 20:07:50.384837', 'Reserva para destino 9', 90.00, 7, 'bmhx3hp7');
INSERT INTO public.reservas VALUES (36, 11, 'Elian De Los Santos ', 'elian@gmail.com', '8495505666', '2024-11-29', '12:00:00', 'cancelado', '2024-11-26 20:17:39.33435', 'Reserva para destino 11', 15.00, 7, '6wmdxq25');
INSERT INTO public.reservas VALUES (37, 11, 'Elian De Los Santos ', 'elian@gmail.com', '8495570556', '2024-11-30', '12:00:00', 'cancelado', '2024-11-26 20:19:50.041171', 'Reserva para destino 11', 15.00, 7, '2ef2y34s');
INSERT INTO public.reservas VALUES (38, 11, 'Elian De Los Santos ', 'elian@gmail.com', '8095563232', '2024-11-30', '12:00:00', 'cancelado', '2024-11-26 20:26:28.26776', 'Reserva para destino 11', 15.00, 7, 'knkr7gny');
INSERT INTO public.reservas VALUES (39, 11, 'Elian De Los Santos ', 'elian@gmail.com', '8095542625', '2024-11-28', '12:00:00', 'cancelado', '2024-11-26 20:27:44.65847', 'Reserva para destino 11', 15.00, 7, '0agygsch');


--
-- TOC entry 4885 (class 0 OID 16565)
-- Dependencies: 217
-- Data for Name: servicios; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.servicios VALUES (9, 'Paquete Todo Incluido', 'Estancia de 7 días en un resort con comidas y actividades.', 8, '2024-11-25 16:39:07.624574', 1500.00, 'imagenes_servicios/1732567147499-311171289.jpg');
INSERT INTO public.servicios VALUES (10, 'Excursión a Isla Saona', 'Tour de un día a la hermosa Isla Saona.', 8, '2024-11-25 16:42:43.236289', 100.00, 'imagenes_servicios/1732567363171-670931576.jpg');
INSERT INTO public.servicios VALUES (11, 'Clases de Buceo', 'Curso introductorio de buceo en aguas cristalinas.', 8, '2024-11-25 16:43:46.741162', 120.00, 'imagenes_servicios/1732567426654-151703448.jpg');
INSERT INTO public.servicios VALUES (12, 'Excursión a Los Haitises', 'Tour en bote por el Parque Nacional Los Haitises.', 9, '2024-11-25 16:49:29.328479', 90.00, 'imagenes_servicios/1732567769238-460379463.jpg');
INSERT INTO public.servicios VALUES (13, 'Observación de Ballenas', 'Temporada de avistamiento de ballenas jorobadas.', 9, '2024-11-25 16:50:33.873475', 120.00, 'imagenes_servicios/1732567833803-283376218.jpg');
INSERT INTO public.servicios VALUES (14, 'Tour por la Zona Colonial', 'Recorrido guiado por la historia de Santo Domingo.', 10, '2024-11-25 16:59:14.104967', 40.00, 'imagenes_servicios/1732568353888-425547873.jpg');
INSERT INTO public.servicios VALUES (15, 'Clases de Cocina Dominicana', 'Aprende a preparar platos típicos Dominicanos.', 10, '2024-11-25 17:00:41.661463', 60.00, 'imagenes_servicios/1732568441609-91882314.jpg');
INSERT INTO public.servicios VALUES (16, 'Espectáculo de Merengue', 'Noche de baile y música en vivo.', 10, '2024-11-25 17:01:55.412336', 50.00, 'imagenes_servicios/1732568515333-761407343.jpg');
INSERT INTO public.servicios VALUES (17, 'Menú del día', 'Platos típicos Dominicanos a seleccionar en el lugar.', 11, '2024-11-25 17:12:20.851876', 15.00, 'imagenes_servicios/1732569140778-172153587.jpg');


--
-- TOC entry 4887 (class 0 OID 16572)
-- Dependencies: 219
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.usuarios VALUES (11, 'sabor24', 'contacto@sabordo.com', '$2a$10$5/E9PGuMsT/Z4ZFe.8zi4..30Tp4iI4Dw.jEahHnbsH6/bGqSVnB.', 'empresa', '2024-11-25 17:04:37.502749', 'uploads/1732568793413-369689281.jpg', 'Sabor Dominicano', 'Santo Domingo, Av 27 de Febrero ', 'imagenes_emp/1732569016757-526356482.jpg', 'Restaurante especializado en cocina Dominicana tradicional y platos criollos.', true, 7, NULL);
INSERT INTO public.usuarios VALUES (7, 'Elian De Los Santos ', 'elian@gmail.com', '$2a$10$Rot0miS.f3wFH/gu3nmd6eVAb9qWAH89KO3hZAs8pl7P0BazcnKHi', 'turista', '2024-11-25 15:29:11.954329', 'uploads/1732581341791-689764564.jpg', 'Elian', NULL, NULL, NULL, false, 0, NULL);
INSERT INTO public.usuarios VALUES (10, 'cultura', 'reservas@cultura.com', '$2a$10$6nZ3oZVmaLrlGOOaoDpgl.CUZKPO236YWWjNmpprElu05dNcB2o76', 'empresa', '2024-11-25 16:53:12.721746', 'uploads/1732568057263-914512589.jpg', 'C & T - Cultura y Tradición', 'Santo Domingo', 'imagenes_emp/1732568190204-799688233.jpg', 'Tours culturales y gastronómicos en la capital Dominicana.', true, 1, NULL);
INSERT INTO public.usuarios VALUES (8, 'maravillas', 'contacto@maravillas.com', '$2a$10$VXziEeTjcUCaUXq7RxSrZeC/ZwVEYsgbju5gO6s8vwwuzuq998XGa', 'empresa', '2024-11-25 15:52:21.11845', 'uploads/1732566830955-181841897.jpg', 'Maravillas', 'Punta Cana', 'imagenes_emp/1732566786867-550167914.jpg', 'Agencia de viajes especializada en servicios turísticos a playas y resorts.', true, 4, NULL);
INSERT INTO public.usuarios VALUES (9, 'aventuras24', 'info@aventuradominicana.com', '$2a$10$Uxtpy1gJIBlcywxAZWiAo.iOqg8QSMC/ZhohexGOTEPXOAh/CCcOO', 'empresa', '2024-11-25 16:45:00.170085', 'uploads/1732567875394-236249805.jpg', 'Aventuras Sama', 'Samaná', 'imagenes_emp/1732567649892-246244492.jpg', 'Especializados en ecoturismo y actividades al aire libre ', true, 1, NULL);


--
-- TOC entry 4903 (class 0 OID 0)
-- Dependencies: 216
-- Name: comentarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.comentarios_id_seq', 1, false);


--
-- TOC entry 4904 (class 0 OID 0)
-- Dependencies: 221
-- Name: promociones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.promociones_id_seq', 5, true);


--
-- TOC entry 4905 (class 0 OID 0)
-- Dependencies: 223
-- Name: reservas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reservas_id_seq', 41, true);


--
-- TOC entry 4906 (class 0 OID 0)
-- Dependencies: 218
-- Name: servicios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.servicios_id_seq', 17, true);


--
-- TOC entry 4907 (class 0 OID 0)
-- Dependencies: 220
-- Name: usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuarios_id_seq', 11, true);


--
-- TOC entry 4723 (class 2606 OID 16620)
-- Name: comentarios comentarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentarios
    ADD CONSTRAINT comentarios_pkey PRIMARY KEY (id);


--
-- TOC entry 4731 (class 2606 OID 16709)
-- Name: promociones promociones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promociones
    ADD CONSTRAINT promociones_pkey PRIMARY KEY (id);


--
-- TOC entry 4733 (class 2606 OID 16732)
-- Name: reservas reservas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservas
    ADD CONSTRAINT reservas_pkey PRIMARY KEY (id);


--
-- TOC entry 4725 (class 2606 OID 16636)
-- Name: servicios servicios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicios
    ADD CONSTRAINT servicios_pkey PRIMARY KEY (id);


--
-- TOC entry 4727 (class 2606 OID 16679)
-- Name: usuarios usuarios_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_email_key UNIQUE (email);


--
-- TOC entry 4729 (class 2606 OID 16655)
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- TOC entry 4734 (class 2606 OID 16637)
-- Name: comentarios comentarios_servicio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentarios
    ADD CONSTRAINT comentarios_servicio_id_fkey FOREIGN KEY (servicio_id) REFERENCES public.servicios(id) ON DELETE CASCADE;


--
-- TOC entry 4735 (class 2606 OID 16656)
-- Name: comentarios comentarios_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentarios
    ADD CONSTRAINT comentarios_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 4737 (class 2606 OID 16710)
-- Name: promociones promociones_servicio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promociones
    ADD CONSTRAINT promociones_servicio_id_fkey FOREIGN KEY (servicio_id) REFERENCES public.servicios(id);


--
-- TOC entry 4738 (class 2606 OID 16715)
-- Name: promociones promociones_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promociones
    ADD CONSTRAINT promociones_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id);


--
-- TOC entry 4739 (class 2606 OID 16733)
-- Name: reservas reservas_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservas
    ADD CONSTRAINT reservas_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id);


--
-- TOC entry 4736 (class 2606 OID 16666)
-- Name: servicios servicios_empresa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicios
    ADD CONSTRAINT servicios_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.usuarios(id);


-- Completed on 2024-11-27 00:03:36

--
-- PostgreSQL database dump complete
--

