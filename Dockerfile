FROM node:22-alpine AS deps

WORKDIR /app

COPY package*.json ./
RUN npm ci

FROM deps AS build

ARG PUBLIC_SITE_URL=https://jorgeveliz.dev
ENV PUBLIC_SITE_URL=$PUBLIC_SITE_URL

COPY . .
RUN npm run build

FROM nginx:1.27-alpine AS runtime

COPY deploy/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

# HTTPS termina en el servicio caddy del docker-compose.
# Este contenedor solo sirve el sitio estático por HTTP interno.
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
