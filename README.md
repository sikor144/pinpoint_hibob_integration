# Pinpoint HiBob Integration

This Rails application integrates Pinpoint and HiBob to handle webhooks and manage employee data and related documents.

## Features

- **Webhook Handling**: Processes webhooks from Pinpoint.
- **Employee Management**: Creates and manages employee records in HiBob.
- **Document Management**: Uploads CVs and other documents to HiBob.
- **Comments Management**: Adds comments to Pinpoint applications.

## Getting Started

### Prerequisites

- Ruby 3.3.0
- Rails 7.1.3.4
- SQLite

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/sikor144/pinpoint_hibob_integration.git
   cd pinpoint_hibob_integration
   ```

2. Install dependencies:

   ```bash
   bundle install
   ```

3. Set up the database:

   ```bash
   rails db:create db:migrate
   ```

4. Set up environment variables:

   Create a `.env` file in the root directory and add the following:

   ```
   HIBOB_BASE_URL=https://api.hibob.com
   HIBOB_BASIC_AUTH_USERNAME=your_username
   HIBOB_BASIC_AUTH_PASSWORD=your_password
   PINPOINT_API_KEY=your_api_key
   PINPOINT_BASE_URL=https://your-subdomain.pinpointhq.com
   PINPOINT_SIGNING_SECRET=your_signing_secret
   ```

### Running the Application

Start the Rails server:

```bash
rails s
```

### Running Tests

Run the test suite:

```bash
bundle exec rspec
```

## Usage

### Webhook Endpoint

The application provides an endpoint to handle webhooks from Pinpoint. The endpoint verifies the request, processes the event, and updates HiBob accordingly.

### Creating Employees

The application creates employee records in HiBob when a `application_hired` event is received. It fetches the application data from Pinpoint, creates the employee in HiBob, uploads the CV, and adds a comment to the application.

### Uploading Documents

The `AddSharedDocument` class is responsible for uploading documents to HiBob. The documents are added as shared documents for the specified employee.

### Adding Comments

The `AddComment` class adds comments to Pinpoint applications, such as noting the creation of an employee record in HiBob.

## Development

### Code Structure

- **Controllers**: Handle HTTP requests and responses.
- **Handlers**: Process specific events and perform business logic.
  -- **Apis**: Interact with external APIs.
- **Services**: Encapsulate reusable business logic and API interactions.
- **Models**: Represent data and interact with the database.

### Key Classes

- `Pinpoint::ApplicationHiredHandler`: Handles the `application_hired` event.
- `Apis::HiBob::People::AddSharedDocument`: Uploads CVs as shared documents to HiBob.
- `Apis::Pinpoint::Applications::AddComment`: Adds comments to Pinpoint applications.
- `WebhookEventHandlerRegistry`: Manages event handler registration.

### Adding New Features

1. **Create a New Handler**: Define a new handler class for the event.
2. **Register the Handler**: Register the handler in `WebhookEventHandlerRegistry`.
3. **Write Tests**: Add tests for the new handler and ensure all tests pass.

## License

This project is licensed under the MIT License.

## Acknowledgments

- [HiBob API](https://apidocs.hibob.com/)
- [Pinpoint API](https://docs.pinpoint.com/)
