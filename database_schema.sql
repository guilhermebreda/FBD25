CREATE SCHEMA public AUTHORIZATION pg_database_owner;


CREATE SEQUENCE public.exportacao_id_seq
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 2147483647
    START 1
    CACHE 1
    NO CYCLE;


CREATE SEQUENCE public.exportacao_por_municipio_id_seq
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 2147483647
    START 1
    CACHE 1
    NO CYCLE;


CREATE SEQUENCE public.importacao_id_seq
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 2147483647
    START 1
    CACHE 1
    NO CYCLE;


CREATE SEQUENCE public.importacao_por_municipio_id_seq
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 2147483647
    START 1
    CACHE 1
    NO CYCLE;


CREATE TABLE public.exportacao_por_municipio (
    id serial4 NOT NULL,
    "CO_ANO" int4 NULL,
    "CO_MES" int4 NULL,
    "SH4" int4 NULL,
    "CO_PAIS" int4 NULL,
    "SG_UF_MUN" varchar(200) NULL,
    "CO_MUN" int4 NULL,
    "KG_LIQUIDO" int4 NULL,
    "VL_FOB" int4 NULL,
    CONSTRAINT exportacao_por_municipio_pkey PRIMARY KEY (id)
);


CREATE TABLE public.importacao_por_municipio (
    id serial4 NOT NULL,
    "CO_ANO" int4 NULL,
    "CO_MES" int4 NULL,
    "SH4" int4 NULL,
    "CO_PAIS" int4 NULL,
    "SG_UF_MUN" varchar(200) NULL,
    "CO_MUN" int4 NULL,
    "KG_LIQUIDO" int4 NULL,
    "VL_FOB" int4 NULL,
    CONSTRAINT importacao_por_municipio_pkey PRIMARY KEY (id)
);
CREATE INDEX idx_importacao_municipio ON public.importacao_por_municipio USING btree ("CO_ANO", "CO_MES", "CO_MUN");


CREATE TABLE public.mes (
    "CO_MES" int4 NOT NULL,
    "NO_MES" varchar(20) NOT NULL,
    CONSTRAINT mes_pkey PRIMARY KEY ("CO_MES")
);


CREATE TABLE public.ncm_cgce (
    "CO_CGCE_N3" int4 NULL,
    "NO_CGCE_N3" varchar(200) NULL,
    "NO_CGCE_N3_ING" varchar(200) NULL,
    "NO_CGCE_N3_ESP" varchar(200) NULL,
    "CO_CGCE_N2" int4 NULL,
    "NO_CGCE_N2" varchar(200) NULL,
    "NO_CGCE_N2_ING" varchar(200) NULL,
    "NO_CGCE_N2_ESP" varchar(200) NULL,
    "CO_CGCE_N1" int4 NULL,
    "NO_CGCE_N1" varchar(200) NULL,
    "NO_CGCE_N1_ING" varchar(200) NULL,
    "NO_CGCE_N1_ESP" varchar(200) NULL,
    CONSTRAINT unique_cgce_n3 UNIQUE ("CO_CGCE_N3")
);


CREATE TABLE public.ncm_fat_agreg (
    "CO_FAT_AGREG" varchar NULL,
    "NO_FAT_AGREG" varchar(200) NULL,
    "NO_FAT_AGREG_GP" varchar(200) NULL,
    CONSTRAINT unique_fat_agreg UNIQUE ("CO_FAT_AGREG")
);


CREATE TABLE public.ncm_ppe (
    "CO_PPE" varchar(20) NOT NULL,
    "NO_PPE" varchar(200) NULL,
    "NO_PPE_MIN" varchar(200) NULL,
    "NO_PPE_ING" varchar(200) NULL,
    CONSTRAINT ncm_ppe_pkey PRIMARY KEY ("CO_PPE")
);


CREATE TABLE public.ncm_ppi (
    "CO_PPI" varchar(20) NOT NULL,
    "NO_PPI" varchar(200) NULL,
    "NO_PPI_MIN" varchar(200) NULL,
    "NO_PPI_ING" varchar(200) NULL,
    CONSTRAINT ncm_ppi_pkey PRIMARY KEY ("CO_PPI")
);


CREATE TABLE public.ncm_sh (
    "CO_SH6" int4 NULL,
    "NO_SH6_POR" varchar(512) NULL,
    "NO_SH6_ESP" varchar(4096) NULL,
    "NO_SH6_ING" varchar(512) NULL,
    "CO_SH4" varchar(200) NULL,
    "NO_SH4_POR" varchar(256) NULL,
    "NO_SH4_ESP" varchar(256) NULL,
    "NO_SH4_ING" varchar(256) NULL,
    "CO_SH2" varchar(200) NULL,
    "NO_SH2_POR" varchar(1024) NULL,
    "NO_SH2_ESP" varchar(256) NULL,
    "NO_SH2_ING" varchar(200) NULL,
    "CO_NCM_SECROM" varchar(200) NULL,
    "NO_SEC_POR" varchar(200) NULL,
    "NO_SEC_ESP" varchar(256) NULL,
    "NO_SEC_ING" varchar(256) NULL,
    CONSTRAINT unique_co_sh6 UNIQUE ("CO_SH6")
);


CREATE TABLE public.ncm_unidade (
    "CO_UNID" int4 NOT NULL,
    "NO_UNID" varchar(200) NULL,
    "SG_UNID" varchar(200) NULL,
    CONSTRAINT ncm_unidade_pkey PRIMARY KEY ("CO_UNID")
);


CREATE TABLE public.pais (
    "CO_PAIS" int4 NOT NULL,
    "CO_PAIS_ISON3" int4 NULL,
    "CO_PAIS_ISOA3" varchar(200) NULL,
    "NO_PAIS" varchar(200) NULL,
    "NO_PAIS_ING" varchar(200) NULL,
    "NO_PAIS_ESP" varchar(200) NULL,
    CONSTRAINT pais_pkey PRIMARY KEY ("CO_PAIS")
);


CREATE TABLE public.uf (
    "CO_UF" int4 NULL,
    "SG_UF" varchar(200) NOT NULL,
    "NO_UF" varchar(200) NULL,
    "NO_REGIAO" varchar(200) NULL,
    CONSTRAINT uf_pkey PRIMARY KEY ("SG_UF")
);


CREATE TABLE public.uf_mun (
    "CO_MUN_GEO" int4 NULL,
    "NO_MUN" varchar(200) NULL,
    "NO_MUN_MIN" varchar(200) NULL,
    "SG_UF" varchar(200) NULL
);


CREATE TABLE public.urf (
    "CO_URF" int4 NOT NULL,
    "NO_URF" varchar(200) NULL,
    CONSTRAINT urf_pkey PRIMARY KEY ("CO_URF")
);


CREATE TABLE public.via (
    "CO_VIA" int4 NOT NULL,
    "NO_VIA" varchar(200) NULL,
    CONSTRAINT via_pkey PRIMARY KEY ("CO_VIA")
);


CREATE TABLE public.ncm (
    "CO_NCM" int4 NOT NULL,
    "CO_UNID" int4 NULL,
    "CO_SH6" int4 NULL,
    "CO_PPE" varchar(200) NULL,
    "CO_PPI" varchar(200) NULL,
    "CO_FAT_AGREG" varchar(200) NULL,
    "CO_CUCI_ITEM" varchar(200) NULL,
    "CO_CGCE_N3" int4 NULL,
    "CO_SIIT" varchar(200) NULL,
    "CO_ISIC_CLASSE" int4 NULL,
    "CO_EXP_SUBSET" varchar(200) NULL,
    "NO_NCM_POR" varchar(1024) NULL,
    "NO_NCM_ESP" varchar(1024) NULL,
    "NO_NCM_ING" varchar(1024) NULL,
    CONSTRAINT ncm_pkey PRIMARY KEY ("CO_NCM"),
    CONSTRAINT fk_ncm_cgce FOREIGN KEY ("CO_CGCE_N3") REFERENCES public.ncm_cgce("CO_CGCE_N3"),
    CONSTRAINT fk_ncm_fat_agreg FOREIGN KEY ("CO_FAT_AGREG") REFERENCES public.ncm_fat_agreg("CO_FAT_AGREG"),
    CONSTRAINT fk_ncm_ppe FOREIGN KEY ("CO_PPE") REFERENCES public.ncm_ppe("CO_PPE"),
    CONSTRAINT fk_ncm_ppi FOREIGN KEY ("CO_PPI") REFERENCES public.ncm_ppi("CO_PPI")
);


CREATE TABLE public.pais_bloco (
    "CO_PAIS" int4 NOT NULL,
    "CO_BLOCO" int4 NOT NULL,
    "NO_BLOCO" varchar(200) NULL,
    "NO_BLOCO_ING" varchar(200) NULL,
    "NO_BLOCO_ESP" varchar(200) NULL,
    CONSTRAINT pk_pais_bloco PRIMARY KEY ("CO_PAIS", "CO_BLOCO"),
    CONSTRAINT fk_pais_bloco FOREIGN KEY ("CO_PAIS") REFERENCES public.pais("CO_PAIS")
);


CREATE TABLE public.exportacao (
    id serial4 NOT NULL,
    "CO_ANO" int4 NOT NULL,
    "CO_MES" int4 NOT NULL,
    "CO_NCM" int4 NOT NULL,
    "CO_UNID" int4 NULL,
    "CO_PAIS" int4 NULL,
    "SG_UF_NCM" varchar(2) NULL,
    "CO_VIA" int4 NULL,
    "CO_URF" int4 NULL,
    "QT_ESTAT" int8 NULL,
    "KG_LIQUIDO" int8 NULL,
    "VL_FOB" numeric(15, 2) NOT NULL,
    CONSTRAINT exportacao_pkey PRIMARY KEY (id),
    CONSTRAINT "exportacao_CO_NCM_fkey" FOREIGN KEY ("CO_NCM") REFERENCES public.ncm("CO_NCM"),
    CONSTRAINT "exportacao_CO_PAIS_fkey" FOREIGN KEY ("CO_PAIS") REFERENCES public.pais("CO_PAIS"),
    CONSTRAINT "exportacao_CO_UNID_fkey" FOREIGN KEY ("CO_UNID") REFERENCES public.ncm_unidade("CO_UNID"),
    CONSTRAINT "exportacao_CO_URF_fkey" FOREIGN KEY ("CO_URF") REFERENCES public.urf("CO_URF"),
    CONSTRAINT "exportacao_CO_VIA_fkey" FOREIGN KEY ("CO_VIA") REFERENCES public.via("CO_VIA"),
    CONSTRAINT "exportacao_SG_UF_NCM_fkey" FOREIGN KEY ("SG_UF_NCM") REFERENCES public.uf("SG_UF"),
    CONSTRAINT fk_exportacao_mes FOREIGN KEY ("CO_MES") REFERENCES public.mes("CO_MES")
);


create trigger trg_audit_exportacao after
insert
    or
delete
    or
update
    on
    public.exportacao for each row execute function log_auditoria();


CREATE TABLE public.importacao (
    id serial4 NOT NULL,
    "CO_ANO" int4 NULL,
    "CO_MES" int4 NULL,
    "CO_NCM" int4 NULL,
    "CO_UNID" int4 NULL,
    "CO_PAIS" int4 NULL,
    "SG_UF_NCM" varchar(500) NULL,
    "CO_VIA" int4 NULL,
    "CO_URF" int4 NULL,
    "QT_ESTAT" int4 NULL,
    "KG_LIQUIDO" int4 NULL,
    "VL_FOB" int4 NULL,
    "VL_FRETE" int4 NULL,
    "VL_SEGURO" int4 NULL,
    CONSTRAINT importacao_pkey PRIMARY KEY (id),
    CONSTRAINT fk_importacao_mes FOREIGN KEY ("CO_MES") REFERENCES public.mes("CO_MES"),
    CONSTRAINT "importacao_CO_NCM_fkey" FOREIGN KEY ("CO_NCM") REFERENCES public.ncm("CO_NCM"),
    CONSTRAINT "importacao_CO_PAIS_fkey" FOREIGN KEY ("CO_PAIS") REFERENCES public.pais("CO_PAIS"),
    CONSTRAINT "importacao_CO_UNID_fkey" FOREIGN KEY ("CO_UNID") REFERENCES public.ncm_unidade("CO_UNID"),
    CONSTRAINT "importacao_CO_URF_fkey" FOREIGN KEY ("CO_URF") REFERENCES public.urf("CO_URF"),
    CONSTRAINT "importacao_CO_VIA_fkey" FOREIGN KEY ("CO_VIA") REFERENCES public.via("CO_VIA"),
    CONSTRAINT "importacao_SG_UF_NCM_fkey" FOREIGN KEY ("SG_UF_NCM") REFERENCES public.uf("SG_UF")
);
CREATE INDEX idx_importacao_mes ON public.importacao USING btree ("CO_MES");


create trigger trg_audit_importacao after
insert
    or
delete
    or
update
    on
    public.importacao for each row execute function log_auditoria();


CREATE OR REPLACE VIEW public.vw_exportacao_detalhada
AS SELECT e."CO_ANO",
    e."CO_MES",
    m."NO_MES",
    e."CO_NCM",
    n."NO_NCM_POR" AS produto,
    e."CO_PAIS",
    p."NO_PAIS" AS destino,
    e."CO_VIA",
    v."NO_VIA" AS modal_transporte,
    e."KG_LIQUIDO",
    e."VL_FOB"
   FROM exportacao e
     JOIN ncm n ON e."CO_NCM" = n."CO_NCM"
     JOIN pais p ON e."CO_PAIS" = p."CO_PAIS"
     JOIN via v ON e."CO_VIA" = v."CO_VIA"
     JOIN mes m ON e."CO_MES" = m."CO_MES";


CREATE OR REPLACE FUNCTION public.log_auditoria()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF current_user = 'desenvolvedor' THEN
        RETURN NULL;
    END IF;
   
    INSERT INTO public.auditoria (tabela, operacao, usuario, data_hora)
    VALUES (TG_TABLE_NAME, TG_OP, current_user, now());
    RETURN NULL;
END;
$function$
;
