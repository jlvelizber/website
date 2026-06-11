# Despliegue en producción

## Variables

Crear un archivo `.env` en el servidor a partir de `.env.example`:

```env
PUBLIC_SITE_URL=https://jorgeveliz.dev
DOMAIN=jorgeveliz.dev
SITE_PORT=8080
```

`PUBLIC_SITE_URL` es la URL que Astro usa para generar sitemap, canonicales y metadatos dependientes del sitio.

`SITE_PORT` es el puerto del host donde queda expuesto el contenedor `site`. Tu Caddy existente debe apuntar ahí.

## Levantar producción

```bash
docker compose up -d --build
```

El sitio queda disponible en el servidor en `http://localhost:8080` (o el puerto que definas en `SITE_PORT`).

## Caddy existente

Este proyecto no levanta Caddy. Sigue el mismo patrón que el resto de tus apps: el compose publica un puerto en el host y Caddy hace TLS + reverse proxy hacia ese puerto.

En tu Caddyfile:

```caddyfile
jorgeveliz.dev, www.jorgeveliz.dev {
	reverse_proxy localhost:8080
}
```

Referencia en `deploy/caddy/Caddyfile`.

Si Caddy corre dentro de Docker y no con `network_mode: host`, usa la IP del host o `host.docker.internal` en lugar de `localhost`:

```caddyfile
reverse_proxy host.docker.internal:8080
```

Recarga Caddy tras cambiar el Caddyfile:

```bash
docker exec caddy caddy reload --config /etc/caddy/Caddyfile
```

## Evitar ERR_TOO_MANY_REDIRECTS

- Caddy debe apuntar al puerto HTTP del sitio (`SITE_PORT`), no al `443` del host.
- No uses `nginx-proxy` ni otro proxy intermedio que redirija otra vez a HTTPS.
- El contenedor `site` solo sirve HTTP estático; no fuerza redirecciones a HTTPS.

## Puertos

| Puerto | Uso |
|--------|-----|
| `SITE_PORT` (default `8080`) | Sitio expuesto en el host para Caddy |
| `80` / `443` | Los gestiona tu Caddy existente |

## Ver logs

```bash
docker compose logs -f
```

Dozzle está incluido como herramienta opcional de logs. Se expone solo en localhost del servidor:

```bash
docker compose --profile tools up -d dozzle
```

Luego abre `http://localhost:9999` desde el servidor o mediante un túnel SSH.
