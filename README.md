# README
# ST Admin

ST Admin is a Rails application designed to manage Accounting offices.

## Getting Started

These instructions will help you set up and run the project on your local machine for development and testing purposes.

### Prerequisites

- Docker
- Docker Compose
- Rails ~ 7.0
- ruby ~ 3.2

### Setup

1. Clone the repository:
  ```sh
  git clone https://github.com/radekzawada/tax-admin
  cd tax-admin
  ```

2. Build and start the Docker containers:
  ```sh
  docker-compose up --build
  ```

3. Setup the database:
  ```sh
  rake db:create
  rake db:migrate
  rake db:seed
  ```

### Running the Application

To start the Rails server, run:
```sh
docker-compose up -d && rails s
```
The application will be available at `http://localhost:3000`.

### Running Tests

To run the test suite, use:
```sh
rspec spec
```

### Additional Information

* **Ruby version**: Check the `.ruby-version` file.
* **System dependencies**: Listed in the `Gemfile`.
* **Configuration**: Environment variables are managed using `dotenv`.
* **Database creation**: See the setup section above.
* **Database initialization**: See the setup section above.
* **Services**: The application uses PostgreSQL as the database.
* **Deployment instructions**: TBD

Project management: [Trello board](https://trello.com/b/3TCK8IDF/tax-admin).
