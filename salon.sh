#!/bin/bash

#psql string for code execution from shell
PSQL="psql -U freecodecamp --dbname=salon -X --tuples-only -c"

#Heading Messages
echo -e "\n:: Fresh Looks Salon ::\n"
echo -e "\nWelcome to Fresh Looks Salon, how can I help you?\n"

#Main Function
MAIN_MENU(){

  #if any arguments are provided, then display the argument
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  #find all available services from services table and display in "#)<service_name>"" format
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done

  #read users input
  read SERVICE_ID_SELECTED

  #check if user inputs numeric characters or not
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    #if a number is received, then check if it's in our services list or not
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    
    #if the id is not in list
    if [[ -z $SERVICE_NAME ]]
    then
      #go back to main menu
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      # proceed with registration, ask for phone number
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE

      #find customer name from phone number
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

      #if customer doesn't exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        #get customer name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        #add it to customers table (name & phone)
        CUSTOMER_UPDATE=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi      
      # ask for service time
      echo -e "\nWhat time would you like your$SERVICE_NAME,$CUSTOMER_NAME?"
      read SERVICE_TIME
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id,time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi

  else
    #non numeric id selected, go back to main menu with a message.
    MAIN_MENU "I could not find that service. What would you like today?"
  fi

}


MAIN_MENU
