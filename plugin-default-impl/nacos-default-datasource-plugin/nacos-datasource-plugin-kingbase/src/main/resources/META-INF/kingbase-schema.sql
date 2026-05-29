/*
 * Copyright 1999-2018 Alibaba Group Holding Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

CREATE TABLE config_info
(
    id                 BIGSERIAL PRIMARY KEY NOT NULL,
    data_id            VARCHAR(255)          NOT NULL,
    group_id           VARCHAR(128)                   DEFAULT NULL,
    content            TEXT                  NOT NULL,
    md5                VARCHAR(32)                    DEFAULT NULL,
    gmt_create         TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified       TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    src_user           TEXT                           DEFAULT NULL,
    src_ip             VARCHAR(50)                    DEFAULT NULL,
    app_name           VARCHAR(128)                   DEFAULT NULL,
    tenant_id          VARCHAR(128)                   DEFAULT '',
    c_desc             VARCHAR(256)                   DEFAULT NULL,
    c_use              VARCHAR(64)                    DEFAULT NULL,
    effect             VARCHAR(64)                    DEFAULT NULL,
    type               VARCHAR(64)                    DEFAULT NULL,
    c_schema           TEXT                           DEFAULT NULL,
    encrypted_data_key VARCHAR(1024)         NOT NULL DEFAULT ''
);

COMMENT ON TABLE config_info IS 'config_info';
COMMENT ON COLUMN config_info.id IS 'id';
COMMENT ON COLUMN config_info.data_id IS 'data_id';
COMMENT ON COLUMN config_info.group_id IS 'group_id';
COMMENT ON COLUMN config_info.content IS 'content';
COMMENT ON COLUMN config_info.md5 IS 'md5';
COMMENT ON COLUMN config_info.gmt_create IS 'gmt_create';
COMMENT ON COLUMN config_info.gmt_modified IS 'gmt_modified';
COMMENT ON COLUMN config_info.src_user IS 'src_user';
COMMENT ON COLUMN config_info.src_ip IS 'src_ip';
COMMENT ON COLUMN config_info.app_name IS 'app_name';
COMMENT ON COLUMN config_info.tenant_id IS 'tenant_id';
COMMENT ON COLUMN config_info.c_desc IS 'c_desc';
COMMENT ON COLUMN config_info.c_use IS 'c_use';
COMMENT ON COLUMN config_info.effect IS 'effect';
COMMENT ON COLUMN config_info.type IS 'type';
COMMENT ON COLUMN config_info.c_schema IS 'c_schema';
COMMENT ON COLUMN config_info.encrypted_data_key IS 'encrypted_data_key';

CREATE UNIQUE INDEX uk_configinfo_datagrouptenant ON config_info (data_id, group_id, tenant_id);

CREATE TABLE config_info_gray
(
    id                 BIGSERIAL PRIMARY KEY NOT NULL,
    data_id            VARCHAR(255)          NOT NULL,
    group_id           VARCHAR(128)          NOT NULL,
    content            TEXT                  NOT NULL,
    md5                VARCHAR(32)                    DEFAULT NULL,
    src_user           TEXT                           DEFAULT NULL,
    src_ip             VARCHAR(100)                   DEFAULT NULL,
    gmt_create         TIMESTAMP(3)          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified       TIMESTAMP(3)          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    app_name           VARCHAR(128)                   DEFAULT NULL,
    tenant_id          VARCHAR(128)                   DEFAULT '',
    gray_name          VARCHAR(128)          NOT NULL,
    gray_rule          TEXT                  NOT NULL,
    encrypted_data_key VARCHAR(256)          NOT NULL DEFAULT ''
);

COMMENT ON TABLE config_info_gray IS 'config_info_gray';
CREATE UNIQUE INDEX uk_configinfogray_datagrouptenantgray ON config_info_gray (data_id, group_id, tenant_id, gray_name);
CREATE INDEX idx_dataid_gmt_modified ON config_info_gray (data_id, gmt_modified);
CREATE INDEX idx_gmt_modified ON config_info_gray (gmt_modified);

CREATE TABLE config_tags_relation
(
    id        BIGINT                NOT NULL,
    tag_name  VARCHAR(128)          NOT NULL,
    tag_type  VARCHAR(64)  DEFAULT NULL,
    data_id   VARCHAR(255)          NOT NULL,
    group_id  VARCHAR(128)          NOT NULL,
    tenant_id VARCHAR(128) DEFAULT '',
    nid       BIGSERIAL PRIMARY KEY NOT NULL
);

COMMENT ON TABLE config_tags_relation IS 'config_tag_relation';
CREATE UNIQUE INDEX uk_configtagrelation_configidtag ON config_tags_relation (id, tag_name, tag_type);
CREATE INDEX idx_tenant_id ON config_tags_relation (tenant_id);

CREATE TABLE group_capacity
(
    id                BIGSERIAL PRIMARY KEY NOT NULL,
    group_id          VARCHAR(128)          NOT NULL DEFAULT '',
    quota             INTEGER               NOT NULL DEFAULT 0,
    usage             INTEGER               NOT NULL DEFAULT 0,
    max_size          INTEGER               NOT NULL DEFAULT 0,
    max_aggr_count    INTEGER               NOT NULL DEFAULT 0,
    max_aggr_size     INTEGER               NOT NULL DEFAULT 0,
    max_history_count INTEGER               NOT NULL DEFAULT 0,
    gmt_create        TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified      TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE group_capacity IS '集群、各Group容量信息表';
CREATE UNIQUE INDEX uk_group_id ON group_capacity (group_id);

CREATE TABLE his_config_info
(
    id                 BIGINT                NOT NULL,
    nid                BIGSERIAL PRIMARY KEY NOT NULL,
    data_id            VARCHAR(255)          NOT NULL,
    group_id           VARCHAR(128)          NOT NULL,
    app_name           VARCHAR(128)                   DEFAULT NULL,
    content            TEXT                  NOT NULL,
    md5                VARCHAR(32)                    DEFAULT NULL,
    gmt_create         TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified       TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    src_user           TEXT                           DEFAULT NULL,
    src_ip             VARCHAR(50)                    DEFAULT NULL,
    op_type            CHAR(10)                       DEFAULT NULL,
    tenant_id          VARCHAR(128)                   DEFAULT '',
    encrypted_data_key VARCHAR(1024)         NOT NULL DEFAULT '',
    publish_type       VARCHAR(50)                    DEFAULT 'formal',
    gray_name          VARCHAR(128)                   DEFAULT NULL,
    ext_info           TEXT                           DEFAULT NULL
);

COMMENT ON TABLE his_config_info IS '多租户改造';
CREATE INDEX idx_gmt_create ON his_config_info (gmt_create);
CREATE INDEX idx_gmt_modified ON his_config_info (gmt_modified);
CREATE INDEX idx_did ON his_config_info (data_id);

CREATE TABLE tenant_capacity
(
    id                BIGSERIAL PRIMARY KEY NOT NULL,
    tenant_id         VARCHAR(128)          NOT NULL DEFAULT '',
    quota             INTEGER               NOT NULL DEFAULT 0,
    usage             INTEGER               NOT NULL DEFAULT 0,
    max_size          INTEGER               NOT NULL DEFAULT 0,
    max_aggr_count    INTEGER               NOT NULL DEFAULT 0,
    max_aggr_size     INTEGER               NOT NULL DEFAULT 0,
    max_history_count INTEGER               NOT NULL DEFAULT 0,
    gmt_create        TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified      TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE tenant_capacity IS '租户容量信息表';
CREATE UNIQUE INDEX uk_tenant_id ON tenant_capacity (tenant_id);

CREATE TABLE tenant_info
(
    id            BIGSERIAL PRIMARY KEY NOT NULL,
    kp            VARCHAR(128)          NOT NULL,
    tenant_id     VARCHAR(128) DEFAULT '',
    tenant_name   VARCHAR(128) DEFAULT '',
    tenant_desc   VARCHAR(256) DEFAULT NULL,
    create_source VARCHAR(32)  DEFAULT NULL,
    gmt_create    BIGINT                NOT NULL,
    gmt_modified  BIGINT                NOT NULL
);

COMMENT ON TABLE tenant_info IS 'tenant_info';
CREATE UNIQUE INDEX uk_tenant_info_kptenantid ON tenant_info (kp, tenant_id);
CREATE INDEX idx_tenant_id ON tenant_info (tenant_id);

CREATE TABLE users
(
    username VARCHAR(50) PRIMARY KEY NOT NULL,
    password VARCHAR(500)            NOT NULL,
    enabled  BOOLEAN                 NOT NULL
);

COMMENT ON COLUMN users.username IS 'username';
COMMENT ON COLUMN users.password IS 'password';
COMMENT ON COLUMN users.enabled IS 'enabled';

CREATE TABLE roles
(
    username VARCHAR(50) NOT NULL,
    role     VARCHAR(50) NOT NULL
);

CREATE UNIQUE INDEX idx_user_role ON roles (username, role);

CREATE TABLE permissions
(
    role     VARCHAR(50)  NOT NULL,
    resource VARCHAR(128) NOT NULL,
    action   VARCHAR(8)   NOT NULL
);

CREATE UNIQUE INDEX uk_role_permission ON permissions (role, resource, action);

CREATE TABLE config_info_beta
(
    id                 BIGSERIAL PRIMARY KEY NOT NULL,
    data_id            VARCHAR(255)          NOT NULL,
    group_id           VARCHAR(128)          NOT NULL,
    tenant_id          VARCHAR(128)                   DEFAULT '',
    app_name           VARCHAR(128)                   DEFAULT NULL,
    content            TEXT                           DEFAULT NULL,
    beta_ips           VARCHAR(1024)                  DEFAULT NULL,
    md5                VARCHAR(32)                    DEFAULT NULL,
    gmt_create         TIMESTAMP             NOT NULL DEFAULT '2010-05-05 00:00:00',
    gmt_modified       TIMESTAMP             NOT NULL DEFAULT '2010-05-05 00:00:00',
    src_user           VARCHAR(128)                   DEFAULT NULL,
    src_ip             VARCHAR(50)                    DEFAULT NULL,
    encrypted_data_key VARCHAR(1024)                  DEFAULT NULL
);

COMMENT ON TABLE config_info_beta IS 'config_info_beta';
CREATE UNIQUE INDEX uk_configinfobeta_datagrouptenant ON config_info_beta (data_id, group_id, tenant_id);

CREATE TABLE config_info_tag
(
    id           BIGSERIAL PRIMARY KEY NOT NULL,
    data_id      VARCHAR(255)          NOT NULL,
    group_id     VARCHAR(128)          NOT NULL,
    tenant_id    VARCHAR(128)          NOT NULL DEFAULT '',
    tag_id       VARCHAR(128)          NOT NULL,
    app_name     VARCHAR(128)                   DEFAULT NULL,
    content      TEXT                  NOT NULL,
    md5          VARCHAR(32)                    DEFAULT NULL,
    gmt_create   TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    src_user     TEXT                           DEFAULT NULL,
    src_ip       VARCHAR(50)                    DEFAULT NULL
);

COMMENT ON TABLE config_info_tag IS 'config_info_tag';
CREATE UNIQUE INDEX uk_configinfotag_datagrouptenanttag ON config_info_tag (data_id, group_id, tenant_id, tag_id);

CREATE TABLE pipeline_execution
(
    execution_id  VARCHAR(64)  PRIMARY KEY NOT NULL,
    resource_type VARCHAR(32)  NOT NULL,
    resource_name VARCHAR(256) NOT NULL,
    namespace_id  VARCHAR(128) DEFAULT NULL,
    version       VARCHAR(64)  DEFAULT NULL,
    status        VARCHAR(32)  NOT NULL,
    pipeline      TEXT         NOT NULL,
    create_time   BIGINT(20)   NOT NULL,
    update_time   BIGINT(20)   NOT NULL
);

COMMENT ON TABLE pipeline_execution IS 'pipeline_execution';

CREATE TABLE ai_resource
(
    id               BIGSERIAL PRIMARY KEY NOT NULL,
    gmt_create       TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified     TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    name             VARCHAR(256)          NOT NULL,
    type             VARCHAR(32)           NOT NULL,
    c_desc           VARCHAR(2048)                  DEFAULT NULL,
    status           VARCHAR(32)                    DEFAULT NULL,
    namespace_id     VARCHAR(128)          NOT NULL DEFAULT '',
    biz_tags         VARCHAR(1024)                  DEFAULT NULL,
    ext              TEXT                           DEFAULT NULL,
    c_from           VARCHAR(256)          NOT NULL DEFAULT 'local',
    version_info     TEXT                           DEFAULT NULL,
    meta_version     BIGINT(20)            NOT NULL DEFAULT 1,
    scope            VARCHAR(16)           NOT NULL DEFAULT 'PRIVATE',
    owner            VARCHAR(128)          NOT NULL DEFAULT '',
    download_count   BIGINT(20)            NOT NULL DEFAULT 0
);

COMMENT ON TABLE ai_resource IS 'ai_resource';
CREATE UNIQUE INDEX uk_ai_resource_ns_name_type ON ai_resource (namespace_id, name, type, c_from);
CREATE INDEX idx_ai_resource_name ON ai_resource (name);
CREATE INDEX idx_ai_resource_type ON ai_resource (type);
CREATE INDEX idx_ai_resource_gmt_modified ON ai_resource (gmt_modified);

CREATE TABLE ai_resource_version
(
    id                    BIGSERIAL PRIMARY KEY NOT NULL,
    gmt_create            TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified          TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    type                  VARCHAR(32)           NOT NULL,
    author                VARCHAR(128)                 DEFAULT NULL,
    name                  VARCHAR(256)          NOT NULL,
    c_desc                VARCHAR(2048)                DEFAULT NULL,
    status                VARCHAR(32)            NOT NULL,
    version               VARCHAR(64)            NOT NULL,
    namespace_id          VARCHAR(128)          NOT NULL DEFAULT '',
    storage               TEXT                         DEFAULT NULL,
    publish_pipeline_info TEXT                         DEFAULT NULL,
    download_count        BIGINT(20)            NOT NULL DEFAULT 0
);

COMMENT ON TABLE ai_resource_version IS 'ai_resource_version';
CREATE UNIQUE INDEX uk_ai_resource_ver_ns_name_type_ver ON ai_resource_version (namespace_id, name, type, version);
CREATE INDEX idx_ai_resource_ver_name ON ai_resource_version (name);
CREATE INDEX idx_ai_resource_ver_status ON ai_resource_version (status);
CREATE INDEX idx_ai_resource_ver_gmt_modified ON ai_resource_version (gmt_modified);

INSERT INTO users(username, password, enabled) VALUES ('nacos', '$2a$10$EuWPZHzz32dJN7jexM34MOeYirDdFAZm2kuWj7VEOJhhZkDrxfvUu', true);

INSERT INTO roles(username, role) VALUES ('nacos', 'ROLE_ADMIN');