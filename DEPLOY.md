# Despliegue en producción

## Variables

Crear un archivo `.env` en el servidor a partir de `.env.example`:

```env
PUBLIC_SITE_URL=https://jorgeveliz.dev
DOMAIN=jorgeveliz.dev
CADDY_NETWORK=proxy
```

`PUBLIC_SITE_URL` es la URL que Astro usa para generar sitemap, canonicales y metadatos dependientes del sitio.

`CADDY_NETWORK` es la red Docker externa donde ya corre tu contenedor Caddy. Por defecto: `proxy`.

## Levantar producción

```bash
docker compose up -d --build
```

El servicio `site` se une a la red externa de Caddy. Caddy y este compose deben compartir la misma red Docker.

Para ver en qué red está tu Caddy:

```bash
docker inspect caddy --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}'
```

Si la red se llama distinto, define `CADDY_NETWORK` en `.env` o créala y conecta Caddy:

```bash
docker network create proxy
docker network connect proxy caddy
```

## Caddy existente

Este proyecto no levanta Caddy. En tu Caddyfile, apunta directamente al contenedor del sitio por HTTP interno:

```caddyfile
jorgeveliz.dev, www.jorgeveliz.dev {
	reverse_proxy marca-personal-site:80
}
```

Referencia completa en `deploy/caddy/Caddyfile`.

Importante para evitar `ERR_TOO_MANY_REDIRECTS`:

- Caddy termina TLS y reenvía HTTP a `marca-personal-site:80`.
- No reenvíes a `nginx-proxy`, al puerto `443` del host ni a otro proxy que redirija otra vez a HTTPS.
- No añadas `redir https://...` dentro del bloque HTTPS; Caddy ya redirige HTTP → HTTPS solo.

Recarga Caddy tras cambiar el Caddyfile:

```bash
docker exec caddy caddy reload --config /etc/caddy/Caddyfile
```

## Puertos

Este compose no publica `80` ni `443`. Esos puertos los gestiona tu contenedor Caddy.

## Ver logs

```bash
docker compose logs -f
```

Dozzle está incluido como herramienta opcional de logs. Se expone solo en localhost del servidor:

```bash
docker compose --profile tools up -d dozzle
```

Luego abre `http://localhost:9999` desde el servidor o mediante un túnel SSH.
