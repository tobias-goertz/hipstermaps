# HipsterMaps

Custom map poster generator. Users search for a city, customize styling/format, and the app generates a high-resolution PNG poster via AWS Lambda.

## Tech Stack

- **Ruby 3.3.6** / **Rails 8.1**
- **PostgreSQL** database
- **Solid Queue** for background jobs (no Redis)
- **Solid Cable** for Action Cable (no Redis)
- **Tailwind CSS** via `tailwindcss-rails` (mobile-first)
- **Propshaft** asset pipeline
- **Importmap** for JS delivery
- **Stimulus** controllers + **Turbo Streams** for real-time updates
- **ERB** templates
- **Minitest** for testing

## Architecture

### Core Flow
1. User visits `/` → `MapsController#new` with interactive Mapbox GL map
2. User searches city via Mapbox Geocoder → auto-fills title/subtitle/coords
3. User submits form → `MapsController#create` → `Map` record created (status: `in_progress`)
4. `MapGenerationJob` enqueued via Solid Queue
5. `MapGenerationService` invokes AWS Lambda, polls S3 for result
6. Map status updated to `available` or `failed`
7. Show page receives Turbo Stream broadcast → UI updates automatically

### Domain Model
- **Map** — single model with: format, style, lon, lat, zoom, filename, title, subtitle, coords, status (enum: in_progress/available/failed)

### External Services
- **Mapbox GL JS** — map rendering and geocoding (client-side)
- **AWS Lambda** (`hipstermaps-lambda` repo) — generates poster PNG
- **AWS S3** — stores generated poster files
- **CDN** — serves poster images via `MAPS_CDN_HOST`

## Key Files

- `app/models/map.rb` — Map model with validations, enum, callbacks
- `app/jobs/map_generation_job.rb` — Active Job wrapper for map generation
- `app/services/map_generation_service.rb` — Lambda invocation + S3 polling
- `app/controllers/maps_controller.rb` — new, create, show actions
- `app/javascript/controllers/map_preview_controller.js` — Mapbox GL Stimulus controller
- `app/javascript/controllers/geocoder_controller.js` — Mapbox Geocoder Stimulus controller
- `app/javascript/controllers/poster_preview_controller.js` — live poster text preview

## Environment Variables

All config is via env vars (see `.env.sample`):
- `AWS_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_BUCKET_NAME`
- `LAMBDA_FN_NAME`
- `MAPBOX_ACCESS_TOKEN` (public token, used in frontend meta tag)
- `MAPS_CDN_HOST`
- `DATABASE_URL` (production only — dev/test use docker-compose postgres)
- `SECRET_KEY_BASE` (production only)

## Development

```bash
docker compose up -d      # Start postgres (dev database)
bin/rails db:create db:migrate
bin/rails server          # Start dev server
bin/jobs                  # Start Solid Queue worker (separate terminal)
bin/rails test            # Run tests
```

## Lambda Repo

The poster generation Lambda lives at `~/git/private/hipstermaps-lambda/`. Node.js 20, AWS SDK v3, Sharp for image processing.
