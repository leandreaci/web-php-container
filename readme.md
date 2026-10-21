# Web PHP Container (PHP-FPM + Nginx on Alpine Linux)

Imagens Docker otimizadas e prontas para produção (Laravel / Lumen / aplicações PHP), baseadas em **Alpine Linux (`3.24.1`)** com **PHP compilado do código-fonte oficial (`php.net`)**, **Nginx Mainline**, **Composer 2**, helpers de instalação de extensões sob demanda (`install-php-extensions`) e gerenciamento de processos via **s6-overlay**.

---

## 📦 Variantes Disponíveis (Ativas)

| Variante | Pasta | Tag da Imagem | Descrição |
| :--- | :--- | :--- | :--- |
| **PHP 8.5** | `php8.5/` | `renatobalbino/php:8.5` | PHP 8.5.12 + Nginx + Redis + Extensões essenciais + `install-php-extensions` |
| **PHP 8.4** | `php8.4/` | `renatobalbino/php:8.4` | PHP 8.4.27 + Nginx + Redis + Extensões essenciais + `install-php-extensions` |
| **PHP 8.5 Octane** | `php8.5-octane/` | `renatobalbino/php:8.5-octane` | PHP 8.5 + Swoole para Laravel Octane |
| **PHP 8.5 Octane + OCI8** | `php8.5-octane-oci8/` | `renatobalbino/php:8.5-octane-oci8` | PHP 8.5 + Swoole + Oracle Instant Client (`oci8`) |

---

## 🧩 Extensões e Bibliotecas Incluídas por Padrão (8.4 e 8.5)

- **Extensões do PHP compiladas e ativas:**
  `bcmath`, `ctype`, `curl`, `dom`, `exif`, `fileinfo`, `filter`, `ftp`, `gd` (com suporte a JPEG, WebP e FreeType), `hash`, `iconv`, `intl`, `json`, `libxml`, `mbstring`, `mysqli`, `mysqlnd`, `openssl`, `pcntl`, `pcre`, `PDO`, `pdo_mysql`, `pdo_sqlite`, `Phar`, `posix`, `redis` (PECL), `session`, `SimpleXML`, `sockets`, `sodium`, `SPL`, `sqlite3`, `tokenizer`, `xml`, `xmlreader`, `xmlwriter`, `Zend OPcache`, `zip`, `zlib`.
- **Pacotes de sistema adicionais (Alpine):**
  `nginx` (mainline oficial), `curl`, `ca-certificates`, `xvfb`, `ttf-freefont`, `fontconfig`, `dbus`, `libxrender`, `icu-libs`, `libzip`.

---

## 🛠️ Helpers para Instalar e Habilitar Extensões nos Microsserviços

As imagens `8.4` e `8.5` incluem os utilitários em `/usr/local/bin/`:
- **`install-php-extensions`** (e o alias **`docker-php-ext-install`**): Instala, compila e habilita uma ou mais extensões (tanto via PECL quanto extensões do core do PHP ou Oracle Instant Client) e remove todas as dependências temporárias de compilação ao final.
- **`docker-php-ext-enable`**: Habilita um módulo `.so` já compilado criando o arquivo `.ini` correspondente em `/usr/local/etc/php/conf.d/`.

### Exemplos de extensões suportadas pelo `install-php-extensions`:
- **Oracle (`oci8` e `pdo_oci`):** Baixa e configura automaticamente o Oracle Instant Client `21.17` em `/opt/oracle/instantclient` e compila a extensão:
  ```dockerfile
  RUN install-php-extensions oci8
  # ou com PDO_OCI:
  RUN install-php-extensions oci8 pdo_oci
  ```
- **Outras extensões (Core ou PECL):**
  ```dockerfile
  RUN install-php-extensions soap xsl pgsql pdo_pgsql ldap gmp gettext bz2 calendar
  RUN install-php-extensions xdebug imagick swoole amqp apcu mongodb
  ```

---

## ⚙️ Configuração de Variáveis (`.env`)

O projeto utiliza arquivos `.env` em dois níveis para facilitar a manutenção e criação de novas versões:

1. **`.env` na raiz do projeto** — define o repositório do Docker Hub e o nome da imagem:
   ```env
   REPOSITORY=renatobalbino
   IMAGE=php
   ```
2. **`.env` dentro da pasta de cada versão** (ex: `php8.5/.env`, `php8.4/.env`) — define a tag específica daquela variante:
   ```env
   TAG=8.5
   ```

---

## 🧪 Executando os Testes Automatizados (Sem enviar para o Docker Hub)

O repositório possui uma suíte de testes automatizados em `tests/test-images.sh` que:
1. Faz o build local da imagem (ou testa uma imagem já construída).
2. Imprime o inventário completo das versões instaladas (Alpine, Kernel, PHP CLI, PHP-FPM, Nginx, Composer, OpenSSL, cURL, pacotes do `apk` e extensões do PHP).
3. Valida a presença dos helpers (`install-php-extensions`, `docker-php-ext-enable`), o carregamento de todas as extensões obrigatórias, pacotes do Alpine e diretivas do `php.ini` (`expose_php = Off`).
4. Sobe um container temporário e valida as respostas HTTP do Nginx + PHP-FPM (`GET /`, headers de segurança, ocultação do `X-Powered-By`, `/ping` e `/status`).

```bash
# Testar todas as variantes principais (php8.4 e php8.5)
./tests/test-images.sh all

# Testar apenas uma versão específica
./tests/test-images.sh 8.5
./tests/test-images.sh 8.4
```

---

## 🚀 Fazendo Build e Publicando no Docker Hub

O script `./build.sh` na raiz executa o build da versão escolhida, **roda automaticamente a bateria de testes** e, somente se 100% dos testes passarem, envia (`docker push`) a imagem para o Docker Hub. Caso qualquer teste falhe, o envio é cancelado automaticamente.

```bash
# Build + Teste + Push do PHP 8.5 (padrão)
./build.sh
# ou
./build.sh 8.5

# Build + Teste + Push do PHP 8.4
./build.sh 8.4
```

---

## 💻 Como Utilizar no Seu Microsserviço (Laravel / Lumen)

### 1. Microsserviço padrão:
```dockerfile
FROM renatobalbino/php:8.5

WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --ignore-platform-reqs --optimize-autoloader
```

### 2. Microsserviço que precisa de Oracle (`oci8`) ou outras extensões específicas:
```dockerfile
FROM renatobalbino/php:8.5

# Instala o Oracle Instant Client + extensão oci8 (e/ou soap, xdebug, pgsql, etc.)
RUN install-php-extensions oci8

WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --ignore-platform-reqs --optimize-autoloader
```

### Rodando um projeto localmente mapeando o volume:
```bash
cd seu_projeto/
docker run -d -p 8000:80 -v $(pwd):/var/www/html renatobalbino/php:8.5
```

---

## ➕ Como Criar uma Nova Versão no Futuro

1. Duplique a pasta da versão mais recente (ex: `cp -r php8.5 php8.6`).
2. Edite o arquivo `php8.6/.env` alterando a variável `TAG` (ex: `TAG=8.6`).
3. Atualize a versão da release do PHP em `php8.6/config/boostrap.sh` (`PHP_RELEASE`).
4. Execute `./tests/test-images.sh php8.6` para validar localmente ou `./build.sh 8.6` para testar e publicar.