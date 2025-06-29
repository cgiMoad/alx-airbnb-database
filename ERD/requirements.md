# Entity-Relationship Diagram Requirements

## Entities and Attributes

### User
- `user_id`: UUID, Primary Key, Indexed
- `first_name`: VARCHAR, NOT NULL
- `last_name`: VARCHAR, NOT NULL
- `email`: VARCHAR, UNIQUE, NOT NULL
- `password_hash`: VARCHAR, NOT NULL
- `phone_number`: VARCHAR, NULL
- `role`: ENUM('guest', 'host', 'admin'), NOT NULL
- `created_at`: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

### Property
- `property_id`: UUID, Primary Key, Indexed
- `host_id`: UUID, Foreign Key → User(user_id)
- `name`: VARCHAR, NOT NULL
- `description`: TEXT, NOT NULL
- `location`: VARCHAR, NOT NULL
- `pricepernight`: DECIMAL, NOT NULL
- `created_at`: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `updated_at`: TIMESTAMP, ON UPDATE CURRENT_TIMESTAMP

### Booking
- `booking_id`: UUID, Primary Key, Indexed
- `property_id`: UUID, Foreign Key → Property(property_id)
- `user_id`: UUID, Foreign Key → User(user_id)
- `start_date`: DATE, NOT NULL
- `end_date`: DATE, NOT NULL
- `total_price`: DECIMAL, NOT NULL
- `status`: ENUM('pending', 'confirmed', 'canceled'), NOT NULL
- `created_at`: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

### Payment
- `payment_id`: UUID, Primary Key, Indexed
- `booking_id`: UUID, Foreign Key → Booking(booking_id)
- `amount`: DECIMAL, NOT NULL
- `payment_date`: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `payment_method`: ENUM('credit_card', 'paypal', 'stripe'), NOT NULL

### Review
- `review_id`: UUID, Primary Key, Indexed
- `property_id`: UUID, Foreign Key → Property(property_id)
- `user_id`: UUID, Foreign Key → User(user_id)
- `rating`: INTEGER, CHECK rating BETWEEN 1 AND 5, NOT NULL
- `comment`: TEXT, NOT NULL
- `created_at`: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

### Message
- `message_id`: UUID, Primary Key, Indexed
- `sender_id`: UUID, Foreign Key → User(user_id)
- `recipient_id`: UUID, Foreign Key → User(user_id)
- `message_body`: TEXT, NOT NULL
- `sent_at`: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

## Relationships

- A User can own many Properties (User 1:N Property)
- A User can make many Bookings (User 1:N Booking)
- A User can leave many Reviews (User 1:N Review)
- A User can send and receive Messages (User 1:N Message)
- A Property can have many Bookings and Reviews
- A Booking has one Payment (Booking 1:1 Payment)
- A Booking is associated with one Property and one User
- A Review is linked to one Property and one User

## Constraints Summary

### User
- `email` must be unique
- Required: `first_name`, `last_name`, `email`, `password_hash`, `role`

### Property
- `host_id` must reference a valid User
- Required: `name`, `location`, `pricepernight`

### Booking
- `user_id` and `property_id` must exist
- `status` must be 'pending', 'confirmed', or 'canceled'

### Payment
- Must link to a valid `booking_id`

### Review
- Rating must be between 1 and 5
- Must link valid `property_id` and `user_id`

### Message
- Must link valid `sender_id` and `recipient_id`

## Indexing

- All Primary Keys are indexed by default
- Additional Indexes:
  - `email` in User
  - `property_id` in Property and Booking
  - `booking_id` in Booking and Payment


