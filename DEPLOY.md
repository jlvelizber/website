# Despliegue en producción

## Variables

Crear un archivo `.env` en el servidor a partir de `.env.example`:

```env
PUBLIC_SITE_URL=https://jorgeveliz.dev
DOMAIN=jorgeveliz.dev
LETSENCRYPT_EMAIL=admin@jorgeveliz.dev
```

`PUBLIC_SITE_URL` es la URL que Astro usa para generar sitemap, canonicales y metadatos dependientes del sitio.

## Levantar producción

```bash
docker compose up -d --build
```

Si migras desde `nginx-proxy`, detén y elimina los contenedores antiguos antes de levantar Caddy:

```bash
docker compose down
docker rm -f nginx-proxy nginx-proxy-acme 2>/dev/null || true
docker compose up -d --build
```

## Puertos

El servicio `site` solo expone el puerto `80` dentro de la red Docker. El HTTPS público lo maneja `caddy`, que publica estos puertos del servidor:

```yaml
ports:
  - "80:80"
  - "443:443"
```

En el servidor, asegúrate de que el firewall permita ambos puertos:

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

El sitio queda disponible en:

- `https://jorgeveliz.dev`
- `https://www.jorgeveliz.dev`

Los certificados se generan automáticamente con Caddy y Let's Encrypt.

## Proxy reverso

Caddy termina TLS y reenvía tráfico HTTP interno directamente a `site:80`. No uses `nginx-proxy` en paralelo: si Caddy reenvía a un proxy que también redirige a HTTPS, el navegador entra en un bucle (`ERR_TOO_MANY_REDIRECTS`).

La configuración vive en `deploy/caddy/Caddyfile`.

## Ver logs

```bash
docker compose logs -f
```

Dozzle está incluido como herramienta opcional de logs. Se expone solo en localhost del servidor:

```bash
docker compose --profile tools up -d dozzle
```

Luego abre `http://localhost:9999` desde el servidor o mediante un túnel SSH.
