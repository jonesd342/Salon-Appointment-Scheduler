#! /bin/bash

# remember that tuples only returns things in a much more parseable format
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
# display message if given an argument
if [[ $1 ]]
then
  echo -e "\n$1"
fi

# display main menu
SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services")
echo "$SERVICES_LIST" | while read SERV_ID BAR SERV_NAME
do
  echo -e "$SERV_ID) $SERV_NAME"
done
echo -e "\n6) Exit"
read SERVICE_ID_SELECTED

if [[ $SERVICE_ID_SELECTED != 6 ]]  # if client enters 6, exit
  then
  if [[ ! $SERVICE_ID_SELECTED = [1-5] ]] # if menu selection is out of range
  then
    MAIN_MENU "Please select a valid option."
  else  # menu selection is valid, proceed with appointment details
    echo -e "\nFantastic! May we have your phone number? Enter in xxx-xxx-xxxx format."
    read CUSTOMER_PHONE
  
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
    # if customer does not exist yet
    if [[ -z $CUSTOMER_NAME ]]
    then
    # ask for name
      echo -e "\nMay we have your name?"
      read CUSTOMER_NAME
      $PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
    fi
    # schedule time
    echo -e "What time would you like your appointment to begin,$CUSTOMER_NAME?"
    read SERVICE_TIME
  
    # get appointment information for printing
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
    MAKE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "I have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
  fi
fi
}

MAIN_MENU "Welcome! Take a look at our services and enter the number of the service you would like to schedule."
