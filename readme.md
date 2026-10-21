# Web PHP Container (PHP-FPM + Nginx on Alpine Linux)

Imagens Docker otimizadas e prontas para produção (Laravel / Lumen / aplicações PHP), baseadas em **Alpine Linux (`3.24.1`)** com **PHP compilado do código-fonte oficial (`php.net`)**, **Nginx Mainline**, **Composer 2** e gerenciamento de processos via **s6-overlay**.

---

## 📦 Variantes Disponíveis (Ativas)

| Variante | Pasta | Tag da Imagem | Descrição |
| :--- | :--- | :--- | :--- |
| **PHP 8.5** | `php8.5/` | `renatobalbino/php:8.5` | PHP 8.5.12 + Nginx + Redis + Extensões essenciais |
| **PHP 8.5 + OCI8** | `php8.5-oci8/` | `renatobalbino/php:8.5-oci8` | PHP 8.5.12 + Nginx + Oracle Instant Client 21.17 (`oci8`) + Redis |
| **PHP 8.4** | `php8.4/` | `renatobalbino/php:8.4` | PHP 8.4.27 + Nginx + Redis + Extensões essenciais |
| **PHP 8.4 + OCI8** | `php8.4-oci8/` | `renatobalbino/php:8.4-oci8` | PHP 8.4.27 + Nginx + Oracle Instant Client 21.17 (`oci8`) + Redis |
| **PHP 8.5 Octane** | `php8.5-octane/` | `renatobalbino/php:8.5-octane` | PHP 8.5 + Swoole para Laravel Octane |
| **PHP 8.5 Octane + OCI8** | `php8.5-octane-oci8/` | `renatobalbino/php:8.5-octane-oci8` | PHP 8.5 + Swoole + Oracle Instant Client (`oci8`) |

---

## 🧩 Extensões e Bibliotecas Incluídas (8.4 e 8.5)

- **Extensões do PHP compiladas e ativas:**
  `bcmath`, `ctype`, `curl`, `dom`, `exif`, `fileinfo`, `filter`, `ftp`, `gd` (com suporte a JPEG, WebP e FreeType), `hash`, `iconv`, `intl`, `json`, `libxml`, `mbstring`, `mysqli`, `mysqlnd`, `openssl`, `pcntl`, `pcre`, `PDO`, `pdo_mysql`, `pdo_sqlite`, `Phar`, `posix`, `redis` (PECL), `session`, `SimpleXML`, `sockets`, `sodium`, `SPL`, `sqlite3`, `tokenizer`, `xml`, `xmlreader`, `xmlwriter`, `Zend OPcache`, `zip`, `zlib` (e `oci8` nas variantes `-oci8`).
- **Pacotes de sistema adicionais (Alpine):**
  `nginx` (mainline oficial), `curl`, `ca-certificates`, `xvfb`, `ttf-freefont`, `fontconfig`, `dbus`, `libxrender`, `icu-libs`, `libzip`.

---

## ⚙️ Configuração de Variáveis (`.env`)

O projeto utiliza arquivos `.env` em dois níveis para facilitar a manutenção e criação de novas versões:

1. **`.env` na raiz do projeto** — define o repositório do Docker Hub e o nome da imagem:
   ```env
   REPOSITORY=renatobalbino
   IMAGE=php
   ```
2. **`.env` dentro da pasta de cada versão** (ex: `php8.5/.env`, `php8.5-oci8/.env`) — define a tag específica daquela variante:
   ```env
   TAG=8.5-oci8
   ```

---

## 🧪 Executando os Testes Automatizados (Sem enviar para o Docker Hub)

O repositório possui uma suíte de testes automatizados em `tests/test-images.sh` que:
1. Faz o build local da imagem (ou testa uma imagem já construída).
2. Imprime o inventário completo das versões instaladas (Alpine, Kernel, PHP CLI, PHP-FPM, Nginx, Composer, OpenSSL, cURL, pacotes do `apk` e extensões do PHP).
3. Valida o carregamento de todas as extensões obrigatórias, pacotes do Alpine e diretivas do `php.ini` (`expose_php = Off`).
4. Sobe um container temporário e valida as respostas HTTP do Nginx + PHP-FPM (`GET /`, headers de segurança, ocultação do `X-Powered-By`, `/ping` e `/status`).

```bash
# Testar todas as variantes principais (8.4, 8.4-oci8, 8.5 e 8.5-oci8)
./tests/test-images.sh all

# Testar apenas a família 8.5 (php8.5 e php8.5-oci8)
./tests/test-images.sh 8.5

# Testar apenas a família 8.4 (php8.4 e php8.4-oci8)
./tests/test-images.sh 8.4

# Testar uma única variante específica
./tests/test-images.sh php8.5
./tests/test-images.sh php8.5-oci8
./tests/test-images.sh php8.4
./tests/test-images.sh php8.4-oci8
```

---

## 🚀 Fazendo Build e Publicando no Docker Hub

O script `./build.sh` na raiz executa o build da versão escolhida, **roda automaticamente a bateria de testes** e, somente se 100% dos testes passarem, envia (`docker push`) a imagem para o Docker Hub. Caso qualquer teste falhe, o envio é cancelado automaticamente.

```bash
# Build + Teste + Push do PHP 8.5 (padrão)
./build.sh
# ou
./build.sh 8.5

# Build + Teste + Push do PHP 8.5 com Oracle OCI8
./build.sh 8.5-oci8

# Build + Teste + Push do PHP 8.4
./build.sh 8.4

# Build + Teste + Push do PHP 8.4 com Oracle OCI8
./build.sh 8.4-oci8
```

---

## 💻 Como Utilizar no Seu Projeto (Laravel / Lumen)

### Exemplo de `Dockerfile` na aplicação:
```dockerfile
FROM renatobalbino/php:8.5

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