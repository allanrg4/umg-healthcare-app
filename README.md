# UmgHealthcare

Medication tracking system for Hospital La Paz. Built for the Web Development
course at Universidad Mariano Gálvez, written in Elixir with Phoenix LiveView
and Postgres.

## Requirements

- Elixir 1.17 or newer (tested with 1.20) and Erlang/OTP 27 or newer
- Docker with `docker compose`

## Running in development

1. Start the database:

       docker compose up -d db

2. Install dependencies, create the database and build the assets:

       mix setup

3. Start the server:

       mix phx.server

Open [http://localhost:4000](http://localhost:4000).

## Demo data

`mix setup` (or `mix run priv/repo/seeds.exs`) loads a medication catalog and
demo users. Every demo user shares the password `demo-lapaz-2026`.

| Email | Role | What to look at |
|---|---|---|
| `medico@lapaz.test` | Doctor | Patient records, new prescriptions and two renewal alerts |
| `ana@lapaz.test` | Patient | Routine, upcoming doses, 12 days of adherence history |
| `carlos@lapaz.test` | Patient | Two doses a day, 7 days of adherence history |
| `sofia@lapaz.test` | Patient | New patient without routine or prescriptions |

Doses and dates are generated relative to the day you load the data. To start
over with fresh data: `mix ecto.reset`.

## Tests

    mix test

Before considering a change done:

    mix precommit

## Stopping the database

    docker compose stop db

To also delete the data: `docker compose down -v`.
