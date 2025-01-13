#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~ Salon Appointment Scheduler ~~\n"

# Function to display services
display_services() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME; do
    echo "$SERVICE_ID) $NAME"
  done
}

# Function to prompt for service ID
prompt_for_service() {
  echo -e "\nEnter a service number:"
  read SERVICE_ID_SELECTED

  # Check if service id is valid
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\nInvalid service number. Please try again."
    display_services
    prompt_for_service
  fi
}

# Display list of services and prompt for input
display_services
prompt_for_service

# Prompt for phone number
echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]]; then
  # Prompt for customer name if not exists
  echo -e "\nEnter your name:"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# Prompt for appointment time
echo -e "\nEnter your appointment time:"
read SERVICE_TIME

# Insert appointment
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
