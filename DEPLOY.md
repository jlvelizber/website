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

El sitio queda disponible en:

- `https://jorgeveliz.dev`
- `https://www.jorgeveliz.dev`

Los certificados se generan automáticamente con `nginxproxy/acme-companion` y Let's Encrypt.

## Ver logs

```bash
docker compose logs -f
```

Dozzle está incluido como herramienta opcional de logs. Se expone solo en localhost del servidor:

```bash
docker compose --profile tools up -d dozzle
```

Luego abre `http://localhost:9999` desde el servidor o mediante un túnel SSH.
